package ru.cninnov.generator.utils;

import lombok.extern.slf4j.Slf4j;
import org.apache.commons.math3.util.CombinatoricsUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;

@Slf4j
public class NodeUtils {

    public static NodeList combi(NodeList source) {
        log.debug("Parameter: {}", source.getClass().getName());
        NodeList result = null;
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.newDocument();

            //Document doc = source.item(0).getOwnerDocument();
            Element target = doc.createElement("combinations");
            doc.appendChild(target);
            log.debug("Source length: {}", source.getLength());
            List<int[]> combinations = new ArrayList<>();
            for (int i = source.getLength() - 1; i >= 0; i--) {
                combinations.addAll(generate(source.getLength(), i + 1));
            }
            for(int[] indexes: combinations) {
                Element combination = doc.createElement("combination");
                target.appendChild(combination);
                for (int i = 0; i < indexes.length; i++) {
                    combination.appendChild(doc.importNode(source.item(indexes[i]), true));
                }
            }
            result = target.getChildNodes();
            log.debug("Result length: {}", result.getLength());
        } catch (Exception e) {
            log.info("Error!", e);
        }
        return result;
    }

    public static List<int[]> generate(int n, int r) {
        List<int[]> result = new ArrayList<>();
        Iterator<int[]> iterator = CombinatoricsUtils.combinationsIterator(n, r);
        while (iterator.hasNext()) {
            final int[] combination = iterator.next();
            //System.out.println(Arrays.toString(combination));
            result.add(combination);
        }
        return result;
    }

}
