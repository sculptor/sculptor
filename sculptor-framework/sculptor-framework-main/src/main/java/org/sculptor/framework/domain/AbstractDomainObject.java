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

package org.sculptor.framework.domain;

import java.io.Serializable;
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.lang3.builder.ReflectionToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;

/**
 * Base class for all Domain Objects. It provides stuff like toString, equals
 * and hashCode.
 * 
 */
public abstract class AbstractDomainObject implements Serializable, Cloneable {
    private static final long serialVersionUID = -7580523094174795539L;

    // acceptedToStringTypes contains Class objects accepted by toString
    private static Set<Object> acceptedToStringTypes = new HashSet<Object>();
    static {
        acceptedToStringTypes.add(int.class);
        acceptedToStringTypes.add(Integer.class);
        acceptedToStringTypes.add(long.class);
        acceptedToStringTypes.add(Long.class);
        acceptedToStringTypes.add(double.class);
        acceptedToStringTypes.add(Double.class);
        acceptedToStringTypes.add(BigDecimal.class);
        acceptedToStringTypes.add(boolean.class);
        acceptedToStringTypes.add(Boolean.class);
        acceptedToStringTypes.add(String.class);
        acceptedToStringTypes.add(Date.class);
        acceptedToStringTypes.add(LocalDate.class);
        acceptedToStringTypes.add(LocalDateTime.class);
        acceptedToStringTypes.add(LocalTime.class);
        acceptedToStringTypes.add(float.class);
        acceptedToStringTypes.add(Float.class);
        acceptedToStringTypes.add(short.class);
        acceptedToStringTypes.add(Short.class);
        // avoid runtime dependency to joda, since it is optional
        try {
            Class.forName("org.joda.time.LocalDate");
            acceptedToStringTypes.add(Class.forName("org.joda.time.LocalDate"));
            acceptedToStringTypes.add(Class.forName("org.joda.time.LocalTime"));
            acceptedToStringTypes.add(Class.forName("org.joda.time.LocalDateTime"));
            acceptedToStringTypes.add(Class.forName("org.joda.time.DateTime"));
        } catch (ClassNotFoundException e) {
            // Joda time library not available on classpath -> IGNORE
        }
    }

    /**
     * Only "simple" types will be included in toString. Relations to other
     * domain objects can not be included since we don't know if they are
     * fetched and we don't wont toString to fetch them.
     * <p>
     * More intelligent implementation can be done in subclasses if needed.
     * Subclasses may also override {@link #acceptToString(Field)}.
     * <p>
     * The
     */
    @Override
    public String toString() {
        try {
            ReflectionToStringBuilder builder = new ReflectionToStringBuilder(this, toStringStyle()) {
                @Override
                protected boolean accept(Field f) {
                    if (super.accept(f)) {
                        return acceptToString(f);
                    } else {
                        return false;
                    }
                }
            };
            builder.setAppendStatics(false);
            builder.setAppendTransients(true);
            return builder.toString();
        } catch (RuntimeException e) {
            // toString is only used for debug purpose and
            // eventual exceptions should not be "ignored"
            return "RuntimeException in " + getClass().getName() + ".toString():" + e.getMessage();
        }
    }

    /**
     * Subclass may override to define the style to use for toString, e.g.
     * ToStringStyle.SHORT_PREFIX_STYLE.
     */
    protected ToStringStyle toStringStyle() {
        return null;
    }

    /**
     * Subclasses may override this method to include or exclude some properties
     * in toString. By default only "simple" types will be included in toString.
     * Relations to other domain objects can not be included since we don't know
     * if they are fetched and we don't wont toString to fetch them.
     * 
     * @param field
     *            the field to include in toString if this method returns true
     * @return true to include the field in toString, or false to exclude it
     */
    protected boolean acceptToString(Field field) {
        return acceptedToStringTypes.contains(field.getType());
    }

    /**
     * Subclass will typically override this method and return the real natural
     * key or UUID key. If it is not overridden this default implementation
     * returns null, which means that equals and hashCode will be implemented by
     * java.lang.Object (if those methods are not overridden in subclass).
     */
    protected Object getKey() {
        return null;
    }

    @Override
    public boolean equals(Object obj) {
        if (getKey() == null) {
            return super.equals(obj);
        }
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }

        if (!isSameClassHierarchy(obj.getClass())) {
            return false;
        }

        AbstractDomainObject other = (AbstractDomainObject) obj;

        Object key = getKey();
        if (key instanceof BigDecimal) {
            return ((BigDecimal) key).compareTo((BigDecimal) other.getKey()) == 0;
        }

        return key.equals(other.getKey());
    }

    protected boolean isSameClassHierarchy(Class<?> otherClass) {
        Class<?> clz = getClass();
        if (clz == otherClass) {
            return true;
        }
        Class<?> potentialRoot;
        do {
            potentialRoot = clz;
            clz = clz.getSuperclass();
        } while (clz != AbstractDomainObject.class);

        return potentialRoot.isAssignableFrom(otherClass);
    }

    @Override
    public int hashCode() {
        if (getKey() == null) {
            return super.hashCode();
        }
        return getKey().hashCode();
    }

    @Override
    public Object clone() {
        try {
            return super.clone();
        } catch (CloneNotSupportedException e) {
            // this shouldn't happen, since we are Cloneable
            throw new InternalError();
        }
    }

}
