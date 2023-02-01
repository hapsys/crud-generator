package ru.aeroflot.generator.command;

import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.Marshaller;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
import ru.aeroflot.generator.config.properties.GeneratorConfigProperties;
import ru.aeroflot.generator.metadata.DataBaseStructure;
import ru.aeroflot.generator.metadata.GeneratorContext;
import ru.aeroflot.generator.metadata.Schema;
import ru.aeroflot.generator.metadata.Table;
import ru.aeroflot.generator.utils.RegexpUtils;

import javax.sql.DataSource;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Component
public class CommandProcessor implements CommandLineRunner {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private DataSource dataSource;

    @Autowired
    private GeneratorConfigProperties properties;

    @Autowired
    private DataBaseStructure structure;

    private boolean enableEntities = true;
    private boolean enableRepository = true;
    private boolean enableModel = true;
    private boolean enableMapper = true;
    private boolean enableService = true;
    private boolean enableController = true;

    @Override
    public void run(String... args) throws Exception {
        log.info("Run application!");

        parseCommandLine(args);

        GeneratorContext.instance.setProperties(properties);
        GeneratorContext.instance.setDataSource(dataSource);

        DatabaseMetaData metaData = dataSource.getConnection().getMetaData();

        structure.addSchema("msdict").generateSchemas();
        //log.info("Genmerated schema {}", structure.toString());

        /*
        // get list tables
        try (ResultSet tables = metaData.getTables(null, "msdict", null, new String[]{"TABLE"})) {
            while(tables.next()) {
                ResultSetMetaData meta = tables.getMetaData();
                for(int i = 1; i < meta.getColumnCount(); i++) {
                    log.info("Table \"{}\":\t{}", meta.getColumnLabel(i), tables.getString(i));
                }
                log.info("---------------------------------------------------------------------");
            }
        }
        try (ResultSet resultSet = metaData.getColumns(null, "msdict", "country", null)) {
            while(resultSet.next()) {
                ResultSetMetaData meta = resultSet.getMetaData();
                for(int i = 1; i < meta.getColumnCount(); i++) {
                    log.info("Table \"{}\":\t{}", meta.getColumnLabel(i), resultSet.getString(i));
                }
                log.info("---------------------------------------------------------------------");
            }
        }
        */
        /*
        try (ResultSet resultSet = metaData.getIndexInfo(null, "msdict", "country_zone_airport", false, false)) {
            while(resultSet.next()) {
                ResultSetMetaData meta = resultSet.getMetaData();
                for(int i = 1; i < meta.getColumnCount(); i++) {
                    log.info("Index \"{}\":\t{}", meta.getColumnLabel(i), resultSet.getString(i));
                }
                log.info("---------------------------------------------------------------------");
            }
        }
        try (ResultSet resultSet = metaData.getPrimaryKeys(null, "msdict", "country")) {
            while(resultSet.next()) {
                ResultSetMetaData meta = resultSet.getMetaData();
                for(int i = 1; i < meta.getColumnCount(); i++) {
                    log.info("Index \"{}\":\t{}", meta.getColumnLabel(i), resultSet.getString(i));
                }
                log.info("---------------------------------------------------------------------");
            }
        }
        try (ResultSet resultSet = metaData.getImportedKeys(null, "msdict", "country")) {
            while(resultSet.next()) {
                ResultSetMetaData meta = resultSet.getMetaData();
                for(int i = 1; i < meta.getColumnCount(); i++) {
                    log.info("Index \"{}\":\t{}", meta.getColumnLabel(i), resultSet.getString(i));
                }
                log.info("---------------------------------------------------------------------");
            }
        }
        */

        /**
         * Prepare paremateres
         */
        File root = new File(properties.getRoot());
        root.mkdirs();
        File pkgDir;

        JAXBContext jaxbContext = org.eclipse.persistence.jaxb.JAXBContextFactory
                .createContext(new Class[]{DataBaseStructure.class}, null);
        Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
        jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
        jaxbMarshaller.setProperty(Marshaller.JAXB_ENCODING, "utf-8");
        jaxbMarshaller.marshal(structure, new File("/structure.xml"));

        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document document = builder.newDocument();
        jaxbMarshaller.marshal(structure, document);

        /**
         * Transformation properties
         */
        Map<String, Object> props = new HashMap<>() {{put("root", properties.getRoot());}};

        // --------------------------------------------------------------------------------------------------


        /**
         * Generate Entities
         */
        if (enableEntities && properties.getEntities().isEnable()) {
            pkgDir = new File(root, properties.getEntities().getPackages().replace('.','/'));
            pkgDir.mkdirs();
            props.put("package", properties.getEntities().getPackages());
            props.put("step", "entity");
            props.put("suffix", properties.getEntities().getSuffix());
            props.put("table", null);
            props.put("schema", null);
            // Load xslt template file
            Transformer transformer = getTransformer(properties.getEntities().getTemplate());

            for (String schemaName: structure.getSchemas().keySet()) {
                props.put("schema", schemaName);
                for (String tableName: structure.getSchemas().get(schemaName).getTables().keySet()) {
                    props.put("table", tableName);
                    String result = transformXML(document, transformer, props);
                    // Save result
                    String classFileName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getEntities().getSuffix() + ".java";
                    log.info("Filename: {}", classFileName);
                    File classFile = new File(pkgDir, classFileName);
                    try (PrintWriter writer = new PrintWriter(classFile)) {
                        writer.print(result);
                    }
                    log.info("{}", result);
                }
            }
        }


        // --------------------------------------------------------------------------------------------------

        /**
         * Generate Repository
         */
        if (enableRepository && properties.getRepository().isEnable()) {
            pkgDir = new File(root, properties.getRepository().getPackages().replace('.','/'));
            pkgDir.mkdirs();
            props.put("package", properties.getRepository().getPackages());
            props.put("step", "repository");
            props.put("suffix", properties.getRepository().getSuffix());
            props.put("table", null);
            props.put("schema", null);
            // Load xslt template file
            Transformer transformer = getTransformer(properties.getRepository().getTemplate());

            for (String schemaName: structure.getSchemas().keySet()) {
                props.put("schema", schemaName);
                for (String tableName: structure.getSchemas().get(schemaName).getTables().keySet()) {

                    String entityPackageName = properties.getEntities().getPackages();

                    String entityClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getEntities().getSuffix();

                    props.put("table", tableName);
                    props.put("entityClass", entityClassName);
                    props.put("entityPackage", entityPackageName);

                    String classFileName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getRepository().getSuffix() + ".java";
                    File classFile = new File(pkgDir, classFileName);

                    String save = "";
                    String savePartStart = properties.getRepository().getSavePartStart();
                    log.info("Check if file contains: {}", savePartStart);
                    if (classFile.exists() && !savePartStart.isEmpty()) {
                        String ctx = readFile(classFile);
                        log.info("File contents: {}", ctx);
                        List<String> matches = new ArrayList<>();
                        if (RegexpUtils.preg_match("~^.+("+ savePartStart +".+)\\}[^\\}]*$~isu", ctx, matches)) {
                            //log.info("{}", matches);
                            save = matches.get(1);
                        }
                    }
                    props.put("save", save);

                    String result = transformXML(document, transformer, props);
                    // Save result
                    try (PrintWriter writer = new PrintWriter(classFile)) {
                        writer.print(result);
                    }
                    log.info("{}", result);
                }
            }
        }

        // ---------------------------------------------------------------------------------------
        /**
         * Generate Models
         */
        if (enableModel && properties.getModel().isEnable()) {
            pkgDir = new File(root, properties.getModel().getPackages().replace('.','/'));
            pkgDir.mkdirs();
            props.put("package", properties.getModel().getPackages());
            props.put("suffix-model", properties.getModel().getSuffixModel());
            props.put("suffix-data", properties.getModel().getSuffixData());
            props.put("table", null);
            props.put("schema", null);
            // Load xslt template file
            Transformer transformer = getTransformer(properties.getModel().getTemplate());

            boolean enableData = properties.getModel().isGenerateData();

            for (String schemaName: structure.getSchemas().keySet()) {
                props.put("schema", schemaName);
                for (String tableName: structure.getSchemas().get(schemaName).getTables().keySet()) {

                    String entityPackageName = properties.getEntities().getPackages();

                    String entityClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getEntities().getSuffix();

                    props.put("step", "model");
                    props.put("table", tableName);
                    props.put("className", structure.getSchemas().get(schemaName).getTable(tableName).getClassName());

                    String result = transformXML(document, transformer, props);
                    // Save result
                    String classFileName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getModel().getSuffixModel() + ".java";
                    //log.info("Filename: {}", classFileName);
                    File classFile = new File(pkgDir, classFileName);
                    try (PrintWriter writer = new PrintWriter(classFile)) {
                        writer.print(result);
                    }
                    log.info("{}", result);

                    if (enableData) {
                        props.put("step", "model-data");

                        result = transformXML(document, transformer, props);
                        // Save result
                        classFileName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                                properties.getModel().getSuffixData() + ".java";
                        //log.info("Filename: {}", classFileName);
                        classFile = new File(pkgDir, classFileName);
                        try (PrintWriter writer = new PrintWriter(classFile)) {
                            writer.print(result);
                        }
                        log.info("{}", result);
                    }
                }
            }
        }


        // ---------------------------------------------------------------------------------------
        /**
         * Generate Mappers
         */
        if (enableMapper && properties.getMapper().isEnable()) {
            pkgDir = new File(root, properties.getMapper().getPackages().replace('.','/'));
            pkgDir.mkdirs();
            props.put("package", properties.getMapper().getPackages());
            props.put("step", "entity");
            props.put("suffix", properties.getMapper().getSuffix());
            props.put("table", null);
            props.put("schema", null);
            String entityPackageName = properties.getEntities().getPackages();
            String dtoPackageName = properties.getModel().getPackages();
            String dtoSuffix = properties.getModel().getSuffixModel();
            props.put("entityPackage", entityPackageName);
            props.put("dtoPackage", dtoPackageName);
            props.put("dtoSuffix", dtoSuffix);
            // Load xslt template file
            Transformer transformer = getTransformer(properties.getMapper().getTemplate());

            for (String schemaName: structure.getSchemas().keySet()) {
                props.put("schema", schemaName);
                for (String tableName: structure.getSchemas().get(schemaName).getTables().keySet()) {
                    String entityClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getEntities().getSuffix();
                    String dtoClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getModel().getSuffixModel();
                    props.put("table", tableName);
                    props.put("entityClass", entityClassName);
                    props.put("dtoClass", dtoClassName);
                    String result = transformXML(document, transformer, props);
                    // Save result
                    String classFileName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getMapper().getSuffix() + ".java";
                    log.info("Filename: {}", classFileName);
                    File classFile = new File(pkgDir, classFileName);
                    try (PrintWriter writer = new PrintWriter(classFile)) {
                        writer.print(result);
                    }
                    log.info("{}", result);
                }
            }
        }

        // ---------------------------------------------------------------------------------------
        /**
         * Generate Service
         */
        if (enableService && properties.getService().isEnable()) {
            pkgDir = new File(root, properties.getService().getPackages().replace('.','/'));
            pkgDir.mkdirs();
            props.put("package", properties.getService().getPackages());
            props.put("step", "entity");
            props.put("suffix", properties.getService().getSuffix());
            props.put("table", null);
            props.put("schema", null);
            String entityPackageName = properties.getEntities().getPackages();
            String dtoPackageName = properties.getModel().getPackages();
            String dtoSuffix = properties.getModel().getSuffixModel();
            String repositoryPackageName = properties.getRepository().getPackages();
            String repositorySuffix = properties.getRepository().getSuffix();
            String mapperPackageName = properties.getMapper().getPackages();
            String mapperSuffix = properties.getMapper().getSuffix();
            props.put("entityPackage", entityPackageName);
            props.put("dtoPackage", dtoPackageName);
            props.put("dtoSuffix", dtoSuffix);
            props.put("repositoryPackage", repositoryPackageName);
            props.put("repositorySuffix", repositorySuffix);
            props.put("mapperPackage", mapperPackageName);
            props.put("mapperSuffix", mapperSuffix);
            // Load xslt template file
            Transformer transformer = getTransformer(properties.getService().getTemplate());

            for (String schemaName: structure.getSchemas().keySet()) {
                props.put("schema", schemaName);
                for (String tableName: structure.getSchemas().get(schemaName).getTables().keySet()) {
                    String entityClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getEntities().getSuffix();
                    String dtoClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getModel().getSuffixModel();
                    String repositoryClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getRepository().getSuffix();
                    String mapperClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            mapperSuffix;
                    props.put("table", tableName);
                    props.put("entityClass", entityClassName);
                    props.put("dtoClass", dtoClassName);
                    props.put("repositoryClass", repositoryClassName);
                    props.put("mapperClass", mapperClassName);
                    String result = transformXML(document, transformer, props);
                    // Save result
                    String classFileName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getService().getSuffix() + ".java";
                    log.info("Filename: {}", classFileName);
                    File classFile = new File(pkgDir, classFileName);
                    try (PrintWriter writer = new PrintWriter(classFile)) {
                        writer.print(result);
                    }
                    log.info("{}", result);
                }
            }
        }

        // ---------------------------------------------------------------------------------------
        /**
         * Generate Controller
         */
        if (enableController && properties.getController().isEnable()) {
            pkgDir = new File(root, properties.getController().getPackages().replace('.','/'));
            pkgDir.mkdirs();
            props.put("package", properties.getController().getPackages());
            props.put("step", "entity");
            props.put("suffix", properties.getController().getSuffix());
            props.put("table", null);
            props.put("schema", null);
            String entityPackageName = properties.getEntities().getPackages();
            String dtoPackageName = properties.getModel().getPackages();
            String dtoSuffix = properties.getModel().getSuffixModel();
            String repositoryPackageName = properties.getRepository().getPackages();
            String repositorySuffix = properties.getRepository().getSuffix();
            String mapperPackageName = properties.getMapper().getPackages();
            String mapperSuffix = properties.getMapper().getSuffix();
            String servicePackageName = properties.getService().getPackages();
            String serviceSuffix = properties.getService().getSuffix();
            props.put("entityPackage", entityPackageName);
            props.put("dtoPackage", dtoPackageName);
            props.put("dtoSuffix", dtoSuffix);
            props.put("repositoryPackage", repositoryPackageName);
            props.put("repositorySuffix", repositorySuffix);
            props.put("mapperPackage", mapperPackageName);
            props.put("mapperSuffix", mapperSuffix);
            props.put("servicePackage", servicePackageName);
            props.put("serviceSuffix", serviceSuffix);
            // Load xslt template file
            Transformer transformer = getTransformer(properties.getController().getTemplate());

            for (String schemaName: structure.getSchemas().keySet()) {
                props.put("schema", schemaName);
                for (String tableName: structure.getSchemas().get(schemaName).getTables().keySet()) {
                    String entityClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getEntities().getSuffix();
                    String dtoClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getModel().getSuffixModel();
                    String repositoryClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getRepository().getSuffix();
                    String mapperClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            mapperSuffix;
                    String serviceClassName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            serviceSuffix;
                    props.put("table", tableName);
                    props.put("entityClass", entityClassName);
                    props.put("dtoClass", dtoClassName);
                    props.put("repositoryClass", repositoryClassName);
                    props.put("mapperClass", mapperClassName);
                    props.put("serviceClass", serviceClassName);
                    String result = transformXML(document, transformer, props);
                    // Save result
                    String classFileName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            properties.getController().getSuffix() + ".java";
                    log.info("Filename: {}", classFileName);
                    File classFile = new File(pkgDir, classFileName);
                    try (PrintWriter writer = new PrintWriter(classFile)) {
                        writer.print(result);
                    }
                    log.info("{}", result);
                }
            }
        }
    }

    private void parseCommandLine(String[] cmdLine) {
        for(String cmd: cmdLine) {
            switch (cmd) {
                case "--enableEntities":
                    enableEntities = true;
                    break;
                case "--disableEntities":
                    enableEntities = false;
                    break;
                case "--enableRepository":
                    enableRepository = true;
                    break;
                case "--disableRepository":
                    enableRepository = false;
                    break;
                case "--enableModel":
                    enableModel = true;
                    break;
                case "--disableModel":
                    enableModel = false;
                    break;
                case "--enableMapper":
                    enableMapper = true;
                    break;
                case "--disableMapper":
                    enableMapper = false;
                    break;
                case "--enableService":
                    enableService = true;
                    break;
                case "--disableService":
                    enableService = false;
                    break;
                case "--enableController":
                    enableController = true;
                    break;
                case "--disableController":
                    enableController = false;
                    break;
                default:
            }
        }
    }

    private Transformer getTransformer(String fileName) throws Exception {
        Document xsl = null;
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setNamespaceAware(true);
        DocumentBuilder db = factory.newDocumentBuilder();
        xsl = db.parse(new File(fileName));

        DOMSource xslSource = new DOMSource(xsl);
        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        Transformer transformer = transformerFactory.newTransformer(xslSource);

        return transformer;
    }

    private String transformXML(Document document, Transformer transformer, Map<String, Object> parameters) throws Exception {
        String result = null;
            DOMSource domSource = new DOMSource(document);
            /*
             * Set Parameters
             */
            if (parameters != null) {
                for (String param_name : parameters.keySet()) {
                    //log.debug(param_name + " {" + parameters.get(param_name) + "}");
                    transformer.setParameter(param_name, parameters.get(param_name));
                }
            }
            /*
             * Transformation
             */
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            StreamResult streamresult = new StreamResult(buffer);
            transformer.transform(domSource, streamresult);
            result = buffer.toString(transformer.getOutputProperty(OutputKeys.ENCODING));

        return result;
    }

    private String readFile(File file) throws IOException {
        Path path = Paths.get(file.getPath());
        List<String> lines = Files.readAllLines(path);
        //String result = lines.size() > 0? lines.get(0):"";
        String result = String.join("\n", lines.toArray(new String[]{}));
        return result;
    }

}
