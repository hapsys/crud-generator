package ru.cninnov.generator.config.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import ru.cninnov.generator.config.AbstractGeneratorConfigProperties;

import java.util.Map;

@ConfigurationProperties(prefix = "generator")
@Data
public class GeneratorConfigProperties {

    private String[] schemas;
    private Map<String, String> schemaPackages;
    private String export;
    private String root;
    private Tables tables;

    private Map<String, AbstractGeneratorConfigProperties> steps;

    /*
    private Entities entities;
    private Repository repository;
    private Model model;
    private Mapper mapper;
    private Service service;
    private Controller controller;
    private Meta meta;

     */

    @Data
    public static class Tables {
        private String[] include;
        private String[] exclude;
    }

    /*
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

    @Data
    public static class Meta extends AbstractGeneratorConfigProperties {
    }

     */
}
