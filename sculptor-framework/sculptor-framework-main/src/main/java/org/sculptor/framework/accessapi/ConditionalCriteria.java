package org.sculptor.framework.accessapi;

import java.util.Collection;
import java.util.List;

import org.sculptor.framework.domain.LeafProperty;
import org.sculptor.framework.domain.Property;

public class ConditionalCriteria {

	Operator operator;
	String propertyName;
	String propertyAlias;
	String[] propertyPath;
	String propertyFullName;
	Object firstOperant;
	Object secondOperant;
	Property<?> property;

	private ConditionalCriteria(Operator operator, Property<?> property) {
		this(operator, property, null, null);
	}

	private ConditionalCriteria(Operator operator, Property<?> property, Object firstOperant) {
		this(operator, property, firstOperant, null);
	}

	private ConditionalCriteria(Operator operator, Property<?> property, Object firstOperant, Object secondOperant) {
		this.property=property;
		this.operator=operator;
		this.firstOperant=firstOperant;
		this.secondOperant=secondOperant;

		if (property == null) {
			this.propertyFullName=null;
			this.propertyName=null;
			this.propertyPath=new String[0];
		} else {
			this.propertyFullName=property instanceof LeafProperty<?>
					? ((LeafProperty<?>)property).getEmbeddedName()
					: property.getName();

			int lastDotPos = propertyFullName.lastIndexOf('.');
			if (lastDotPos == -1) {
				this.propertyName=propertyFullName;
				this.propertyPath=new String[0];
			} else {
				this.propertyName=propertyFullName.substring(lastDotPos+1);
				this.propertyPath=propertyFullName.substring(0, lastDotPos).split("\\.");
			}
		}
	}

	public Operator getOperator() {
		return operator;
	}

	public String getPropertyFullName() {
		return propertyFullName == null ? null : propertyFullName.replaceAll("#", ".");
	}

	public String getPropertyName() {
		return propertyName == null ? null : propertyName.replaceAll("#", ".");
	}

	public String[] getPropertyPath() {
		return propertyPath;
	}

	public String getPropertyAlias() {
		return propertyAlias;
	}

    public Object getFirstOperant() {
        return firstOperant;
    }

    public <Y extends Comparable<?>> Y getFirstOperantAs(Class<Y> type) {
        return type.cast(firstOperant);
    }

	public Object getSecondOperant() {
		return secondOperant;
	}

    public <Y extends Comparable<?>>  Y getSecondOperantAs(Class<Y> type) {
        return type.cast(secondOperant);
    }

	public ConditionalCriteria withProperty(Property<?> property) {
		return new ConditionalCriteria(this.operator, property, firstOperant, secondOperant);
	}

	public static ConditionalCriteria equal(Property<?> property, Object value) {
		return new ConditionalCriteria(Operator.Equal, property, value);
	}

	public static ConditionalCriteria ignoreCaseEqual(Property<?> property, Object value) {
		return new ConditionalCriteria(Operator.IgnoreCaseEqual, property, value);
	}

	public static ConditionalCriteria lessThan(Property<?> property, Object value) {
		return new ConditionalCriteria(Operator.LessThan, property, value);
	}

	public static ConditionalCriteria lessThanOrEqual(Property<?> property, Object value) {
		return new ConditionalCriteria(Operator.LessThanOrEqual, property, value);
	}

	public static ConditionalCriteria greatThan(Property<?> property, Object value) {
		return new ConditionalCriteria(Operator.GreatThan, property, value);
	}

	public static ConditionalCriteria greatThanOrEqual(Property<?> property, Object value) {
		return new ConditionalCriteria(Operator.GreatThanOrEqual, property, value);
	}

	public static ConditionalCriteria like(Property<?> property, Object value) {
		return new ConditionalCriteria(Operator.Like, property, value);
	}

	public static ConditionalCriteria ignoreCaseLike(Property<?> property, Object value) {
		return new ConditionalCriteria(Operator.IgnoreCaseLike, property, value);
	}

	public static ConditionalCriteria between(Property<?> property, Object lowRange, Object hightRange) {
		return new ConditionalCriteria(Operator.Between, property, lowRange, hightRange);
	}

	public static ConditionalCriteria in(Property<?> property, Object... itemList) {
		if (itemList != null && itemList.length == 1 && itemList[0] instanceof Collection<?>) {
			return new ConditionalCriteria(Operator.In, property, itemList[0]);
		} else {
			return new ConditionalCriteria(Operator.In, property, itemList);
		}
	}

	public static ConditionalCriteria isNull(Property<?> property) {
		return new ConditionalCriteria(Operator.IsNull, property);
	}

	public static ConditionalCriteria isNotNull(Property<?> property) {
		return new ConditionalCriteria(Operator.IsNotNull, property);
	}

	public static ConditionalCriteria isEmpty(Property<?> property) {
		return new ConditionalCriteria(Operator.IsEmpty, property);
	}

	public static ConditionalCriteria isNotEmpty(Property<?> property) {
		return new ConditionalCriteria(Operator.IsNotEmpty, property);
	}

	public static ConditionalCriteria not(ConditionalCriteria criteria) {
		return new ConditionalCriteria(Operator.Not, null, criteria);
	}

	public static ConditionalCriteria or(ConditionalCriteria criteriaLeft, ConditionalCriteria criteriaRight) {
		return new ConditionalCriteria(Operator.Or, null, criteriaLeft, criteriaRight);
	}

	public static ConditionalCriteria or(List<ConditionalCriteria> orCriteria) {
		return new ConditionalCriteria(Operator.Or, null, orCriteria);
	}

	public static ConditionalCriteria and(ConditionalCriteria criteriaLeft, ConditionalCriteria criteriaRight) {
		return new ConditionalCriteria(Operator.And, null, criteriaLeft, criteriaRight);
	}

	public static ConditionalCriteria and(List<ConditionalCriteria> andCriteria) {
		return new ConditionalCriteria(Operator.And, null, andCriteria);
	}

	// Property comparators
	public static ConditionalCriteria equalProperty(Property<?> propertyLeft, Property<?> propertyRight) {
		return new ConditionalCriteria(Operator.EqualProperty, propertyLeft, propertyRight.getName());
	}

	public static ConditionalCriteria lessThanProperty(Property<?> propertyLeft, Property<?> propertyRight) {
		return new ConditionalCriteria(Operator.LessThanProperty, propertyLeft, propertyRight.getName());
	}

	public static ConditionalCriteria lessThanOrEqualProperty(Property<?> propertyLeft, Property<?> propertyRight) {
		return new ConditionalCriteria(Operator.LessThanOrEqualProperty, propertyLeft, propertyRight.getName());
	}

	public static ConditionalCriteria greatThanProperty(Property<?> propertyLeft, Property<?> propertyRight) {
		return new ConditionalCriteria(Operator.GreatThanProperty, propertyLeft, propertyRight.getName());
	}

	public static ConditionalCriteria greatThanOrEqualProperty(Property<?> propertyLeft, Property<?> propertyRight) {
		return new ConditionalCriteria(Operator.GreatThanOrEqualProperty, propertyLeft, propertyRight.getName());
	}

	public static ConditionalCriteria orderAsc(Property<?> property) {
		return new ConditionalCriteria(Operator.OrderAsc, property);
	}

	public static ConditionalCriteria orderDesc(Property<?> property) {
		return new ConditionalCriteria(Operator.OrderDesc, property);
	}

	public static ConditionalCriteria fetchEager(Property<?> property) {
		return new ConditionalCriteria(Operator.FetchEager, property);
	}

	public static ConditionalCriteria fetchLazy(Property<?> property) {
		return new ConditionalCriteria(Operator.FetchLazy, property);
	}

	public static ConditionalCriteria distinctRoot() {
		return new ConditionalCriteria(Operator.DistinctRoot, null);
	}

	public static ConditionalCriteria projectionRoot() {
		return new ConditionalCriteria(Operator.ProjectionRoot, null);
	}

	public static ConditionalCriteria groupBy(Property<?> property) {
		return new ConditionalCriteria(Operator.GroupBy, property);
	}

	public static ConditionalCriteria groupBy(Property<?> property, Function function) {
		return new ConditionalCriteria(Operator.GroupBy, property, function);
	}

	public static ConditionalCriteria select(Property<?> property) {
		return new ConditionalCriteria(Operator.Select, property);
	}

	public static ConditionalCriteria select(Property<?> property, Function function) {
		return new ConditionalCriteria(Operator.Select, property, function);
	}

	public static ConditionalCriteria min(Property<?> property, Function function) {
		return new ConditionalCriteria(Operator.Min, property, function);
	}

	public static ConditionalCriteria max(Property<?> property, Function function) {
		return new ConditionalCriteria(Operator.Max, property, function);
	}

	public static ConditionalCriteria avg(Property<?> property, Function function) {
		return new ConditionalCriteria(Operator.Avg, property, function);
	}

	public static ConditionalCriteria sum(Property<?> property, Function function) {
		return new ConditionalCriteria(Operator.Sum, property, function);
	}

	public static ConditionalCriteria sumAsLong(Property<?> property, Function function) {
		return new ConditionalCriteria(Operator.SumAsLong, property, function);
	}

	public static ConditionalCriteria sumAsDouble(Property<?> property, Function function) {
		return new ConditionalCriteria(Operator.SumAsDouble, property, function);
	}

	public static ConditionalCriteria count(Property<?> property, Function function) {
		return new ConditionalCriteria(Operator.Count, property, function);
	}

	public static ConditionalCriteria countDistinct(Property<?> property, Function function) {
		return new ConditionalCriteria(Operator.CountDistinct, property, function);
	}

	public enum Operator {
		Equal, LessThan, LessThanOrEqual, GreatThan, GreatThanOrEqual, Like, IgnoreCaseLike, IgnoreCaseEqual
		, IsNull, IsNotNull, IsEmpty, IsNotEmpty
		, Not, Or, And
		, In, Between
		, EqualProperty, LessThanProperty, LessThanOrEqualProperty, GreatThanProperty, GreatThanOrEqualProperty
		, OrderAsc, OrderDesc, DistinctRoot, ProjectionRoot
		, FetchLazy, FetchEager
		, GroupBy
		, Select, Min, Max, Avg, Sum, SumAsLong, SumAsDouble, Count, CountDistinct
	}

	public enum Function {
		hour, day, week, month, quarter, year, dayOfWeek, dayOfYear
	}
}
