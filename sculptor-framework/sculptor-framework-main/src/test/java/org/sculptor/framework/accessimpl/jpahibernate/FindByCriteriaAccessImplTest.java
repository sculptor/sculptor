package org.sculptor.framework.accessimpl.jpahibernate;

import java.util.List;

import org.sculptor.framework.accessimpl.jpahibernate.JpaHibFindByCriteriaAccessImpl;

import junit.framework.TestCase;

public class FindByCriteriaAccessImplTest extends TestCase {

    public void testCreateSubCriteriasWithoutAnySubCriterias() {
        JpaHibFindByCriteriaAccessImpl<Foo> finder = new JpaHibFindByCriteriaAccessImpl<Foo>(
                Foo.class);
        finder.addRestriction("a", 1);

        List<String> subCriteriaNames = finder.getSubCriteriaNames();

        assertEquals(0, subCriteriaNames.size());
    }

    public void testCreateSubCriteriasWithOne() {
        JpaHibFindByCriteriaAccessImpl<Foo> finder = new JpaHibFindByCriteriaAccessImpl<Foo>(
                Foo.class);
        finder.addRestriction("a", 1);
        finder.addRestriction("bbb.b", 2);

        List<String> subCriteriaNames = finder.getSubCriteriaNames();

        assertTrue(subCriteriaNames.contains("bbb"));
        assertEquals(1, subCriteriaNames.size());
    }

    public void testCreateSubCriteriasWithSeveral() {
        JpaHibFindByCriteriaAccessImpl<Foo> finder = new JpaHibFindByCriteriaAccessImpl<Foo>(
                Foo.class);
        finder.addRestriction("a", 1);
        finder.addRestriction("bbb.b1", 2);
        finder.addRestriction("bbb.b2", 3);
        finder.addRestriction("bbb.ccc.c1", 4);
        finder.addRestriction("bbb.ccc.c2", 5);
        finder.addRestriction("ddd.d1", 6);
        finder.addRestriction("eee.fff.ggg.hhh.h1", 7);
        finder.addRestriction("eee.fff.ggg.hhh.h2", 8);

        List<String> subCriteriaNames = finder.getSubCriteriaNames();

        assertTrue(subCriteriaNames.contains("bbb"));
        assertTrue(subCriteriaNames.contains("bbb.ccc"));
        assertTrue(subCriteriaNames.contains("ddd"));
        assertTrue(subCriteriaNames.contains("eee"));
        assertTrue(subCriteriaNames.contains("eee.fff"));
        assertTrue(subCriteriaNames.contains("eee.fff.ggg"));
        assertTrue(subCriteriaNames.contains("eee.fff.ggg.hhh"));

        assertEquals(7, subCriteriaNames.size());
    }

    public static class Foo {
    }

}
