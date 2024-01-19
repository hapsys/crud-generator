package org.c3s.generator.metadata;

import jakarta.xml.bind.annotation.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;
import lombok.extern.slf4j.Slf4j;
import org.c3s.generator.utils.Utils;

import java.sql.*;
import java.util.LinkedHashMap;
import java.util.Map;

//@Setter @Getter @RequiredArgsConstructor @ToString
@Slf4j
@NoArgsConstructor
@Data
@XmlAccessorType(XmlAccessType.FIELD)
public class Table {

    @ToString.Exclude
    @XmlTransient
    private Schema schema;
    @XmlAttribute
    private String name;
    @XmlAttribute
    private String comment;
    @XmlAttribute
    private String className;
    @XmlAttribute
    private String methodName;
    @XmlElement
    private Map<String, Column> columns = new LinkedHashMap<>();
    @XmlElement
    private Map<String, Index> indexes = new LinkedHashMap<>();

    public Table(Schema schema, String name, String comment) {
        this.schema = schema;
        this.name = name;
        this.comment = comment;
        //
        this.className = Utils.generateClassName(name);
        this.methodName = Utils.generateMethodName(name);
    }

    public Column getColumn(String columnName) {
        return columns.get(columnName);
    }

    public void generateColumns() throws Exception {

        Connection connection = GeneratorContext.instance.getConnection();
        DatabaseMetaData metaData = GeneratorContext.instance.getMetaData();


        try (ResultSet resultSet = metaData.getColumns(this.schema.getCatalog().getName(), this.schema.getName(), getName(), null)) {
            while(resultSet.next()) {
                String name = resultSet.getString("COLUMN_NAME");
                String comment = resultSet.getString("REMARKS");
                String baseType = resultSet.getString("TYPE_NAME");
                int size = resultSet.getInt("COLUMN_SIZE");
                String columnDef = resultSet.getString("COLUMN_DEF");
                boolean isNullable = !"NO".equals(resultSet.getString("IS_NULLABLE"));
                boolean isAutoincrement = "YES".equals(resultSet.getString("IS_AUTOINCREMENT"));

                Column column = new Column(this, name, comment, baseType, size, isNullable, isAutoincrement, columnDef);
                columns.put(name, column);
            }
        }

        // get columns class type
        String useSchema = schema.getName() != null?schema.getName() + ".":"";
        String sql = "SELECT * FROM " + useSchema + name + " WHERE 1=0 LIMIT 1";
        try (PreparedStatement stmp = connection.prepareStatement(sql, java.sql.ResultSet.TYPE_FORWARD_ONLY, java.sql.ResultSet.CONCUR_UPDATABLE, java.sql.ResultSet.HOLD_CURSORS_OVER_COMMIT)) {
            ResultSetMetaData resultSetMetaData = stmp.getMetaData();
            if (resultSetMetaData != null) {
                for (int i = 1; i < resultSetMetaData.getColumnCount() + 1; i++) {
                    String name = resultSetMetaData.getColumnName(i);
                    String className = resultSetMetaData.getColumnClassName(i);
                    //log.info("Class name: {}", className);
                    if ("bytea".equals(columns.get(name).getBaseType())) {
                        className = "java.lang.String";
                    }
                    columns.get(name).setType(Class.forName(className));
                    String shortName = className;
                    String prefix = "java.lang.";
                    if (shortName.startsWith(prefix)) {
                        shortName = shortName.substring(prefix.length());
                    }
                    columns.get(name).setShortType(shortName);
                }
            }
        }
        // get primary keys
        try (ResultSet resultSet = metaData.getPrimaryKeys(this.schema.getCatalog().getName(), schema.getName(), getName())) {
            while (resultSet.next()) {
                String name = resultSet.getString("column_name");
                columns.get(name).setPrimaryKey(true);
            }
        }
        // get indexes
        try (ResultSet resultSet = metaData.getIndexInfo(this.schema.getCatalog().getName(), schema.getName(), getName(), false, false)) {
            while(resultSet.next()) {
                String columnName = resultSet.getString("column_name");
                String name = resultSet.getString("index_name");
                boolean isUniq = "f".equals(resultSet.getString("non_unique")) || "0".equals(resultSet.getString("non_unique"));
                Index index;
                if (indexes.containsKey(name)) {
                    index = indexes.get(name);
                } else {
                    index = new Index(name, isUniq);
                    indexes.put(name, index);
                }
                index.getColumns().add(getColumn(columnName));

                /*
                ResultSetMetaData meta = resultSet.getMetaData();
                for(int i = 1; i < meta.getColumnCount(); i++) {
                    log.info("Table \"{}\":\t{}", meta.getColumnLabel(i), resultSet.getString(i));
                }
                log.info("---------------------------------------------------------------------");
                */
            }
        }
    }

    public void generateForeignKeys(DataBaseStructure structure) throws Exception {
        DatabaseMetaData metaData = GeneratorContext.instance.getMetaData();
        try (ResultSet resultSet = metaData.getImportedKeys(null, schema.getName(), getName())) {
            while(resultSet.next()) {
                //ResultSetMetaData meta = resultSet.getMetaData();
                //String sourceSchema = meta.getCo
                String fkName = resultSet.getString("fk_name");
                String sourceSchema = resultSet.getString("pktable_schem");
                String sourceTable = resultSet.getString("pktable_name");
                String sourceColumn = resultSet.getString("pkcolumn_name");
                Column source = null;
                /*
                Schema columnSchema = structure.getSchemas().get(sourceSchema);
                if (columnSchema != null) {
                    Table columnTable = columnSchema.getTable(sourceTable);
                    if (columnTable != null) {
                        source = columnTable.getColumn(sourceColumn);
                    }
                }
                if (source != null) {
                    getColumn(resultSet.getString("fkcolumn_name")).setForeignKey(new ForeignKey(fkName, sourceSchema, sourceTable, source));
                }
                */
            }
        }
    }
}
