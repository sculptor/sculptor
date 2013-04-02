package org.sculptor.framework.accessapi;

import org.sculptor.framework.domain.Property;

public class ColumnStat<T> {
	public static final byte COUNT   = 1 << 0;
	public static final byte MIN     = 1 << 1;
	public static final byte MAX     = 1 << 2;
	public static final byte AVERAGE = 1 << 3;
	public static final byte SUM     = 1 << 4;

	public static final byte ALL=COUNT | MIN | MAX | AVERAGE | SUM;
	public static final byte ALL_EXCEPT_SUM=COUNT | MIN | MAX | AVERAGE;
	public static final byte STRING_STAT=COUNT | MIN | MAX;

	Property<T> column;
	byte statFlags=0;
	boolean counted;

	Long countNotNull=null;
	Long countWithNull=null;
	Double min=null;
	Double max=null;
	Double average=null;
	Double sum=null;
	String minString=null;
	String maxString=null;

	public ColumnStat(Property<T> column, byte... flags) {
		this.column=column;
		if (flags.length == 0) {
			statFlags=ALL;
		} else {
			for (byte flag : flags) {
				statFlags |= flag;
			}
		}
	}

	// set result
	public void setResultString(Long countWithNull, Long countNotNull, String minString, String maxString, Double average, Double sum) {
		setResultNum(countWithNull, countNotNull, null, null, average, sum);
		this.minString=minString;
		this.maxString=maxString;
	}

	public void setResultNum(Long countWithNull, Long countNotNull, Double min, Double max, Double average, Double sum) {
		this.countWithNull=countWithNull;
		this.countNotNull=countNotNull;
		this.min=min;
		this.max=max;
		this.average=average;
		this.sum=sum;
	}

	// getters
	public byte getStatFlags() {
		return statFlags;
	}

	public Property<T> getColumn() {
		return column;
	}

	public boolean isFlag(byte flag) {
		return (statFlags & flag) > 0;
	}
	public boolean isSumFlag() {
		return (statFlags & ColumnStat.SUM) > 0;
	}

	public boolean isAverageFlag() {
		return (statFlags & ColumnStat.AVERAGE) > 0;
	}

	public boolean isMinFlag() {
		return (statFlags & ColumnStat.MIN) > 0;
	}

	public boolean isMaxFlag() {
		return (statFlags & ColumnStat.MAX) > 0;
	}

	public boolean isCountNotNullFlag() {
		return (statFlags & ColumnStat.COUNT) > 0;
	}

	public boolean isCountWithNullFlag() {
		return (statFlags & ColumnStat.COUNT) > 0;
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
		sb.append("'").append(column.getName()).append("'").append("[countFlags=");
		StringBuilder sb2=new StringBuilder("");

		if (isCountNotNullFlag()) {
			sb.append("COUNT ");
			sb2.append(", countWithNull=").append(getCountWithNull());
			sb2.append(", countNotNull=").append(getCountNotNull());
		}
		if (isMinFlag()) {
			sb.append("MIN ");
			if (min != null) {
				sb2.append(", minD=").append(getMin());
			} else {
				sb2.append(", minS=").append(getMinString());
			}
		}
		if (isMaxFlag()) {
			sb.append("MAX ");
			if (max != null) {
				sb2.append(", maxD=").append(getMax());
			} else {
				sb2.append(", maxS='").append(getMaxString()).append("'");
			}
		}
		if (isAverageFlag()) {
			sb.append("AVERAGE ");
			sb2.append(", avg=").append(getAverage());
		}
		if (isSumFlag()) {
			sb.append("SUM ");
			sb2.append(", sum=").append(getSum());
		}

		return sb.append(sb2).append("]").toString();
	}
}