/*
 * Copyright 2010 The Fornax Project Team, including the original
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

package org.sculptor.framework.accessimpl.mongodb;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.beanutils.PropertyUtils;
import org.sculptor.framework.accessapi.FindByKeysAccess;

/**
 * <p>
 * Find all entities with matching keys. Implementation of Access command
 * FindByKeysAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class MongoDbFindByKeysAccessImpl<T> extends MongoDbAccessBase<T>
		implements FindByKeysAccess<T> {

	private String keyPropertyName;
	private String restrictionPropertyName;
	private Set<?> keys;
	private Map<Object, T> result;

	public MongoDbFindByKeysAccessImpl(Class<T> persistentClass) {
		setPersistentClass(persistentClass);
	}

	protected String getKeyPropertyName() {
		return keyPropertyName;
	}

	public void setKeyPropertyName(String keyPropertyName) {
		this.keyPropertyName = keyPropertyName;
	}

	protected String getRestrictionPropertyName() {
		if (restrictionPropertyName == null) {
			return getKeyPropertyName();
		} else {
			return restrictionPropertyName;
		}
	}

	public void setRestrictionPropertyName(String restrictionPropertyName) {
		this.restrictionPropertyName = restrictionPropertyName;
	}

	protected String getRestrictionValuePropertyName() {
		if (restrictionPropertyName == null) {
			return null;
		} else if (restrictionPropertyName.startsWith(getKeyPropertyName()
				+ ".")) {
			return restrictionPropertyName.substring(getKeyPropertyName()
					.length() + 1);
		} else {
			return restrictionPropertyName;
		}
	}

	public void setKeys(Set<?> keys) {
		this.keys = keys;
	}

	@Override
	public void setPersistentClass(Class<? extends T> persistentClass) {
		super.setPersistentClass(persistentClass);
	}

	public Map<Object, T> getResult() {
		return this.result;
	}

	@Override
	public void performExecute() {
		MongoDbChunkFetcher<T, Object> chunkFetcher = new MongoDbChunkFetcher<T, Object>(
				getDBCollection(), getDataMapper(),
				getRestrictionPropertyName()) {
			@Override
			protected Object key(T obj) {
				try {
					return PropertyUtils.getProperty(obj, getKeyPropertyName());
				} catch (Exception e) {
					throw new IllegalArgumentException("Invalid property: "
							+ getKeyPropertyName());
				}
			}

			@Override
			protected Collection<Object> restrictionPropertyValues(
					Collection<Object> keys) {
				if (getRestrictionValuePropertyName() == null) {
					Collection<Object> values = super
							.restrictionPropertyValues(keys);
					List<Object> dbValues = new ArrayList<Object>();
					for (Object each : values) {
						dbValues.add(toData(each));
					}
					return dbValues;
				} else {
					try {
						List<Object> values = new ArrayList<Object>();
						for (Object k : keys) {
							Object restrictionValue = PropertyUtils
									.getProperty(k,
											getRestrictionValuePropertyName());
							Object dbValue = toData(restrictionValue);
							values.add(dbValue);
						}
						return values;
					} catch (Exception e) {
						throw new IllegalArgumentException("Invalid property: "
								+ getRestrictionValuePropertyName());
					}
				}
			}
		};

		this.result = chunkFetcher.getDomainObjects(keys);
	}

}