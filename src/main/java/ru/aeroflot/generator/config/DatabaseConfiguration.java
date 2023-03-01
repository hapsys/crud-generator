package ru.aeroflot.generator.config;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.SQLException;

@Configuration
@RequiredArgsConstructor
public class DatabaseConfiguration {

    private final DataSource dataSource;

    private Connection connection;

    @Bean
    public Connection getConnection() throws SQLException {
        if (connection == null) {
            connection = dataSource.getConnection();
        }
        return connection;
    }

    @Bean
    public DatabaseMetaData getMetaData() throws SQLException {
        return getConnection().getMetaData();
    }
}
