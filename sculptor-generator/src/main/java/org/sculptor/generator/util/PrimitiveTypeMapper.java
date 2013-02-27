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

import java.util.HashMap;
import java.util.Map;

/**
 * This class is responsible for mapping of primitive Java types to Object
 * types.
 * 
 */
public class PrimitiveTypeMapper {

	private Map<String, String> primitive2ObjectTypeNameMap = new HashMap<String, String>();

	public PrimitiveTypeMapper() {
		initTypeMap();
	}

	private void initTypeMap() {
		primitive2ObjectTypeNameMap.put("int", "Integer");
		primitive2ObjectTypeNameMap.put("long", "Long");
		primitive2ObjectTypeNameMap.put("float", "Float");
		primitive2ObjectTypeNameMap.put("double", "Double");
		primitive2ObjectTypeNameMap.put("boolean", "Boolean");
	}

	/**
	 * Translate primitive type names (such as int, long, boolean) to Object
	 * type names (such as Integer, Long, Boolean). If the primitive type is not
	 * defined this method will return the primitiveTypeName.
	 */
	public String mapPrimitiveType2ObjectTypeName(String primitiveTypeName) {
		if (primitive2ObjectTypeNameMap.containsKey(primitiveTypeName)) {
			return primitive2ObjectTypeNameMap.get(primitiveTypeName);
		} else {
			return primitiveTypeName;
		}
	}

	public boolean isPrimitiveType(String typeName) {
		return primitive2ObjectTypeNameMap.containsKey(typeName);
	}

}
