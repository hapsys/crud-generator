package org.c3s.generator.command.process;

import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.c3s.generator.config.properties.AbstractGeneratorConfigProperties;
import org.c3s.generator.config.properties.GeneratorConfigProperties;
import org.c3s.generator.metadata.DataBaseStructure;
import org.c3s.generator.utils.RegexpUtils;
import org.c3s.transformers.velocity.VelocityTransformer;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Slf4j
public abstract class AbstractProcess implements GeneralProcess {
    @Override
    public void processMultiFile(DataBaseStructure structure, String step, GeneratorConfigProperties properties, Map<String, Object> commonProps) throws Exception {

        VelocityTransformer velocity = new VelocityTransformer();
        AbstractGeneratorConfigProperties stepProps = properties.getSteps().get(step);
        String rootPath = stepProps.getRoot() != null ? stepProps.getRoot():properties.getRoot();
        File root = new File(rootPath);
        root.mkdirs();
        File template = new File(stepProps.getTemplate());
        Map<String, Object> props = new HashMap<>(commonProps);
        props.put("step", step);
        structure.getCatalogs().forEach((catalogName, catalog) -> {
            props.put("catalogue", catalogName != null?catalogName:"");
            catalog.getSchemas().forEach((schemaName, schema) -> {
                props.put("schema", schemaName != null?schemaName:"");
                String pkg = stepProps.getPackages();
                File pkgDir;
                if (pkg != null) {
                    pkgDir = new File(root, pkg.replace('.', File.separatorChar));
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
                        String result = transform(structure, template, props);
                        writer.print(result);
                        log.debug("{}", result);
                    } catch (Exception e) {
                        log.error(e.getMessage(), e);
                    }
                });
            });
        });
    }

    @Override
    public void processSingleFile(DataBaseStructure structure, String step, GeneratorConfigProperties properties, Map<String, Object> commonProps) throws Exception {
        VelocityTransformer velocity = new VelocityTransformer();
        AbstractGeneratorConfigProperties stepProps = properties.getSteps().get(step);
        String rootPath = stepProps.getRoot() != null ? stepProps.getRoot():properties.getRoot();
        File root = new File(rootPath);
        root.mkdirs();
        File template = new File(stepProps.getTemplate());
        Map<String, Object> props = new HashMap<>(commonProps);
        props.put("step", step);

        String pkg = stepProps.getPackages();
        File pkgDir;
        if (pkg != null) {
            pkgDir = new File(root, pkg.replace('.', File.separatorChar));
        } else {
            pkgDir = root;
        }
        pkgDir.mkdirs();

        structure.getCatalogs().forEach((catalogName, catalog) -> {
            props.put("catalogue", catalogName != null?catalogName:"");
            catalog.getSchemas().forEach((schemaName, schema) -> {
                props.put("schema", schemaName != null?schemaName:"");
                schema.getTables().forEach((tableName, table) -> {
                    //props.put("table", tableName);
                    properties.getSteps().forEach((x,y)->{
                        props.put(x + "_class_name", table.getClassName() + y.getSuffix());
                    });
                });
            });
        });
        props.put("class_name", stepProps.getClassName());
        String classFileName;
        if (!StringUtils.isEmpty(stepProps.getFileName())) {
            try {
                classFileName = velocity.transform(props, stepProps.getFileName(), null);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        } else {
            classFileName = stepProps.getClassName() + ".java";
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
        log.info("Single file properties:\n{}", props);
        try (PrintWriter writer = new PrintWriter(classFile)) {
            String result = transform(structure, template, props);
            writer.print(result);
            log.debug("{}", result);
        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
    }

    protected abstract String transform(DataBaseStructure structure, File template, Map<String, Object> properties) throws Exception;

    private String readFile(File file) throws IOException {
        Path path = Paths.get(file.getPath());
        List<String> lines = Files.readAllLines(path);
        //String result = lines.size() > 0? lines.get(0):"";
        String result = String.join("\n", lines.toArray(new String[]{}));
        return result;
    }

}
