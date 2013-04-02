/*
 * Copyright 2009 The Fornax Project Team, including the original
 * author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sculptor.framework.test;

import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.dom4j.Attribute;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

class PersistenceXmlParser {

    private final Set<String> persictenceUnitNames = new HashSet<String>();

    @SuppressWarnings("unchecked")
    void parse(String xml) {
        try {
            Document document = DocumentHelper.parseText(xml);
            Element rootElement = document.getRootElement();

            Iterator<Element> elementIterator = rootElement.elementIterator("persistence-unit");
            while (elementIterator.hasNext()) {
                parsePersistentUnit(elementIterator.next());
            }

        } catch (DocumentException e) {
            throw new RuntimeException(e.getMessage());
        }
    }

    private void parsePersistentUnit(Element persistenceUnitElement) {
        Attribute persistenceUnitNameAttribute = persistenceUnitElement.attribute("name");
        if (persistenceUnitNameAttribute == null) {
            throw new IllegalArgumentException("Invalid persistence.xml, no persistence-unit name");
        }

        persictenceUnitNames.add(persistenceUnitNameAttribute.getText());
    }

    Set<String> getPersictenceUnitNames() {
        return persictenceUnitNames;
    }



}
