package org.sculptor.framework.accessapi;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import static org.sculptor.framework.accessapi.ColumnStatType.*;

import org.sculptor.framework.domain.Property;

public class ColumnStatRequest<T> {
	private static final List<ColumnStatType> ALL_PROPS;
	private static final List<ColumnStatType> ALL_EXCEPT_SUM_PROPS;
	private static final List<ColumnStatType> STRING_STAT_PROPS;

	static {
		ALL_PROPS=new ArrayList<ColumnStatType>();
		ALL_PROPS.addAll(Arrays.asList(new ColumnStatType[]
				{COUNT, COUNT_DISTINCT, MIN, MAX, AVERAGE, SUM}));

		ALL_EXCEPT_SUM_PROPS=new ArrayList<ColumnStatType>();
		ALL_EXCEPT_SUM_PROPS.addAll(Arrays.asList(new ColumnStatType[]
				{COUNT, COUNT_DISTINCT, MIN, MAX, AVERAGE}));

		STRING_STAT_PROPS=new ArrayList<ColumnStatType>();
		STRING_STAT_PROPS.addAll(Arrays.asList(new ColumnStatType[]
				{COUNT, COUNT_DISTINCT, MIN, MAX}));
	}

	Property<T> column;
	List<ColumnStatType> statFlags;

	public ColumnStatRequest(Property<T> column, List<ColumnStatType> flags) {
		this(column, flags.toArray(new ColumnStatType[flags.size()]));
	}

	public ColumnStatRequest(Property<T> column, ColumnStatType... flags) {
		this.column=column;
		if (flags.length == 0) {
			statFlags=ALL_PROPS;
		} else {
			// expand special values ALL, ALL_EXCEPT_SUM, STRING_STAT
			statFlags=new ArrayList<ColumnStatType>();
			for (ColumnStatType fl : flags) {
				if (fl.equals(ColumnStatType.ALL)) {
					statFlags.addAll(ALL_PROPS);
				} else if (fl.equals(ColumnStatType.ALL_EXCEPT_SUM)) {
					statFlags.addAll(ALL_EXCEPT_SUM_PROPS);
				} else if (fl.equals(ColumnStatType.STRING_STAT)) {
					statFlags.addAll(STRING_STAT_PROPS);
				} else {
					statFlags.add(fl);
				}
			}
		}
	}

	// getters
	public List<ColumnStatType> getStatFlags() {
		return statFlags;
	}

	public Property<T> getColumn() {
		return column;
	}

	public boolean isFlag(ColumnStatType isFlag) {
		for (ColumnStatType setFlag : statFlags) {
			if (setFlag.equals(isFlag)) {
				return true;
			}
		}
		return false;
	}

	public String toString() {
		StringBuilder sb=new StringBuilder("ColumnStat for ");
		sb.append("'").append(column.getName()).append("'").append("[flags=");

		String sep = "";
		for (ColumnStatType flag : statFlags) {
			sb.append(sep).append(flag.name());
			sep=" | ";
		}

		return sb.append("]").toString();
	}
}