package org.sculptor.framework.accessimpl.jpa;

/**
 *
 *
 * @author Oliver Ringel
 *
 */
//TODO: very simple approach to support more complex criteria based queries
public class QueryPropertyRestriction  {

	private String property = null;
	private Class<?> propertyType = null;
	private Operator operator = null;
	private Object value = null;

	public QueryPropertyRestriction(String property, Object value) {
		this.property = getPropertyName(property);
		this.operator = getOperator(property);
		this.value = value;
	}

	public QueryPropertyRestriction(String property, Operator operator,	Object value) {
		this.property = property;
		this.operator = operator;
		this.value = value;
	}

	public String getProperty() {
		return property;
	}

	public void setProperty(String property) {
		this.property = property;
	}

	public Class<?> getPropertyType() {
		return propertyType;
	}

	public void setPropertyType(Class<?> propertyType) {
		this.propertyType = propertyType;
	}

	public Operator getOperator() {
		return operator;
	}

	public void setOperator(Operator operator) {
		this.operator = operator;
	}

	public Object getValue() {
		return value;
	}

	public void setValue(Object value) {
		this.value = value;
	}

	/**
	 *
	 * @param expression
	 * @return
	 */
	private String getPropertyName(String property) {
		String propertyName = property.trim();

		propertyName = propertyName.replace("GreaterThan", "");
		propertyName = propertyName.replace("GreaterThanOrEqual", "");
		propertyName = propertyName.replace("LessThan", "");
		propertyName = propertyName.replace("LessThanOrEqual", "");
		propertyName = propertyName.replace("NotEqual", "");
		propertyName = propertyName.replace("IsNull", "");
		propertyName = propertyName.replace("IsNotNull", "");
		propertyName = propertyName.replace("IsIn", "");
		propertyName = propertyName.replace("IsEmpty", "");
		propertyName = propertyName.replace("IsNotEmpty", "");
		propertyName = propertyName.replace("IgnoreCaseLike", "");
		propertyName = propertyName.replace("IgnoreCaseEqual", "");

		return propertyName;
	}

	/**
	 *
	 * @param expression
	 * @return
	 */
	private Operator getOperator(String expression) {
		String expr = expression.trim();
		if (expr.endsWith(" >") || expr.endsWith(" gt") || expr.endsWith("GreaterThan")) {
			return Operator.GreaterThan;
		}
		else if (expr.endsWith(" >=") || expr.endsWith(" ge") || expr.endsWith("GreaterThanOrEqual")) {
			return Operator.GreaterThanOrEqual;
		}
		else if (expr.endsWith(" <") || expr.endsWith(" lt") || expr.endsWith("LessThan")) {
			return Operator.LessThan;
		}
		else if (expr.endsWith(" <=") || expr.endsWith(" le") || expr.endsWith("LessThanOrEqual")) {
			return Operator.LessThanOrEqual;
		}
		else if (expr.endsWith(" like") || expr.endsWith("Like")) {
			return Operator.Like;
		}
		else if (expr.endsWith(" notLike") || expr.endsWith(" not like") || expr.endsWith("NotLike")) {
			return Operator.NotLike;
		}
		else if (expr.endsWith(" ignoreCaseLike") || expr.endsWith("IgnoreCaseLike")) {
			return Operator.IgnoreCaseLike;
		}
		else if (expr.endsWith(" ignoreCaseEqual") || expr.endsWith("IgnoreCaseEqual")) {
			return Operator.IgnoreCaseEqual;
		}
		else if (expr.endsWith(" isNull") || expr.endsWith(" is null") || expr.endsWith("IsNull")) {
			return Operator.IsNull;
		}
		else if (expr.endsWith(" isNotNull") || expr.endsWith(" is not null") || expr.endsWith("IsNotNull")) {
			return Operator.IsNull;
		}
		else if (expr.endsWith(" isEmpty") || expr.endsWith(" is empty") || expr.endsWith("IsEmpty")) {
			return Operator.IsEmpty;
		}
		else if (expr.endsWith(" isNotEmpty") || expr.endsWith(" is not empty") || expr.endsWith("IsNotEmpty")) {
			return Operator.IsNotEmpty;
		}
		else if (expr.endsWith(" in") || expr.endsWith("IsIn")) {
			return Operator.In;
		}
		else if (expr.endsWith(" notIn") || expr.endsWith("IsNotIn")) {
			return Operator.NotIn;
		}
		else if (expr.endsWith(" !=") || expr.endsWith(" <>")  || expr.endsWith("NotEqual")) {
			return Operator.NotEqual;
		}
		else if (expr.endsWith(" =") || expr.endsWith(" ==")) {
			return Operator.Equal;
		}
		return Operator.Equal;
	}

	public enum Operator {
		Equal, IgnoreCaseEqual, NotEqual,
		LessThan, LessThanOrEqual, GreaterThan, GreaterThanOrEqual,
		Like, IgnoreCaseLike, NotLike,
		IsNull, IsNotNull,
		IsEmpty, IsNotEmpty,
		In, NotIn
	}
}
