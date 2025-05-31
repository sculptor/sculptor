package org.sculptor.framework.domain.expression;

import jakarta.persistence.criteria.Expression;

public interface ExpressionConverter {
	Expression convertObject(Object obj);
	Expression[] convertObjectArray(Object... obj);
}
