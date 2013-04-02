package org.sculptor.framework.domain;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;
import org.sculptor.framework.domain.AbstractDomainObject;
import org.slf4j.LoggerFactory;

public class EqualsTest {

    @Test
    public void shouldBeReflexive() {
        A a = new A(17);
        assertTrue(a.equals(a));
    }

    @Test
    public void shouldBeSymetric() {
        A a1 = new A(17);
        A a2 = new A(17);
        assertTrue(a1.equals(a2));
        assertTrue(a2.equals(a1));
    }

    @Test
    public void performance() {
        long t0 = System.currentTimeMillis();
        int count = 0;
        A a1 = new A(17);
        B b = new B(17);
        A a3 = new A(-1);
        for (int i = 0; i < 10000000; i++) {
            if (a1.equals(b)) {
                count++;
            }
            if (!a1.equals(a3)) {
                count--;
            }
        }
        long duration = System.currentTimeMillis() - t0;
        assertEquals(0, count);
        LoggerFactory.getLogger(getClass()).info("Performance test took {} ms", duration);
    }

    @Test
    public void shouldConsiderDifferentClassHierarchiesNotEqual() {
        A a = new A(17);
        D d = new D(17);
        assertFalse(a.equals(d));
    }

    @Test
    public void shouldConsiderNonDomainObjectNotEqual() {
        A a = new A(17);
        Object x = new Object();
        assertFalse(a.equals(x));
    }

    @Test
    public void shouldBeSymetricForSubclass() {
        A a = new A(17);
        B b = new B(17);
        assertTrue(a.equals(b));
        assertTrue(b.equals(a));
    }

    @Test
    public void shouldBeTransitive() {
        A a = new A(17);
        B b = new B(17);
        C c = new C(17);
        assertTrue(b.equals(a));
        assertTrue(a.equals(c));
        assertTrue(b.equals(c));
    }

    private static class A extends AbstractDomainObject {
        private static final long serialVersionUID = 1L;
        private final Integer key;

        public A(Integer key) {
            this.key = key;
        }

        @Override
        protected Object getKey() {
            return key;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = super.hashCode();
            result = prime * result + ((key == null) ? 0 : key.hashCode());
            return result;
        }
    }

    private static class B extends A {
        private static final long serialVersionUID = 1L;

        public B(Integer key) {
            super(key);
        }
    }

    private static class C extends A {
        private static final long serialVersionUID = 1L;

        public C(Integer key) {
            super(key);
        }
    }

    private static class D extends AbstractDomainObject {
        private static final long serialVersionUID = 1L;
        private final Integer key;

        public D(Integer key) {
            this.key = key;
        }

        @Override
        protected Object getKey() {
            return key;
        }
    }

}
