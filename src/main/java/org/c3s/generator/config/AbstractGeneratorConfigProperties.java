package org.c3s.generator.config;

import lombok.Data;

@Data
public class AbstractGeneratorConfigProperties {

    private boolean enable;         // generate
    private String  root;           // override parent root
    private boolean single;         // generate single file
    private String  packages;       // package from root
    //private boolean split;          // schema split (packages + schema)
    private String  template;       // uses template for generate class(es)
    private String  suffix;         // ClassSuffix (if single == true - using as common ClassName)
    //private String  extension;      // extension for file (default java)
    private String  savePartStart;  //
    private String  fileName;       // Template (Velocity) for generated file name (default ${class_name}${suffix}.java// )
}
