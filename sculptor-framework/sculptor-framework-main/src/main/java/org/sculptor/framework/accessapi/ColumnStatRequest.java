package org.sculptor.framework.accessapi;

import org.sculptor.framework.domain.Property;

public class ColumnStatRequest<T> {
	public static final byte COUNT   = 1 << 0;
	public static final byte MIN     = 1 << 1;
	public static final byte MAX     = 1 << 2;
	public static final byte AVERAGE = 1 << 3;
	public static final byte SUM     = 1 << 4;
	public static final byte GROUPBY = 1 << 5;

	public static final byte ALL=COUNT | MIN | MAX | AVERAGE | SUM;
	public static final byte ALL_EXCEPT_SUM=COUNT | MIN | MAX | AVERAGE;
	public static final byte STRING_STAT=COUNT | MIN | MAX;

	Property<T> column;
	byte statFlags=0;

	public ColumnStatRequest(Property<T> column, byte... flags) {
		this.column=column;
		if (flags.length == 0) {
			statFlags=ALL;
		} else {
			for (byte flag : flags) {
				statFlags |= flag;
			}
		}
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

	public boolean isGroupByFlag() {
		return (statFlags & ColumnStatRequest.GROUPBY) > 0;
	}

	public boolean isSumFlag() {
		return (statFlags & ColumnStatRequest.SUM) > 0;
	}

	public boolean isAverageFlag() {
		return (statFlags & ColumnStatRequest.AVERAGE) > 0;
	}

	public boolean isMinFlag() {
		return (statFlags & ColumnStatRequest.MIN) > 0;
	}

	public boolean isMaxFlag() {
		return (statFlags & ColumnStatRequest.MAX) > 0;
	}

	public boolean isCountNotNullFlag() {
		return (statFlags & ColumnStatRequest.COUNT) > 0;
	}

	public boolean isCountWithNullFlag() {
		return (statFlags & ColumnStatRequest.COUNT) > 0;
	}

	public String toString() {
		StringBuilder sb=new StringBuilder("ColumnStat for ");
		sb.append("'").append(column.getName()).append("'").append("[countFlags=");
		StringBuilder sb2=new StringBuilder("");

		if (isCountNotNullFlag()) {
			sb.append("| COUNT");
		}
		if (isMinFlag()) {
			sb.append("| MIN");
		}
		if (isMaxFlag()) {
			sb.append("| MAX");
		}
		if (isAverageFlag()) {
			sb.append("| AVERAGE");
		}
		if (isSumFlag()) {
			sb.append("| SUM");
		}

		return sb.append(sb2.length() > 0 ? sb2.substring(2) : "").append("]").toString();
	}
}