package org.sculptor.framework.test;

import java.util.Set;

import org.junit.jupiter.api.Test;
import org.sculptor.framework.test.DataHelper;
import org.sculptor.framework.test.PersistenceXmlParser;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class PersistenceXmlParserTest {

    @Test
    public void shouldFindPersistenceUnitName() throws Exception {
        String persistenceXml = DataHelper.content("/persistence-testdata.xml");
        PersistenceXmlParser parser = new PersistenceXmlParser();
        parser.parse(persistenceXml);

        Set<String> unitNames = parser.getPersictenceUnitNames();
        assertTrue(unitNames.contains("UniverseEntityManagerFactory"));
        assertTrue(unitNames.contains("SecondaryEntityManagerFactory"));
        assertEquals(2, unitNames.size());
    }


}
