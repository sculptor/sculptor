package org.sculptor.framework.util;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;
import org.sculptor.framework.util.EqualsHelper;


public class EqualsHelperTest {
    
    @Test
    public void sameAreEqual() {
        String s = new String("a");
        assertTrue(EqualsHelper.equals(s, s));
    }
    
    @Test
    public void equalAreEqual() {
        String s1 = new String("a");
        String s2 = new String("a");
        assertTrue(EqualsHelper.equals(s1, s2));
    }
    
    @Test
    public void differentAreNotEqual() {
        String s1 = new String("a");
        String s2 = new String("b");
        assertFalse(EqualsHelper.equals(s1, s2));
    }
    
    @Test
    public void bothNullAreEqual() {
        String s1 = null;
        String s2 = null;
        assertTrue(EqualsHelper.equals(s1, s2));
    }
    
    @Test
    public void firstNullAreNotEqual() {
        String s1 = null;
        String s2 = new String("b");
        assertFalse(EqualsHelper.equals(s1, s2));
    }
    
    @Test
    public void secondNullAreNotEqual() {
        String s1 = new String("a");
        String s2 = null;
        assertFalse(EqualsHelper.equals(s1, s2));
    }
    
    

}
