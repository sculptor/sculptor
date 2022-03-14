package org.sculptor.framework.domain;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class PagingParameterTest {

	@Test
	void testRowAccess() {
		PagingParameter rowAccess = PagingParameter.rowAccess(12, 19);
		assertEquals(12, rowAccess.getStartRow());
		assertEquals(19, rowAccess.getEndRow());
		assertEquals(7, rowAccess.getRowCount());
		assertEquals(7, rowAccess.getRealFetchCount());
		assertEquals(PagingParameter.UNKNOWN, rowAccess.getPage());
		assertEquals(PagingParameter.UNKNOWN, rowAccess.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, rowAccess.getAdditionalResultPages());

		rowAccess = PagingParameter.rowAccess(34, 88, true);
		assertEquals(34, rowAccess.getStartRow());
		assertEquals(88, rowAccess.getEndRow());
		assertEquals(54, rowAccess.getRowCount());
		assertEquals(54, rowAccess.getRealFetchCount());
		assertEquals(PagingParameter.UNKNOWN, rowAccess.getPage());
		assertEquals(PagingParameter.UNKNOWN, rowAccess.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, rowAccess.getAdditionalResultPages());

		rowAccess = PagingParameter.rowAccess(23, 33, true, 8);
		assertEquals(23, rowAccess.getStartRow());
		assertEquals(33, rowAccess.getEndRow());
		assertEquals(10, rowAccess.getRowCount());
		assertEquals(18, rowAccess.getRealFetchCount());
		assertEquals(PagingParameter.UNKNOWN, rowAccess.getPage());
		assertEquals(PagingParameter.UNKNOWN, rowAccess.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, rowAccess.getAdditionalResultPages());
	}

	@Test
	void testPageAccess() {
		PagingParameter pageAccess = PagingParameter.pageAccess(9);
		assertEquals(0, pageAccess.getStartRow());
		assertEquals(9, pageAccess.getEndRow());
		assertEquals(9, pageAccess.getRowCount());
		assertEquals(9, pageAccess.getRealFetchCount());
		assertEquals(0, pageAccess.getPage());
		assertEquals(9, pageAccess.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, pageAccess.getAdditionalResultPages());

		pageAccess = PagingParameter.pageAccess(6, 3);
		assertEquals(12, pageAccess.getStartRow());
		assertEquals(18, pageAccess.getEndRow());
		assertEquals(6, pageAccess.getRowCount());
		assertEquals(6, pageAccess.getRealFetchCount());
		assertEquals(2, pageAccess.getPage());
		assertEquals(6, pageAccess.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, pageAccess.getAdditionalResultPages());

		pageAccess = PagingParameter.pageAccess(7, 9, 2);
		assertEquals(56, pageAccess.getStartRow());
		assertEquals(63, pageAccess.getEndRow());
		assertEquals(7, pageAccess.getRowCount());
		assertEquals(15, pageAccess.getRealFetchCount());
		assertEquals(8, pageAccess.getPage());
		assertEquals(7, pageAccess.getPageSize());
		assertEquals(2, pageAccess.getAdditionalResultPages());

		pageAccess = PagingParameter.pageAccess(12, 4, true);
		assertEquals(36, pageAccess.getStartRow());
		assertEquals(48, pageAccess.getEndRow());
		assertEquals(12, pageAccess.getRowCount());
		assertEquals(12, pageAccess.getRealFetchCount());
		assertEquals(3, pageAccess.getPage());
		assertEquals(12, pageAccess.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, pageAccess.getAdditionalResultPages());

		pageAccess = PagingParameter.pageAccess(15, 2, true, 3);
		assertEquals(15, pageAccess.getStartRow());
		assertEquals(30, pageAccess.getEndRow());
		assertEquals(15, pageAccess.getRowCount());
		assertEquals(46, pageAccess.getRealFetchCount());
		assertEquals(1, pageAccess.getPage());
		assertEquals(15, pageAccess.getPageSize());
		assertEquals(3, pageAccess.getAdditionalResultPages());
	}

	@Test
	void testFirstAccess() {
		PagingParameter firstRows = PagingParameter.firstRow();
		assertEquals(0, firstRows.getStartRow());
		assertEquals(1, firstRows.getEndRow());
		assertEquals(1, firstRows.getRowCount());
		assertEquals(1, firstRows.getRealFetchCount());
		assertEquals(PagingParameter.UNKNOWN, firstRows.getPage());
		assertEquals(PagingParameter.UNKNOWN, firstRows.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, firstRows.getAdditionalResultPages());

		firstRows = PagingParameter.firstRows(8);
		assertEquals(0, firstRows.getStartRow());
		assertEquals(8, firstRows.getEndRow());
		assertEquals(8, firstRows.getRowCount());
		assertEquals(8, firstRows.getRealFetchCount());
		assertEquals(PagingParameter.UNKNOWN, firstRows.getPage());
		assertEquals(PagingParameter.UNKNOWN, firstRows.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, firstRows.getAdditionalResultPages());
	}

	@Test
	void testNoLimits() {
		PagingParameter noLimits = PagingParameter.noLimits();
		assertEquals(PagingParameter.UNKNOWN, noLimits.getStartRow());
		assertEquals(-2, noLimits.getEndRow());
		assertEquals(PagingParameter.UNKNOWN, noLimits.getRowCount());
		assertEquals(PagingParameter.UNKNOWN, noLimits.getRealFetchCount());
		assertEquals(PagingParameter.UNKNOWN, noLimits.getPage());
		assertEquals(PagingParameter.UNKNOWN, noLimits.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, noLimits.getAdditionalResultPages());
	}

	@Test
	void testInternalLimits() {
		Assertions.assertThrows(IllegalArgumentException.class, () -> {
			PagingParameter.pageAccess(0);
		});

		Assertions.assertThrows(IllegalArgumentException.class, () -> {
			PagingParameter.pageAccess(-1);
		});

		Assertions.assertThrows(IllegalArgumentException.class, () -> {
			PagingParameter.pageAccess(4, 0);
		});

		Assertions.assertThrows(IllegalArgumentException.class, () -> {
			PagingParameter.pageAccess(0, 3);
		});

		Assertions.assertThrows(IllegalArgumentException.class, () -> {
			PagingParameter.pageAccess(5, 8, -1);
		});
	}

	@Test
	void testPagedResult() {
		final PagedResult noPageResult = new PagedResult(new ArrayList(), 9, 12, PagingParameter.UNKNOWN);
		Assertions.assertThrows(IllegalArgumentException.class, () -> {
			PagingParameter.getPage(noPageResult, 3);
		});

		PagedResult pagedResult = new PagedResult(new ArrayList(), 9, 12, 4);
		PagingParameter page = PagingParameter.getPage(pagedResult, 7);
		assertEquals(24, page.getStartRow());
		assertEquals(28, page.getEndRow());
		assertEquals(4, page.getRowCount());
		assertEquals(4, page.getRealFetchCount());
		assertEquals(6, page.getPage());
		assertEquals(4, page.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, page.getAdditionalResultPages());

		pagedResult = new PagedResult(new ArrayList(), 16, 14, 12);
		page = PagingParameter.getPreviousPage(pagedResult);
		assertEquals(4, page.getStartRow());
		assertEquals(16, page.getEndRow());
		assertEquals(12, page.getRowCount());
		assertEquals(12, page.getRealFetchCount());
		assertEquals(0, page.getPage());
		assertEquals(12, page.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, page.getAdditionalResultPages());

		pagedResult = new PagedResult(new ArrayList(), 23, 11, 9);
		page = PagingParameter.getNextPage(pagedResult);
		assertEquals(32, page.getStartRow());
		assertEquals(41, page.getEndRow());
		assertEquals(9, page.getRowCount());
		assertEquals(9, page.getRealFetchCount());
		assertEquals(3, page.getPage());
		assertEquals(9, page.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, page.getAdditionalResultPages());

		pagedResult = new PagedResult(new ArrayList(), 22, 3, 7);
		page = PagingParameter.getFirstPage(pagedResult);
		assertEquals(0, page.getStartRow());
		assertEquals(7, page.getEndRow());
		assertEquals(7, page.getRowCount());
		assertEquals(7, page.getRealFetchCount());
		assertEquals(0, page.getPage());
		assertEquals(7, page.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, page.getAdditionalResultPages());

		pagedResult = new PagedResult(new ArrayList(), 44, 12, 11, 137, 3);
		page = PagingParameter.getLastPage(pagedResult);
		assertEquals(132, page.getStartRow());
		assertEquals(137, page.getEndRow());
		assertEquals(5, page.getRowCount());
		assertEquals(5, page.getRealFetchCount());
		assertEquals(12, page.getPage());
		assertEquals(11, page.getPageSize());
		assertEquals(PagingParameter.UNKNOWN, page.getAdditionalResultPages());
	}
}
