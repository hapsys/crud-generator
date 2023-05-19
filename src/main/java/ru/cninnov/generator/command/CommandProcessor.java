package ru.cninnov.generator.command;

import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.Marshaller;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
import ru.cninnov.generator.config.AbstractGeneratorConfigProperties;
import ru.cninnov.generator.config.properties.GeneratorConfigProperties;
import ru.cninnov.generator.metadata.DataBaseStructure;
import ru.cninnov.generator.metadata.GeneratorContext;
import ru.cninnov.generator.utils.RegexpUtils;

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
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.*;

@Slf4j
@Component
public class CommandProcessor implements CommandLineRunner {

    //@Autowired
    //private JdbcTemplate jdbcTemplate;

    @Autowired
    private Connection connection;

    @Autowired
    private DatabaseMetaData metaData;

    @Autowired
    private GeneratorConfigProperties properties;

    @Autowired
    private DataBaseStructure structure;

    File root;
    @Override
    public void run(String... args) throws Exception {
        log.info("Run application!");

        parseCommandLine(args);

        GeneratorContext.instance.setProperties(properties);
        GeneratorContext.instance.setConnection(connection);
        GeneratorContext.instance.setMetaData(metaData);

        //DatabaseMetaData metaData = dataSource.getConnection().getMetaData();

        /*

        try (ResultSet resultSet = metaData.getColumns(null, "msdict", "country", null)) {
            while(resultSet.next()) {
                ResultSetMetaData meta = resultSet.getMetaData();
                for(int i = 1; i < meta.getColumnCount(); i++) {
                    log.debug("Table \"{}\":\t{}", meta.getColumnLabel(i), resultSet.getString(i));
                }
                log.debug("---------------------------------------------------------------------");
            }
        }
        System.exit(0);
         */

        for (String schema: properties.getSchemas()) {
            structure.addSchema(schema);
        }
        structure.generateSchemas();

        structure.generateForeignKeys();

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
        String export = properties.getExport();
        if (export != null && !export.isEmpty()) {
            jaxbMarshaller.marshal(structure, new File(export));
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


        //File pkgDir;

        log.info("Configuration size {}",properties.getSteps().size());
        properties.getSteps().forEach((x,y)-> log.info(x));
    }

    private void parseCommandLine(String[] cmdLine) {
        for(int i=0; i < cmdLine.length; i++) {
            String cmd = cmdLine[i];
            if ("--root".equals(cmd)) {
                if (i < cmdLine.length - 1) {
                    i++;
                    properties.setRoot(cmdLine[i]);
                }
            } else {
                /*
                switch (cmd) {
                    case "--enableEntities":
                        properties.getEntities().setEnable(true);
                        break;
                    case "--disableEntities":
                        properties.getEntities().setEnable(false);
                        break;
                    case "--enableRepository":
                        properties.getRepository().setEnable(true);
                        break;
                    case "--disableRepository":
                        properties.getRepository().setEnable(false);
                        break;
                    case "--enableModel":
                        properties.getModel().setEnable(true);
                        break;
                    case "--disableModel":
                        properties.getModel().setEnable(false);
                        break;
                    case "--enableMapper":
                        properties.getMapper().setEnable(true);
                        break;
                    case "--disableMapper":
                        properties.getMapper().setEnable(false);
                        break;
                    case "--enableService":
                        properties.getService().setEnable(true);
                        break;
                    case "--disableService":
                        properties.getService().setEnable(false);
                        break;
                    case "--enableController":
                        properties.getController().setEnable(true);
                        break;
                    case "--disableController":
                        properties.getController().setEnable(false);
                        break;
                    case "--enableMetadata":
                        properties.getMeta().setEnable(true);
                        break;
                    case "--disableMetadata":
                        properties.getMeta().setEnable(false);
                        break;
                    default:
                }

                 */
            }
        }
    }

    private void processParts(AbstractGeneratorConfigProperties part, Document document) throws Exception {
        /*
        Map<String, Object> props = new HashMap<>() {{put("root", properties.getRoot());}};
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
        props.put("entitySuffix", entitySuffix);
        props.put("dtoSuffix", dtoSuffix);
        props.put("repositorySuffix", repositorySuffix);
        props.put("mapperSuffix", mapperSuffix);
        props.put("serviceSuffix", serviceSuffix);
        props.put("metaSuffix", metaSuffix);
        // Load xslt template file
        Transformer transformer = getTransformer(part.getTemplate());

        for (String schemaName: structure.getSchemas().keySet()) {
            props.put("schema", schemaName);
            String packageSuffix = "";
            if (properties.getSchemaPackages() != null) {
                if (properties.getSchemaPackages() != null && properties.getSchemaPackages().containsKey(schemaName)) {
                    packageSuffix = "." + properties.getSchemaPackages().get(schemaName);
                } else {
                    packageSuffix = "." + schemaName;
                }
            }
            String pkg = part.getPackages() + packageSuffix;
            File pkgDir;
            pkgDir = new File(root, pkg.replace('.','/'));
            pkgDir.mkdirs();
            props.put("package", pkg);
            props.put("entityPackage", entityPackageName + packageSuffix);
            props.put("dtoPackage", dtoPackageName + packageSuffix);
            props.put("repositoryPackage", repositoryPackageName + packageSuffix);
            props.put("mapperPackage", mapperPackageName + packageSuffix);
            props.put("servicePackage", servicePackageName + packageSuffix);
            props.put("metaPackage", metaPackageName + packageSuffix);
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
                log.debug("Filename: {}", classFileName);
                File classFile = new File(pkgDir, classFileName);

                if (Objects.nonNull(part.getSavePartStart())) {
                    String save = "";
                    String savePartStart = part.getSavePartStart();
                    log.debug("Check if file contains: {}", savePartStart);
                    if (classFile.exists() && !savePartStart.isEmpty()) {
                        String ctx = readFile(classFile);
                        log.debug("File contents: {}", ctx);
                        List<String> matches = new ArrayList<>();
                        if (RegexpUtils.preg_match("~^.+(" + savePartStart + ".+)\\}[^\\}]*$~isu", ctx, matches)) {
                            //log.debug("{}", matches);
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
                log.debug("{}", result);
                if (part.isGenerateData()) {
                    props.put("step", "additional");

                    result = transformXML(document, transformer, props);
                    // Save result
                    classFileName = structure.getSchemas().get(schemaName).getTable(tableName).getClassName() +
                            part.getSuffixData() + ".java";
                    //log.debug("Filename: {}", classFileName);
                    classFile = new File(pkgDir, classFileName);
                    try (PrintWriter writer = new PrintWriter(classFile)) {
                        writer.print(result);
                    }
                    log.debug("{}", result);
                }
            }
        }
       */

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
