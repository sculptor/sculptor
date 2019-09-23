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

import org.sculptor.framework.accessapi.ConditionalCriteria.Operator;
import org.sculptor.framework.domain.Property;

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

    public class RootBuilderImpl implements ConditionRoot<T>, OrderBy<T>, Selection<T>, GroupBy<T> {
        private final SimpleStack<ConditionalCriteria> criteriaStack = new SimpleStack<ConditionalCriteria>();
        private final SimpleStack<ExpressionOperator> operatorStack = new SimpleStack<ExpressionOperator>();

        // only used to give good error message
        private int braceCount;

        /**
         * End the expression with this build
         */
        @SuppressWarnings("unchecked")
        public List<ConditionalCriteria> build() {
            assertBraceCount();
            assertOperatorStack();

            List<ConditionalCriteria> critList = new ArrayList<ConditionalCriteria>();
            for (ConditionalCriteria singleCrit : criteriaStack.asList()) {
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
            return critList;
        }

        /**
         * Easier to use from test
         */
        public ConditionalCriteria buildSingle() {
            assertBraceCount();
            assertOperatorStack();
            if (criteriaStack.size() > 1) {
                throw new IllegalStateException("Invalid criteria, too many items in the build stack: "
                        + criteriaStack.size());
            }
            if (criteriaStack.isEmpty()) {
                return null;
            }
            return criteriaStack.peek();
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

        public ConditionProperty<T> withProperty(Property<T> property) {
            if (operatorStack.isEmpty() && !criteriaStack.isEmpty()) {
                // implicit and condition
                and();
            }
            return new PropBuilderImpl(property);
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

        public OrderBy<T> orderBy(Property<T> property) {
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
            ConditionalCriteria last = popCriteria();
            if (last.getOperator() != Operator.OrderAsc) {
                throw new IllegalStateException("descending can only be used after orderBy");
            }
            pushCriteria(ConditionalCriteria.orderDesc(last.property));
            return this;
        }

		@Override
		public GroupBy<T> groupBy(Property<T> property) {
			pushCriteria(ConditionalCriteria.groupBy(property));
			return this;
		}

		@Override
		public GroupBy<T> groupBy(Property<T> property, ConditionalCriteria.Function function) {
			pushCriteria(ConditionalCriteria.groupBy(property, function));
			return this;
		}

		@Override
		public Selection<T> select(Property<T> property) {
			pushCriteria(ConditionalCriteria.select(property));
			return this;
		}

		@Override
		public Selection<T> select(Property<T> property, ConditionalCriteria.Function function) {
			pushCriteria(ConditionalCriteria.select(property, function));
			return this;
		}

		@Override
		public Selection<T> select(Property<T> property, ConditionalCriteria.Function function, String alias) {
			ConditionalCriteria criteria = ConditionalCriteria.select(property, function);
			criteria.propertyAlias = alias;
			pushCriteria(criteria);
			return this;
		}

		@Override
		public Selection<T> select(Property<T> property, String alias) {
			ConditionalCriteria criteria = ConditionalCriteria.select(property);
			criteria.propertyAlias = alias;
			pushCriteria(criteria);
			return this;
		}

		@Override
		public Selection<T> alias(String alias) {
			ConditionalCriteria last = popCriteria();
			if (last.getOperator() != Operator.Select) {
				throw new IllegalStateException("alias can only be used after select");
			}
			last.propertyAlias = alias;
			pushCriteria(last);
			return this;
		}

		@Override
		public ConditionRoot<T> max() {
            ConditionalCriteria last = popCriteria();
            if (last.getOperator() != Operator.Select) {
                throw new IllegalStateException("max can only be used after select");
            }
            last.operator = Operator.Max;
            pushCriteria(last);
			return this;
		}

		@Override
		public ConditionRoot<T> min() {
            ConditionalCriteria last = popCriteria();
            if (last.getOperator() != Operator.Select) {
                throw new IllegalStateException("min can only be used after select");
            }
            last.operator = Operator.Min;
            pushCriteria(last);
			return this;
		}

		@Override
		public ConditionRoot<T> sum() {
            ConditionalCriteria last = popCriteria();
            if (last.getOperator() != Operator.Select) {
                throw new IllegalStateException("sum can only be used after select");
            }
            last.operator = Operator.Sum;
            pushCriteria(last);
			return this;
		}

		@Override
		public ConditionRoot<T> avg() {
            ConditionalCriteria last = popCriteria();
            if (last.getOperator() != Operator.Select) {
                throw new IllegalStateException("avg can only be used after select");
            }
            last.operator = Operator.Avg;
            pushCriteria(last);
			return this;
		}

		@Override
		public ConditionRoot<T> sumAsLong() {
            ConditionalCriteria last = popCriteria();
            if (last.getOperator() != Operator.Select) {
                throw new IllegalStateException("sumAsLong can only be used after select");
            }
            last.operator = Operator.SumAsLong;
            pushCriteria(last);
			return this;
		}

		@Override
		public ConditionRoot<T> sumAsDouble() {
            ConditionalCriteria last = popCriteria();
            if (last.getOperator() != Operator.Select) {
                throw new IllegalStateException("sumAsDouble can only be used after select");
            }
            last.operator = Operator.SumAsDouble;
            pushCriteria(last);
			return this;
		}

		@Override
		public ConditionRoot<T> count() {
            ConditionalCriteria last = popCriteria();
            if (last.getOperator() != Operator.Select) {
                throw new IllegalStateException("count can only be used after select");
            }
            last.operator = Operator.Count;
            pushCriteria(last);
			return this;
		}

		@Override
		public ConditionRoot<T> countDistinct() {
            ConditionalCriteria last = popCriteria();
            if (last.getOperator() != Operator.Select) {
                throw new IllegalStateException("countDistinct can only be used after select");
            }
            last.operator = Operator.CountDistinct;
            pushCriteria(last);
			return this;
		}

		public ConditionRoot<T> lbrace() {
            braceCount++;
            operatorStack.push(ExpressionOperator.LBrace);
            return this;
        }

        public ConditionRoot<T> rbrace() {
            braceCount--;
            operatorStack.pop();
            if (criteriaStack.isEmpty()) {
                return this;
            }
            ConditionalCriteria lastCriteria = popCriteria();
            pushCriteria(lastCriteria);
            return this;
        }

        private ConditionalCriteria popCriteria() {
            return criteriaStack.pop();
        }

      @SuppressWarnings("unchecked")
      private void pushCriteria(ConditionalCriteria criteria) {
            ExpressionOperator currentOperator = operatorStack.peek();
            if (currentOperator == ExpressionOperator.Or || currentOperator == ExpressionOperator.And) {
                ConditionalCriteria compositeCriteria;
                if (currentOperator == ExpressionOperator.Or) {
                    compositeCriteria = ConditionalCriteria.or(popCriteria(), criteria);
                } else {
                    ConditionalCriteria popCriteria = popCriteria();
                    if (popCriteria.getOperator() == Operator.And && popCriteria.getFirstOperant() instanceof List) {
                        ((List<ConditionalCriteria>) popCriteria.getFirstOperant()).add(criteria);
                        compositeCriteria = popCriteria;
                    } else if (popCriteria.getOperator() == Operator.And) {
                       List<ConditionalCriteria> critList=new ArrayList<ConditionalCriteria>();
                       critList.add((ConditionalCriteria) popCriteria.getFirstOperant());
                       critList.add((ConditionalCriteria) popCriteria.getSecondOperant());
                       critList.add(criteria);
                       compositeCriteria = ConditionalCriteria.and(critList);
                    } else {
                       compositeCriteria = ConditionalCriteria.and(popCriteria, criteria);
                    }
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
            } else {
                criteriaStack.push(criteria);
            }
        }

        private class PropBuilderImpl implements ConditionProperty<T>, Between<T> {
            Property<?> baseProp;
            Object value1;

            PropBuilderImpl(Property<?> name) {
                this.baseProp = name;
            }

            public ConditionRoot<T> eq(Object value) {
                pushCriteria(ConditionalCriteria.equal(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> ignoreCaseEq(Object value) {
               pushCriteria(ConditionalCriteria.ignoreCaseEqual(baseProp, value));
               return RootBuilderImpl.this;
            }

            public ConditionRoot<T> eq(Property<T> property) {
                pushCriteria(ConditionalCriteria.equalProperty(baseProp, property));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> between(Object value1, Object value2) {
                pushCriteria(ConditionalCriteria.between(baseProp, value1, value2));
                return RootBuilderImpl.this;
            }

            public Between<T> between(Object value1) {
                this.value1 = value1;
                return this;
            }

            public ConditionRoot<T> to(Object value2) {
                pushCriteria(ConditionalCriteria.between(baseProp, value1, value2));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> lessThan(Object value) {
                pushCriteria(ConditionalCriteria.lessThan(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> lessThanOrEqual(Object value) {
                pushCriteria(ConditionalCriteria.lessThanOrEqual(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> greaterThan(Object value) {
                pushCriteria(ConditionalCriteria.greatThan(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> greaterThanOrEqual(Object value) {
                pushCriteria(ConditionalCriteria.greatThanOrEqual(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> lessThan(Property<T> property) {
                pushCriteria(ConditionalCriteria.lessThanProperty(baseProp, property));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> lessThanOrEqual(Property<T> property) {
                pushCriteria(ConditionalCriteria.lessThanOrEqualProperty(baseProp, property));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> greaterThan(Property<T> property) {
                pushCriteria(ConditionalCriteria.greatThanProperty(baseProp, property));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> greaterThanOrEqual(Property<T> property) {
                pushCriteria(ConditionalCriteria.greatThanOrEqualProperty(baseProp, property));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> like(Object value) {
                pushCriteria(ConditionalCriteria.like(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> ignoreCaseLike(Object value) {
                pushCriteria(ConditionalCriteria.ignoreCaseLike(baseProp, value));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> in(Object... values) {
                pushCriteria(ConditionalCriteria.in(baseProp, values));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> in(Collection<?> values) {
                pushCriteria(ConditionalCriteria.in(baseProp, values));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> isNull() {
                pushCriteria(ConditionalCriteria.isNull(baseProp));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> isNotNull() {
                pushCriteria(ConditionalCriteria.isNotNull(baseProp));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> isEmpty() {
                pushCriteria(ConditionalCriteria.isEmpty(baseProp));
                return RootBuilderImpl.this;
            }

            public ConditionRoot<T> isNotEmpty() {
               pushCriteria(ConditionalCriteria.isNotEmpty(baseProp));
               return RootBuilderImpl.this;
           }

            public ConditionRoot<T> fetchEager() {
               pushCriteria(ConditionalCriteria.fetchEager(baseProp));
               return RootBuilderImpl.this;
           }

            public ConditionRoot<T> fetchLazy() {
               pushCriteria(ConditionalCriteria.fetchLazy(baseProp));
               return RootBuilderImpl.this;
           }
        }
   }

    public interface ConditionRoot<T> {
        List<ConditionalCriteria> build();
		ConditionalCriteria buildSingle();
        ConditionProperty<T> withProperty(Property<T> property);
        ConditionRoot<T> and();
        ConditionRoot<T> or();
        ConditionRoot<T> not();
        Selection<T> select(Property<T> property);
        Selection<T> select(Property<T> property, ConditionalCriteria.Function function);
        Selection<T> select(Property<T> property, ConditionalCriteria.Function function, String alias);
        Selection<T> select(Property<T> property, String alias);
        OrderBy<T> orderBy(Property<T> property);
        GroupBy<T> groupBy(Property<T> property);
        GroupBy<T> groupBy(Property<T> property, ConditionalCriteria.Function function);
        ConditionRoot<T> distinctRoot();
        ConditionRoot<T> projectionRoot();
        ConditionRoot<T> readOnly();
        ConditionRoot<T> scroll();
        ConditionRoot<T> lbrace();
        ConditionRoot<T> rbrace();
    }

    public interface ConditionProperty<T> {
        ConditionRoot<T> eq(Object value);
        ConditionRoot<T> ignoreCaseEq(Object value);
        ConditionRoot<T> eq(Property<T> property);
        ConditionRoot<T> between(Object value1, Object value2);
        Between<T> between(Object value1);
        ConditionRoot<T> lessThan(Object value);
        ConditionRoot<T> lessThanOrEqual(Object value);
        ConditionRoot<T> greaterThan(Object value);
        ConditionRoot<T> greaterThanOrEqual(Object value);
        ConditionRoot<T> lessThan(Property<T> property);
        ConditionRoot<T> lessThanOrEqual(Property<T> property);
        ConditionRoot<T> greaterThan(Property<T> property);
        ConditionRoot<T> greaterThanOrEqual(Property<T> property);
        ConditionRoot<T> like(Object value);
        ConditionRoot<T> ignoreCaseLike(Object value);
        ConditionRoot<T> in(Object... values);
        ConditionRoot<T> in(Collection<?> values);
        ConditionRoot<T> isNull();
        ConditionRoot<T> isNotNull();
        ConditionRoot<T> isEmpty();
        ConditionRoot<T> isNotEmpty();
        ConditionRoot<T> fetchLazy();
        ConditionRoot<T> fetchEager();
    }

    public interface Between<T> {
        ConditionRoot<T> to(Object value2);
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
// TODO:
//    	ConditionRoot<T> having(...);
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
