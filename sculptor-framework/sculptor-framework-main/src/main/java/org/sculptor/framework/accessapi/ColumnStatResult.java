package org.sculptor.framework.accessapi;

public class ColumnStatResult {

	String fieldName;

	Long count=null;
	Long countDistinct=null;
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

	public ColumnStatResult(ColumnStatRequest<?> statRequest) {
		this.fieldName=statRequest.getColumn().getName();
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

	public Long getCount() {
		return count;
	}

	public Long getCountDistinct() {
		return countDistinct;
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

	public void setCount(Long count) {
		this.count = count;
	}

	public void setCountDistinct(Long countDistinct) {
		this.countDistinct = countDistinct;
	}

	public void setMin(Double min) {
		this.min = min;
	}

	public void setMax(Double max) {
		this.max = max;
	}

	public void setAverage(Double average) {
		this.average = average;
	}

	public void setSum(Double sum) {
		this.sum = sum;
	}

	public void setMinString(String minString) {
		this.minString = minString;
	}

	public void setMaxString(String maxString) {
		this.maxString = maxString;
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

	public String toString() {
		StringBuilder sb=new StringBuilder("ColumnStat[field=");
		sb.append("'").append(getName()).append("'");

		if (getCount() != null) {
			sb.append(", count=").append(getCount());
		}
		if (getCountDistinct() != null) {
			sb.append(", countDistinct=").append(getCountDistinct());
		}
		if (getMin() != null) {
			sb.append(", minD=").append(getMin());
		}
		if (getMinString() != null) {
			sb.append(", minS='").append(getMinString()).append("'");
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
}