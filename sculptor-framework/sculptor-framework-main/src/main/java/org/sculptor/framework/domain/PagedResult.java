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
import java.util.ArrayList;
import java.util.List;

public class PagedResult<T> implements Serializable {
    private static final long serialVersionUID = 4199450784756389139L;

    public static final int UNKNOWN = -1;

    private final List<T> values;
    private final int startRow;
    private final int totalRows;
    private final int additionalResultRows;
    private final int pageSize;

    public PagedResult(List<T> values, int startRow, int rowCount, int pageSize) {
        this(values, startRow, rowCount, pageSize, UNKNOWN, UNKNOWN);
    }

    public PagedResult(List<T> values, int startRow, int rowCount, int pageSize, int totalRows, int additionalResultRows) {
        // Check arguments
        if (values == null) {
            throw new IllegalArgumentException("Result is empty");
        } else if (startRow == UNKNOWN && rowCount == UNKNOWN && pageSize == UNKNOWN && totalRows==UNKNOWN && additionalResultRows==UNKNOWN) {
            // don't check following limits - noLimit paging
        } else if (startRow < 0) {
            throw new IllegalArgumentException("Negative startRow");
        } else if (rowCount < 0) {
            throw new IllegalArgumentException("Negative rowCount");
        }

        // Store values
        if (startRow == UNKNOWN && rowCount == UNKNOWN && pageSize == UNKNOWN && totalRows==UNKNOWN && additionalResultRows==UNKNOWN) {
            this.values = values;
        } else if (values.size() > rowCount) {
            // result of subList is not Serializable
            this.values = new ArrayList<T>(values.subList(0, rowCount));
        } else {
            this.values = values;
        }
        this.startRow = startRow;
        this.pageSize = pageSize > 0 ? pageSize : UNKNOWN;
        this.totalRows = totalRows >= 0 ? totalRows : UNKNOWN;
        this.additionalResultRows = additionalResultRows >= 0 ? additionalResultRows : UNKNOWN;
    }

    // ###########################################
    // # Common methods
    // ###########################################
    public List<T> getValues() {
        return values;
    }

    public boolean isTotalCounted() {
        return totalRows != UNKNOWN;
    }

    public boolean isAddionalResultCounted() {
        return additionalResultRows != UNKNOWN;
    }

    public boolean isPagedResult() {
        return pageSize != UNKNOWN;
    }

    // ###########################################
    // # Row support
    // ###########################################
    public int getStartRow() {
        return startRow;
    }

    public int getEndRow() {
        return startRow + values.size();
    }

    public int getRowCount() {
        return values.size();
    }

    public int getTotalRows() {
        return totalRows;
    }

    public int getAdditionalResultRows() {
        return additionalResultRows;
    }

    // ###########################################
    // # Paging support
    // ###########################################
    public int getPageSize() {
        return pageSize;
    }

    public int getPage() {
        return pageSize > 0 ? (startRow / pageSize) + 1 : UNKNOWN;
    }

    public int getTotalPages() {
        return pageSize > 0 && totalRows >= 0 ? totalRows / pageSize + (totalRows % pageSize > 0 ? 1 : 0) : UNKNOWN;
    }

    public int getAdditionalResultPages() {
        return pageSize > 0 && additionalResultRows >= 0 ? additionalResultRows / pageSize
                + (additionalResultRows % pageSize > 0 ? 1 : 0) : UNKNOWN;
    }
}
