package org.sculptor.framework.accessimpl.jpa;

import org.sculptor.framework.accessapi.ColumnStatRequest;
import org.sculptor.framework.accessapi.ColumnStatResult;
import org.sculptor.framework.accessapi.ColumnStatType;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.ConditionalCriteriaBuilder;
import org.sculptor.framework.accessapi.FindByConditionStatAccess;

import javax.persistence.Tuple;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by tavoda on 10/27/16.
 */
public class JpaFindByConditionStatAccessImpl<T> extends JpaFindByConditionAccessImplGeneric<T, Tuple> implements FindByConditionStatAccess<T> {
	private List<ColumnStatRequest<T>> columnStatRequest;
	private List<List<ColumnStatResult>> columnStatResult;

	public JpaFindByConditionStatAccessImpl(Class<T> clazz) {
		super(clazz, Tuple.class);
	}

	@Override
	public void setColumnStat(List<ColumnStatRequest<T>> columnStat) {
		columnStatRequest = columnStat;
		@SuppressWarnings("unchecked")
		ConditionalCriteriaBuilder.ConditionRoot<T> criteriaBuilder = (ConditionalCriteriaBuilder.ConditionRoot<T>) ConditionalCriteriaBuilder.criteriaFor(getPersistentClass());
		for (ColumnStatRequest<T> statRequest : columnStat) {
			List<ColumnStatType> statFlags = statRequest.getStatFlags();
			for (ColumnStatType statType : statFlags) {
				if (ColumnStatType.COUNT.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn()).count();
				} else if (ColumnStatType.COUNT_DISTINCT.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn()).countDistinct();
				} else if (ColumnStatType.MIN.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn()).min();
				} else if (ColumnStatType.MAX.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn()).max();
				} else if (ColumnStatType.AVERAGE.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn()).avg();
				} else if (ColumnStatType.SUM.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn()).sum();
				} else if (ColumnStatType.GROUP_BY_VAL.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn());
					criteriaBuilder.groupBy(statRequest.getColumn());
				} else if (ColumnStatType.GROUP_BY_HOUR.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn().expr().hour());
					criteriaBuilder.groupBy(statRequest.getColumn().expr().hour());
				} else if (ColumnStatType.GROUP_BY_DAY.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn().expr().day());
					criteriaBuilder.groupBy(statRequest.getColumn().expr().day());
				} else if (ColumnStatType.GROUP_BY_WEEK.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn().expr().week());
					criteriaBuilder.groupBy(statRequest.getColumn().expr().week());
				} else if (ColumnStatType.GROUP_BY_MONTH.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn().expr().month());
					criteriaBuilder.groupBy(statRequest.getColumn().expr().month());
				} else if (ColumnStatType.GROUP_BY_QUARTER.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn().expr().quarter());
					criteriaBuilder.groupBy(statRequest.getColumn().expr().quarter());
				} else if (ColumnStatType.GROUP_BY_YEAR.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn().expr().year());
					criteriaBuilder.groupBy(statRequest.getColumn().expr().year());
				} else if (ColumnStatType.GROUP_BY_DOW.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn().expr().dayOfWeek());
					criteriaBuilder.groupBy(statRequest.getColumn().expr().dayOfWeek());
				} else if (ColumnStatType.GROUP_BY_DOY.equals(statType)) {
					criteriaBuilder.select(statRequest.getColumn().expr().dayOfYear());
					criteriaBuilder.groupBy(statRequest.getColumn().expr().dayOfYear());
				}
			}
		}

		for (ConditionalCriteria criteria : criteriaBuilder.build()) {
			addCondition(criteria);
		}
	}

	private List<List<ColumnStatResult>> prepareColumnStatResult() {
		List<Tuple> queryResult = getListResult();
		List<List<ColumnStatResult>> result = new ArrayList<>();
		for (Tuple row : queryResult) {
			List<ColumnStatResult> rowResult = new ArrayList<>();
			result.add(rowResult);
			int i = 0;
			for (ColumnStatRequest<T> statRequest : columnStatRequest) {
				List<ColumnStatType> statFlags = statRequest.getStatFlags();
				ColumnStatResult colResult = new ColumnStatResult(statRequest);

				for (ColumnStatType statType : statFlags) {
					if (ColumnStatType.COUNT.equals(statType)) {
						colResult.setCount((Long) row.get(i));
					} else if (ColumnStatType.COUNT_DISTINCT.equals(statType)) {
						colResult.setCountDistinct((Long) row.get(i));
					} else if (ColumnStatType.MIN.equals(statType) && row.get(i) instanceof String) {
						colResult.setMinString(row.get(i).toString());
					} else if (ColumnStatType.MAX.equals(statType) && row.get(i) instanceof String) {
						colResult.setMaxString(row.get(i).toString());
					} else if (ColumnStatType.MIN.equals(statType) && row.get(i) instanceof Date) {
						colResult.setMin(new Double(((Date) row.get(i)).getTime()));
					} else if (ColumnStatType.MAX.equals(statType) && row.get(i) instanceof Date) {
						colResult.setMax(new Double(((Date) row.get(i)).getTime()));
					} else if (ColumnStatType.MIN.equals(statType) && row.get(i) instanceof Number) {
						colResult.setMin(((Number) row.get(i)).doubleValue());
					} else if (ColumnStatType.MAX.equals(statType) && row.get(i) instanceof Number) {
						colResult.setMax(((Number) row.get(i)).doubleValue());
					} else if (ColumnStatType.AVERAGE.equals(statType) && row.get(i) instanceof Number) {
						colResult.setAverage(((Number) row.get(i)).doubleValue());
					} else if (ColumnStatType.SUM.equals(statType) && row.get(i) instanceof Number) {
						colResult.setSum(((Number) row.get(i)).doubleValue());
					} else if (ColumnStatType.GROUP_BY_VAL.equals(statType) && row.get(i) != null) {
						colResult.setGroupByValue(row.get(i).toString());
					} else if (ColumnStatType.GROUP_BY_HOUR.equals(statType)) {
						colResult.setGroupByHour((Integer) row.get(i));
					} else if (ColumnStatType.GROUP_BY_DAY.equals(statType)) {
						colResult.setGroupByDay((Integer) row.get(i));
					} else if (ColumnStatType.GROUP_BY_WEEK.equals(statType)) {
						colResult.setGroupByWeek((Integer) row.get(i));
					} else if (ColumnStatType.GROUP_BY_MONTH.equals(statType)) {
						colResult.setGroupByMonth((Integer) row.get(i));
					} else if (ColumnStatType.GROUP_BY_QUARTER.equals(statType)) {
						colResult.setGroupByQuarter((Integer) row.get(i));
					} else if (ColumnStatType.GROUP_BY_YEAR.equals(statType)) {
						colResult.setGroupByYear((Integer) row.get(i));
					} else if (ColumnStatType.GROUP_BY_DOW.equals(statType)) {
						colResult.setGroupByDow((Integer) row.get(i));
					} else if (ColumnStatType.GROUP_BY_DOY.equals(statType)) {
						colResult.setGroupByDoy((Integer) row.get(i));
					}
					i++;
				}
				rowResult.add(colResult);
			}
		}
		return result;
	}

	@Override
	protected void prepareConfig(QueryConfig config) {
		super.prepareConfig(config);
		setCriteriaQuery(getCriteriaBuilder().createTupleQuery());
	}

	@Override
	public List<List<ColumnStatResult>> getColumnStatResult() {
		if (columnStatResult == null) {
			columnStatResult = prepareColumnStatResult();
		}
		return columnStatResult;
	}
}