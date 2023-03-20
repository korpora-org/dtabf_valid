module dtabfvalid {
    requires java.xml;
    requires com.fasterxml.jackson.core;
    requires com.fasterxml.jackson.databind;
    requires com.helger.commons;
    requires com.helger.schematron;
    requires com.helger.schematron.xslt;
    requires org.apache.commons.io;
    requires org.apache.commons.lang3;
    requires org.korpora.useful;
    requires org.slf4j;
    requires info.picocli;
    requires java.base;

    exports de.ids.mannheim.clarin.tools.dtabf
            to com.fasterxml.jackson.databind;
}