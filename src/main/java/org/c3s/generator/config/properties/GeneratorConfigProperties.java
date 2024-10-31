package org.c3s.generator.config.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.List;
import java.util.Map;

@ConfigurationProperties(prefix = "generator")
@Data
public class GeneratorConfigProperties {

    private List<String> catalog;
    private List<String> schemas;
    private Map<String, String> schemaPackages;
    private String export;
    private String root;
    private Tables tables;

    private Map<String, String> properties;

    private Map<String, AbstractGeneratorConfigProperties> steps;

    @Data
    public static class Tables {
        private List<String> include;
        private List<String> exclude;
    }
}
