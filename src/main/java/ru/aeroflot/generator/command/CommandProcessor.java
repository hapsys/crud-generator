package ru.aeroflot.generator.command;

import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.Marshaller;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
import ru.aeroflot.generator.config.AbstractGeneratorConfigProperties;
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
import java.util.*;

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
    private boolean enableMetadata = true;

    File root;
    @Override
    public void run(String... args) throws Exception {
        log.info("Run application!");

        parseCommandLine(args);

        GeneratorContext.instance.setProperties(properties);
        GeneratorContext.instance.setDataSource(dataSource);

        DatabaseMetaData metaData = dataSource.getConnection().getMetaData();

        for (String schema: properties.getSchemas()) {
            structure.addSchema(schema);
        }
        structure.generateSchemas();

        /**
         * Prepare paremateres
         */
        root = new File(properties.getRoot());
        root.mkdirs();

        JAXBContext jaxbContext = org.eclipse.persistence.jaxb.JAXBContextFactory
                .createContext(new Class[]{DataBaseStructure.class}, null);
        Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
        jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
        jaxbMarshaller.setProperty(Marshaller.JAXB_ENCODING, "utf-8");
        if (!properties.getExport().isEmpty()) {
            jaxbMarshaller.marshal(structure, new File(properties.getExport()));
        }

        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document document = builder.newDocument();
        jaxbMarshaller.marshal(structure, document);

        /**
         * Transformation properties
         */
        Map<String, Object> props = new HashMap<>() {{put("root", properties.getRoot());}};

        // --------------------------------------------------------------------------------------------------


        File pkgDir;
        /**
         * Generate Entities
         */
        if (enableEntities && properties.getEntities().isEnable()) {
            processParts(properties.getEntities(), document);
        }

        // --------------------------------------------------------------------------------------------------

        /**
         * Generate Repository
         */
        if (enableRepository && properties.getRepository().isEnable()) {
            processParts(properties.getRepository(), document);
        }

        // ---------------------------------------------------------------------------------------
        /**
         * Generate Models
         */
        if (enableModel && properties.getModel().isEnable()) {
            processParts(properties.getModel(), document);
        }


        // ---------------------------------------------------------------------------------------
        /**
         * Generate Mappers
         */
        if (enableMapper && properties.getMapper().isEnable()) {
            processParts(properties.getMapper(), document);
        }

        // ---------------------------------------------------------------------------------------
        /**
         * Generate Service
         */
        if (enableService && properties.getService().isEnable()) {
            processParts(properties.getService(), document);
        }

        // ---------------------------------------------------------------------------------------
        /**
         * Generate Metadata
         */
        if (enableMetadata && properties.getMeta().isEnable()) {
            processParts(properties.getMeta(), document);
        }

        // ---------------------------------------------------------------------------------------
        /**
         * Generate Controller
         */
        if (enableController && properties.getController().isEnable()) {
            processParts(properties.getController(), document);
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
                case "--enableMetadata":
                    enableMetadata = true;
                    break;
                case "--disableMetadata":
                    enableMetadata = false;
                    break;
                default:
            }
        }
    }

    private void processParts(AbstractGeneratorConfigProperties part, Document document) throws Exception {
        Map<String, Object> props = new HashMap<>() {{put("root", properties.getRoot());}};
        File pkgDir;
        pkgDir = new File(root, part.getPackages().replace('.','/'));
        pkgDir.mkdirs();
        props.put("package", part.getPackages());
        props.put("step", "process");
        props.put("suffix", part.getSuffix());
        props.put("suffix-data", Objects.nonNull(part.getSuffixData())?part.getSuffixData():"");
        String entityPackageName = properties.getEntities().getPackages();
        String entitySuffix = properties.getEntities().getSuffix();
        String dtoPackageName = properties.getModel().getPackages();
        String dtoSuffix = properties.getModel().getSuffix();
        String repositoryPackageName = properties.getRepository().getPackages();
        String repositorySuffix = properties.getRepository().getSuffix();
        String mapperPackageName = properties.getMapper().getPackages();
        String mapperSuffix = properties.getMapper().getSuffix();
        String servicePackageName = properties.getService().getPackages();
        String serviceSuffix = properties.getService().getSuffix();
        String metaPackageName = properties.getMeta().getPackages();
        String metaSuffix = properties.getMeta().getSuffix();
        props.put("entityPackage", entityPackageName);
        props.put("entitySuffix", entitySuffix);
        props.put("dtoPackage", dtoPackageName);
        props.put("dtoSuffix", dtoSuffix);
        props.put("repositoryPackage", repositoryPackageName);
        props.put("repositorySuffix", repositorySuffix);
        props.put("mapperPackage", mapperPackageName);
        props.put("mapperSuffix", mapperSuffix);
        props.put("servicePackage", servicePackageName);
        props.put("serviceSuffix", serviceSuffix);
        props.put("metaPackage", metaPackageName);
        props.put("metaSuffix", metaSuffix);
        // Load xslt template file
        Transformer transformer = getTransformer(part.getTemplate());

        for (String schemaName: structure.getSchemas().keySet()) {
            props.put("schema", schemaName);
            for (String tableName: structure.getSchemas().get(schemaName).getTables().keySet()) {
                String className = structure.getSchemas().get(schemaName).getTable(tableName).getClassName();
                String entityClassName = className + properties.getEntities().getSuffix();
                String dtoClassName = className + properties.getModel().getSuffix();
                String repositoryClassName = className + properties.getRepository().getSuffix();
                String mapperClassName = className + mapperSuffix;
                String serviceClassName = className + serviceSuffix;
                String metaClassName = className + metaSuffix;
                props.put("table", tableName);
                props.put("entityClass", entityClassName);
                props.put("dtoClass", dtoClassName);
                props.put("repositoryClass", repositoryClassName);
                props.put("mapperClass", mapperClassName);
                props.put("serviceClass", serviceClassName);
                props.put("metaClass", metaClassName);
                props.put("step", "process");

                String classFileName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                        part.getSuffix() + ".java";
                log.info("Filename: {}", classFileName);
                File classFile = new File(pkgDir, classFileName);

                if (Objects.nonNull(part.getSavePartStart())) {
                    String save = "";
                    String savePartStart = part.getSavePartStart();
                    log.info("Check if file contains: {}", savePartStart);
                    if (classFile.exists() && !savePartStart.isEmpty()) {
                        String ctx = readFile(classFile);
                        log.info("File contents: {}", ctx);
                        List<String> matches = new ArrayList<>();
                        if (RegexpUtils.preg_match("~^.+(" + savePartStart + ".+)\\}[^\\}]*$~isu", ctx, matches)) {
                            //log.info("{}", matches);
                            save = matches.get(1);
                        }
                    }
                    props.put("save", save);
                }


                String result = transformXML(document, transformer, props);
                // Save result
                try (PrintWriter writer = new PrintWriter(classFile)) {
                    writer.print(result);
                }
                log.info("{}", result);
                if (part.isGenerateData()) {
                    props.put("step", "additional");

                    result = transformXML(document, transformer, props);
                    // Save result
                    classFileName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            part.getSuffixData() + ".java";
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
