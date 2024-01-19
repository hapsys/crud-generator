package org.c3s.generator.metadata;

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
    private Map<String, Catalog> catalogs = new LinkedHashMap<>();

    public DataBaseStructure addCatalog(String catalogName) {
        Catalog catalog = new Catalog(catalogName);
        catalogs.put(catalogName, catalog);
        return this;
    }

    public void generateCatalogs() throws Exception {
        for (Catalog catalog: catalogs.values()) {
            catalog.generateSchemas();
        }
    }

    public void generateForeignKeys() throws Exception {
        for (Catalog catalog: catalogs.values()) {
            catalog.generateForeignKeys(this);
        }
    }
}
