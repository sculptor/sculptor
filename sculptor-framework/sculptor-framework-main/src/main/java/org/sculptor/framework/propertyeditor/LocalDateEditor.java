/*
 * Copyright 2007 The Fornax Project Team, including the original
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
package org.sculptor.framework.propertyeditor;

import java.beans.PropertyEditorSupport;

import org.joda.time.LocalDate;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.springframework.util.StringUtils;

/**
 * Custom <tt>PropertyEditorSupport</tt> to convert from <tt>String</tt> to
 * JODA's <tt>LocalDate</tt>.
 *
 * @see <a
 *      href="http://springframework.cvs.sourceforge.net/springframework/spring/src/org/springframework/beans/propertyeditors/CustomDateEditor.java?revision=HEAD&view=markup">Spring's
 *      CustomDateEditor</a>
 * @see <a
 *      href="http://www.springframework.org/docs/reference/beans.html#beans-applicationcontext-customeditors">http://www.springframework.org/docs/reference/beans.html#beans-applicationcontext-customeditors</a>
 * @see <a
 *      href="http://joda-time.sourceforge.net/userguide.html#Standard_Formatters">http://joda-time.sourceforge.net/userguide.html#Standard_Formatters</a>
 */
public class LocalDateEditor extends PropertyEditorSupport {
    private final DateTimeFormatter formatter;
    private final boolean allowEmpty;

    /**
     * Create a new LocalDateEditor instance, using the given format for
     * parsing and rendering.
     *
     * The "allowEmpty" parameter states if an empty String should be allowed
     * for parsing, i.e. get interpreted as null value. Otherwise, an
     * IllegalArgumentException gets thrown in that case.
     *
     * @param dateFormat
     *            DateFormat to use for parsing and rendering
     * @param allowEmpty
     *            if empty strings should be allowed
     */
    public LocalDateEditor(String dateFormat, boolean allowEmpty) {
        this.formatter = DateTimeFormat.forPattern(dateFormat);
        this.allowEmpty = allowEmpty;
    }

    /**
     * Parse the value from the given text, using the specified format.
     */
    public void setAsText(String text) throws IllegalArgumentException {
        if (this.allowEmpty && !StringUtils.hasText(text)) {
            // Treat empty String as null value.
            setValue(null);
        } else {
            setValue(new LocalDate(this.formatter.parseDateTime(text)));
        }
    }

    /**
     * Format the LocalDate as String, using the specified format.
     */
    public String getAsText() {
        LocalDate value = (LocalDate) getValue();
        return (value != null ? value.toString(this.formatter) : "");
    }
}