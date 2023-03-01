package ru.aeroflot.generator.metadata;

import jakarta.xml.bind.annotation.*;
import lombok.Data;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.Map;

@Data
@Component
@XmlRootElement
@XmlAccessorType(XmlAccessType.FIELD)
public class DataBaseStructure {

    @XmlElement
    private Map<String, Schema> schemas = new LinkedHashMap<>();

    public DataBaseStructure addSchema(String schemaName) {
        Schema schema = new Schema(schemaName);
        schemas.put(schemaName, schema);
        return this;
    }

    public void generateSchemas() throws Exception {
        for (Schema schema: schemas.values()) {
            schema.generateTables();
        }
    }

    public void generateForeignKeys() throws Exception {
        for (Schema schema: schemas.values()) {
            schema.generateForeignKeys(this);
        }
    }
}
