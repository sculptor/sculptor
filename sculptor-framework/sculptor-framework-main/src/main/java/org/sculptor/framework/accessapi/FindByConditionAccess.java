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

/**
 * <p>Access command for finding objects by condition. The specified
 * {@link #setRestrictions restrictions} are used to build the restrictions with
 * simple equals conditions.</p>
 * <p>Command design pattern.</p>
 */
public interface FindByConditionAccess<T> extends Cacheable, Pageable {

	/**
	 * These criteria are used to build complex restrictions which depends on
	 * provided criteria. This criteria are used in conjuction with Restriction.<br>
	 * {@link #addCriteria} - add additional condition<br> {@link #setRestriction} -
	 * set simple restriction<br> {@link #addRestriction} - add additional simple
	 * restriction
	 */
	void setCondition(List<ConditionalCriteria> criteria);

	/**
	 * Add additional complex criteria. For details look to {@link #setCriteria}
	 * documentation
	 */
	void addCondition(ConditionalCriteria criteria);

	void execute();

	/**
	 * The result of the command.
	 */
	List<T> getResult();

	void executeCount();

	/**
	 * Count of rows
	 */
	Long getResultCount();
}