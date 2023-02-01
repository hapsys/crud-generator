package ru.aeroflot.generator.metadata;

import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlAttribute;
import jakarta.xml.bind.annotation.XmlElement;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@XmlAccessorType(XmlAccessType.FIELD)
public class Index {
    @XmlAttribute
    private String name;
    @XmlAttribute
    private boolean isUniq;
    @XmlElement
    private List<Column> columns = new ArrayList<>();

    public Index(String name, boolean isUniq) {
        this.name = name;
        this.isUniq = isUniq;
    }
}
