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

import java.util.Arrays;
import java.util.List;

import javax.persistence.criteria.Predicate;

import org.sculptor.framework.accessapi.FindByExampleAccess2;

/**
 * <p>
 * Find all entities similar to another entity. Implementation of Access command
 * FindByExampleAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByExampleAccessImplGeneric<T, R> extends JpaCriteriaQueryAccessBase<T, R> implements
		FindByExampleAccess2<T, R> {

	private T exampleInstance;

	public JpaFindByExampleAccessImplGeneric() {
		super();
	}

	public JpaFindByExampleAccessImplGeneric(Class<T> type) {
		super(type);
	}

	public JpaFindByExampleAccessImplGeneric(Class<T> type, Class<R> resultType) {
		super(type, resultType);
	}

	public T getExample() {
		return exampleInstance;
	}

	public void setExample(T example) {
		this.exampleInstance = example;
	}

	public String[] getExcludeProperties() {
		return (String[]) getConfig().getExcludeProperties().toArray();
	}

	public void setExcludeProperties(String[] excludeProperties) {
		getConfig().setExcludeProperties(Arrays.asList(excludeProperties));
	}

	public List<R> getResult() {
		return getListResult();
	}

	@Override
	protected List<Predicate> preparePredicates() {
		return preparePredicates(exampleInstance);
	}

}