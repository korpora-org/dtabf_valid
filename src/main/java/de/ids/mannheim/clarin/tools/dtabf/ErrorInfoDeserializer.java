package de.ids.mannheim.clarin.tools.dtabf;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.deser.std.StdDeserializer;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.type.CollectionType;
import de.ids.mannheim.clarin.tools.dtabf.ErrorInfo.Occurrence;

import java.io.IOException;
import java.util.List;

/*
 * TODO: UNTESTED!
 */
public class ErrorInfoDeserializer extends StdDeserializer<ErrorInfo> {

    private static ObjectMapper mapper = new ObjectMapper();

    public ErrorInfoDeserializer() {
        this(null);
    }

    public ErrorInfoDeserializer(Class<?> vc) {
        super(vc);
    }

    @Override
    public ErrorInfo deserialize(JsonParser jp, DeserializationContext ctxt)
            throws IOException, JsonProcessingException {
        JsonNode node = jp.getCodec().readTree(jp);
        ErrorType errorType = ErrorType.valueOf(node.get("type").asText());
        ArrayNode occurrencesN = (ArrayNode) node.get("occurrences");
        ErrorInfo eInfo = new ErrorInfo(errorType);
        CollectionType javaType = mapper.getTypeFactory()
                .constructCollectionType(List.class, Occurrence.class);
        List<Occurrence> occurrences = mapper.readValue(occurrencesN.asText(),
                javaType);
        eInfo.addOccurrences(occurrences);
        return eInfo;
    }
}
