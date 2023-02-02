package ru.aeroflot.generator.config.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import ru.aeroflot.generator.config.AbstractGeneratorConfigProperties;

@ConfigurationProperties(prefix = "generator")
@Data
public class GeneratorConfigProperties {

    private String root;
    private Tables tables;
    private Entities entities;
    private Repository repository;
    private Model model;
    private Mapper mapper;
    private Service service;
    private Controller controller;

    @Data
    public static class Tables {
        private String[] include;
        private String[] exclude;
    }

    @Data
    public static class Entities extends AbstractGeneratorConfigProperties {
    }

    @Data
    public static class Repository extends AbstractGeneratorConfigProperties {
    }

    @Data
    public static class Model extends AbstractGeneratorConfigProperties {
    }

    @Data
    public static class Mapper extends AbstractGeneratorConfigProperties {
    }

    @Data
    public static class Service extends AbstractGeneratorConfigProperties {
    }

    @Data
    public static class Controller extends AbstractGeneratorConfigProperties {
    }
}
