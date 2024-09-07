package org.c3s.generator.command.process;

import org.c3s.generator.metadata.DataBaseStructure;
import org.c3s.transformers.Transformer;
import org.c3s.transformers.velocity.VelocityTransformer;
import org.c3s.transformers.xml.XSLTransformer;

import java.io.File;
import java.util.Map;

public class VelocityProcess extends AbstractProcess {

    private Transformer transformer = new VelocityTransformer();

    @Override
    protected String transform(DataBaseStructure structure, File template, Map<String, Object> properties) throws Exception {
        return transformer.transform(structure, template, properties);
    }

    @Override
    public Transformer getTransformer() {
        return transformer;
    }
}
