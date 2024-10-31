package org.c3s.generator.config.properties;

import lombok.Data;

@Data
public class AbstractGeneratorConfigProperties {

    private boolean enable;         // generate
    private String  root;           // override parent root
    private String  className;      // generate single file, if not null or empty
    private String  packages;       // package from root
    //private boolean split;        // schema split (packages + schema)
    private String  template;       // uses template for generate class(es)
    private String  suffix;         // ClassSuffix (if className not is empty - using as common ClassName)
    //private String  extension;    // extension for file (default java)
    private String  savePartStart;  //
    private String  fileName;       // Template (Velocity) for generated file name (default ${class_name}${suffix}.java//. if className not is empty - using as common ClassName ignoring suffix)
}
