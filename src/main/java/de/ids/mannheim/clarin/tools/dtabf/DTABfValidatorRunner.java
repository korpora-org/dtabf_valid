package de.ids.mannheim.clarin.tools.dtabf;

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.Callable;

/**
 * runs DTABf validation on argument and writes errors to
 * {@link DTABfValidatorRunner#errorFile}
 */
@Command(mixinStandardHelpOptions = true, description = "process directories for DTABf schema(tron) errors", versionProvider = VersionProvider.class)
public class DTABfValidatorRunner implements Callable<Integer> {
    /**
     * the file name for the error map serialization
     */
    @Parameters(description = "the directories to process", arity = "1..*")
    List<String> directories;

    @Option(names = "--error-file", description = "the file name stem for logs (default: ${DEFAULT-VALUE}.json,  ${DEFAULT-VALUE}.md)", defaultValue = "errors")
    String errorFile;

    @Option(names = "--manuscript", description = "use schema of DTABf for manuscripts, instead of standard schema for prints")
    boolean manuscript;

    @Option(names = {"--full-error-list", "--full-list", "--full"}, description = "use schema of DTABf for manuscripts, instead of standard schema for prints")
    boolean fullErrorList;

    /**
     * run validation
     * @param argv CLI args (check help)
     */
    public static void main(String[] argv) {
        int exitCode = new CommandLine(new DTABfValidatorRunner())
                .execute(argv);
        System.exit(exitCode);
    }

    @Override
    public Integer call() {
        DTABfValidator vali = new DTABfValidator(fullErrorList, manuscript);
        directories.forEach(vali::processDir);
        try {
            vali.writeErrorMap(errorFile);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return 0;
    }
}
