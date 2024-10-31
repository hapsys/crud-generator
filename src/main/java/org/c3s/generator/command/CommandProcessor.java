package org.c3s.generator.command;

import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.Marshaller;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.c3s.generator.command.process.Processes;
import org.c3s.generator.metadata.DataBaseStructure;
import org.c3s.transformers.velocity.VelocityTransformer;
import org.c3s.transformers.xml.XSLTransformer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
import org.c3s.generator.config.properties.GeneratorConfigProperties;
import org.c3s.generator.metadata.GeneratorContext;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.*;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.util.*;

@Slf4j
@Component
public class CommandProcessor implements CommandLineRunner {

    @Autowired
    private Connection connection;

    @Autowired
    private DatabaseMetaData metaData;

    @Autowired
    private GeneratorConfigProperties properties;

    @Autowired
    private DataBaseStructure structure;

    private List<org.c3s.transformers.Transformer> transformers = new ArrayList<>();

    @Override
    public void run(String... args) throws Exception {
        log.info("Run application!");

        parseCommandLine(args);

        GeneratorContext.instance.setProperties(properties);
        GeneratorContext.instance.setConnection(connection);
        GeneratorContext.instance.setMetaData(metaData);

        // Register transformers
        transformers.add(new XSLTransformer());
        transformers.add(new VelocityTransformer());

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

        log.info("Configuration size {}",properties.getSteps().size());
        properties.getSteps().forEach((x,y)-> log.info(x));
        properties.getSteps().forEach((x,y)->{
            props.put(x + "_package", y.getPackages());
            props.put(x + "_suffix", y.getSuffix());
        });

        properties.getSteps().forEach((x,y) -> {
            Processes process = Processes.getApplicableProcess(y.getTemplate());
            log.info("Process for {} is {}", x, process);
            if (process != null) {
                try {
                    if (StringUtils.isEmpty(y.getClassName())) {
                        log.info("Files type for {} is MULTIPLE", x, process);
                        process.getProcess().processMultiFile(structure, x, properties, props);
                    } else {
                        log.info("Files type for {} is SINGLE", x, process);
                        process.getProcess().processSingleFile(structure, x, properties, props);
                    }
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            } else {
                log.error("Process not found for template \"{}\"", y.getTemplate());
            }
        });
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
}
