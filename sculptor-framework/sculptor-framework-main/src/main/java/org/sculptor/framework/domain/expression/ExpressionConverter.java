package org.sculptor.framework.domain.expression;

import javax.persistence.criteria.Expression;

public interface ExpressionConverter {
	Expression convertObject(Object obj);
	Expression[] convertObjectArray(Object... obj);
}
