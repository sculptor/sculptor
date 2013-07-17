package org.sculptor.framework.accessapi;

public class ColumnStatResult {

	String fieldName;

	Long countNotNull=null;
	Long countWithNull=null;
	Double min=null;
	Double max=null;
	Double average=null;
	Double sum=null;
	String minString=null;
	String maxString=null;
	String groupByVal=null;
	Integer groupByHour=null;
	Integer groupByDay=null;
	Integer groupByWeek=null;
	Integer groupByMonth=null;
	Integer groupByQuarter=null;
	Integer groupByYear=null;
	Integer groupByDow=null;
	Integer groupByDoy=null;

	public ColumnStatResult(ColumnStatRequest<?> statRequest, Long countWithNull, Long countNotNull, String minString, String maxString, Double average, Double sum, String groupBy) {
		this.fieldName=statRequest.getColumn().getName();
		this.countWithNull=countWithNull;
		this.countNotNull=countNotNull;
		this.average=average;
		this.sum=sum;
		this.minString=minString;
		this.maxString=maxString;
		this.groupByVal=groupBy;
	}

	public ColumnStatResult(ColumnStatRequest<?> statRequest, Long countWithNull, Long countNotNull, Double min, Double max, Double average, Double sum, String groupBy) {
		this.fieldName=statRequest.getColumn().getName();
		this.countWithNull=countWithNull;
		this.countNotNull=countNotNull;
		this.min=min;
		this.max=max;
		this.average=average;
		this.sum=sum;
		this.groupByVal=groupBy;
	}

	// getters
	public String getName() {
		return fieldName;
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

	public String toString() {
		StringBuilder sb=new StringBuilder("ColumnStat for ");
		sb.append("'").append(getName()).append("'").append(" [");

		if (getCountNotNull() != null || getCountWithNull() != null) {
			sb.append(", countWithNull=").append(getCountWithNull());
			sb.append(", countNotNull=").append(getCountNotNull());
		}
		if (getMin() != null) {
			sb.append(", minD=").append(getMin());
		}
		if (getMinString() != null) {
			sb.append(", minS=").append(getMinString());
		}
		if (getMax() != null) {
			sb.append(", maxD=").append(getMax());
		}
		if (getMaxString() != null) {
			sb.append(", maxS='").append(getMaxString()).append("'");
		}
		if (getAverage() != null) {
			sb.append(", avg=").append(getAverage());
		}
		if (getSum() != null) {
			sb.append(", sum=").append(getSum());
		}
		if (getGroupByValue() != null) {
			sb.append(", groupByVal=").append(getGroupByValue());
		}
		if (getGroupByDay() != null) {
			sb.append(", groupByDay=").append(getGroupByDay());
		}
		if (getGroupByDow() != null) {
			sb.append(", groupByDow=").append(getGroupByDow());
		}
		if (getGroupByDoy() != null) {
			sb.append(", groupByDoy=").append(getGroupByDoy());
		}
		if (getGroupByHour() != null) {
			sb.append(", groupByHour=").append(getGroupByHour());
		}
		if (getGroupByMonth() != null) {
			sb.append(", groupByMonth=").append(getGroupByMonth());
		}
		if (getGroupByQuarter() != null) {
			sb.append(", groupByQuarter=").append(getGroupByQuarter());
		}
		if (getGroupByWeek() != null) {
			sb.append(", groupByWeek=").append(getGroupByWeek());
		}
		if (getGroupByYear() != null) {
			sb.append(", groupByYear=").append(getGroupByYear());
		}

		return sb.append("]").toString();
	}

	public String getGroupByValue() {
		return groupByVal;
	}

	public Integer getGroupByHour() {
		return groupByHour;
	}

	public Integer getGroupByDay() {
		return groupByDay;
	}

	public Integer getGroupByWeek() {
		return groupByWeek;
	}

	public Integer getGroupByMonth() {
		return groupByMonth;
	}

	public Integer getGroupByQuarter() {
		return groupByQuarter;
	}

	public Integer getGroupByYear() {
		return groupByYear;
	}

	public Integer getGroupByDow() {
		return groupByDow;
	}

	public Integer getGroupByDoy() {
		return groupByDoy;
	}

	public void setGroupByValue(String groupByVal) {
		this.groupByVal = groupByVal;
	}

	public void setGroupByHour(Integer groupByHour) {
		this.groupByHour = groupByHour;
	}

	public void setGroupByDay(Integer groupByDay) {
		this.groupByDay = groupByDay;
	}

	public void setGroupByWeek(Integer groupByWeek) {
		this.groupByWeek = groupByWeek;
	}

	public void setGroupByMonth(Integer groupByMonth) {
		this.groupByMonth = groupByMonth;
	}

	public void setGroupByQuarter(Integer groupByQuarter) {
		this.groupByQuarter = groupByQuarter;
	}

	public void setGroupByYear(Integer groupByYear) {
		this.groupByYear = groupByYear;
	}

	public void setGroupByDow(Integer groupByDow) {
		this.groupByDow = groupByDow;
	}

	public void setGroupByDoy(Integer groupByDoy) {
		this.groupByDoy = groupByDoy;
	}
}