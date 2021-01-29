package org.sculptor.framework.accessapi;

import static org.junit.jupiter.api.Assertions.*;
import static org.sculptor.framework.accessapi.ConditionalCriteria.Operator.*;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilderTest.PersonProperties.*;

import java.util.Arrays;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.sculptor.framework.accessapi.ConditionalCriteriaBuilderTest.AddressProperties.AddressProperty;
import org.sculptor.framework.domain.LeafProperty;
import org.sculptor.framework.domain.PropertiesCollection;
import org.sculptor.framework.domain.Property;

public class ConditionalCriteriaBuilderTest {

	@Test
	public void testLongPathElements() {
		ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(PersonProperties.boss().boss().boss().aaa()).eq(1234)
			.buildSingle();
		
		assertEquals("aaa", criteria.getPropertyName());
		assertEquals(Equal, criteria.getOperator());
		assertEquals(1234, criteria.getFirstOperant());
		assertNull(criteria.getSecondOperant());
		for (String path : criteria.getPropertyPath()) {
			assertEquals("boss", path);
		}
	}

   @Test
    public void shouldBuildSimpleEqualsCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(PersonProperties.aaa()).eq(1234)
                .buildSingle();

        assertEquals("aaa", criteria.getPropertyName());
        assertEquals(Equal, criteria.getOperator());
        assertEquals(1234, criteria.getFirstOperant());
        assertNull(criteria.getSecondOperant());
    }

    @Test
    public void shouldBuildNestedProperties() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(
                PersonProperties.primaryAddress().city())
                .eq("Stockholm")
                .buildSingle();

        assertEquals("primaryAddress.city", criteria.getPropertyName());
        assertEquals(Equal, criteria.getOperator());
        assertEquals("Stockholm", criteria.getFirstOperant());
        assertNull(criteria.getSecondOperant());
    }

    @Test
    public void shouldBuildWithStaticImportProperty() {
        // import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilderTest.Person.PersonProperties.primaryAddress;
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(
                primaryAddress().city())
                .eq("Stockholm").buildSingle();

        assertEquals("primaryAddress.city", criteria.getPropertyName());
        assertEquals(Equal, criteria.getOperator());
        assertEquals("Stockholm", criteria.getFirstOperant());
        assertNull(criteria.getSecondOperant());
    }

    @Test
    public void shouldBuildWithEqObjectProperty() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(primaryAddress()).eq(
                new Address("Kungsgatan 10", "Stockholm"))
                .buildSingle();

        assertEquals("primaryAddress", criteria.getPropertyName());
        assertEquals(Equal, criteria.getOperator());
        assertNull(criteria.getSecondOperant());
    }

    @Test
    public void shouldBuildSimpleBetweenCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).between(1234, 6789)
                .buildSingle();

        assertEquals(ConditionalCriteria.Operator.Between, criteria.getOperator());
        assertEquals(1234, criteria.getFirstOperant());
        assertEquals(6789, criteria.getSecondOperant());
    }

    @Test
    public void shouldBuildLessThanCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).lessThan(1234).buildSingle();

        assertEquals(LessThan, criteria.getOperator());
        assertEquals(1234, criteria.getFirstOperant());
    }

    @Test
    public void shouldBuildLikeCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).like("A").buildSingle();

        assertEquals(ConditionalCriteria.Operator.Like, criteria.getOperator());
        assertEquals("A", criteria.getFirstOperant());
    }

    @Test
    public void shouldBuildInCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).in("A", "B").buildSingle();

        assertEquals(ConditionalCriteria.Operator.In, criteria.getOperator());
    }

    @Test
    public void shouldBuildIsNullCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).isNull().buildSingle();

        assertEquals(ConditionalCriteria.Operator.IsNull, criteria.getOperator());
    }

    @Test
    public void shouldBuildEqualsPropertyCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(PersonProperties.aaa()).eq(
                PersonProperties.bbb()).buildSingle();

        assertEquals("aaa", criteria.getPropertyName());
        assertEquals(ConditionalCriteria.Operator.EqualProperty, criteria.getOperator());
        assertEquals("bbb", ((Property) criteria.getFirstOperant()).getName());
    }


    @Test
    public void shouldBuildBetweenToCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).between(1234).to(6789)
                .buildSingle();

        assertEquals(ConditionalCriteria.Operator.Between, criteria.getOperator());
        assertEquals(1234, criteria.getFirstOperant());
        assertEquals(6789, criteria.getSecondOperant());
    }

    @Test
    public void shouldBuildAndCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).eq(1234).and().withProperty(bbb())
                .eq("zzz")
                .buildSingle();

        assertEquals(And, criteria.getOperator());
        ConditionalCriteria firstOperant = (ConditionalCriteria) criteria.getFirstOperant();
        ConditionalCriteria secondOperant = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals("aaa", ((Property) firstOperant.expression).getName());
        assertEquals("bbb", ((Property) secondOperant.expression).getName());
    }

    @Test
    public void shouldBuildAndConditionWithoutAndKeyword() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).eq(1234).withProperty(bbb()).eq(
                "zzz")
                .buildSingle();

        assertEquals(And, criteria.getOperator());
        ConditionalCriteria firstOperant = (ConditionalCriteria) criteria.getFirstOperant();
        ConditionalCriteria secondOperant = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals("aaa", ((Property) firstOperant.expression).getName());
        assertEquals("bbb", ((Property) secondOperant.expression).getName());
    }

    @Test
    public void shouldBuildSingleListOfConditions() {
        ConditionalCriteria criteriaS = criteriaFor(Person.class).withProperty(aaa()).eq(1234).and().withProperty(bbb())
                .eq("zzz")
                .and()
                .withProperty(ccc()).eq("xxx").buildSingle();

        assertEquals(And, criteriaS.getOperator());

        @SuppressWarnings("unchecked")
        List<ConditionalCriteria> criteria=(List<ConditionalCriteria>) criteriaS.getFirstOperant();
        ConditionalCriteria first=(ConditionalCriteria) criteria.get(0);
        ConditionalCriteria second=(ConditionalCriteria) criteria.get(1);
        ConditionalCriteria third=(ConditionalCriteria) criteria.get(2);
        assertEquals("aaa", ((Property) first.expression).getName());
        assertEquals("bbb", ((Property) second.expression).getName());
        assertEquals("ccc", ((Property) third.expression).getName());
    }

    @Test
    public void shouldBuildListOfConditions() {
        List<ConditionalCriteria> criteria = criteriaFor(Person.class)
                .withProperty(aaa()).eq(1234)
                .and().withProperty(bbb()).eq("zzz")
                .and().withProperty(ccc()).eq("xxx")
                .build();

        ConditionalCriteria first=(ConditionalCriteria) criteria.get(0);
        ConditionalCriteria second=(ConditionalCriteria) criteria.get(1);
        ConditionalCriteria third=(ConditionalCriteria) criteria.get(2);
        assertEquals("aaa", ((Property) first.expression).getName());
        assertEquals("bbb", ((Property) second.expression).getName());
        assertEquals("ccc", ((Property) third.expression).getName());
    }

    @Test
    public void shouldBuildOrCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).eq(1234).or().withProperty(bbb())
                .eq("zzz")
                .buildSingle();

        assertNull(criteria.getPropertyName());
        assertEquals(Or, criteria.getOperator());
        ConditionalCriteria left = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals("aaa", ((Property) left.expression).getName());
        ConditionalCriteria right = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals("bbb", ((Property) right.expression).getName());
    }

    @Test
    public void shouldBuildNotCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).not().withProperty(aaa()).eq(1234).buildSingle();

        assertNull(criteria.getPropertyName());
        assertEquals(ConditionalCriteria.Operator.Not, criteria.getOperator());
        ConditionalCriteria op = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals("aaa", ((Property) op.expression).getName());
    }

    @Test
    public void shouldBuildOrderByAsc() {
        ConditionalCriteria criteria = criteriaFor(Person.class).orderBy(ccc()).ascending().buildSingle();

        assertEquals(ConditionalCriteria.Operator.OrderAsc, criteria.getOperator());
        assertEquals("ccc", criteria.getPropertyName());
    }

    @Test
    public void shouldBuildOrderByDesc() {
        ConditionalCriteria criteria = criteriaFor(Person.class).orderBy(ccc()).descending().buildSingle();

        assertEquals(ConditionalCriteria.Operator.OrderDesc, criteria.getOperator());
        assertEquals("ccc", criteria.getPropertyName());
    }

    @Test
    public void shouldBuildEqualsWithOrderBy() {
        List<ConditionalCriteria> criteriaList = criteriaFor(Person.class)
                .withProperty(aaa()).eq(1234)
                .withProperty(bbb()).eq("qqq")
                .orderBy(ccc()).ascending()
                .build();
        assertEquals(3, criteriaList.size());

        ConditionalCriteria criteria1 = criteriaList.get(0);
        assertEquals("aaa", criteria1.getPropertyName());
        assertEquals(Equal, criteria1.getOperator());
        assertEquals(1234, criteria1.getFirstOperant());
        assertNull(criteria1.getSecondOperant());

        ConditionalCriteria criteria2 = criteriaList.get(1);
        assertEquals("bbb", criteria2.getPropertyName());
        assertEquals(Equal, criteria2.getOperator());
        assertEquals("qqq", criteria2.getFirstOperant());
        assertNull(criteria2.getSecondOperant());

        ConditionalCriteria criteria3 = criteriaList.get(2);
        assertEquals(ConditionalCriteria.Operator.OrderAsc, criteria3.getOperator());
        assertEquals("ccc", criteria3.getPropertyName());
    }

    @Test
    public void shouldBuildEqualsConditionWithBraces() {
        ConditionalCriteria criteria = criteriaFor(Person.class).lbrace().withProperty(aaa()).eq(1234).rbrace()
                .buildSingle();

        assertEquals("aaa", criteria.getPropertyName());
        assertEquals(Equal, criteria.getOperator());
        assertEquals(1234, criteria.getFirstOperant());
        assertNull(criteria.getSecondOperant());
    }

    @Test
    public void shouldBuildOrConditionWithBraces() {
        ConditionalCriteria criteria = criteriaFor(Person.class).lbrace().withProperty(aaa()).eq(1234).or()
                .withProperty(bbb()).eq("zzz").rbrace()
                .buildSingle();

        assertNull(criteria.getPropertyName());
        assertEquals(Or, criteria.getOperator());
        ConditionalCriteria left = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals("aaa", ((Property) left.expression).getName());
        ConditionalCriteria right = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals("bbb", ((Property) right.expression).getName());
    }

    @Test
    public void shouldBuildEmptyBraces() {
        ConditionalCriteria criteria = criteriaFor(Person.class).lbrace().rbrace().buildSingle();
        assertNull(criteria);
    }

    @Test
    public void shouldBuildMultipleEmptyBraces() {
        ConditionalCriteria criteria = criteriaFor(Person.class).lbrace().lbrace().lbrace().rbrace().rbrace()
                .rbrace().buildSingle();
        assertNull(criteria);
    }

    /**
     * A and B or C
     * <pre>
     *           or
     *         /    \
     *      and      C
     *     /   \
     *    A     B
     *
     * </pre>
     */
    @Test
    public void shouldBuildUngroupedAndOr() {
        ConditionalCriteria criteria =
            criteriaFor(Person.class).withProperty(aaa()).eq("A").and().withProperty(bbb())
                .eq("B")
                .or()
                .withProperty(ccc()).eq("C")
                .buildSingle();

        assertEquals(Or, criteria.getOperator());
        ConditionalCriteria left1 = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(And, left1.getOperator());
        ConditionalCriteria right1 = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(Equal, right1.getOperator());
        assertEquals("ccc", ((Property) right1.expression).getName());
        assertEquals("C", right1.getFirstOperant());
    }

    /**
     * A and !B or C
     *
     * <pre>
     *           or
     *         /    \
     *      and      C
     *     /   \
     *    A     not
     *           |
     *           B
     *
     * </pre>
     */
    @Test
    public void shouldBuildUngroupedNotAndOr() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).eq("A").and().not().withProperty(
                bbb()).eq("B").or().withProperty(ccc()).eq("C").buildSingle();

        assertEquals(Or, criteria.getOperator());
        ConditionalCriteria left1 = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(And, left1.getOperator());
        ConditionalCriteria notCriteria = ((ConditionalCriteria) left1.getSecondOperant());
        assertEquals(ConditionalCriteria.Operator.Not, notCriteria.getOperator());
        ConditionalCriteria firstOper=(ConditionalCriteria) notCriteria.getFirstOperant();
        assertEquals("bbb", ((Property) firstOper.expression).getName());

        ConditionalCriteria right1 = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(Equal, right1.getOperator());
        assertEquals("ccc", right1.getPropertyName());
        assertEquals("C", right1.getFirstOperant());
    }

    /**
     * !(A and B) or C
     *
     * <pre>
     *           or
     *         /    \
     *       not     C
     *        |
     *       and
     *      /   \
     *     A     B
     *
     * </pre>
     */
    @Test
    public void shouldBuildGroupedNotAndOr() {
        ConditionalCriteria criteria = criteriaFor(Person.class).not().lbrace().withProperty(aaa()).eq("A").and()
                .withProperty(bbb()).eq("B").rbrace().or().withProperty(ccc()).eq("C").buildSingle();

        assertEquals(Or, criteria.getOperator());
        ConditionalCriteria left1 = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(ConditionalCriteria.Operator.Not, left1.getOperator());

        ConditionalCriteria andCriteria = ((ConditionalCriteria) left1.getFirstOperant());
        assertEquals(And, andCriteria.getOperator());
        assertEquals("aaa", ((ConditionalCriteria) andCriteria.getFirstOperant()).getPropertyName());
        assertEquals("bbb", ((ConditionalCriteria) andCriteria.getSecondOperant()).getPropertyName());

        ConditionalCriteria right1 = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(Equal, right1.getOperator());
        assertEquals("ccc", right1.getPropertyName());
        assertEquals("C", right1.getFirstOperant());
    }

    /**
     * A and (B or C)
     * <pre>
     *           and
     *         /    \
     *        A      or
     *               / \
     *              B   C
     *
     * </pre>
     */
    @Test
    public void shouldBuildGroupedAndOr1() {
        ConditionalCriteria criteria =
            criteriaFor(Person.class).withProperty(aaa()).eq("A").and().lbrace()
                .withProperty(bbb()).eq("B").or().withProperty(ccc()).eq("C").rbrace()
                .buildSingle();

        assertEquals(And, criteria.getOperator());
        ConditionalCriteria left1 = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(Equal, left1.getOperator());
        assertEquals("aaa", left1.getPropertyName());
        assertEquals("A", left1.getFirstOperant());

        ConditionalCriteria right1 = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(Or, right1.getOperator());

    }

    /**
     * A, !(B or C)
     * <pre>
     *        A[0], not[1]
     *               |
     *               or
     *              / \
     *             B   C
     *
     * </pre>
     */
    @Test
    public void shouldBuildGroupedAndOr1Implicit() {
        List<ConditionalCriteria> criteriaList =
                criteriaFor(Person.class).where(aaa()).greaterThanOrEqual("A")
                        .not().lbrace() .where(bbb()).eq("B") .or() .where(ccc()).eq("C") .rbrace()
                        .build();

        ConditionalCriteria criteria0 = criteriaList.get(0);
        assertEquals(ConditionalCriteria.Operator.GreatThanOrEqual, criteria0.getOperator());
        assertEquals("aaa", criteria0.getPropertyName());
        assertEquals("A", criteria0.getFirstOperant());

        ConditionalCriteria criteria1 = criteriaList.get(1);
        assertEquals(ConditionalCriteria.Operator.Not, criteria1.getOperator());
        ConditionalCriteria inside = (ConditionalCriteria) criteria1.getFirstOperant();
        assertEquals(Or, inside.getOperator());
        ConditionalCriteria insideLeft = (ConditionalCriteria) inside.getFirstOperant();
        assertEquals("bbb", insideLeft.getPropertyName());
        assertEquals("B", insideLeft.getFirstOperant());
        ConditionalCriteria insideRight = (ConditionalCriteria) inside.getSecondOperant();
        assertEquals("ccc", insideRight.getPropertyName());
        assertEquals("C", insideRight.getFirstOperant());
    }

    /**
     * (A and B) or (C and D)
     * <pre>
     *           or
     *         /    \
     *      and      and
     *     /   \     /  \
     *    A     B   C    D
     *
     * </pre>
     */
    @Test
    public void shouldBuildGroupedAndOr2() {
        ConditionalCriteria criteria =
                criteriaFor(Person.class).lbrace().withProperty(aaa()).eq("A").and()
                        .withProperty(bbb()).eq("B").rbrace()
                        .or()
                        .lbrace().withProperty(ccc()).eq("C").and().withProperty(
                        ddd()).eq("D").rbrace()
                        .buildSingle();

        assertEquals(Or, criteria.getOperator());
        ConditionalCriteria leftAnd = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(And, leftAnd.getOperator());
        ConditionalCriteria rightAnd = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(And, rightAnd.getOperator());

        assertEquals(Equal, ((ConditionalCriteria) leftAnd.getFirstOperant())
                .getOperator());
        assertEquals(Equal, ((ConditionalCriteria) leftAnd.getSecondOperant())
                .getOperator());
        assertEquals("aaa", ((ConditionalCriteria) leftAnd.getFirstOperant()).getPropertyName());
        assertEquals("bbb", ((ConditionalCriteria) leftAnd.getSecondOperant()).getPropertyName());

        assertEquals(Equal, ((ConditionalCriteria) rightAnd.getFirstOperant())
                .getOperator());
        assertEquals(Equal, ((ConditionalCriteria) rightAnd.getSecondOperant())
                .getOperator());
        assertEquals("ccc", ((ConditionalCriteria) rightAnd.getFirstOperant()).getPropertyName());
        assertEquals("ddd", ((ConditionalCriteria) rightAnd.getSecondOperant()).getPropertyName());

    }

    /**
     * A and B or C and D (or has higher priority than and)
     * <pre>
     *           or
     *         /    \
     *      and      and
     *     /   \     /  \
     *    A     B   C    D
     *
     * </pre>
     */
    @Test
    public void shouldBuildGroupedAndOr3() {
        ConditionalCriteria criteria =
                criteriaFor(Person.class)
                        .where(aaa()).lessThan("A").and().where(bbb()).greaterThan("B")
                        .or()
                        .where(ccc()).ignoreCaseEq("C").and().where(ddd()).ignoreCaseLike("D")
                        .buildSingle();

        assertEquals(Or, criteria.getOperator());
        ConditionalCriteria leftAnd = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(And, leftAnd.getOperator());
        ConditionalCriteria rightAnd = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(And, rightAnd.getOperator());

        assertEquals("aaa", ((ConditionalCriteria) leftAnd.getFirstOperant()).getPropertyName());
        assertEquals("bbb", ((ConditionalCriteria) leftAnd.getSecondOperant()).getPropertyName());
        assertEquals(LessThan, ((ConditionalCriteria) leftAnd.getFirstOperant())
                .getOperator());
        assertEquals(GreatThan, ((ConditionalCriteria) leftAnd.getSecondOperant())
                .getOperator());

        assertEquals("ccc", ((ConditionalCriteria) rightAnd.getFirstOperant()).getPropertyName());
        assertEquals("ddd", ((ConditionalCriteria) rightAnd.getSecondOperant()).getPropertyName());
        assertEquals(IgnoreCaseEqual, ((ConditionalCriteria) rightAnd.getFirstOperant())
                .getOperator());
        assertEquals(IgnoreCaseLike, ((ConditionalCriteria) rightAnd.getSecondOperant())
                .getOperator());
    }

    /**
     * A and B or C and D and E (OR has higher priority than AND)
     * <pre>
     *             or
     *         /       \
     *      and         and
     *     /   \     /  |  \
     *    A     B   C   D   E
     *
     * </pre>
     */
    @Test
    public void shouldBuildGroupedAndOr4() {
        ConditionalCriteria criteria =
                criteriaFor(Person.class)
                        .where(aaa()).lessThan("A").and().where(bbb()).greaterThan("B")
                        .or()
                        .where(ccc()).ignoreCaseEq("C").and().where(ddd()).ignoreCaseLike("D").where(eee()).isNotNull()
                        .buildSingle();

        assertEquals(Or, criteria.getOperator());
        ConditionalCriteria leftAnd = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(And, leftAnd.getOperator());
        ConditionalCriteria rightAnd = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(And, rightAnd.getOperator());

        assertEquals("aaa", ((ConditionalCriteria) leftAnd.getFirstOperant()).getPropertyName());
        assertEquals("bbb", ((ConditionalCriteria) leftAnd.getSecondOperant()).getPropertyName());
        assertEquals(LessThan, ((ConditionalCriteria) leftAnd.getFirstOperant()).getOperator());
        assertEquals(GreatThan, ((ConditionalCriteria) leftAnd.getSecondOperant()).getOperator());

        List<ConditionalCriteria> criteriaList = (List<ConditionalCriteria>) rightAnd.getFirstOperant();
        assertEquals("ccc", criteriaList.get(0).getPropertyName());
        assertEquals("ddd", criteriaList.get(1).getPropertyName());
        assertEquals("eee", criteriaList.get(2).getPropertyName());
        assertEquals(IgnoreCaseEqual, criteriaList.get(0).getOperator());
        assertEquals(IgnoreCaseLike, criteriaList.get(1).getOperator());
        assertEquals(IsNotNull, criteriaList.get(2).getOperator());
    }

    /**
     * A and B or C and D or E (OR has higher priority than AND)
     * <pre>
     *                or
     *         /      |    \
     *      and      and    E
     *     /  \     /  \
     *    A    B   C   D
     *
     * </pre>
     */
    @Test
    public void shouldBuildGroupedAndOr5() {
        ConditionalCriteria criteria =
                criteriaFor(Person.class)
                        .where(aaa()).lessThan("A").and().where(bbb()).greaterThan("B")
                        .or()
                        .where(ccc()).ignoreCaseEq("C").and().where(ddd()).ignoreCaseLike("D")
                        .or()
                        .where(eee()).isNotNull()
                        .buildSingle();

        assertEquals(Or, criteria.getOperator());
        List<ConditionalCriteria> criteriaList = (List<ConditionalCriteria>) criteria.getFirstOperant();
        ConditionalCriteria first = criteriaList.get(0);
        assertEquals(And, first.getOperator());
        ConditionalCriteria second = criteriaList.get(1);
        assertEquals(And, second.getOperator());
        ConditionalCriteria third = criteriaList.get(2);

        assertEquals("aaa", ((ConditionalCriteria) first.getFirstOperant()).getPropertyName());
        assertEquals("bbb", ((ConditionalCriteria) first.getSecondOperant()).getPropertyName());
        assertEquals(LessThan, ((ConditionalCriteria) first.getFirstOperant())
                .getOperator());
        assertEquals(GreatThan, ((ConditionalCriteria) first.getSecondOperant())
                .getOperator());

        assertEquals("ccc", ((ConditionalCriteria) second.getFirstOperant()).getPropertyName());
        assertEquals("ddd", ((ConditionalCriteria) second.getSecondOperant()).getPropertyName());
        assertEquals(IgnoreCaseEqual, ((ConditionalCriteria) second.getFirstOperant())
                .getOperator());
        assertEquals(IgnoreCaseLike, ((ConditionalCriteria) second.getSecondOperant())
                .getOperator());

        assertEquals(IsNotNull, third.getOperator());
    }

    /**
     * (A and B) or (C and D) - use implicit and() between where()
     * <pre>
     *           or
     *         /    \
     *      and      and
     *     /   \     /  \
     *    A     B   C    D
     *
     * </pre>
     */
    @Test
    public void shouldBuildGroupedAndOr6() {
        ConditionalCriteria criteria =
                criteriaFor(Person.class).lbrace().where(aaa()).eq("A").where(bbb()).eq("B").rbrace()
                        .or()
                        .lbrace().where(ccc()).eq("C").where(ddd()).eq("D").rbrace()
                        .buildSingle();

        assertEquals(Or, criteria.getOperator());
        ConditionalCriteria leftAnd = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(And, leftAnd.getOperator());
        ConditionalCriteria rightAnd = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(And, rightAnd.getOperator());

        assertEquals(Equal, ((ConditionalCriteria) leftAnd.getFirstOperant())
                .getOperator());
        assertEquals(Equal, ((ConditionalCriteria) leftAnd.getSecondOperant())
                .getOperator());
        assertEquals("aaa", ((ConditionalCriteria) leftAnd.getFirstOperant()).getPropertyName());
        assertEquals("bbb", ((ConditionalCriteria) leftAnd.getSecondOperant()).getPropertyName());

        assertEquals(Equal, ((ConditionalCriteria) rightAnd.getFirstOperant())
                .getOperator());
        assertEquals(Equal, ((ConditionalCriteria) rightAnd.getSecondOperant())
                .getOperator());
        assertEquals("ccc", ((ConditionalCriteria) rightAnd.getFirstOperant()).getPropertyName());
        assertEquals("ddd", ((ConditionalCriteria) rightAnd.getSecondOperant()).getPropertyName());

    }

    /**
     * A or (A, B, C, D)
     * <pre>
     *           or
     *         /    \
     *        A      and
     *           /  / | \
     *          A  B  C  D
     *
     * </pre>
     */
    @Test
    public void shouldBuildImplicitInsideBraces() {
        ConditionalCriteria criteria =
            criteriaFor(Person.class).withProperty(aaa()).eq("X").or()
                .lbrace()
                    .withProperty(aaa()).eq("A")
                    .withProperty(bbb()).eq("B")
                    .withProperty(ccc()).greaterThan("C")
                    .withProperty(ddd()).lessThan("D")
                .rbrace()
                .buildSingle();

        assertEquals(Or, criteria.getOperator());

        ConditionalCriteria left = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals("aaa", left.getPropertyName());
        assertEquals(Equal, left.getOperator());
        assertEquals("X", left.getFirstOperant());

        ConditionalCriteria right = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(And, right.getOperator());

        List<ConditionalCriteria> criteriaList = (List<ConditionalCriteria>) right.getFirstOperant();
        assertEquals("aaa", criteriaList.get(0).getPropertyName());
        assertEquals("bbb", criteriaList.get(1).getPropertyName());
        assertEquals("ccc", criteriaList.get(2).getPropertyName());
        assertEquals("ddd", criteriaList.get(3).getPropertyName());
        assertEquals(Equal, criteriaList.get(0).getOperator());
        assertEquals(Equal, criteriaList.get(1).getOperator());
        assertEquals(GreatThan, criteriaList.get(2).getOperator());
        assertEquals(LessThan, criteriaList.get(3).getOperator());
    }

    /**
     * A or (A and B and C and D)
     * <pre>
     *           or
     *         /    \
     *        A      and
     *           /  / | \
     *          A  B  C  D
     *
     * </pre>
     */
    @Test
    public void shouldBuildExplicitInsideBraces() {
        ConditionalCriteria criteria =
            criteriaFor(Person.class).withProperty(aaa()).eq("X").or()
                .lbrace()
                    .withProperty(aaa()).eq("A")
                    .and()
                    .withProperty(bbb()).eq("B")
                    .and()
                    .withProperty(ccc()).greaterThan("C")
                    .and()
                    .withProperty(ddd()).lessThan("D")
                .rbrace()
                .buildSingle();

        assertEquals(Or, criteria.getOperator());

        ConditionalCriteria left = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals("aaa", left.getPropertyName());
        assertEquals(Equal, left.getOperator());
        assertEquals("X", left.getFirstOperant());

        ConditionalCriteria right = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(And, right.getOperator());

        List<ConditionalCriteria> criteriaList = (List<ConditionalCriteria>) right.getFirstOperant();
        assertEquals("aaa", criteriaList.get(0).getPropertyName());
        assertEquals("bbb", criteriaList.get(1).getPropertyName());
        assertEquals("ccc", criteriaList.get(2).getPropertyName());
        assertEquals("ddd", criteriaList.get(3).getPropertyName());
        assertEquals(Equal, criteriaList.get(0).getOperator());
        assertEquals(Equal, criteriaList.get(1).getOperator());
        assertEquals(GreatThan, criteriaList.get(2).getOperator());
        assertEquals(LessThan, criteriaList.get(3).getOperator());
    }

    /**
     * Test mixing Where and Having inside braces
     */
    @Test
    public void balancedBraceForWhereAndHaving() {
    	try {
            ConditionalCriteria criteria =
                    criteriaFor(Person.class).lbrace().where(aaa()).eq("A").having(bbb()).eq("B").rbrace()
                            .buildSingle();
            fail("Have to fire exception");
        } catch (IllegalStateException ise) {
            assertEquals("withProperty()/where()/having() mixed inside braces (missing 1 rbrace)", ise.getMessage(), "Wrong message for where/having mixup");
            assertEquals("having", ise.getStackTrace()[1].getMethodName(), "Wrong method fired exception");
        }

        try {
            ConditionalCriteria criteria =
                    criteriaFor(Person.class).lbrace().having(aaa()).eq("A").where(bbb()).eq("B").rbrace()
                            .buildSingle();
            fail("Have to fire exception");
        } catch (IllegalStateException ise) {
            assertEquals("withProperty()/where()/having() mixed inside braces (missing 1 rbrace)", ise.getMessage(), "Wrong message for where/having mixup");
            assertEquals("where", ise.getStackTrace()[2].getMethodName(), "Wrong method fired exception");
        }

        try {
            ConditionalCriteria criteria =
                    criteriaFor(Person.class).lbrace().where(aaa()).eq("A").where(bbb()).eq("B").rbrace()
                    .lbrace().having(aaa()).eq("A").having(bbb()).eq("B").rbrace()
                    .lbrace().having(aaa()).eq("A").where(ccc()).eq("B").rbrace() // where(ccc()) should fire exception
                    .buildSingle();
            fail("Have to fire exception");
        } catch (IllegalStateException ise) {
            assertEquals("withProperty()/where()/having() mixed inside braces (missing 1 rbrace)", ise.getMessage(), "Wrong message for where/having mixup");
            assertEquals("where", ise.getStackTrace()[2].getMethodName(), "Wrong method fired exception");
        }

        try {
            // This is OK
            List<ConditionalCriteria> criteria =
                    criteriaFor(Person.class).lbrace().where(aaa()).eq("A").where(bbb()).eq("B").rbrace()
                            .lbrace().having(aaa()).eq("A").having(bbb()).eq("B").rbrace()
                            .lbrace().where(aaa()).eq("A").where(ccc()).eq("B").rbrace()
                            .lbrace().having(aaa()).eq("A").having(bbb()).eq("B").rbrace()
                            .build();
        } catch (IllegalStateException ise) {
            fail("Exception fired: " + ise.getMessage());
        }

        try {
            // This is OK - multiple lbrace().lbrace() test
            List<ConditionalCriteria> criteria =
                    criteriaFor(Person.class).lbrace().where(aaa()).eq("A").and().where(bbb()).eq("B").rbrace()
                            .lbrace().having(aaa()).eq("A").and().having(bbb()).eq("B").rbrace()
                            .lbrace().lbrace().where(aaa()).eq("A").and().where(ccc()).eq("B").rbrace().rbrace()
                            .lbrace().lbrace().having(aaa()).eq("A").and().having(bbb()).eq("B").rbrace().rbrace()
                            .build();
        } catch (IllegalStateException ise) {
            fail("Exception fired: " + ise.getMessage());
        }

        try {
            // This is NOT OK - ((where AND where) AND having) - ERROR
            List<ConditionalCriteria> criteria =
                    criteriaFor(Person.class).lbrace().where(aaa()).eq("A").and().where(bbb()).eq("B").rbrace()
                            .lbrace().having(aaa()).eq("A").and().having(bbb()).eq("B").rbrace()
                            .lbrace().lbrace().where(aaa()).eq("A").and().where(ccc()).eq("B").rbrace()
                                .having(ddd()).isNotNull().rbrace() // having(ddd()) should fire exception
                            .build();
            fail("Have to fire exception");
        } catch (IllegalStateException ise) {
            assertEquals("withProperty()/where()/having() mixed inside braces (missing 1 rbrace)", ise.getMessage(), "Wrong message for where/having mixup");
            assertEquals("having", ise.getStackTrace()[1].getMethodName(), "Wrong method fired exception");
        }
    }

    @Test()
    public void shouldDetectTooManyLeftBraces() {
        assertThrows(IllegalStateException.class, () -> {
            criteriaFor(Person.class).lbrace().withProperty(aaa()).eq("A").buildSingle();
        });
    }

    @Test()
    public void shouldDetectTooManyRightBraces() {
        assertThrows(IllegalStateException.class, () -> {
            criteriaFor(Person.class).lbrace().withProperty(aaa()).eq("A").rbrace().rbrace().buildSingle();
        });
    }

    // Entity
    public static class Person {
        private String aaa;
        private String bbb;
        private int ccc;
        private Long ddd;
        private Address primaryAddress;
        private Address secondaryAddress;

        public String getAaa() {
            return aaa;
        }

        public void setAaa(String aaa) {
            this.aaa = aaa;
        }

        public String getBbb() {
            return bbb;
        }

        public void setBbb(String bbb) {
            this.bbb = bbb;
        }

        public int getCcc() {
            return ccc;
        }

        public void setCcc(int ccc) {
            this.ccc = ccc;
        }

        public Long getDdd() {
            return ddd;
        }

        public void setDdd(Long ddd) {
            this.ddd = ddd;
        }

        public Address getPrimaryAddress() {
            return primaryAddress;
        }

        public void setPrimaryAddress(Address primaryAddress) {
            this.primaryAddress = primaryAddress;
        }

        public Address getSecondaryAddress() {
            return secondaryAddress;
        }

        public void setSecondaryAddress(Address secondaryAddress) {
            this.secondaryAddress = secondaryAddress;
        }
    }

    // this class is the starting point, i.e. root of the criteria
    // note that it doesn't implements Property
    public static class PersonProperties {
        private static final PersonPropertiesImpl<Person> sharedInstance = new PersonPropertiesImpl<Person>(Person.class);

        private PersonProperties() {
        }

        public static Property<Person> aaa() {
            return sharedInstance.aaa();
        }

        public static Property<Person> bbb() {
            return sharedInstance.bbb();
        }

        public static Property<Person> ccc() {
            return sharedInstance.ccc();
        }

        public static Property<Person> ddd() {
            return sharedInstance.ddd();
        }

        public static Property<Person> eee() {
            return sharedInstance.eee();
        }

        public static AddressProperty<Person> primaryAddress() {
            return sharedInstance.primaryAddress();
        }

        public static AddressProperty<Person> secondaryAddress() {
            return sharedInstance.secondaryAddress();
        }

        public static PersonProperty<Person> boss() {
           return sharedInstance.boss();
       }

    }

    // this class is used for references to Person, i.e. nested property
    public static class PersonProperty<T> extends PersonPropertiesImpl<T> {
        private static final long serialVersionUID = 1L;

        public PersonProperty(String parentPath, String additionalPath, Class<T> owningClass) {
            super(parentPath, additionalPath, owningClass);
        }
    }

    // note private visibility
    private static class PersonPropertiesImpl<T> extends PropertiesCollection<T> {
        private static final long serialVersionUID = 1L;

        Class<T> owningClass;

        PersonPropertiesImpl(Class<T> owningClass) {
            super(null);
            this.owningClass=owningClass;
        }

        PersonPropertiesImpl(String parentPath, String additionalPath, Class<T> owningClass) {
            super(parentPath, additionalPath);
            this.owningClass=owningClass;
        }

        public Property<T> aaa() {
            return new LeafProperty<T>(getParentPath(), "aaa", false, owningClass);
        }

        public Property<T> bbb() {
            return new LeafProperty<T>(getParentPath(), "bbb", false, owningClass);
        }

        public Property<T> ccc() {
            return new LeafProperty<T>(getParentPath(), "ccc", false, owningClass);
        }

        public Property<T> ddd() {
            return new LeafProperty<T>(getParentPath(), "ddd", false, owningClass);
        }

        public Property<T> eee() {
            return new LeafProperty<T>(getParentPath(), "eee", false, owningClass);
        }

        public AddressProperty<T> primaryAddress() {
            return new AddressProperty<T>(getParentPath(), "primaryAddress", owningClass);
        }

        public AddressProperty<T> secondaryAddress() {
            return new AddressProperty<T>(getParentPath(), "secondaryAddress", owningClass);
        }

        public PersonProperty<T> boss() {
           return new PersonProperty<T>(getParentPath(), "boss", owningClass);
       }
    }

    // BasicType
    public static class Address {
        private final String street;
        private final String city;

        public Address(String street, String city) {
            this.street = street;
            this.city = city;
        }

        public String getStreet() {
            return street;
        }

        public String getCity() {
            return city;
        }
    }

    public static class AddressProperties {

        // note that static methods are not generated in BasicType, since they can't be root of the criteria

        public static class AddressProperty<T> extends AddressPropertiesImpl<T> {
            private static final long serialVersionUID = 1L;
            public AddressProperty(String parentPath, String additionalPath, Class<T> owningClass) {
                super(parentPath, additionalPath, owningClass);
            }
        }

        private static class AddressPropertiesImpl<T> extends PropertiesCollection<T> {
            private static final long serialVersionUID = 1L;
            Class<T> owningClass;

            AddressPropertiesImpl(String parentPath, Class<T> owningClass) {
                super(parentPath);
                this.owningClass=owningClass;
            }

            AddressPropertiesImpl(String parentPath, String additionalPath, Class<T> owningClass) {
                super(parentPath, additionalPath);
                this.owningClass=owningClass;
            }

            public Property<T> city() {
                return new LeafProperty<T>(getParentPath(), "city", true, owningClass);
            }
        }

    }



}
