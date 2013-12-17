/*
 * Copyright 2013 The Sculptor Project Team, including the original 
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

import static org.sculptor.framework.accessapi.ColumnStatType.AVERAGE;
import static org.sculptor.framework.accessapi.ColumnStatType.COUNT;
import static org.sculptor.framework.accessapi.ColumnStatType.GROUP_BY_DAY;
import static org.sculptor.framework.accessapi.ColumnStatType.GROUP_BY_DOW;
import static org.sculptor.framework.accessapi.ColumnStatType.GROUP_BY_DOY;
import static org.sculptor.framework.accessapi.ColumnStatType.GROUP_BY_HOUR;
import static org.sculptor.framework.accessapi.ColumnStatType.GROUP_BY_MONTH;
import static org.sculptor.framework.accessapi.ColumnStatType.GROUP_BY_QUARTER;
import static org.sculptor.framework.accessapi.ColumnStatType.GROUP_BY_VAL;
import static org.sculptor.framework.accessapi.ColumnStatType.GROUP_BY_WEEK;
import static org.sculptor.framework.accessapi.ColumnStatType.GROUP_BY_YEAR;
import static org.sculptor.framework.accessapi.ColumnStatType.MAX;
import static org.sculptor.framework.accessapi.ColumnStatType.MIN;
import static org.sculptor.framework.accessapi.ColumnStatType.SUM;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.PersistenceException;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projection;
import org.hibernate.criterion.ProjectionList;
import org.hibernate.criterion.Projections;
import org.hibernate.dialect.Dialect;
import org.hibernate.dialect.Oracle10gDialect;
import org.hibernate.dialect.Oracle9iDialect;
import org.hibernate.dialect.PostgreSQL82Dialect;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.hibernate.type.IntegerType;
import org.hibernate.type.Type;
import org.sculptor.framework.accessapi.ColumnStatRequest;
import org.sculptor.framework.accessapi.ColumnStatResult;
import org.sculptor.framework.accessapi.ColumnStatType;
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

	ColumnStatType[] timeGroups = {GROUP_BY_DAY, GROUP_BY_DOW, GROUP_BY_DOY, GROUP_BY_HOUR
			, GROUP_BY_MONTH, GROUP_BY_QUARTER, GROUP_BY_WEEK, GROUP_BY_YEAR};

	private void addStatProjection(Criteria criteria) throws PersistenceException {
		ProjectionList projList = Projections.projectionList();
		projList.add(Projections.rowCount());
		for (ColumnStatRequest<T> column : statRequest) {
			if ( column.isFlag(COUNT)) {
				projList.add(Projections.count(column.getColumn().getName()));
			}
			if ( column.isFlag(MIN) ) {
				projList.add(Projections.min(column.getColumn().getName()));
			}
			if ( column.isFlag(MAX) ) {
				projList.add(Projections.max(column.getColumn().getName()));
			}
			if ( column.isFlag(AVERAGE) ) {
				projList.add(Projections.avg(column.getColumn().getName()));
			}
			if ( column.isFlag(SUM) ) {
				projList.add(Projections.sum(column.getColumn().getName()));
			}
			if ( column.isFlag(GROUP_BY_VAL) ) {
				projList.add(Projections.groupProperty(column.getColumn().getName()));
			}

			// Time groups
			for (ColumnStatType flag : timeGroups) {
				if (column.isFlag(flag)) {
					projList.add(makeTimeGroupBy(column, flag, criteria));
				}
			}
		}

		criteria.setProjection(projList);
	}

	private Type[] timeResultType = new Type[] {new IntegerType()};

	private Projection makeTimeGroupBy(ColumnStatRequest<T> column, ColumnStatType func, Criteria criteria) {
		if (getDialect() instanceof PostgreSQL82Dialect) {
			return makeTimeGroupByPostgreSql(column, func, criteria);
		} else if (getDialect() instanceof Oracle9iDialect || getDialect() instanceof Oracle10gDialect) {
			return makeTimeGroupByOracle(column, func, criteria);
		} else {
			// TODO Add more dialects
			throw new RuntimeException("findByConditionStat "+func.name()+" is supported only on Oracle and PostgreSQL");
		}
	}

	private Projection makeTimeGroupByPostgreSql(ColumnStatRequest<T> column, ColumnStatType statType, Criteria criteria) {
		String func;
		if (statType.equals(GROUP_BY_DAY)) {
			func = "day";
		} else if (statType.equals(GROUP_BY_DOW)) {
			func = "dow";
		} else if (statType.equals(GROUP_BY_DOY)) {
			func = "doy";
		} else if (statType.equals(GROUP_BY_HOUR)) {
			func = "hour";
		} else if (statType.equals(GROUP_BY_MONTH)) {
			func = "month";
		} else if (statType.equals(GROUP_BY_QUARTER)) {
			func = "quarter";
		} else if (statType.equals(GROUP_BY_WEEK)) {
			func = "week";
		} else if (statType.equals(GROUP_BY_YEAR)) {
			func = "year";
		} else {
			func = "day";
		}

		String colName = column.getColumn().getName();
		String fldName = colName + "_"+func;
		String sqlFunc = "extract("+func+" from {alias}." + colName + ")";
		criteria.addOrder(Order.asc(fldName));
		return Projections.alias(Projections.sqlGroupProjection(sqlFunc + " as " + fldName
				, fldName
				, new String[] {fldName}
				, timeResultType)
			, fldName
		);
	}

	private Projection makeTimeGroupByOracle(ColumnStatRequest<T> column, ColumnStatType statType, Criteria criteria) {
		String func;
		if (statType.equals(GROUP_BY_DAY)) {
			func = "DD";
		} else if (statType.equals(GROUP_BY_DOW)) {
			func = "D";
		} else if (statType.equals(GROUP_BY_DOY)) {
			func = "DDD";
		} else if (statType.equals(GROUP_BY_HOUR)) {
			func = "HH24";
		} else if (statType.equals(GROUP_BY_MONTH)) {
			func = "MM";
		} else if (statType.equals(GROUP_BY_QUARTER)) {
			func = "Q";
		} else if (statType.equals(GROUP_BY_WEEK)) {
			func = "WW";
		} else if (statType.equals(GROUP_BY_YEAR)) {
			func = "YYYY";
		} else {
			func = "DD";
		}
		String colName = column.getColumn().getName();
		String fldName = colName + "_"+func;
		String sqlFunc = "to_char({alias}." + colName + ", '" + func + "')";
		criteria.addOrder(Order.asc(fldName));
		return Projections.alias(Projections.sqlGroupProjection(sqlFunc + " as " + fldName
				, fldName
				, new String[] {fldName}
				, timeResultType)
			, fldName
		);
	}

	Dialect resolvedDialect = null;
	private Dialect getDialect() {
		if (resolvedDialect == null) {
			resolvedDialect = ((SessionFactoryImplementor) ((Session) getEntityManager().getDelegate())
					.getSessionFactory()).getDialect();
		}
		return resolvedDialect;
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

			if ( column.isFlag(COUNT) ) {
				columnCount=((Number) colResults[i++]).longValue();
			}
			if ( column.isFlag(MIN) ) {
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
			if ( column.isFlag(MAX) ) {
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
			if ( column.isFlag(AVERAGE) ) {
				avg=(Double) colResults[i++];
			}
			if ( column.isFlag(SUM) ) {
				Object sumResult=colResults[i++];
				sum= sumResult == null ? null : new Double(sumResult.toString());
			}
			if ( column.isFlag(GROUP_BY_VAL) ) {
				Object groupByResult = colResults[i++];
				groupBy=groupByResult != null ? groupByResult.toString() : "";
			}

			ColumnStatResult colStatResult;
			if (min != null || max != null) {
				colStatResult=new ColumnStatResult(column, totalCount, columnCount, min, max, avg, sum, groupBy);
			} else {
				colStatResult=new ColumnStatResult(column, totalCount, columnCount, minString, maxString, avg, sum, groupBy);
			}

			if (column.isFlag(GROUP_BY_DAY)) {
				colStatResult.setGroupByDay(extractInt(colResults[i++]));
			}
			if (column.isFlag(GROUP_BY_DOW)) {
				colStatResult.setGroupByDow(extractInt(colResults[i++]));
			}
			if (column.isFlag(GROUP_BY_DOY)) {
				colStatResult.setGroupByDoy(extractInt(colResults[i++]));
			}
			if (column.isFlag(GROUP_BY_HOUR)) {
				colStatResult.setGroupByHour(extractInt(colResults[i++]));
			}
			if (column.isFlag(GROUP_BY_MONTH)) {
				colStatResult.setGroupByMonth(extractInt(colResults[i++]));
			}
			if (column.isFlag(GROUP_BY_QUARTER)) {
				colStatResult.setGroupByQuarter(extractInt(colResults[i++]));
			}
			if (column.isFlag(GROUP_BY_WEEK)) {
				colStatResult.setGroupByWeek(extractInt(colResults[i++]));
			}
			if (column.isFlag(GROUP_BY_YEAR)) {
				colStatResult.setGroupByYear(extractInt(colResults[i++]));
			}
			result.add(colStatResult);
		}
		return result;
	}

	private Integer extractInt(Object objVal) {
		return objVal != null ? new Integer(objVal.toString()) : 0;
	}

	public void setUseSingleResult(boolean useSingleResult) {
		// It's always using single result
		// Only for compatibility with other generic access methods
	}

}
