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

package org.sculptor.framework.domain;

import java.io.Serializable;

public class PagingParameter implements Serializable {
    private static final long serialVersionUID = 3699427660197780892L;

    public static final int UNKNOWN=-1;
    public static final int DEFAULT_PAGE_SIZE = 50;

    private final int startRow;
    private final int rowCount;
    private final boolean countTotal;
    private final int additionalResultRows;
    private final int pageSize;

    // ###########################################
    // # Constructors
    // ###########################################
    public static PagingParameter pageAccess(int pageSize) {
        return pageAccess(pageSize, 1);
    }

    public static PagingParameter pageAccess(int pageSize, int page) {
        return pageAccess(pageSize, page, false);
    }

    public static PagingParameter pageAccess(int pageSize, int page, boolean countTotalPages) {
        return pageAccess(pageSize, page, countTotalPages, 0);
    }

    public static PagingParameter pageAccess(int pageSize, int page, int additionalResultPages) {
        return pageAccess(pageSize, page, false, additionalResultPages);
    }

    public static PagingParameter pageAccess(int pageSize, int page, boolean countTotalPages, int additionalResultPages) {
        if (page < 1) {
            throw new IllegalArgumentException("Page numbers are 1 based");
        }
        if (additionalResultPages < 0) {
            throw new IllegalArgumentException("additionalResultPages min values is 0 (actual " + additionalResultPages + ")");
        }
        int startRow = (page - 1) * pageSize;
        // To ensure N additional pages we need only (N - 1) * pageSize + 1 rows
        int additionalRows=additionalResultPages > 0 ? (additionalResultPages - 1) * pageSize + 1 : UNKNOWN;
        return new PagingParameter(startRow, startRow + pageSize, countTotalPages, additionalRows, pageSize);
    }

    public static PagingParameter rowAccess(int startRow, int endRow) {
        return new PagingParameter(startRow, endRow, false, 0, UNKNOWN);
    }

    public static PagingParameter rowAccess(int startRow, int endRow, boolean countTotalRows) {
        return new PagingParameter(startRow, endRow, countTotalRows, 0, UNKNOWN);
    }

    public static PagingParameter rowAccess(int startRow, int endRow, int additionalResultRows) {
        return new PagingParameter(startRow, endRow, false, additionalResultRows, UNKNOWN);
    }

    public static PagingParameter rowAccess(int startRow, int endRow, boolean countTotalRows, int additionalResultRows) {
        return new PagingParameter(startRow, endRow, countTotalRows, additionalResultRows, UNKNOWN);
    }

    public static PagingParameter firstRow() {
        return new PagingParameter(0, 1, false, 0, UNKNOWN);
    }

    public static PagingParameter firstRows(int numberOfRows) {
        return new PagingParameter(0, numberOfRows, false, 0, UNKNOWN);
    }

    public static PagingParameter noLimits() {
        return new PagingParameter();
    }

    private PagingParameter() {
       this.startRow = UNKNOWN;
       this.rowCount = UNKNOWN;
       this.countTotal = false;
       this.additionalResultRows=UNKNOWN;
       this.pageSize = UNKNOWN;
   }

    private PagingParameter(int startRow, int endRow, boolean countTotal, int additionalResultRows, int pageSize) {
        if (startRow < 0) {
            throw new IllegalArgumentException("startRow must be 0 or possitive number (" + startRow + " < 0)");
        }
        if (endRow < 1) {
            throw new IllegalArgumentException("endRow must be possitive number (" + endRow + " < 1)");
        }
        if (startRow >= endRow) {
            throw new IllegalArgumentException("startRow must be less than endRow (" + startRow + " >= " + endRow + "");
        }

        this.startRow = startRow;
        this.rowCount = endRow - startRow;
        this.countTotal = countTotal;
        this.additionalResultRows=additionalResultRows > 0 ? additionalResultRows : UNKNOWN;
        this.pageSize = pageSize > 0 ? pageSize : UNKNOWN;
    }

    // ###########################################
    // # Paging methods
    // ###########################################
    public boolean isPagedParameter() {
        return pageSize != UNKNOWN;
    }

    public int getPage() {
        return pageSize != UNKNOWN ? startRow / pageSize : UNKNOWN;
    }

    /**
     * Number of results (rows) per page
     */
    public int getPageSize() {
        return pageSize;
    }

    public int getAdditionalResultPages() {
        return pageSize > 0 && additionalResultRows >= 0
            ? additionalResultRows / pageSize + (additionalResultRows % pageSize > 0 ? 1 : 0)
            : UNKNOWN;
    }

    public boolean isCountTotal() {
        return countTotal;
    }

    public static PagingParameter getNextPage(PagedResult<?> result) {
        if (! result.isPagedResult()) {
            throw new IllegalArgumentException("Is not paged result");
        }
        // TODO be more clever, look to getAdditionalPages or getTotalPages and if exceeded don't increment
        // TODO cache total count, countTotal set to false but remember real count from previous result
        int pageSize=result.getPageSize();
        int startRow=result.getStartRow() + result.getPageSize();
        return new PagingParameter(startRow, startRow + pageSize, false, result.getAdditionalResultPages(), pageSize);
    }

    public static PagingParameter getPreviousPage(PagedResult<?> result) {
        if (! result.isPagedResult()) {
            throw new IllegalArgumentException("Is not paged result");
        }
        int pageSize=result.getPageSize();
        int startRow=result.getStartRow() - result.getPageSize();
        startRow=startRow < 0 ? 0 : startRow;
        return new PagingParameter(startRow, startRow + pageSize, false, result.getAdditionalResultPages(), pageSize);
    }

    public static PagingParameter getFirstPage(PagedResult<?> result) {
        if (! result.isPagedResult()) {
            throw new IllegalArgumentException("Is not paged result");
        }
        return new PagingParameter(0, result.getPageSize(), false, result.getAdditionalResultPages(), result.getPageSize());
    }

    public static PagingParameter getLastPage(PagedResult<?> result) {
       if (! result.isPagedResult()) {
          throw new IllegalArgumentException("Is not paged result");
       }
       if (result.getTotalPages() == UNKNOWN) {
          throw new IllegalArgumentException("Unknown total pages - PagingParameter need countTotalPages=true");
       }
       int startRow=result.getTotalPages() * result.getPageSize() - result.getPageSize();
       int endRow=result.getTotalRows();
       return new PagingParameter(startRow, endRow, false, 0, result.getPageSize());
    }

    public static PagingParameter getPage(PagedResult<?> result, int pageNumber) {
        if (! result.isPagedResult()) {
            throw new IllegalArgumentException("Is not paged result");
        }
        int pageSize=result.getPageSize();
        int startRow=pageNumber * pageSize - result.getPageSize();
        return new PagingParameter(startRow, startRow + pageSize, false, result.getAdditionalResultPages(), pageSize);
    }

    // ###########################################
    // # Row access methods
    // ###########################################
    /**
     * The position of the first result (row) to retrieve, numbered from 0.
     */
    public int getStartRow() {
        return startRow;
    }

    /**
     * The position of the end row to retrieve, numbered from 0 and exclusive.
     */
    public int getEndRow() {
        return startRow + rowCount;
    }

    /**
     * Number of fetched rows
     */
    public int getRowCount() {
        return rowCount;
    }

    /**
     * Number of really fetched rows including additionalResult Rows/Pages
     */
    public int getRealFetchCount() {
        return rowCount + (additionalResultRows > 0 ? additionalResultRows : 0);
    }

    public int getAdditionalResultRows() {
        return additionalResultRows;
    }
}
