package org.c3s.generator.metadata;

import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlAttribute;
import jakarta.xml.bind.annotation.XmlElement;
import jakarta.xml.bind.annotation.XmlTransient;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.c3s.generator.config.properties.GeneratorConfigProperties;

import javax.sql.DataSource;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Data
@NoArgsConstructor
@XmlAccessorType(XmlAccessType.FIELD)
public class Catalog {

    @XmlTransient
    private List<String> props;

    @XmlTransient
    private DataSource dataSource;


    @XmlAttribute
    private String name;
    @XmlElement
    private Map<String, Schema> schemas = new LinkedHashMap<>();

    public Catalog(String name) {
        this.name = name;
    }

    public Schema getSchema(String schemaName) {
        return schemas.get(schemaName);
    }

    public void generateSchemas() throws Exception {

        props = GeneratorContext.instance.getProperties().getSchemas();

        DatabaseMetaData metaData = GeneratorContext.instance.getMetaData();

        boolean hasSchemas = false;
        try (ResultSet schemas = metaData.getSchemas(this.getName(), null)) {
            while(schemas.next()) {
                hasSchemas = true;
                ResultSetMetaData meta = schemas.getMetaData();
                for(int i = 1; i < meta.getColumnCount(); i++) {
                    log.info("Table \"{}\":\t{}", meta.getColumnLabel(i), schemas.getString(i));
                }
                log.info("---------------------------------------------------------------------");

                /*

                String name = tables.getString("table_name");
                String comment = tables.getString("remarks");

                boolean addFlag = include.size() == 0 || include.contains(name);
                addFlag = addFlag && (exclude.size() == 0 || !exclude.contains(name));

                if (addFlag) {
                    Table table = new Table(this, name, comment);
                    this.tables.put(name, table);
                }

                 */
            }
        }
        if (!hasSchemas) {
            schemas.put(null, new Schema(this, null));
        }

        for (Schema schema: schemas.values()) {
            schema.generateTables();
        }

    }

    public void generateForeignKeys(DataBaseStructure structure) throws Exception {
        for (Schema schema: schemas.values()) {
            schema.generateForeignKeys(structure);
        }
    }
}
