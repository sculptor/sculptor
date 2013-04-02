/*
 * Copyright 2009 The Fornax Project Team, including the original
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

package org.sculptor.framework.accessimpl.jpahibernate;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.PersistenceException;

import org.hibernate.Criteria;
import org.hibernate.criterion.ProjectionList;
import org.hibernate.criterion.Projections;
import org.sculptor.framework.accessapi.ColumnStatRequest;
import org.sculptor.framework.accessapi.ColumnStatResult;
import org.sculptor.framework.accessapi.FindByConditionStatAccess;

/**
 * <p>
 * Implementation of Access command FindByCriteriaAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaHibFindByConditionStatAccessImpl<T> extends JpaHibFindByConditionAccessImpl<T>
		implements FindByConditionStatAccess<T> {
	private List<ColumnStatRequest<T>> statRequest;
	private List<List<ColumnStatResult>> statResult=new ArrayList<List<ColumnStatResult>>();

	
	public JpaHibFindByConditionStatAccessImpl(Class<T> persistentClass) {
		super(persistentClass);
	}

	public void setColumnStat(List<ColumnStatRequest<T>> columnStat) {
		statRequest=columnStat;
	}

	@Override
	public void execute() throws PersistenceException {
		Criteria criteria = createCriteria();
		prepareCache(criteria);

		// Prepare where clause
		addSubCriterias(criteria);
		addConditionalCriteria(criteria);

		addResultTransformer(criteria);

		addStatProjection(criteria);

		@SuppressWarnings("unchecked")
		List<Object[]> uniqResult = (List<Object[]>) criteria.list();
		extractStatResult(uniqResult);
	}

	public List<List<ColumnStatResult>> getSingleResult() {
		return this.statResult;
	}

	private void addStatProjection(Criteria criteria) throws PersistenceException {
		ProjectionList projList = Projections.projectionList();
		projList.add(Projections.rowCount());
		for (ColumnStatRequest<T> column : statRequest) {
			if ( column.isCountNotNullFlag()) {
				projList.add(Projections.count(column.getColumn().getName()));
			}
			if ( column.isMinFlag() ) {
				projList.add(Projections.min(column.getColumn().getName()));
			}
			if ( column.isMaxFlag() ) {
				projList.add(Projections.max(column.getColumn().getName()));
			}
			if ( column.isAverageFlag() ) {
				projList.add(Projections.avg(column.getColumn().getName()));
			}
			if ( column.isSumFlag() ) {
				projList.add(Projections.sum(column.getColumn().getName()));
			}
			if ( column.isGroupByFlag() ) {
				projList.add(Projections.groupProperty(column.getColumn().getName()));
			}
		}

		criteria.setProjection(projList);
	}

	private void extractStatResult(List<Object[]> colResults) {
		for (Object[] colResult : colResults) {
			statResult.add(extractSingleRowStatResult(colResult));
		}
	}

	private List<ColumnStatResult> extractSingleRowStatResult(Object[] colResults) {
		Long totalCount=((Number) colResults[0]).longValue();
		int i=1;
		List<ColumnStatResult> result = new ArrayList<ColumnStatResult>();
		for (ColumnStatRequest<T> column : statRequest) {
			Long columnCount=null;
			Double min=null;
			Double max=null;
			Double avg=null;
			Double sum=null;
			String minString=null;
			String maxString=null;
			String groupBy=null;

			if ( column.isCountNotNullFlag() ) {
				columnCount=((Number) colResults[i++]).longValue();
			}
			if ( column.isMinFlag() ) {
				Object minResult = colResults[i++];
				if (minResult == null) {
					min=null;
					minString=null;
				} else if (minResult instanceof Number) {
					min=((Number) minResult).doubleValue();
					minString=min.toString();
				} else {
					min=null;
					minString=minResult.toString();
				}
			}
			if ( column.isMaxFlag() ) {
				Object maxResult = colResults[i++];
				if (maxResult == null) {
					max=null;
					maxString=null;
				} else if (maxResult instanceof Number) {
					max=((Number) maxResult).doubleValue();
					maxString=max.toString();
				} else {
					max=null;
					maxString=maxResult.toString();
				}
			}
			if ( column.isAverageFlag() ) {
				avg=(Double) colResults[i++];
			}
			if ( column.isSumFlag() ) {
				Object sumResult=colResults[i++];
				sum= sumResult == null ? null : new Double(sumResult.toString());
			}
			if ( column.isGroupByFlag() ) {
				Object groupByResult = colResults[i++];
				groupBy=groupByResult != null ? groupByResult.toString() : "";
			}

			ColumnStatResult colStatResult;
			if ( column.isGroupByFlag() ) {
				colStatResult=new ColumnStatResult(column, groupBy);
			} else if (min != null || max != null) {
				colStatResult=new ColumnStatResult(column, totalCount, columnCount, min, max, avg, sum);
			} else {
				colStatResult=new ColumnStatResult(column, totalCount, columnCount, minString, maxString, avg, sum);
			}
			result.add(colStatResult);
		}
		return result;
	}

	public void setUseSingleResult(boolean useSingleResult) {
		// It's always using single result
		// Only for compatibility with other generic access methods
	}

}
