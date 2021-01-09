package org.sculptor.framework.accessapi;

import java.util.Collection;
import java.util.List;

import org.sculptor.framework.domain.Property;
import org.sculptor.framework.domain.PropertyWithExpression;
import org.sculptor.framework.domain.expression.Expression;
import org.sculptor.framework.domain.LeafProperty;

public class ConditionalCriteria {

	Operator operator;
	String propertyName;
	String propertyAlias;
	String[] propertyPath;
	String propertyFullName;
	Object firstOperant;
	Object secondOperant;
	Expression<?> expression;
	boolean having=false;

	private ConditionalCriteria(Operator operator, Expression<?> expression) {
		this(operator, expression, null, null);
	}

	private ConditionalCriteria(Operator operator, Expression<?> expression, Object firstOperant) {
		this(operator, expression, firstOperant, null);
	}

	private ConditionalCriteria(Operator operator, Expression<?> expression, Object firstOperant, Object secondOperant) {
		this.expression = expression;
		this.operator=operator;
		this.firstOperant=firstOperant;
		this.secondOperant=secondOperant;

		Property p;
		if (expression instanceof PropertyWithExpression) {
			p = ((PropertyWithExpression) expression).getBase();
		} else if (expression instanceof Property) {
			p = (Property) expression;
		} else {
			p = null;
		}

		if (p == null) {
			this.propertyFullName=null;
			this.propertyName=null;
			this.propertyPath=new String[0];
		} else if (p instanceof Property) {
			this.propertyFullName=p instanceof LeafProperty<?>
					? ((LeafProperty<?>)p).getEmbeddedName()
					: p.getName();

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

    public Expression getExpression() {
		return expression;
	}

	public ConditionalCriteria withProperty(Expression<?> property) {
		return new ConditionalCriteria(this.operator, property, firstOperant, secondOperant);
	}

	public static ConditionalCriteria equal(Expression<?> property, Object value) {
		return new ConditionalCriteria(Operator.Equal, property, value);
	}

	public static ConditionalCriteria ignoreCaseEqual(Expression<?> property, Object value) {
		return new ConditionalCriteria(Operator.IgnoreCaseEqual, property, value);
	}

	public static ConditionalCriteria lessThan(Expression<?> property, Object value) {
		return new ConditionalCriteria(Operator.LessThan, property, value);
	}

	public static ConditionalCriteria lessThanOrEqual(Expression<?> property, Object value) {
		return new ConditionalCriteria(Operator.LessThanOrEqual, property, value);
	}

	public static ConditionalCriteria greatThan(Expression<?> property, Object value) {
		return new ConditionalCriteria(Operator.GreatThan, property, value);
	}

	public static ConditionalCriteria greatThanOrEqual(Expression<?> property, Object value) {
		return new ConditionalCriteria(Operator.GreatThanOrEqual, property, value);
	}

	public static ConditionalCriteria like(Expression<?> property, Object value) {
		return new ConditionalCriteria(Operator.Like, property, value);
	}

	public static ConditionalCriteria ignoreCaseLike(Expression<?> property, Object value) {
		return new ConditionalCriteria(Operator.IgnoreCaseLike, property, value);
	}

	public static ConditionalCriteria between(Expression<?> property, Object lowRange, Object hightRange) {
		return new ConditionalCriteria(Operator.Between, property, lowRange, hightRange);
	}

	public static ConditionalCriteria in(Expression<?> property, Object... itemList) {
		if (itemList != null && itemList.length == 1 && itemList[0] instanceof Collection<?>) {
			return new ConditionalCriteria(Operator.In, property, itemList[0]);
		} else {
			return new ConditionalCriteria(Operator.In, property, itemList);
		}
	}

	public static ConditionalCriteria isNull(Expression<?> property) {
		return new ConditionalCriteria(Operator.IsNull, property);
	}

	public static ConditionalCriteria isNotNull(Expression<?> property) {
		return new ConditionalCriteria(Operator.IsNotNull, property);
	}

	public static ConditionalCriteria isEmpty(Expression<?> property) {
		return new ConditionalCriteria(Operator.IsEmpty, property);
	}

	public static ConditionalCriteria isNotEmpty(Expression<?> property) {
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
	public static ConditionalCriteria equalProperty(Expression<?> propertyLeft, Expression<?> propertyRight) {
		return new ConditionalCriteria(Operator.EqualProperty, propertyLeft, propertyRight);
	}

	public static ConditionalCriteria lessThanProperty(Expression<?> propertyLeft, Expression<?> propertyRight) {
		return new ConditionalCriteria(Operator.LessThanProperty, propertyLeft, propertyRight);
	}

	public static ConditionalCriteria lessThanOrEqualProperty(Expression<?> propertyLeft, Expression<?> propertyRight) {
		return new ConditionalCriteria(Operator.LessThanOrEqualProperty, propertyLeft, propertyRight);
	}

	public static ConditionalCriteria greatThanProperty(Expression<?> propertyLeft, Expression<?> propertyRight) {
		return new ConditionalCriteria(Operator.GreatThanProperty, propertyLeft, propertyRight);
	}

	public static ConditionalCriteria greatThanOrEqualProperty(Expression<?> propertyLeft, Expression<?> propertyRight) {
		return new ConditionalCriteria(Operator.GreatThanOrEqualProperty, propertyLeft, propertyRight);
	}

	public static ConditionalCriteria orderAsc(Expression<?> property) {
		return new ConditionalCriteria(Operator.OrderAsc, property);
	}

	public static ConditionalCriteria orderDesc(Expression<?> property) {
		return new ConditionalCriteria(Operator.OrderDesc, property);
	}

	public static ConditionalCriteria fetchEager(Expression<?> property) {
		return new ConditionalCriteria(Operator.FetchEager, property);
	}

	public static ConditionalCriteria fetchLazy(Expression<?> property) {
		return new ConditionalCriteria(Operator.FetchLazy, property);
	}

	public static ConditionalCriteria distinctRoot() {
		return new ConditionalCriteria(Operator.DistinctRoot, null);
	}

	public static ConditionalCriteria projectionRoot() {
		return new ConditionalCriteria(Operator.ProjectionRoot, null);
	}

	public static ConditionalCriteria readOnly() {
		return new ConditionalCriteria(Operator.ReadOnly, null);
	}

	public static ConditionalCriteria scroll() {
		return new ConditionalCriteria(Operator.Scroll, null);
	}

	public static ConditionalCriteria groupBy(Expression<?> property) {
		return new ConditionalCriteria(Operator.GroupBy, property);
	}

	public static ConditionalCriteria select(Expression<?> property) {
		return new ConditionalCriteria(Operator.Select, property);
	}

	public void setHaving() {
		having=true;
	}

	public void unsetHaving() {
		having=false;
	}

	public boolean isHaving() {
		return having;
	}

	public enum OperatorType {
		Predicate, Sql, Config
	}

	public enum Operator {
		Equal, LessThan, LessThanOrEqual, GreatThan, GreatThanOrEqual, Like, IgnoreCaseLike, IgnoreCaseEqual
		, IsNull, IsNotNull, IsEmpty, IsNotEmpty
		, In, Between
		, EqualProperty, LessThanProperty, LessThanOrEqualProperty, GreatThanProperty, GreatThanOrEqualProperty
		, Not, Or, And
		, OrderAsc(OperatorType.Sql), OrderDesc(OperatorType.Sql)
		, GroupBy(OperatorType.Sql), Select(OperatorType.Sql)
		, DistinctRoot(OperatorType.Config), ProjectionRoot(OperatorType.Config)
		, FetchLazy(OperatorType.Config), FetchEager(OperatorType.Config)
		, ReadOnly(OperatorType.Config), Scroll(OperatorType.Config)
		;

		private OperatorType operatorType;

		Operator() {
			this.operatorType = OperatorType.Predicate;
		}

		Operator(OperatorType type) {
			this.operatorType = type;
		}

		public OperatorType getOperatorType() {
			return operatorType;
		}
	}
}
