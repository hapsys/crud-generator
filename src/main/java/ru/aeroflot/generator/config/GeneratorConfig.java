package ru.aeroflot.generator.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import ru.aeroflot.generator.config.properties.GeneratorConfigProperties;

import javax.sql.DataSource;

@Configuration
public class GeneratorConfig {

    /*
    @Autowired
    private DataSource dataSource;

    @Autowired
    private GeneratorConfigProperties props;

    @Bean
    public GeneratorConfigProperties.Tables getTablesProperties() {
        return this.props.getTables();
    }

    @Bean
    public DataSource getDataSource() {
        return dataSource;
    }

     */
}
