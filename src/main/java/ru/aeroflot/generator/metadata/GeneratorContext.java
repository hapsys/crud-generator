package ru.aeroflot.generator.metadata;

import lombok.Getter;
import lombok.Setter;
import ru.aeroflot.generator.config.properties.GeneratorConfigProperties;

import javax.sql.DataSource;


public enum GeneratorContext {
    instance;

    @Getter @Setter
    private GeneratorConfigProperties properties;
    @Getter @Setter
    private DataSource dataSource;
}
