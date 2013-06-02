package org.sculptor.generator.util;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class QueryConverterTest {

    @Test
    public void testSimpleConditions() {
        assertEquals(
                ".withProperty(RootProperties.name().first()).eq(RootProperties.name().last())",
                new QueryConverter.ConditionalCriteriaStrategy("name.first = name.last", "Root").toQueryDsl());
        assertEquals(
                ".withProperty(RootProperties.name().first()).eq(\"a and b\")",
                new QueryConverter.ConditionalCriteriaStrategy("name.first = 'a and b'", "Root").toQueryDsl());
        assertEquals(
                ".withProperty(RootProperties.name().first()).eq(first)",
                new QueryConverter.ConditionalCriteriaStrategy("name.first = :first", "Root").toQueryDsl());
        assertEquals(
                ".not().withProperty(RootProperties.name().first()).eq(first)",
                new QueryConverter.ConditionalCriteriaStrategy("name.first != :first", "Root").toQueryDsl());
    }
    
    
    @Test
    public void testBetween() {
        assertEquals(
                ".withProperty(RootProperties.salary()).between(first,last)",
                new QueryConverter.ConditionalCriteriaStrategy("salary between :first and :last", "Root").toQueryDsl());
    }

    @Test
    public void testIn() {
        assertEquals(
                ".withProperty(RootProperties.name().first()).in(first)",
                new QueryConverter.ConditionalCriteriaStrategy("name.first in (:first)", "Root").toQueryDsl());
        assertEquals(
                ".withProperty(RootProperties.name().first()).in(\"A\",\"B\")",
                new QueryConverter.ConditionalCriteriaStrategy("name.first in ('A','B')", "Root").toQueryDsl());
    }
    
    @Test
    public void testAnd() {
        assertEquals(
                ".withProperty(RootProperties.salary()).isNotNull().and().withProperty(RootProperties.salary()).lessThanOrEqual(first)",
                new QueryConverter.ConditionalCriteriaStrategy("salary is not null and salary <= :first", "Root").toQueryDsl());
    }

    @Test
    public void testOr() {
        assertEquals(
                ".withProperty(RootProperties.salary()).isNull().or().withProperty(RootProperties.salary2()).isNull().or().withProperty(RootProperties.salary()).eq(RootProperties.salary2())",
                new QueryConverter.ConditionalCriteriaStrategy("salary is null or salary2 is null or salary = salary2", "Root").toQueryDsl());
    }

    @Test
    public void testSelect() {
        assertEquals(
                ".select(RootProperties.name()).select(RootProperties.name().first()).select(RootProperties.salary()).alias(\"s\").max()",
                new QueryConverter.ConditionalCriteriaStrategy("select name, name.first,max(salary) as s", "Root").toQueryDsl());
    }
    
    @Test
    public void testSelectWithFrom() {
        assertEquals(
                ".select(RootProperties.name()).select(RootProperties.name().first()).select(RootProperties.salary()).alias(\"s\").max()",
                new QueryConverter.ConditionalCriteriaStrategy("select r.name, r.name.first, max(r.salary) as s from Root r", "Root").toQueryDsl());
    }

    @Test
    public void testGroupBy() {
        assertEquals(
                ".groupBy(RootProperties.name().first()).groupBy(RootProperties.test())",
                new QueryConverter.ConditionalCriteriaStrategy("group by name.first, test", "Root").toQueryDsl());
    }

    @Test
    public void testOrderBy() {
        assertEquals(
                ".withProperty(RootProperties.test()).isNull().orderBy(RootProperties.name().first()).descending().orderBy(RootProperties.test()).ascending()",
                new QueryConverter.ConditionalCriteriaStrategy("order by name.first desc, test where test is null", "Root").toQueryDsl());
    }
}
