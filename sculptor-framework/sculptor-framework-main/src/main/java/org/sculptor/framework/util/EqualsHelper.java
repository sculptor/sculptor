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

package org.sculptor.framework.util;

import java.math.BigDecimal;

/**
 * Utility class for comparing two Objects for equality, including null check.
 * 
 * @author Patrik Nordwall
 */
public class EqualsHelper {

    private EqualsHelper() {
    }

    public static boolean equals(Object obj1, Object obj2) {
        if (obj1 == obj2) {
            return true;
        }
        if (obj1 == null) {
            return false;
        }
        if (obj1 instanceof BigDecimal && obj2 instanceof BigDecimal) {
            return ((BigDecimal) obj1).compareTo((BigDecimal) obj2) == 0;
        }

        return obj1.equals(obj2);
    }

    public static int computeHashCode(final Object o) {
        if (null == o) {
            return 19;
        }
        if (o.getClass().isArray()) {
            return 0;
        }
        return o.hashCode();
    }
}
