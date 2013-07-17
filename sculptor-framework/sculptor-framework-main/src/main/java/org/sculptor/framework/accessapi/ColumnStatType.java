package org.sculptor.framework.accessapi;

public enum ColumnStatType {
	COUNT,
	MIN,
	MAX,
	AVERAGE,
	SUM,
	GROUP_BY_VAL,
	GROUP_BY_HOUR,
	GROUP_BY_DAY,
	GROUP_BY_WEEK,
	GROUP_BY_MONTH,
	GROUP_BY_QUARTER,
	GROUP_BY_YEAR,
	GROUP_BY_DOW,
	GROUP_BY_DOY,

	// Special values
	ALL,
	ALL_EXCEPT_SUM,
	STRING_STAT;
}
