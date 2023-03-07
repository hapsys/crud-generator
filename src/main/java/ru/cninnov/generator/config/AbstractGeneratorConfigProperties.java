package ru.cninnov.generator.config;

import lombok.Data;

@Data
public class AbstractGeneratorConfigProperties {

    private boolean enable;
    private String  packages;
    private String  template;
    private String  suffix;
    private boolean usePrimary;
    private boolean generateData;
    private String  suffixData;
    private String  savePartStart;

}
