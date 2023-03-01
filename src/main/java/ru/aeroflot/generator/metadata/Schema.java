package ru.aeroflot.generator.metadata;

import jakarta.xml.bind.annotation.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ru.aeroflot.generator.config.properties.GeneratorConfigProperties;

import javax.sql.DataSource;
import java.sql.Connection;
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


    @XmlAttribute
    private String name;
    @XmlElement
    private Map<String, Table> tables = new LinkedHashMap<>();

    public Schema(String name) {
        this.name = name;
    }

    public Table getTable(String tableName) {
        return tables.get(tableName);
    }

    public void generateTables() throws Exception {

        props = GeneratorContext.instance.getProperties().getTables();

        List<String> include = props.getInclude() != null? Arrays.asList(props.getInclude()): new ArrayList<>();
        List<String> exclude = props.getExclude() != null? Arrays.asList(props.getExclude()): new ArrayList<>();

        //Connection connection = GeneratorContext.instance.getConnection();
        DatabaseMetaData metaData = GeneratorContext.instance.getMetaData();

        try (ResultSet tables = metaData.getTables(null, this.getName(), null, new String[]{"TABLE"})) {
            while(tables.next()) {

                String name = tables.getString("table_name");
                String comment = tables.getString("remarks");

                boolean addFlag = include.size() == 0 || include.contains(name);
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
