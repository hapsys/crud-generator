package ru.cninnov.generator.metadata;

import lombok.Getter;
import lombok.Setter;
import ru.cninnov.generator.config.properties.GeneratorConfigProperties;

import java.sql.Connection;
import java.sql.DatabaseMetaData;


public enum GeneratorContext {
    instance;

    @Getter @Setter
    private GeneratorConfigProperties properties;
    @Getter @Setter
    private Connection connection;
    @Getter @Setter
    private DatabaseMetaData metaData;

}
