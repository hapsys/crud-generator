package ru.aeroflot.generator.config.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

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
    public static class Entities {
        private boolean enable;
        private String  packages;
        private String  template;
        private String  suffix;
    }

    @Data
    public static class Repository {
        private boolean enable;
        private String  packages;
        private String  template;
        private String  suffix;
        private String  savePartStart;
    }

    @Data
    public static class Model {
        private boolean enable;
        private boolean usePrimary;
        private boolean generateData;
        private String  packages;
        private String  template;
        private String  suffixModel;
        private String  suffixData;
    }

    @Data
    public static class Mapper {
        private boolean enable;
        private String  packages;
        private String  template;
        private String  suffix;
    }

    @Data
    public static class Service {
        private boolean enable;
        private String  packages;
        private String  template;
        private String  suffix;
    }

    @Data
    public static class Controller {
        private boolean enable;
        private String  packages;
        private String  template;
        private String  suffix;
    }
}
