package org.sculptor.dddsample.routing.serviceapi;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.sculptor.dddsample.routing.domain.TransitPath;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

import static org.junit.jupiter.api.Assertions.assertFalse;

/**
 * Spring based transactional test with DbUnit support.
 */
public class GraphTraversalServiceTest extends AbstractDbUnitJpaTests implements GraphTraversalServiceTestBase {
    private GraphTraversalService graphTraversalService;

    @Autowired
    public void setGraphTraversalService(GraphTraversalService graphTraversalService) {
        this.graphTraversalService = graphTraversalService;
    }

    @Override
    protected String getDataSetFile() {
        return "dbunit/TestData.xml";
    }

    @Test
    public void testFindShortestPath() throws Exception {
        List<TransitPath> paths = graphTraversalService.findShortestPath(getServiceContext(), "SESTO", "FIHEL");
        assertFalse(paths.isEmpty());
    }
}
