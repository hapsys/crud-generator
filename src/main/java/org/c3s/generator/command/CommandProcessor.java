package org.c3s.generator.command;

import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.Marshaller;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.c3s.generator.config.AbstractGeneratorConfigProperties;
import org.c3s.generator.metadata.DataBaseStructure;
import org.c3s.generator.metadata.Table;
import org.c3s.generator.utils.RegexpUtils;
import org.c3s.transformers.velocity.VelocityTransformer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
import org.c3s.generator.config.properties.GeneratorConfigProperties;
import org.c3s.generator.metadata.GeneratorContext;

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

    @Override
    public void run(String... args) throws Exception {
        log.info("Run application!");

        parseCommandLine(args);

        GeneratorContext.instance.setProperties(properties);
        GeneratorContext.instance.setConnection(connection);
        GeneratorContext.instance.setMetaData(metaData);

        // metaData = dataSource.getConnection().getMetaData();


        /*
        try (ResultSet tables = metaData.getTables("ed-go", null, null, new String[]{"TABLE"})) {
            while(tables.next()) {

                String name = tables.getString("table_name");
                String comment = tables.getString("remarks");
                log.info("Table: \"{}\". Comment: {}", name, comment);
            }
        }
        System.exit(0);

        try (ResultSet resultSet = metaData.getColumns("ed-go", null, "systems", null)) {
            while(resultSet.next()) {
                ResultSetMetaData meta = resultSet.getMetaData();
                for(int i = 1; i < meta.getColumnCount(); i++) {
                    log.info("Table \"{}\":\t{}", meta.getColumnLabel(i), resultSet.getString(i));
                }
                log.info("---------------------------------------------------------------------");
            }
        }
        System.exit(0);
         */

        if (properties.getCatalog() != null) {
            for (String catalog : properties.getCatalog()) {
                structure.addCatalog(catalog);
            }
        } else {
            structure.addCatalog(null);
        }
        structure.generateCatalogs();

        structure.generateForeignKeys();

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
        Map<String, Object> props = new HashMap<>() {{
            //put("root", properties.getRoot());
            if (properties.getProperties() != null) {
                putAll(properties.getProperties());
            }
        }};
        // --------------------------------------------------------------------------------------------------


        //File pkgDir;

        log.info("Configuration size {}",properties.getSteps().size());
        properties.getSteps().forEach((x,y)-> log.info(x));
        properties.getSteps().forEach((x,y)->{
            props.put(x + "_package", y.getPackages());
            props.put(x + "_suffix", y.getSuffix());
        });

        for (String key: properties.getSteps().keySet()) {
            AbstractGeneratorConfigProperties stepProps = properties.getSteps().get(key);
            if (stepProps.isSingle()) {

            } else {
                processMultiFilePart(document, key, stepProps, props);
            }
        }
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

    private void processMultiFilePart(Document document, String step, AbstractGeneratorConfigProperties stepProps, Map<String, Object> commonProps) throws Exception {
        VelocityTransformer velocity = new VelocityTransformer();
        String rootPath = stepProps.getRoot() != null ? stepProps.getRoot():properties.getRoot();
        //String ext = stepProps.getExtension() == null?"java":stepProps.getExtension();
        File root = new File(rootPath);
        root.mkdirs();
        Transformer transformer = getTransformer(stepProps.getTemplate());
        Map<String, Object> props = new HashMap<>(commonProps);
        props.put("step", step);
        structure.getCatalogs().forEach((catalogName, catalog) -> {
            props.put("catalogue", catalogName != null?catalogName:"");
            catalog.getSchemas().forEach((schemaName, schema) -> {
                props.put("schema", schemaName != null?schemaName:"");
                String pkg = stepProps.getPackages();
                File pkgDir;
                if (pkg != null) {
                    pkgDir = new File(root, pkg.replace('.', '/'));
                } else {
                    pkgDir = root;
                }
                pkgDir.mkdirs();
                schema.getTables().forEach((tableName, table) -> {
                    props.put("table", tableName);
                    properties.getSteps().forEach((x,y)->{
                        props.put(x + "_class_name", table.getClassName() + y.getSuffix());
                    });
                    String classFileName;
                    if (!StringUtils.isEmpty(stepProps.getFileName())) {
                        try {
                            classFileName = velocity.transform(props, stepProps.getFileName(), null);
                        } catch (Exception e) {
                            throw new RuntimeException(e);
                        }
                    } else {
                        classFileName = table.getClassName() + stepProps.getSuffix() + ".java";
                    }
                    log.debug("Filename: {}", classFileName);
                    File classFile = new File(pkgDir, classFileName);

                    if (Objects.nonNull(stepProps.getSavePartStart())) {
                        String save = "";
                        String savePartStart = stepProps.getSavePartStart();
                        log.debug("Check if file contains: {}", savePartStart);
                        if (classFile.exists() && !savePartStart.isEmpty()) {
                            try {
                                String ctx = readFile(classFile);
                                log.debug("File contents: {}", ctx);
                                List<String> matches = new ArrayList<>();
                                if (RegexpUtils.preg_match("~^.+(" + savePartStart + ".+)\\}[^\\}]*$~isu", ctx, matches)) {
                                    //log.debug("{}", matches);
                                    save = matches.get(1);
                                }
                            } catch (IOException e) {
                                log.error(e.getMessage(), e);
                            }
                        }
                        props.put("save", save);
                    }
                    // Save result
                    try (PrintWriter writer = new PrintWriter(classFile)) {
                        String result = transformXML(document, transformer, props);
                        writer.print(result);
                        log.debug("{}", result);
                    } catch (Exception e) {
                        log.error(e.getMessage(), e);
                    }
                });
            });
        });
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
        //transformer.setOutputProperty(OutputKeys.ENCODING,"UTF-8");

        return transformer;
    }

    private String transformXML(Document document, Transformer transformer, Map<String, Object> parameters) throws Exception {
        String result = null;
            DOMSource domSource = new DOMSource(document);
            /*
             * Set Parameters
             */
            if (parameters != null) {
                log.debug("Transform parameters: {}", parameters);
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
            //result = buffer.toString(transformer.getOutputProperty(OutputKeys.ENCODING));
            result = buffer.toString();

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
