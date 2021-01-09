/*
 * Copyright 2009 The Fornax Project Team, including the original
 * author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.sculptor.framework.accessapi;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.function.Consumer;

import org.sculptor.framework.accessapi.ConditionalCriteria.Operator;
import org.sculptor.framework.domain.Property;
import org.sculptor.framework.domain.expression.ComplexExpression;
import org.sculptor.framework.domain.expression.Expression;

/**
 * Expression Builder for ConditionalCriteria. A small internal DSL (fluent
 * interface) for creating criteria conditions.
 *
 * @author Patrik Nordwall
 *
 * @param <T>
 *            root type of criteria
 */
public class ConditionalCriteriaBuilder<T> {

    private enum ExpressionOperator {
        Not, Or, And, LBrace
    }

    private ConditionalCriteriaBuilder() {
    }

    public static <T> ConditionRoot<T> criteriaFor(Class<T> clazz) {
        return new ConditionalCriteriaBuilder<T>().new RootBuilderImpl();
    }

    public class RootBuilderImpl implements ConditionRootLogic<T>, OrderBy<T>, Selection<T>, GroupBy<T> {
        private final SimpleStack<ConditionalCriteria> otherCriteriaStack = new SimpleStack<ConditionalCriteria>();
        private final SimpleStack<ConditionalCriteria> havingCriteriaStack = new SimpleStack<ConditionalCriteria>();
        private final SimpleStack<ConditionalCriteria> whereCriteriaStack = new SimpleStack<ConditionalCriteria>();
        private final SimpleStack<ExpressionOperator> operatorStack = new SimpleStack<ExpressionOperator>();

        // only used to give good error message
        private int braceCount = 0;
        private boolean isHaving = false;

        /**
         * End the expression with this build
         */
        @SuppressWarnings("unchecked")
        public List<ConditionalCriteria> build() {
            assertBraceCount();
            assertOperatorStack();

            List<ConditionalCriteria> critList = new ArrayList<ConditionalCriteria>();
            addCriteriaStack(critList, whereCriteriaStack, false);
            addCriteriaStack(critList, havingCriteriaStack, true);
            critList.addAll(otherCriteriaStack.asList());
            return critList;
        }

        private void addCriteriaStack(List<ConditionalCriteria> critList, SimpleStack<ConditionalCriteria> criteriaStack, boolean havingStack) {
            for (ConditionalCriteria singleCrit : criteriaStack.asList()) {
                if (havingStack) {
                    singleCrit.setHaving();
                }
                if (singleCrit.getOperator() == Operator.And) {
                    if (singleCrit.getFirstOperant() instanceof List) {
                        critList.addAll( (List<ConditionalCriteria>) singleCrit.getFirstOperant() );
                    } else {
                        critList.add( (ConditionalCriteria) singleCrit.getFirstOperant() );
                        critList.add( (ConditionalCriteria) singleCrit.getSecondOperant() );
                    }
                } else {
                    critList.add(singleCrit);
                }
            }
        }

        /**
         * Easier to use from test
         */
        public ConditionalCriteria buildSingle() {
            assertBraceCount();
            assertOperatorStack();
            int stackSize = whereCriteriaStack.size() + havingCriteriaStack.size() + otherCriteriaStack.size();
            if (stackSize > 1) {
                throw new IllegalStateException("Invalid criteria, too many items in the build stack: " + stackSize);
            }
            if (whereCriteriaStack.isEmpty() && havingCriteriaStack.isEmpty() && otherCriteriaStack.isEmpty()) {
                return null;
            }
            return whereCriteriaStack.size() > 0 ? whereCriteriaStack.peek()
                    : havingCriteriaStack.size() > 0 ? havingCriteriaStack.peek()
                    : otherCriteriaStack.peek();
        }

        private void assertBraceCount() {
            if (braceCount != 0) {
                throw new IllegalStateException("Unmatched braces. "
                        + (braceCount > 0 ? ("Missing " + braceCount + " rbrace") : (braceCount + " too many rbrace")));
            }
        }

        private void assertOperatorStack() {
            if (!operatorStack.isEmpty()) {
                throw new IllegalStateException("Expected all operators completed, got: " + operatorStack.size()
                        + " left: " + operatorStack.peek());
            }
        }

        private void assertHaving() {
            Optional<ExpressionOperator> operator = operatorStack.asList()
                    .stream().filter(o -> !o.equals(ExpressionOperator.LBrace)).findAny();
            if (braceCount != 0 && operator.isPresent()) {
                throw new IllegalStateException("withProperty()/where()/having() mixed inside braces ("
                        + (braceCount > 0 ? ("missing " + braceCount + " rbrace)") : (braceCount + " too many rbrace)")));
            }
        }

        public ConditionProperty<T> withProperty(Expression<T> property) {
            if (isHaving == true) {
                assertHaving();
            }
            isHaving = false;
            if (operatorStack.isEmpty() && !whereCriteriaStack.isEmpty()) {
                // implicit and condition
                and();
            }
            return new PropBuilderImpl(property, false);
        }

		public ConditionProperty<T> where(Expression<T> property) {
        	return withProperty(property);
		}

		public ConditionRoot<T> and() {
			operatorStack.push(ExpressionOperator.And);
            return this;
        }

        public ConditionRoot<T> or() {
            operatorStack.push(ExpressionOperator.Or);
            return this;
        }

        public ConditionRoot<T> not() {
            operatorStack.push(ExpressionOperator.Not);
            return this;
        }

        public OrderBy<T> orderBy(Expression<T> property) {
            pushCriteria(ConditionalCriteria.orderAsc(property));
            return this;
        }

        public ConditionRoot<T> distinctRoot() {
            pushCriteria(ConditionalCriteria.distinctRoot());
            return this;
        }

        public ConditionRoot<T> projectionRoot() {
           pushCriteria(ConditionalCriteria.projectionRoot());
           return this;
        }

		@Override
		public ConditionRoot<T> readOnly() {
			pushCriteria(ConditionalCriteria.readOnly());
			return this;
		}

		@Override
		public ConditionRoot<T> scroll() {
			pushCriteria(ConditionalCriteria.scroll());
			return this;
		}

        public ConditionRoot<T> ascending() {
            // syntactic sugar
            return this;
        }

        public ConditionRoot<T> descending() {
            ConditionalCriteria last = otherCriteriaStack.pop();
            if (last.getOperator() != Operator.OrderAsc) {
                throw new IllegalStateException("descending can only be used after orderBy");
            }
            pushCriteria(ConditionalCriteria.orderDesc(last.expression));
            return this;
        }

		@Override
		public GroupBy<T> groupBy(Expression<T> property) {
			pushCriteria(ConditionalCriteria.groupBy(property));
			return this;
		}

//		@Override
//		public GroupBy<T> groupBy(Expression<T> property, ConditionalCriteria.Function function) {
//			pushCriteria(ConditionalCriteria.groupBy(property, function));
//			return this;
//		}

		@Override
		public ConditionProperty<T> having(Expression<T> property) {
            if (isHaving == false) {
                assertHaving();
            }
            isHaving = true;
            if (operatorStack.isEmpty() && !havingCriteriaStack.isEmpty()) {
                // implicit and condition
                and();
            }
            return new PropBuilderImpl(property, true);
		}

		@Override
		public Selection<T> select(Expression<T> property) {
			pushCriteria(ConditionalCriteria.select(property));
			return this;
		}

//		@Override
//		public Selection<T> select(Expression<T> property, ConditionalCriteria.Function function) {
//			pushCriteria(ConditionalCriteria.select(property, function));
//			return this;
//		}

//		@Override
//		public Selection<T> select(Expression<T> property, ConditionalCriteria.Function function, String alias) {
//			ConditionalCriteria criteria = ConditionalCriteria.select(property, function);
//			criteria.propertyAlias = alias;
//			pushCriteria(criteria);
//			return this;
//		}

		@Override
		public Selection<T> select(Expression<T> property, String alias) {
			ConditionalCriteria criteria = ConditionalCriteria.select(property);
			criteria.propertyAlias = alias;
			pushCriteria(criteria);
			return this;
		}

		@Override
		public Selection<T> alias(String alias) {
			ConditionalCriteria last = otherCriteriaStack.pop();
			if (last.getOperator() != Operator.Select) {
				throw new IllegalStateException("alias can only be used after select");
			}
			last.propertyAlias = alias;
			pushCriteria(last);
			return this;
		}

        private void makeAggregateFunction(String operation, Consumer<ComplexExpression> c) {
            ConditionalCriteria last = otherCriteriaStack.pop();
            if (last.getOperator() != Operator.Select) {
                throw new IllegalStateException(operation + " can only be used after select");
            }

            ComplexExpression complexExpression;
            if (last.expression instanceof ComplexExpression) {
                complexExpression = (ComplexExpression) last.expression;
            } else if (last.expression instanceof Property) {
                complexExpression = ((Property) last.expression).expr();
            } else {
                throw new IllegalArgumentException("Expression " + last + " can NOT be cast to ComplexExpression");
            }
            c.accept(complexExpression);
            last.expression = complexExpression;
            pushCriteria(last);
        }

        @Override
		public ConditionRoot<T> max() {
            makeAggregateFunction("max", ComplexExpression::max);
			return this;
		}

        @Override
		public ConditionRoot<T> min() {
            makeAggregateFunction("min", ComplexExpression::min);
            return this;
		}

		@Override
		public ConditionRoot<T> sum() {
            makeAggregateFunction("sum", ComplexExpression::sum);
            return this;
		}

		@Override
		public ConditionRoot<T> avg() {
            makeAggregateFunction("avg", ComplexExpression::avg);
			return this;
		}

		@Override
		public ConditionRoot<T> sumAsLong() {
            makeAggregateFunction("sumAsLong", ComplexExpression::sumAsLong);
            return this;
		}

		@Override
		public ConditionRoot<T> sumAsDouble() {
            makeAggregateFunction("sumAsDouble", ComplexExpression::sumAsDouble);
            return this;
		}

		@Override
		public ConditionRoot<T> count() {
            makeAggregateFunction("count", ComplexExpression::count);
            return this;
		}

		@Override
		public ConditionRoot<T> countDistinct() {
            makeAggregateFunction("countDistinct", ComplexExpression::countDistinct);
            return this;
		}

		public ConditionRoot<T> lbrace() {
            braceCount++;
            operatorStack.push(ExpressionOperator.LBrace);
            return this;
        }

        public ConditionRootLogic<T> rbrace() {
            braceCount--;
            ExpressionOperator pop = operatorStack.pop();
            if (pop.equals(ExpressionOperator.And)) {
                operatorStack.pop();
            }
            if (isHaving && havingCriteriaStack.isEmpty() || whereCriteriaStack.isEmpty()) {
                return this;
            }
            SimpleStack<ConditionalCriteria> criteriaStack = isHaving ? havingCriteriaStack : whereCriteriaStack;
            ConditionalCriteria lastCriteria = criteriaStack.pop();
            pushCriteria(lastCriteria);
            return this;
        }

		@SuppressWarnings("unchecked")
		private void pushCriteria(ConditionalCriteria criteria) {
            ConditionalCriteria.OperatorType operatorType = criteria.getOperator().getOperatorType();
            if (ConditionalCriteria.OperatorType.Sql.equals(operatorType)
                    || ConditionalCriteria.OperatorType.Config.equals(operatorType)) {
                otherCriteriaStack.push(criteria);
            } else {
                SimpleStack<ConditionalCriteria> criteriaStack = isHaving ? havingCriteriaStack : whereCriteriaStack;
                ExpressionOperator currentOperator = operatorStack.peek();
                if (currentOperator == ExpressionOperator.Or || currentOperator == ExpressionOperator.And) {
                    ConditionalCriteria compositeCriteria;
                    ConditionalCriteria popCriteria = criteriaStack.pop();
                    if (popCriteria.getOperator() == Operator.And && currentOperator == ExpressionOperator.And
                            || popCriteria.getOperator() == Operator.Or && currentOperator == ExpressionOperator.Or) {
                        compositeCriteria = addSameCriteria(popCriteria, criteria);
                    } else if (popCriteria.getOperator() == Operator.Or && currentOperator == ExpressionOperator.And) {
                    	// Add to rightmost branch of OR
                        ConditionalCriteria rightmost;
                        if (popCriteria.getFirstOperant() instanceof List) {
                            List<ConditionalCriteria> criteriaList = (List<ConditionalCriteria>) popCriteria.getFirstOperant();
                            rightmost = criteriaList.get(criteriaList.size() - 1);
                            ConditionalCriteria newCriteria = rightmost.getOperator() == Operator.And
                                    ? addSameCriteria(rightmost, criteria)
                                    : ConditionalCriteria.and(rightmost, criteria);
                            criteriaList.set(criteriaList.size() - 1, newCriteria);
						} else {
                            rightmost = (ConditionalCriteria) popCriteria.getSecondOperant();
                            ConditionalCriteria newCriteria = rightmost.getOperator() == Operator.And
                                    ? addSameCriteria(rightmost, criteria)
                                    : ConditionalCriteria.and(rightmost, criteria);
                            popCriteria.secondOperant = newCriteria;
                        }
                        compositeCriteria = popCriteria;
                    } else if (currentOperator == ExpressionOperator.And) {
                        compositeCriteria = ConditionalCriteria.and(popCriteria, criteria);
                    } else {
                        // currentOperator == ExpressionOperator.Or
                        compositeCriteria = ConditionalCriteria.or(popCriteria, criteria);
                    }
                    criteriaStack.push(compositeCriteria);
                    operatorStack.pop();
                } else if (currentOperator == ExpressionOperator.Not) {
                    ConditionalCriteria notCriteria = ConditionalCriteria.not(criteria);
                    criteriaStack.push(notCriteria);
                    operatorStack.pop();
                    if (!operatorStack.isEmpty() && !criteriaStack.isEmpty()) {
                        pushCriteria(criteriaStack.pop());
                    }
                } else if (currentOperator == ExpressionOperator.LBrace) {
                    criteriaStack.push(criteria);
                    operatorStack.push(ExpressionOperator.And);
                } else {
                    criteriaStack.push(criteria);
                }
            }
        }

        private ConditionalCriteria addSameCriteria(ConditionalCriteria existingCriteria, ConditionalCriteria newCriteria) {
            ConditionalCriteria compositeCriteria;
            if (existingCriteria.getFirstOperant() instanceof List) {
                ((List<ConditionalCriteria>) existingCriteria.getFirstOperant()).add(newCriteria);
                compositeCriteria = existingCriteria;
            } else {
                List<ConditionalCriteria> critList = new ArrayList<ConditionalCriteria>();
                critList.add((ConditionalCriteria) existingCriteria.getFirstOperant());
                critList.add((ConditionalCriteria) existingCriteria.getSecondOperant());
                critList.add(newCriteria);
                compositeCriteria = existingCriteria.getOperator() == Operator.And
                        ? ConditionalCriteria.and(critList)
                        : ConditionalCriteria.or(critList);
            }

            return compositeCriteria;
        }

        private class PropBuilderImpl implements ConditionProperty<T>, Between<T> {
            Expression<T> baseProp;
            Object value1;
            boolean having;

            PropBuilderImpl(Expression<T> name, boolean having) {
                this.baseProp = name;
                this.having = having;
            }

            private void pushConditionalCriteria(ConditionalCriteria criteria) {
            	if (having) {
            	    criteria.setHaving();
                }
            	pushCriteria(criteria);
            }

            public ConditionRootLogic<T> eq(Object value) {
                pushConditionalCriteria(ConditionalCriteria.equal(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> ignoreCaseEq(Object value) {
               pushConditionalCriteria(ConditionalCriteria.ignoreCaseEqual(baseProp, value));
               return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> eq(Expression<T> property) {
                pushConditionalCriteria(ConditionalCriteria.equalProperty(baseProp, property));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> between(Object value1, Object value2) {
                pushConditionalCriteria(ConditionalCriteria.between(baseProp, value1, value2));
                return RootBuilderImpl.this;
            }

            public Between<T> between(Object value1) {
                this.value1 = value1;
                return this;
            }

            public ConditionRootLogic<T> to(Object value2) {
                pushConditionalCriteria(ConditionalCriteria.between(baseProp, value1, value2));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> lessThan(Object value) {
                pushConditionalCriteria(ConditionalCriteria.lessThan(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> lessThanOrEqual(Object value) {
                pushConditionalCriteria(ConditionalCriteria.lessThanOrEqual(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> greaterThan(Object value) {
                pushConditionalCriteria(ConditionalCriteria.greatThan(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> greaterThanOrEqual(Object value) {
                pushConditionalCriteria(ConditionalCriteria.greatThanOrEqual(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> lessThan(Expression<T> property) {
                pushConditionalCriteria(ConditionalCriteria.lessThanProperty(baseProp, property));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> lessThanOrEqual(Expression<T> property) {
                pushConditionalCriteria(ConditionalCriteria.lessThanOrEqualProperty(baseProp, property));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> greaterThan(Expression<T> property) {
                pushConditionalCriteria(ConditionalCriteria.greatThanProperty(baseProp, property));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> greaterThanOrEqual(Expression<T> property) {
                pushConditionalCriteria(ConditionalCriteria.greatThanOrEqualProperty(baseProp, property));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> like(Object value) {
                pushConditionalCriteria(ConditionalCriteria.like(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> ignoreCaseLike(Object value) {
                pushConditionalCriteria(ConditionalCriteria.ignoreCaseLike(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> in(Object... values) {
                pushConditionalCriteria(ConditionalCriteria.in(baseProp, values));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> in(Collection<?> values) {
                pushConditionalCriteria(ConditionalCriteria.in(baseProp, values));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> isNull() {
                pushConditionalCriteria(ConditionalCriteria.isNull(baseProp));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> isNotNull() {
                pushConditionalCriteria(ConditionalCriteria.isNotNull(baseProp));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> isEmpty() {
                pushConditionalCriteria(ConditionalCriteria.isEmpty(baseProp));
                return RootBuilderImpl.this;
            }

            public ConditionRootLogic<T> isNotEmpty() {
               pushConditionalCriteria(ConditionalCriteria.isNotEmpty(baseProp));
               return RootBuilderImpl.this;
           }

            public ConditionRootLogic<T> fetchEager() {
               pushConditionalCriteria(ConditionalCriteria.fetchEager(baseProp));
               return RootBuilderImpl.this;
           }

            public ConditionRootLogic<T> fetchLazy() {
               pushConditionalCriteria(ConditionalCriteria.fetchLazy(baseProp));
               return RootBuilderImpl.this;
           }
        }
   }

    public interface ConditionRoot<T> {
        List<ConditionalCriteria> build();
		ConditionalCriteria buildSingle();
        ConditionRoot<T> not();
        ConditionProperty<T> withProperty(Expression<T> property);
		ConditionProperty<T> where(Expression<T> property);
        Selection<T> select(Expression<T> property);
        Selection<T> select(Expression<T> property, String alias);
        OrderBy<T> orderBy(Expression<T> property);
        GroupBy<T> groupBy(Expression<T> property);
		ConditionProperty<T> having(Expression<T> property);
		ConditionRoot<T> distinctRoot();
        ConditionRoot<T> projectionRoot();
        ConditionRoot<T> readOnly();
        ConditionRoot<T> scroll();
        ConditionRoot<T> lbrace();
        ConditionRootLogic<T> rbrace();
    }

    public interface ConditionRootLogic<T> extends ConditionRoot<T> {
        ConditionRoot<T> and();
        ConditionRoot<T> or();
    }

    public interface ConditionProperty<T> {
        ConditionRootLogic<T> eq(Object value);
        ConditionRootLogic<T> ignoreCaseEq(Object value);
        ConditionRootLogic<T> eq(Expression<T> property);
        ConditionRootLogic<T> between(Object value1, Object value2);
        Between<T> between(Object value1);
        ConditionRootLogic<T> lessThan(Object value);
        ConditionRootLogic<T> lessThanOrEqual(Object value);
        ConditionRootLogic<T> greaterThan(Object value);
        ConditionRootLogic<T> greaterThanOrEqual(Object value);
        ConditionRootLogic<T> lessThan(Expression<T> property);
        ConditionRootLogic<T> lessThanOrEqual(Expression<T> property);
        ConditionRootLogic<T> greaterThan(Expression<T> property);
        ConditionRootLogic<T> greaterThanOrEqual(Expression<T> property);
        ConditionRootLogic<T> like(Object value);
        ConditionRootLogic<T> ignoreCaseLike(Object value);
        ConditionRootLogic<T> in(Object... values);
        ConditionRootLogic<T> in(Collection<?> values);
        ConditionRootLogic<T> isNull();
        ConditionRootLogic<T> isNotNull();
        ConditionRootLogic<T> isEmpty();
        ConditionRootLogic<T> isNotEmpty();
        ConditionRootLogic<T> fetchLazy();
        ConditionRootLogic<T> fetchEager();
    }

    public interface Between<T> {
        ConditionRootLogic<T> to(Object value2);
    }

	public interface Selection<T> extends ConditionRoot<T> {
		Selection<T> alias(String alias);

        ConditionRoot<T> max();
        ConditionRoot<T> min();
        ConditionRoot<T> avg();
        ConditionRoot<T> sum();
        ConditionRoot<T> sumAsLong();
        ConditionRoot<T> sumAsDouble();
        ConditionRoot<T> count();
        ConditionRoot<T> countDistinct();
    }

    public interface OrderBy<T> extends ConditionRoot<T> {
        ConditionRoot<T> ascending();
        ConditionRoot<T> descending();
    }

    public interface GroupBy<T> extends ConditionRoot<T> {
    }

    private static class SimpleStack<T> {
        private final List<T> list = new ArrayList<T>();

        T pop() {
            if (list.isEmpty()) {
                throw new IllegalStateException("Can't pop from empty stack.");
            }
            return list.remove(list.size() - 1);
        }

        public List<T> asList() {
            return new ArrayList<T>(list);
        }

        T peek() {
            if (list.isEmpty()) {
                return null;
            }
            return list.get(list.size() - 1);
        }

        void push(T item) {
            list.add(item);
        }

        int size() {
            return list.size();
        }

        public boolean isEmpty() {
            return size() == 0;
        }
    }

}
