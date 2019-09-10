package org.sculptor.framework.accessapi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilderTest.PersonProperties.aaa;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilderTest.PersonProperties.bbb;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilderTest.PersonProperties.ccc;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilderTest.PersonProperties.ddd;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilderTest.PersonProperties.primaryAddress;

import java.util.List;

import org.junit.Test;
import org.sculptor.framework.accessapi.ConditionalCriteria;
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
		assertEquals(ConditionalCriteria.Operator.Equal, criteria.getOperator());
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
        assertEquals(ConditionalCriteria.Operator.Equal, criteria.getOperator());
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
        assertEquals(ConditionalCriteria.Operator.Equal, criteria.getOperator());
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
        assertEquals(ConditionalCriteria.Operator.Equal, criteria.getOperator());
        assertEquals("Stockholm", criteria.getFirstOperant());
        assertNull(criteria.getSecondOperant());
    }

    @Test
    public void shouldBuildWithEqObjectProperty() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(primaryAddress()).eq(
                new Address("Kungsgatan 10", "Stockholm"))
                .buildSingle();

        assertEquals("primaryAddress", criteria.getPropertyName());
        assertEquals(ConditionalCriteria.Operator.Equal, criteria.getOperator());
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

        assertEquals(ConditionalCriteria.Operator.LessThan, criteria.getOperator());
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
        assertEquals("bbb", criteria.getFirstOperant());
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

        assertEquals(ConditionalCriteria.Operator.And, criteria.getOperator());
        ConditionalCriteria firstOperant = (ConditionalCriteria) criteria.getFirstOperant();
        ConditionalCriteria secondOperant = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals("aaa", firstOperant.property.getName());
        assertEquals("bbb", secondOperant.property.getName());
    }

    @Test
    public void shouldBuildAndConditionWithoutAndKeyword() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).eq(1234).withProperty(bbb()).eq(
                "zzz")
                .buildSingle();

        assertEquals(ConditionalCriteria.Operator.And, criteria.getOperator());
        ConditionalCriteria firstOperant = (ConditionalCriteria) criteria.getFirstOperant();
        ConditionalCriteria secondOperant = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals("aaa", firstOperant.property.getName());
        assertEquals("bbb", secondOperant.property.getName());
    }

    @Test
    public void shouldBuildSingleListOfConditions() {
        ConditionalCriteria criteriaS = criteriaFor(Person.class).withProperty(aaa()).eq(1234).and().withProperty(bbb())
                .eq("zzz")
                .and()
                .withProperty(ccc()).eq("xxx").buildSingle();

        assertEquals(ConditionalCriteria.Operator.And, criteriaS.getOperator());

        @SuppressWarnings("unchecked")
        List<ConditionalCriteria> criteria=(List<ConditionalCriteria>) criteriaS.getFirstOperant();
        ConditionalCriteria first=(ConditionalCriteria) criteria.get(0);
        ConditionalCriteria second=(ConditionalCriteria) criteria.get(1);
        ConditionalCriteria third=(ConditionalCriteria) criteria.get(2);
        assertEquals("aaa", first.property.getName());
        assertEquals("bbb", second.property.getName());
        assertEquals("ccc", third.property.getName());
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
        assertEquals("aaa", first.property.getName());
        assertEquals("bbb", second.property.getName());
        assertEquals("ccc", third.property.getName());
    }

    @Test
    public void shouldBuildOrCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).withProperty(aaa()).eq(1234).or().withProperty(bbb())
                .eq("zzz")
                .buildSingle();

        assertNull(criteria.getPropertyName());
        assertEquals(ConditionalCriteria.Operator.Or, criteria.getOperator());
        ConditionalCriteria left = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals("aaa", left.property.getName());
        ConditionalCriteria right = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals("bbb", right.property.getName());
    }

    @Test
    public void shouldBuildNotCondition() {
        ConditionalCriteria criteria = criteriaFor(Person.class).not().withProperty(aaa()).eq(1234).buildSingle();

        assertNull(criteria.getPropertyName());
        assertEquals(ConditionalCriteria.Operator.Not, criteria.getOperator());
        ConditionalCriteria op = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals("aaa", op.property.getName());
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
        assertEquals(ConditionalCriteria.Operator.Equal, criteria1.getOperator());
        assertEquals(1234, criteria1.getFirstOperant());
        assertNull(criteria1.getSecondOperant());

        ConditionalCriteria criteria2 = criteriaList.get(1);
        assertEquals("bbb", criteria2.getPropertyName());
        assertEquals(ConditionalCriteria.Operator.Equal, criteria2.getOperator());
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
        assertEquals(ConditionalCriteria.Operator.Equal, criteria.getOperator());
        assertEquals(1234, criteria.getFirstOperant());
        assertNull(criteria.getSecondOperant());
    }

    @Test
    public void shouldBuildOrConditionWithBraces() {
        ConditionalCriteria criteria = criteriaFor(Person.class).lbrace().withProperty(aaa()).eq(1234).or()
                .withProperty(bbb()).eq("zzz").rbrace()
                .buildSingle();

        assertNull(criteria.getPropertyName());
        assertEquals(ConditionalCriteria.Operator.Or, criteria.getOperator());
        ConditionalCriteria left = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals("aaa", left.property.getName());
        ConditionalCriteria right = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals("bbb", right.property.getName());
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

        assertEquals(ConditionalCriteria.Operator.Or, criteria.getOperator());
        ConditionalCriteria left1 = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(ConditionalCriteria.Operator.And, left1.getOperator());
        ConditionalCriteria right1 = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(ConditionalCriteria.Operator.Equal, right1.getOperator());
        assertEquals("ccc", right1.property.getName());
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

        assertEquals(ConditionalCriteria.Operator.Or, criteria.getOperator());
        ConditionalCriteria left1 = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(ConditionalCriteria.Operator.And, left1.getOperator());
        ConditionalCriteria notCriteria = ((ConditionalCriteria) left1.getSecondOperant());
        assertEquals(ConditionalCriteria.Operator.Not, notCriteria.getOperator());
        ConditionalCriteria firstOper=(ConditionalCriteria) notCriteria.getFirstOperant();
        assertEquals("bbb", firstOper.property.getName());

        ConditionalCriteria right1 = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(ConditionalCriteria.Operator.Equal, right1.getOperator());
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

        assertEquals(ConditionalCriteria.Operator.Or, criteria.getOperator());
        ConditionalCriteria left1 = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(ConditionalCriteria.Operator.Not, left1.getOperator());

        ConditionalCriteria andCriteria = ((ConditionalCriteria) left1.getFirstOperant());
        assertEquals(ConditionalCriteria.Operator.And, andCriteria.getOperator());
        assertEquals("aaa", ((ConditionalCriteria) andCriteria.getFirstOperant()).getPropertyName());
        assertEquals("bbb", ((ConditionalCriteria) andCriteria.getSecondOperant()).getPropertyName());

        ConditionalCriteria right1 = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(ConditionalCriteria.Operator.Equal, right1.getOperator());
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

        assertEquals(ConditionalCriteria.Operator.And, criteria.getOperator());
        ConditionalCriteria left1 = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(ConditionalCriteria.Operator.Equal, left1.getOperator());
        assertEquals("aaa", left1.getPropertyName());
        assertEquals("A", left1.getFirstOperant());

        ConditionalCriteria right1 = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(ConditionalCriteria.Operator.Or, right1.getOperator());

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

        assertEquals(ConditionalCriteria.Operator.Or, criteria.getOperator());
        ConditionalCriteria leftAnd = (ConditionalCriteria) criteria.getFirstOperant();
        assertEquals(ConditionalCriteria.Operator.And, leftAnd.getOperator());
        ConditionalCriteria rightAnd = (ConditionalCriteria) criteria.getSecondOperant();
        assertEquals(ConditionalCriteria.Operator.And, rightAnd.getOperator());

        assertEquals(ConditionalCriteria.Operator.Equal, ((ConditionalCriteria) leftAnd.getFirstOperant())
                .getOperator());
        assertEquals(ConditionalCriteria.Operator.Equal, ((ConditionalCriteria) leftAnd.getSecondOperant())
                .getOperator());
        assertEquals("aaa", ((ConditionalCriteria) leftAnd.getFirstOperant()).getPropertyName());
        assertEquals("bbb", ((ConditionalCriteria) leftAnd.getSecondOperant()).getPropertyName());

        assertEquals(ConditionalCriteria.Operator.Equal, ((ConditionalCriteria) rightAnd.getFirstOperant())
                .getOperator());
        assertEquals(ConditionalCriteria.Operator.Equal, ((ConditionalCriteria) rightAnd.getSecondOperant())
                .getOperator());
        assertEquals("ccc", ((ConditionalCriteria) rightAnd.getFirstOperant()).getPropertyName());
        assertEquals("ddd", ((ConditionalCriteria) rightAnd.getSecondOperant()).getPropertyName());

    }

    @Test(expected = IllegalStateException.class)
    public void shouldDetectTooManyLeftBraces() {
        criteriaFor(Person.class).lbrace().withProperty(aaa()).eq("A").buildSingle();
    }

    @Test(expected = IllegalStateException.class)
    public void shouldDetectTooManyRightBraces() {
        criteriaFor(Person.class).lbrace().withProperty(aaa()).eq("A").rbrace().rbrace().buildSingle();
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
    public static class PersonProperty<T> extends PersonPropertiesImpl<T> implements Property<T> {
        private static final long serialVersionUID = 1L;

        public PersonProperty(String parentPath, String additionalPath, Class<T> owningClass) {
            super(parentPath, additionalPath, owningClass);
        }
    }

    // note private visibility
    private static class PersonPropertiesImpl<T> extends PropertiesCollection {
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

        public static class AddressProperty<T> extends AddressPropertiesImpl<T> implements Property<T> {
            private static final long serialVersionUID = 1L;
            public AddressProperty(String parentPath, String additionalPath, Class<T> owningClass) {
                super(parentPath, additionalPath, owningClass);
            }
        }

        private static class AddressPropertiesImpl<T> extends PropertiesCollection {
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
