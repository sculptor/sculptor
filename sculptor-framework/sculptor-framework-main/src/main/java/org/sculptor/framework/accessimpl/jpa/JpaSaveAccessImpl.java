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

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.persistence.PersistenceException;

import org.sculptor.framework.accessapi.SaveAccess;

/**
 * <p>
 * Save an entity. Implementation of Access command for Update.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaSaveAccessImpl<T> extends JpaAccessBase<T> implements SaveAccess<T> {

	private T entity;
	private T result;
	private Collection<T> entities;

	public JpaSaveAccessImpl() {
	}

	public JpaSaveAccessImpl(Class<T> persistentClass) {
		setPersistentClass(persistentClass);
	}

	public T getEntity() {
		return entity;
	}

	public void setEntity(T entity) {
		this.entity = entity;
	}

	public Collection<T> getEntities() {
		return entities;
	}

	public void setEntities(Collection<T> entities) {
		this.entities = entities;
	}

	public T getResult() {
		return result;
	}

	@Override
	public void performExecute() throws PersistenceException {
		if (entity != null) {
			result = performMerge(entity);
		}
		if (entities != null) {
			List<T> newInstances = new ArrayList<T>();
			for (T each : getEntities()) {
				newInstances.add(performMerge(each));
			}
			setEntities(newInstances);
		}
	}

	protected T performMerge(T obj) {
		if (getEntityManager().contains(obj)) {
			return obj;
		} else {
			return getEntityManager().merge(obj);
		}
	}

}