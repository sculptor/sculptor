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

package org.sculptor.framework.accessapi;

import java.util.List;

import javax.persistence.PersistenceException;
import javax.persistence.Tuple;

/**
 * <p>Access command for calculating statistics by condition. The specified
 * {@link #setCondition restrictions} are used to build the restrictions with
 * simple equals conditions.</p>
 * <p>Command design pattern.</p>
 */
public interface FindByConditionStatAccess<T> extends FindByConditionAccess<Tuple>, Cacheable {

	/**
	 * These criteria are used to build complex restrictions which depends on
	 * provided criteria. This criteria are used in conjuction with Restriction.<br>
	 * {@link #addCondition} - add additional condition<br> {@link #setCondition} -
	 * set simple restriction<br> {@link #addCondition} - add additional simple
	 * restriction
	 */
	void setCondition(List<ConditionalCriteria> criteria);

	/**
	 * Add additional complex criteria. For details look to {@link #setCondition}
	 * documentation
	 */
	void addCondition(ConditionalCriteria criteria);

	/**
	 * Add additional column stat
	 */
	void setColumnStat(List<ColumnStatRequest<T>> columnStat);

	/**
	 * Calculate statistics about columns
	 */
	void execute() throws PersistenceException;

	/**
	 * Get result after executeStat
	 */
	List<List<ColumnStatResult>> getColumnStatResult();
}