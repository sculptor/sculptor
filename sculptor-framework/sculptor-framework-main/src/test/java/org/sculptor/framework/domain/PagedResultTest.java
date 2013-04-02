package org.sculptor.framework.domain;

import static org.junit.Assert.assertEquals;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import org.sculptor.framework.domain.PagedResult;

@RunWith(Parameterized.class)
public class PagedResultTest {

    private final PagedResult<Object> pagedResult;
    private final int expectedPage;
    private final int expectedTotalPages;
    private final int expectedAdditionalResultPages;


    @Parameters
    public static Collection<Object[]> data() {
        return Arrays.asList(new Object[][] {
                { 0, 0, 10, 0, 0, 1, 0, 0 },
                { 0, 10, 10, 26, 3, 1, 3, 1 },
                { 1, 10, 10, 26, 3, 1, 3, 1 },
                { 9, 10, 10, 26, 3, 1, 3, 1 },
                { 10, 10, 10, 26, 3, 2, 3, 1 },
                { 10, 10, 10, 30, 3, 2, 3, 1 },
                { 10, 10, 10, 31, 3, 2, 4, 1 }
        });
    }

    public PagedResultTest(int startRow, int rowCount, int pageSize, int totalRows, int additionalResultRows,
            int expectedPage, int expectedTotalPages, int expectedAdditionalResultPages) {
        this.expectedPage = expectedPage;
        this.expectedTotalPages = expectedTotalPages;
        this.expectedAdditionalResultPages = expectedAdditionalResultPages;
        pagedResult = new PagedResult<Object>(new ArrayList<Object>(), startRow, rowCount, pageSize, totalRows,
                additionalResultRows);
    }


    @Test
    public void shouldCalculatePageCorrect() throws Exception {
        assertEquals(expectedPage, pagedResult.getPage());
    }

    @Test
    public void shouldCalculateTotalPagesCorrect() throws Exception {
        assertEquals(expectedTotalPages, pagedResult.getTotalPages());
    }

    @Test
    public void shouldCalculateAdditionalResultPagesCorrect() throws Exception {
        assertEquals(expectedAdditionalResultPages, pagedResult.getAdditionalResultPages());
    }

}
