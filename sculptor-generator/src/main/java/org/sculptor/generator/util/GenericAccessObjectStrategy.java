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

import sculptormetamodel.RepositoryOperation;

public interface GenericAccessObjectStrategy {

	/**
	 * Add default return type and parameters to the operation.
	 * 
	 * @param operation
	 *            the operation to modify
	 */
	public void addDefaultValues(RepositoryOperation operation);

	/**
	 * Specify if the constructor of the AccessObject implementation takes the
	 * class of the persistent object as parameter.
	 */
	public boolean isPersistentClassConstructor();

	/**
	 * Specify the generic type litteral for the AccessObject
	 */
	public String getGenericType(RepositoryOperation op);

}
