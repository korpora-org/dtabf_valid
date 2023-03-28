package de.ids.mannheim.clarin.tools.dtabf;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.xml.XMLConstants;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.transform.Source;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.sax.SAXSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import org.apache.commons.io.input.BOMInputStream;
import org.apache.commons.lang3.StringUtils;
import org.korpora.useful.Utilities;
import org.korpora.useful.XMLUtilities;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.ErrorHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.helger.commons.collection.impl.ICommonsList;
import com.helger.schematron.ISchematronResource;
import com.helger.schematron.svrl.SVRLFailedAssert;
import com.helger.schematron.svrl.SVRLHelper;
import com.helger.schematron.svrl.jaxb.SchematronOutputType;
import com.helger.schematron.xslt.SchematronResourceXSLT;

/**
 * a validator for DTABf files that aggregates error messages
 */
public class DTABfValidator {

    private final Validator validator;
    private final ISchematronResource schemaTron;
    private final Map<Path, Map<String, ErrorInfo>> errorMap = new HashMap<>();
    private List<String> messages = new ArrayList<>();

    private final Logger logger = LoggerFactory
            .getLogger(DTABfValidator.class.getSimpleName());
    private CollectingErrorHandler handler;

    /**
     * a validator against the DTABF schema and Schematron rules
     *
     * @param fullErrorList whether to build a full error list or only new errors when going from
     *                      file to file.
     */
    public DTABfValidator(boolean fullErrorList, boolean manuscript) {
        System.setProperty(
                SchemaFactory.class.getName() + ":"
                        + XMLConstants.RELAXNG_NS_URI,
                "com.thaiopensource.relaxng.jaxp.XMLSyntaxSchemaFactory");
        SchemaFactory schemaFactory = SchemaFactory
                .newInstance(XMLConstants.RELAXNG_NS_URI);
        schemaTron = SchematronResourceXSLT.fromClassPath("basisformat.xslt");
        if (!schemaTron.isValidSchematron())
            throw new IllegalArgumentException("Invalid Schematron!");
        try {
            Schema schema = schemaFactory.newSchema(manuscript
                    ? new URL(
                    "https://www.deutschestextarchiv.de/basisformat_ms.rng")
                    : new URL(
                    "https://www.deutschestextarchiv.de/basisformat.rng"));
            validator = schema.newValidator();
            handler = new CollectingErrorHandler(
                    fullErrorList);
            validator.setErrorHandler(handler);
        } catch (SAXException | IOException e) {
            throw new RuntimeException(e);
        }

    }

    private void teeScreenLog(String message) {
        messages.add(message.replace("@", "\\@"));
        logger.info(message);
    }

    /**
     * delegate to {@link CollectingErrorHandler#ignoreAllFromNow}
     *
     * @return Map of error messages : occurrences
     */
    public Map<String, ErrorInfo> ignoreAllFromNow() {
        CollectingErrorHandler handler = ((CollectingErrorHandler) validator
                .getErrorHandler());
        Map<String, ErrorInfo> previousErrorMap = handler.getErrorMap();
        handler.ignoreAllFromNow();
        return previousErrorMap;
    }

    /**
     * validate a document
     *
     * @param path  the path of the document
     * @param title the title of the document
     */
    public void validate(Path path, String title) {
        if (path.toFile().isDirectory()) {
            return;
        } else {
            teeScreenLog(String.format("# `%s`", title));
        }
        SAXParserFactory spf = SAXParserFactory.newInstance();
        spf.setNamespaceAware(true);
        try {
            SAXSource src = new SAXSource(spf.newSAXParser().getXMLReader(),
                    new InputSource(new BOMInputStream(
                            new FileInputStream(path.toFile()))));
            handler = (CollectingErrorHandler) validator
                    .getErrorHandler();
            List<String> lines = Files.readAllLines(path);
            handler.setCurrentLines(lines);
            validator.validate(src);
            Source domSource = new DOMSource(XMLUtilities.parseXML(path.toFile()));
            SchematronOutputType tronResult = schemaTron
                    .applySchematronValidationToSVRL(domSource);
            ICommonsList<SVRLFailedAssert> tronFailures = SVRLHelper
                    .getAllFailedAssertions(tronResult);
            tronFailures.forEach(f -> handler.addErrorInfo(
                    StringUtils.normalizeSpace(f.getText()),
                    ErrorType.SchemaTron, 0, 0, null));
            for (ErrorType type : ErrorType.values()) {
                List<Map.Entry<String, ErrorInfo>> eList =
                        handler.getErrorsByType(type);
                teeScreenLog(
                        String.format("## %s %s error%s",
                                eList.isEmpty() ? "No" : Integer.toString(eList.size()),
                                type,
                                eList.size() > 1 ? "s" : ""));
                eList.stream().sorted(Map.Entry.comparingByKey())
                        .forEach(e -> teeScreenLog(String.format("- %s [%d×]",
                                e.getKey(), e.getValue().size())));
            }
            messages = messages.stream()
                    .map(l -> l.startsWith("#") ? "\n" + l + "\n" : l)
                    .collect(Collectors.toList());

        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

    /**
     * get the error map
     *
     * @return the error map
     */
    public Map<Path, Map<String, ErrorInfo>> getErrorMap() {
        return errorMap;
    }

    /**
     * process a directory by validating all files
     *
     * @param directory the directory
     */
    void processDir(String directory) {
        Path dir = Path.of(directory);
        try (Stream<Path> walk = Files.walk(dir)) {
            walk.sorted().forEach(file -> {
                if (!file.getFileName().toString().endsWith(".xml")) return;
                String title = dir.relativize(file).toString();
                validate(file, title);
                Map<String, ErrorInfo> fileErrorMap = ignoreAllFromNow();
                if (!fileErrorMap.isEmpty()) {
                    errorMap.put(file, fileErrorMap);
                }
            });
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * write error map to a JSON file
     *
     * @param stem the file name stem (+ ".json", + ".md")
     * @throws IOException in case of error
     */
    public void writeErrorMap(String stem) throws IOException {
        Utilities.linesToFile(messages, String.format("%s.md", stem));
        ObjectMapper objectMapper = new ObjectMapper();
        File file = new File(String.format("%s.json", stem));
        try {
            logger.info("number of checked files: {}", getErrorMap().size());
            objectMapper.writerWithDefaultPrettyPrinter().writeValue(file,
                    getErrorMap());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

    }

    /**
     * a SAX ErrorHandler that collects the errors into a map structure
     * <p>
     * the map structure is also (ab)used for storing Schematron errors.
     */
    private static class CollectingErrorHandler implements ErrorHandler {

        /**
         * pattern to recognise the messages about completely disallowed
         * elements
         */
        private static final Pattern notAnywhere = Pattern
                .compile("^.*?not allowed anywhere(?=\\p{P})");

        private static final Pattern invalidToken = Pattern.compile(
                "token\\s+\"\\P{javaWhitespace}+\"\\s+"
        );
        /**
         * whether to keep all errors, ignore ignoreList
         */
        private final boolean fullErrorList;
        /**
         * the list of simple errors, just for convenience
         */
        private List<SAXParseException> errors;
        /**
         * the list of error messages to be ignored
         */
        private Set<String> ignoreList;
        /**
         * a map of error messages pointing to type (RelaxNG, Schematron) and
         * occurrences; occurrences are [line, col] for RelaxNG, but
         * unfortunately empty [0, 0] for Schematron.
         */
        private Map<String, ErrorInfo> errorMap;
        /**
         * the current path to be processed
         */
        private List<String> currentLines;

        /**
         * an error handler that collects its errors in a list
         *
         * @param fullErrorList whether to keep the full list despite ignoreList
         */
        CollectingErrorHandler(boolean fullErrorList) {
            this.fullErrorList = fullErrorList;
            initLists();
        }

        /**
         * set the lines of current file, so that they can be extracted
         *
         * @param currentLines the lines
         */
        public void setCurrentLines(List<String> currentLines) {
            this.currentLines = currentLines;
        }

        /**
         * add a set of error messages to be ignored
         *
         * @param ignoreList error messages
         */
        public void addToIgnoreList(Set<String> ignoreList) {
            this.ignoreList.addAll(ignoreList);
        }

        @SuppressWarnings("unused")
        public Set<String> getIgnoreList() {
            return ignoreList;
        }

        /**
         * set the list of errors to ignore
         *
         * @param ignoreList the list of errors
         */
        @SuppressWarnings("unused")
        public void setIgnoreList(Set<String> ignoreList) {
            this.ignoreList = ignoreList;
        }

        public Set<String> makeIgnoreList() {
            return errorMap.keySet();
        }

        /**
         * ignore all known error messages from now on, in addition(!) to
         * already ignored ones.
         */
        public void ignoreAllFromNow() {
            Set<String> tmpIgnoreList = makeIgnoreList();
            reset(false);
            addToIgnoreList(tmpIgnoreList);
        }

        public void initLists() {
            reset(true);
        }

        /**
         * reset the Handler
         *
         * @param resetIgnoreList whether to reset the error List as well
         */
        public void reset(boolean resetIgnoreList) {
            errors = new ArrayList<>();
            errorMap = new ConcurrentHashMap<>();
            if (resetIgnoreList)
                ignoreList = new HashSet<>();
        }

        /**
         * add a RelaxNG SAXException, extract info and put it into the errorMap
         * and errorList
         *
         * @param exception encountered during parsing
         */
        private void addException(SAXParseException exception) {
            errors.add(exception);
            String message = exception.getMessage();
            Matcher notAnywhereMatcher = notAnywhere.matcher(message);
            message = invalidToken.matcher(message).replaceFirst("token ");
            if (notAnywhereMatcher.find()) {
                message = notAnywhereMatcher.group();
            }
            addErrorInfo(message, ErrorType.RelaxNG, exception.getLineNumber(),
                    exception.getColumnNumber(),
                    currentLines.get(exception.getLineNumber() - 1));
        }

        /**
         * add error info to errorMap
         *
         * @param message      the error message
         * @param type         the type of Error
         * @param lineNumber   the line number
         * @param columnNumber the column number
         */
        private void addErrorInfo(String message, ErrorType type,
                                  int lineNumber, int columnNumber, String offendingLine) {
            if (!fullErrorList && ignoreList.contains(message))
                return;
            errorMap.computeIfAbsent(message, s -> new ErrorInfo(type));
            errorMap.get(message).addOccurrence(lineNumber, columnNumber,
                    offendingLine);
        }

        @SuppressWarnings("unused")
        public List<SAXParseException> getErrors() {
            return errors;
        }

        public List<Map.Entry<String, ErrorInfo>> getErrorsByType(
                ErrorType type) {
            return errorMap.entrySet().stream()
                    .filter(e -> e.getValue().type == type)
                    .toList();

        }

        public Map<String, ErrorInfo> getErrorMap() {
            return errorMap;
        }

        @Override
        public void warning(SAXParseException exception) {
            addException(exception);
        }

        @Override
        public void fatalError(SAXParseException exception) {
            addException(exception);
        }

        @Override
        public void error(SAXParseException exception) {
            addException(exception);
        }

    }

}
