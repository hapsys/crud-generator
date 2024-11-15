package org.c3s.generator.metadata;

import jakarta.xml.bind.annotation.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.c3s.generator.utils.Utils;

@Data
@NoArgsConstructor
@XmlAccessorType(XmlAccessType.FIELD)
public class Column {

    @ToString.Exclude
    @XmlTransient
    private Table table;
    @XmlAttribute
    private String name;
    @XmlAttribute
    private String comment;
    @XmlAttribute
    private boolean isNullable;
    @XmlAttribute
    private boolean isAutoincrement;

    @XmlAttribute
    private Class<?> type;
    @XmlAttribute
    private String shortType;

    @XmlAttribute
    private String baseType;

    @XmlAttribute
    private boolean isPrimaryKey;
    @XmlAttribute
    private String className;
    @XmlAttribute
    private String methodName;

    @XmlAttribute
    private int size;

    @XmlAttribute
    private String defaultValue;
    //@XmlElement
    //private List<Index> indexes = new ArrayList<>();
    @XmlElement
    private ForeignKey foreignKey;

    public Column(Table table, String name, String comment, String baseType, int size, boolean isNullable, boolean isAutoincrement, String defaultValue) {
        this.table = table;
        this.name = name;
        this.comment = comment;
        this.baseType = baseType;
        this.size = size;
        this.isNullable = isNullable;
        this.isAutoincrement = isAutoincrement;
        this.defaultValue = defaultValue;
        //
        this.className = Utils.generateClassName(name);
        this.methodName = Utils.generateMethodName(name);
    }
}
