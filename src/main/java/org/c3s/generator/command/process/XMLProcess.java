package org.c3s.generator.command.process;

import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.Marshaller;
import org.apache.commons.lang3.StringUtils;
import org.c3s.generator.config.AbstractGeneratorConfigProperties;
import org.c3s.generator.config.properties.GeneratorConfigProperties;
import org.c3s.generator.metadata.DataBaseStructure;
import org.c3s.generator.utils.RegexpUtils;
import org.c3s.transformers.Transformer;
import org.c3s.transformers.xml.XSLTransformer;
import org.w3c.dom.Document;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.File;
import java.util.Map;

public class XMLProcess extends AbstractProcess {

    private Transformer transformer = new XSLTransformer();

    private Document document = null;

    @Override
    protected String transform(DataBaseStructure structure, File template, Map<String, Object> properties) throws Exception {
        if (document == null) {
            JAXBContext jaxbContext = org.eclipse.persistence.jaxb.JAXBContextFactory
                    .createContext(new Class[]{DataBaseStructure.class}, null);
            Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
            jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
            jaxbMarshaller.setProperty(Marshaller.JAXB_ENCODING, "utf-8");
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            document = builder.newDocument();
            jaxbMarshaller.marshal(structure, document);
        }
        String result = getTransformer().transform(document, template, properties);
        return result;
    }

    @Override
    public Transformer getTransformer() {
        return transformer;
    }
}
