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

package org.sculptor.framework.accessimpl.jpa;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Tuple;
import javax.persistence.TupleElement;
import javax.persistence.metamodel.SingularAttribute;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Utility class for JPA.
 *
 * @author Oliver Ringel
 */
public class JpaHelper {

    private static final Logger log = LoggerFactory.getLogger(JpaHelper.class);

    /**
     * Converts a collection with IN parameters to a plain string representation
     *
     * @param parameters
     *            collection with IN parameters
     * @return plain string representation
     */
    public static String convertToString(Collection<? extends Object> parameters) {
        if (parameters == null || parameters.isEmpty())
            return "";

        StringBuilder result = new StringBuilder();
        for (Object param : parameters) {
            if (param instanceof String)
                param = "'" + param + "'";
            if (result.length() != 0)
                result.append(",");
            result.append(param);
        }

        log.debug("restriction list converted to {}", result);

        return result.toString();
    }

    public static boolean isJpaProviderHibernate(EntityManager entityManager) {
        return entityManager.getDelegate().getClass().getName().toLowerCase().contains("hibernate");
    }

    public static boolean isJpaProviderEclipselink(EntityManager entityManager) {
        return entityManager.getDelegate().getClass().getName().toLowerCase().contains("eclipse");
    }

    public static boolean isJpaProviderOpenJpa(EntityManager entityManager) {
        return entityManager.getDelegate().getClass().getName().toLowerCase().contains("openjpa");
    }

    public static boolean isJpaProviderDataNucleus(EntityManager entityManager) {
        return entityManager.getDelegate().getClass().getName().toLowerCase().contains("datanucleus");
    }

    /**
     * lists all fields of a given class
     *
     * @param clazz type
     * @return
     */
    public static List<Field> listFields(Class<?> clazz) {
    	assert clazz != null;
        Class<?> entityClass = clazz;
        List<Field> list = new ArrayList<Field>();
        while (!Object.class.equals(entityClass) && entityClass != null) {
            list.addAll(Arrays.asList(entityClass.getDeclaredFields()));
            entityClass = entityClass.getSuperclass();
        }
        return list;
    }

    /**
     * tries to find a field by a field name
     *
     * @param clazz type
     * @param name name of the field
     * @return
     */
    public static Field findField(Class<?> clazz, String name) {
        Class<?> entityClass = clazz;
        while (!Object.class.equals(entityClass) && entityClass != null) {
            Field[] fields = entityClass.getDeclaredFields();
            for (Field field : fields) {
                if (name.equals(field.getName())) {
                    return field;
                }
            }
            entityClass = entityClass.getSuperclass();
        }
        return null;
    }

    /**
     * tries to find a property method by name
     *
     * @param clazz type
     * @param name name of the property
     * @return
     */
    public static Method findProperty(Class<?> clazz, String name) {
    	assert clazz != null;
    	assert name != null;
        Class<?> entityClass = clazz;
        while (entityClass != null) {
            Method[] methods = (entityClass.isInterface() ? entityClass.getMethods() : entityClass.getDeclaredMethods());
            for (Method method : methods) {
                if (method.getName().equals("get"+ StringUtils.capitalize(name)) ||
                    method.getName().equals("is"+ StringUtils.capitalize(name))) {
                    return method;
                }
            }
            entityClass = entityClass.getSuperclass();
        }
        return null;
    }

    /**
     * tries to get the value from a field or a getter property for a given object instance
     *
     * @param instance the object instance
     * @param name name of the property or field
     * @return
     * @throws IllegalArgumentException
     * @throws IllegalAccessException
     * @throws InvocationTargetException
     */
    public static Object getValue(Object instance, String name) {
        assert instance != null;
        assert name != null;
        try {
            Class<?> clazz = instance.getClass();
            Object value = null;
            Method property = findProperty(clazz, name);
            if (property != null) {
            	value = property.invoke(instance);
            }
            else {
                Field field = findField(clazz, name);
                if (field != null) {
                    value = field.get(instance);
                }
            }
            log.debug("Value for field/property '{}' is: '{}'", name, value);
            return value;
        }
        catch (Exception e) {
            log.error("Could not get a value for field/property '" + name + "'", e);
            return null;
        }
    }

    public static void setValue(Object instance, String name) {
        assert instance != null;
        assert name != null;
        try {
            Class<?> clazz = instance.getClass();
            Object value = null;
            Method property = findProperty(clazz, name);
            if (property != null) {
            	value = property.invoke(instance);
            }
            else {
                Field field = findField(clazz, name);
                if (field != null) {
                    value = field.get(instance);
                }
            }
            log.debug("Value for field/property '{}' is: '{}'", name, value);
        }
        catch (Exception e) {
            log.error("Could not get a value for field/property '" + name + "'", e);
        }
    }

    @SuppressWarnings({ "rawtypes" })
    public static Object getValue(Object entity, SingularAttribute attribute) {
        try {
            return getValue(entity, attribute.getName());
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * get a named query from an entity
     *
     * @param type
     * @param name
     * @return
     */
    public static NamedQuery findNamedQuery(Class<?> type, String name)
    {
        NamedQuery annotatedNamedQuery = (NamedQuery) type.getAnnotation(NamedQuery.class);
        if (annotatedNamedQuery != null) {
            return annotatedNamedQuery;
        }

        NamedQueries annotatedNamedQueries = (NamedQueries) type.getAnnotation(NamedQueries.class);
        if (annotatedNamedQueries != null) {
            NamedQuery[] namedQueries = annotatedNamedQueries.value();
            if (namedQueries != null) {
                for (NamedQuery namedQuery : namedQueries) {
                    if (namedQuery.name().equalsIgnoreCase(name)) {
                        return namedQuery;
                    }
                }
            }
        }
        // no named query with that name
        log.debug("No NamedQuery with name '{}' exists for type '{}'", name, type);
        return null;
    }

    /**
     * Build a query based on the original query to count results
     *
     * @param query
     * @return
     */
    public static String createResultCountQuery(String query) {
        String resultCountQueryString = null;

        int select = query.toLowerCase().indexOf("select");
        int from = query.toLowerCase().indexOf("from");
        if (select == -1 || from == -1) {
            return null;
        }

        resultCountQueryString = "select count(" + query.substring(select + 6, from).trim() + ") " + query.substring(from);

        // remove order by
        // TODO: remove more parts
        if (resultCountQueryString.toLowerCase().contains("order by")) {
            resultCountQueryString = resultCountQueryString.substring(0, resultCountQueryString.toLowerCase().indexOf("order by"));
        }

        log.debug("Created query for counting results '{}'", resultCountQueryString);
        return resultCountQueryString;
    }

    /**
     * build a single String from a List of objects with a given separator
     *
     * @param values
     * @param separator
     * @return
     */
    public static String toSeparatedString(List<?> values, String separator) {
    	return toSeparatedString(values, separator, null);
    }

    /**
     * build a single String from a List of objects with a given separator and prefix
     *
     * @param values
     * @param separator
     * @param prefix
     * @return
     */
    public static String toSeparatedString(List<?> values, String separator, String prefix) {
        StringBuilder result = new StringBuilder();
        for (Object each : values) {
            if (each == null) {
                continue;
            }
            if (result.length() > 0) {
                result.append(separator);
            }
            if (prefix != null) {
                result.append(String.valueOf(each));
            } else {
                result.append(prefix + String.valueOf(each));
            }
        }
        return result.toString();
    }

	/**
	 *
	 * @param <T>
	 * @param tuple
	 * @param object
	 * @return
	 */
	public static <T> T mapTupleToObject(Tuple tuple, T object)
			throws IllegalAccessException, InvocationTargetException {
		assert tuple != null;
		assert object != null;
		try {
			for (TupleElement<?> element : tuple.getElements()) {
				if (element.getAlias() != null) {
					BeanUtils.setProperty(
							object, element.getAlias(), tuple.get(element.getAlias()));
				}
			}
			return object;
		} catch (Exception e) {
			log.error("mapTupleToObject not successful", e);
			throw new QueryConfigException("mapTupleToObject not successful");
		}
	}

	/**
	 *
	 * @param <T>
	 * @param tuple
	 * @param type
	 * @return
	 */
	public static <T> T mapTupleToObject(Tuple tuple, Class<T> type) {
		assert tuple != null;
		assert type != null;
		try {
			return mapTupleToObject(tuple, type.newInstance());
		} catch (Exception e) {
			log.error("mapTupleToObject not successful", e);
			throw new QueryConfigException("mapTupleToObject not successful");
		}
	}
}
