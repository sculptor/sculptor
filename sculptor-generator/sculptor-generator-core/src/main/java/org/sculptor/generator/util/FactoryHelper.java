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

package org.sculptor.generator.util;

import java.lang.reflect.Constructor;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Utility class for creating Objects from properies (Strings).
 * 
 * @author Patrik Nordwall
 */
public class FactoryHelper {

	private static final Logger LOG = LoggerFactory.getLogger(FactoryHelper.class);

	private FactoryHelper() {
	}

	/**
	 * Creates an instance from a String class name.
	 * @param genericAccessObjectManager 
	 * 
	 * @param className
	 *            full class name
	 * @param classLoader
	 *            the class will be loaded with this ClassLoader
	 * @return new instance of the class
	 * @throws RuntimeException
	 *             if class not found or could not be instantiated
	 */
	public static Object newInstanceFromName(Object enclosingObject, String className) {
		return newInstanceFromName(enclosingObject, className, FactoryHelper.class.getClassLoader());
	}

	/**
	 * Creates an instance from a String class name.
	 * 
	 * @param className
	 *            full class name
	 * @param classLoader
	 *            the class will be loaded with this ClassLoader
	 * @return new instance of the class
	 * @throws RuntimeException
	 *             if class not found or could not be instantiated
	 */
	public static Object newInstanceFromName(Object enclosingObject, String className, ClassLoader classLoader) {
		try {
			Class<?> clazz = Class.forName(className, false, classLoader);
			for (Constructor<?> c : clazz.getConstructors()) {
				Class<?>[] parameterTypes = c.getParameterTypes();
				if (parameterTypes.length == 0) {
					return c.newInstance();
				} else if (parameterTypes.length == 1 && enclosingObject != null && parameterTypes[0].equals(enclosingObject.getClass())) {
					return c.newInstance(enclosingObject);
				}
			}
			return clazz.newInstance();
		} catch (Exception e) {
			String m = "Couldn't create instance from name " + className + " (" + e.getMessage() + ")";
			LOG.error(m, e);
			throw new RuntimeException(m);
		}
	}
}
