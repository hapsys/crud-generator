package org.c3s.generator.metadata;

import jakarta.xml.bind.annotation.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.c3s.generator.config.properties.GeneratorConfigProperties;

import javax.sql.DataSource;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.util.*;

@Slf4j
@Data
@NoArgsConstructor
@XmlAccessorType(XmlAccessType.FIELD)
public class Schema {

    @XmlTransient
    private GeneratorConfigProperties.Tables props;

    @XmlTransient
    private DataSource dataSource;

    @XmlTransient
    private Catalog catalog;


    @XmlAttribute
    private String name;
    @XmlElement
    private Map<String, Table> tables = new LinkedHashMap<>();

    public Schema(Catalog catalog, String name) {
        this.catalog = catalog;
        this.name = name;
    }

    public Table getTable(String tableName) {
        return tables.get(tableName);
    }

    public void generateTables() throws Exception {

        props = GeneratorContext.instance.getProperties().getTables();
        //log.info("Tables include: {}", props.getInclude());
        //log.info("Tables exclude: {}", props.getExclude());
        List<String> include = props.getInclude();
        List<String> exclude = props.getExclude();

        //Connection connection = GeneratorContext.instance.getConnection();
        DatabaseMetaData metaData = GeneratorContext.instance.getMetaData();

        try (ResultSet tables = metaData.getTables(catalog != null?catalog.getName():null, this.getName(), null, new String[]{"TABLE"})) {
            while(tables.next()) {

                String name = tables.getString("table_name");
                String comment = tables.getString("remarks");

                boolean addFlag = include.size() == 0 || include.contains(name);
                //log.info("Table \"{}\" include: {}", name, addFlag);
                addFlag = addFlag && (exclude.size() == 0 || !exclude.contains(name));

                if (addFlag) {
                    Table table = new Table(this, name, comment);
                    this.tables.put(name, table);
                }
            }
        }

        for (Table table: tables.values()) {
            table.generateColumns();
        }

    }

    public void generateForeignKeys(DataBaseStructure structure) throws Exception {
        for (Table table: tables.values()) {
            table.generateForeignKeys(structure);
        }
    }
}
