package org.sculptor.framework.domain;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.sculptor.framework.domain.PagedResult;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class PagedResultTest {

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

    @ParameterizedTest
    @MethodSource("data")
    void testPagedResult(int startRow, int rowCount, int pageSize, int totalRows, int additionalResultRows,
            int expectedPage, int expectedTotalPages, int expectedAdditionalResultPages) {
        PagedResult<Object> pagedResult = new PagedResult<Object>(new ArrayList<Object>(), startRow, rowCount, pageSize, totalRows,
                additionalResultRows);

        assertEquals(expectedPage, pagedResult.getPage(), "Page wrong calculated");
        assertEquals(expectedTotalPages, pagedResult.getTotalPages(), "TotalPages wrong calculated");
        assertEquals(expectedAdditionalResultPages, pagedResult.getAdditionalResultPages(), "AdditionalResultPages wrong calculated");
    }
}
