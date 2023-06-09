package de.ids.mannheim.clarin.tools.dtabf;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.SerializerProvider;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.deser.std.StdDeserializer;
import com.fasterxml.jackson.databind.node.IntNode;
import com.fasterxml.jackson.databind.ser.std.StdSerializer;

/**
 * info on a validation error: type, occurrences
 */
public class ErrorInfo {

    public final ErrorType type;
    // public final List<Triple<Integer, Integer, String>> occurrences; //
    // better serializability; maybe use custom ImmutablePair
    private final List<Occurrence> occurrences;

    public ErrorInfo(ErrorType type) {
        this.type = type;
        this.occurrences = new ArrayList<>();
    }

    public void addOccurrence(int line, int col, String offendingLine) {
        this.occurrences.add(new Occurrence(line, col, offendingLine));
    }

    public void addOccurrences(List<Occurrence> occurrences) {
        this.occurrences.addAll(occurrences);
    }

    public List<Occurrence> getOccurrences() {
        return occurrences;
    }

    public int size() {
        return occurrences.size();
    }

    public static class OccurrenceSerializer extends StdSerializer<Occurrence> {

        public OccurrenceSerializer() {
            this(null);
        }

        public OccurrenceSerializer(Class<Occurrence> t) {
            super(t);
        }

        @Override
        public void serialize(Occurrence value, JsonGenerator jgen,
                              SerializerProvider provider) throws IOException {

            jgen.writeStartObject();
            if (value.line > 0)
                jgen.writeNumberField("line", value.line);
            if (value.col > 0)
                jgen.writeNumberField("col", value.col);
            if (value.offendingLine != null && !"".equals(value.offendingLine))
                jgen.writeStringField("offendingLine", value.offendingLine);
            jgen.writeEndObject();
        }
    }

    public static class OccurrenceDeserializer
            extends StdDeserializer<Occurrence> {

        public OccurrenceDeserializer() {
            this(null);
        }

        public OccurrenceDeserializer(Class<?> vc) {
            super(vc);
        }

        @Override
        public Occurrence deserialize(JsonParser jp,
                                      DeserializationContext ctxt)
                throws IOException {
            JsonNode node = jp.getCodec().readTree(jp);
            JsonNode lineNode = node.get("line");
            JsonNode colNode = node.get("col");
            JsonNode offendingNode = node.get("offendingLine");
            int col = colNode != null
                    ? (Integer) colNode.numberValue()
                    : 0;
            int line = lineNode != null
                    ? (Integer) lineNode.numberValue()
                    : 0;
            String offendingLine = offendingNode != null
                    ? offendingNode.asText()
                    : null;

            return new Occurrence(line, col, offendingLine);
        }
    }

    @JsonSerialize(using = OccurrenceSerializer.class)
    @JsonDeserialize(using = OccurrenceDeserializer.class)

    public record Occurrence(
            int line,
            int col,
            String offendingLine
    ) {
    }
}
