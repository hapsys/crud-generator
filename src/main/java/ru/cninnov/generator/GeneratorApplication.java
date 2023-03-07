package ru.cninnov.generator;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import ru.cninnov.generator.config.properties.GeneratorConfigProperties;

@EnableConfigurationProperties(GeneratorConfigProperties.class)
@SpringBootApplication
public class GeneratorApplication {

    public static void main(String[] args) {
        SpringApplication.run(GeneratorApplication.class, args);
    }

}
