package ru.aeroflot.generator.metadata;

import jakarta.xml.bind.annotation.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;
import ru.aeroflot.generator.utils.Utils;

import java.util.ArrayList;
import java.util.List;

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
    //@XmlElement
    //private List<Index> indexes = new ArrayList<>();
    @XmlElement
    private ForeignKey foreignKey;

    public Column(Table table, String name, String comment, String baseType, boolean isNullable, boolean isAutoincrement) {
        this.table = table;
        this.name = name;
        this.comment = comment;
        this.baseType = baseType;
        this.isNullable = isNullable;
        this.isAutoincrement = isAutoincrement;
        //
        this.className = Utils.generateClassName(name);
        this.methodName = Utils.generateMethodName(name);
    }
}
