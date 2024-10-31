# Class generator based on DatabaseMetadata

### General description

Using DatabaseMetadata for the DB, you can get the structure of tables, etc. Based on this, you can generate a number of classes to ensure work with the DB or accompanying process classes. For example: JPA entities, repositories, services, controllers, etc.  

#### In examples:

Generating basic classes to provide CRUD manipulation of DB entities based on DB table metadata and/or additional description (view https://gitlab.ed-go.xyz/ed-go/backend/services/ms-dict and default config)

### Explanations

Generation occurs according to the steps described in the configuration. Each step can generate either one common file for all tables or a separate file is generated for each table. 

#### Configuration

General configuration parameters:

| Parameter                 | Purpose                                                                                                     |
|---------------------------|-------------------------------------------------------------------------------------------------------------|
| generator.root            | The default path for generating the resulting files.                                                        |
| generator.export          | Path to XML file to save structure (just for debugging). If not specified or empty, structure is not saved. |
| generator.catalog         | Catalogs in the database for which metadata is generated (for example, for MySQL).                          |
| generator.schemas         | Schemas in the database for which metadata is generated (for example, for PostgreSQL).                      |
| generator.schema-packages | If defined, a sub-package is generated for each scheme. Parameters inside \<schemename>: value.             |
| generator.tables.include  | List of tables (comma separated) for which metadata will be generated. Empty: all.                          |
| generator.tables.exclude  | List of tables (comma separated) to be excluded from metadata generation.                                   |
| generator.properties      | Additional parameters passed to all generation steps (\<parameter>: \<value>).                              |
| generator.steps           | Generation Step Description Section (\<step>: \<generation step configuration>).                            |

For each step section the following parameters apply (\<generation step configuration>):

| Parameter                               | Type   | Purpose                                                                                       |
|----------------------------------------|--------|--------------------------------------------------------------------------------------------------|
| generator.steps.<step>.enable          | bool   | Turning off generation of classes of the corresponding section.                                                |
| generator.steps.<step>.root            | String | Redefining the path for generating the resulting files.                                          |
| generator.steps.<step>.packages        | String | The name of the package of generated classes.                                                    |
| generator.steps.<step>.class-name      | String | (!!!) If specified, one common file will be generated for all processed tables.         |
| generator.steps.<step>.template        | String | XSLT/Velocity template file used to generate classes.                                  |
| generator.steps.<step>.suffix          | String | Suffix for generated classes.                                                                    |
| generator.steps.<step>.file-name       | String | Velocity string template for file generation name (default: \${class\_name}${suffix}.java) |
| generator.steps.<step>.save-part-start | String | Regular expression to detect existing additional code (cheat).               |


#### Explanations

1. To avoid recompiling the generator again, all template paths use OS paths.
2. Additionally, as an example, the project contains an XML file **meta-info.xml**, which is connected to XSLT templates and can carry additional meta-information for generation. 

### Compilation and launch

The project is built on Spring Boot 3.x.x with the Maven builder, so you can compile and run it with the line:

**mvn spring-boot:run**

### Additional

(later)