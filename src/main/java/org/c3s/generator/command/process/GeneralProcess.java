package org.c3s.generator.command.process;

import org.c3s.generator.config.properties.GeneratorConfigProperties;
import org.c3s.generator.metadata.DataBaseStructure;
import org.c3s.transformers.Transformer;

import java.util.Map;

public interface GeneralProcess {
    public void processMultiFile(DataBaseStructure structure, String step, GeneratorConfigProperties properties, Map<String, Object> commonProps) throws Exception;
    public void processSingleFile(DataBaseStructure structure, String step, GeneratorConfigProperties properties, Map<String, Object> commonProps) throws Exception;
    public Transformer getTransformer();
}
