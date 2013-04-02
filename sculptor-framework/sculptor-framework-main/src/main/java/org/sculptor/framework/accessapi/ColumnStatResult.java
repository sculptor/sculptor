package org.sculptor.framework.accessapi;



public class ColumnStatResult {

	ColumnStatRequest<?> columnStat;

	Long countNotNull=null;
	Long countWithNull=null;
	Double min=null;
	Double max=null;
	Double average=null;
	Double sum=null;
	String minString=null;
	String maxString=null;
	String groupBy=null;

	public ColumnStatResult(ColumnStatRequest<?> statRequest, Long countWithNull, Long countNotNull, String minString, String maxString, Double average, Double sum) {
		this.columnStat=statRequest;
		this.countWithNull=countWithNull;
		this.countNotNull=countNotNull;
		this.average=average;
		this.sum=sum;
		this.minString=minString;
		this.maxString=maxString;
	}

	public ColumnStatResult(ColumnStatRequest<?> statRequest, Long countWithNull, Long countNotNull, Double min, Double max, Double average, Double sum) {
		this.columnStat=statRequest;
		this.countWithNull=countWithNull;
		this.countNotNull=countNotNull;
		this.min=min;
		this.max=max;
		this.average=average;
		this.sum=sum;
	}

	public ColumnStatResult(ColumnStatRequest<?> statRequest, String groupValue) {
		this.columnStat=statRequest;
		this.groupBy=groupValue;
	}

	// getters
	public ColumnStatRequest<?> getColumnStatRequest() {
		return columnStat;
	}

	public String getName() {
		return columnStat.column.getName();
	}

	public Double getSum() {
		return sum;
	}

	public Double getAverage() {
		return average;
	}

	public Double getMin() {
		return min;
	}

	public Double getMax() {
		return max;
	}

	public String getMinString() {
		return min != null ? min.toString() : minString;
	}

	public String getMaxString() {
		return max != null ? max.toString() : maxString;
	}

	public Long getCountNotNull() {
		return countNotNull;
	}

	public Long getCountWithNull() {
		return countWithNull;
	}

	public String getGroupBy() {
		return groupBy;
	}

	public String toString() {
		StringBuilder sb=new StringBuilder("ColumnStat for ");
		sb.append("'").append(columnStat.column.getName()).append("'").append(" [countFlags =");
		StringBuilder sb2=new StringBuilder("");

		if (columnStat.isCountNotNullFlag()) {
			sb.append(" COUNT");
			sb2.append(", countWithNull=").append(getCountWithNull());
			sb2.append(", countNotNull=").append(getCountNotNull());
		}
		if (columnStat.isMinFlag()) {
			sb.append(" MIN");
			if (min != null) {
				sb2.append(", minD=").append(getMin());
			} else {
				sb2.append(", minS=").append(getMinString());
			}
		}
		if (columnStat.isMaxFlag()) {
			sb.append(" MAX");
			if (max != null) {
				sb2.append(", maxD=").append(getMax());
			} else {
				sb2.append(", maxS='").append(getMaxString()).append("'");
			}
		}
		if (columnStat.isAverageFlag()) {
			sb.append(" AVERAGE");
			sb2.append(", avg=").append(getAverage());
		}
		if (columnStat.isSumFlag()) {
			sb.append(" SUM");
			sb2.append(", sum=").append(getSum());
		}
		if (columnStat.isGroupByFlag()) {
			sb.append(" GROUPBY");
			sb2.append(", groupBy=").append(getGroupBy());
		}

		return sb.append(sb2).append("]").toString();
	}
}