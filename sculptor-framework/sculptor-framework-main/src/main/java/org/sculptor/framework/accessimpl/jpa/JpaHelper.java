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

import java.util.Collection;

import javax.persistence.EntityManager;

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
}