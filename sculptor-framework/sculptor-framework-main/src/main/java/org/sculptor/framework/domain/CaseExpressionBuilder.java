package org.sculptor.framework.domain;

import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.ConditionalCriteriaBuilder;
import org.sculptor.framework.domain.expression.*;

import javax.persistence.criteria.CriteriaBuilder;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

class CaseExpressionBuilder<T> implements JpaFunction, CaseRoot, CaseConditionRoot<T>, CaseCondition<T>, Between<T> {
	List<CaseWhenThan> cases = new ArrayList<>();
	PropertyWithExpression<T> back;
	PropertyWithExpression<T> baseExpr;
	ConditionalCriteriaBuilder.RootBuilderImpl rootBuilder;
	private ConditionalCriteriaBuilder.ConditionProperty propertyCondition;

	public CaseExpressionBuilder(PropertyWithExpression<T> back) {
		this.back = back;
		this.baseExpr = new PropertyWithExpression<T>(back);
	}

	@Override
	public javax.persistence.criteria.Expression prepareFunction(CriteriaBuilder cb, javax.persistence.criteria.Expression left, ExpressionConverter converter) {
		CriteriaBuilder.Case<Object> selectCase = cb.selectCase();
		javax.persistence.criteria.Expression result = selectCase;
		for (CaseWhenThan wt : cases) {
			if (wt.condition != null) {
				selectCase.when(converter.convertObject(wt.condition), converter.convertObject(wt.result));
			} else {
				result = selectCase.otherwise(converter.convertObject(wt.result));
			}
		}
		return result;
	}

	@Override
	public CaseWhen<T> not() {
		rootBuilder.not();
		return this;
	}

	@Override
	public CaseWhen<T> lbrace() {
		rootBuilder.lbrace();
		return this;
	}

	@Override
	public CaseConditionRoot<T> rbrace() {
		rootBuilder.rbrace();
		return null;
	}

	@Override
	public CaseWhen<T> and() {
		rootBuilder.and();
		return this;
	}

	@Override
	public CaseWhen<T> or() {
		rootBuilder.or();
		return this;
	}

	@Override
	public CaseCondition when() {
		return when(baseExpr);
	}

	@Override
	public CaseCondition<T> when(Expression condition) {
		if (rootBuilder == null) {
			rootBuilder = new ConditionalCriteriaBuilder.RootBuilderImpl();
		}
		propertyCondition = rootBuilder.withProperty(condition);
		return this;
	}

	@Override
	public CaseRoot<T> than() {
		return genericThan(baseExpr);
	}

	@Override
	public CaseRoot<T> than(Expression<T> result) {
		return genericThan(result);
	}

	@Override
	public CaseRoot<T> than(String result) {
		return genericThan(result);
	}

	@Override
	public CaseRoot<T> than(Number result) {
		return genericThan(result);
	}

	@Override
	public CaseRoot<T> than(java.util.Date result) {
		return genericThan(result);
	}

	private CaseRoot<T> genericThan(Object result) {
		if (rootBuilder == null) {
			throw new IllegalStateException("CASE THAN called before WHEN");
		}
		CaseWhenThan wt = new CaseWhenThan(rootBuilder.buildSingle());
		wt.setThan(result);
		cases.add(wt);

		rootBuilder = null;
		propertyCondition = null;
		return this;
	}

	@Override
	public ComplexExpression<T> otherwise() {
		return genericOtherwise(baseExpr);
	}

	@Override
	public ComplexExpression<T> otherwise(Number result) {
		return genericOtherwise(result);
	}

	@Override
	public ComplexExpression<T> otherwise(String result) {
		return (ComplexExpression<T>) genericOtherwise(result);
	}

	@Override
	public ComplexExpression<T> otherwise(java.util.Date result) {
		return genericOtherwise(result);
	}

	@Override
	public ComplexExpression<T> otherwise(Expression result) {
		return genericOtherwise(result);
	}

	private ComplexExpression<T> genericOtherwise(Object result) {
		CaseWhenThan wt = new CaseWhenThan(null);
		wt.setThan(result);
		cases.add(wt);
		return back;
	}

	@Override
	public ComplexExpression<T> end() {
		return back;
	}

	@Override
	public CaseConditionRoot<T> eq(Object value) {
		propertyCondition.eq(value);
		return this;
	}

	@Override
	public CaseConditionRoot<T> ignoreCaseEq(Object value) {
		propertyCondition.ignoreCaseEq(value);
		return this;
	}

	@Override
	public CaseConditionRoot<T> eq(Expression<T> property) {
		propertyCondition.eq(property);
		return this;
	}

	@Override
	public CaseConditionRoot<T> between(Object from, Object to) {
		propertyCondition.between(from, to);
		return this;
	}

	Object from;

	@Override
	public Between<T> between(Object from) {
		this.from = from;
		return this;
	}

	public CaseConditionRoot<T> to(Object to) {
		if (baseExpr == null) {
			throw new IllegalStateException("Between.to() called without from");
		}
		propertyCondition.between(baseExpr, to);
		from = null;
		return this;
	}

	@Override
	public CaseConditionRoot<T> lessThan(Object value) {
		propertyCondition.lessThan(value);
		return this;
	}

	@Override
	public CaseConditionRoot<T> lessThan(Expression<T> property) {
		propertyCondition.lessThan(property);
		return this;
	}

	@Override
	public CaseConditionRoot<T> lessThanOrEqual(Object value) {
		propertyCondition.lessThanOrEqual(value);
		return this;
	}

	@Override
	public CaseConditionRoot<T> lessThanOrEqual(Expression<T> property) {
		propertyCondition.lessThanOrEqual(property);
		return this;
	}

	@Override
	public CaseConditionRoot<T> greaterThan(Object value) {
		propertyCondition.greaterThan(value);
		return this;
	}

	@Override
	public CaseConditionRoot<T> greaterThan(Expression<T> property) {
		propertyCondition.greaterThan(property);
		return this;
	}

	@Override
	public CaseConditionRoot<T> greaterThanOrEqual(Object value) {
		propertyCondition.greaterThanOrEqual(value);
		return this;
	}

	@Override
	public CaseConditionRoot<T> greaterThanOrEqual(Expression<T> property) {
		propertyCondition.greaterThanOrEqual(property);
		return this;
	}

	@Override
	public CaseConditionRoot<T> like(Object value) {
		propertyCondition.like(value);
		return this;
	}

	@Override
	public CaseConditionRoot<T> ignoreCaseLike(Object value) {
		propertyCondition.ignoreCaseLike(value);
		return this;
	}

	@Override
	public CaseConditionRoot<T> in(Object... values) {
		propertyCondition.in(values);
		return this;
	}

	@Override
	public CaseConditionRoot<T> in(Collection<?> values) {
		propertyCondition.in(values);
		return this;
	}

	@Override
	public CaseConditionRoot<T> isNull() {
		propertyCondition.isNull();
		return this;
	}

	@Override
	public CaseConditionRoot<T> isNotNull() {
		propertyCondition.isNotNull();
		return this;
	}

	@Override
	public CaseConditionRoot<T> isEmpty() {
		propertyCondition.isEmpty();
		return this;
	}

	@Override
	public CaseConditionRoot<T> isNotEmpty() {
		propertyCondition.isNotEmpty();
		return this;
	}

	private class CaseWhenThan {
		ConditionalCriteria condition;
		Object result;

		public CaseWhenThan(ConditionalCriteria condition) {
			this.condition = condition;
		}

		public void setThan(Object result) {
			this.result = result;
		}
	}
}

