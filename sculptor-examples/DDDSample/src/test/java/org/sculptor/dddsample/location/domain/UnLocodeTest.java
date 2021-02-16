package org.sculptor.dddsample.location.domain;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class UnLocodeTest {

  @Test
  public void testNew() throws Exception {
    assertValid("AA234");
    assertValid("AAA9B");
    assertValid("AAAAA");
    
    assertInvalid("AAAA");
    assertInvalid("AAAAAA");
    assertInvalid("AAAA");
    assertInvalid("AAAAAA");
    assertInvalid("22AAA");
    assertInvalid("AA111");
    assertThrows(NullPointerException.class, () -> {
      new UnLocode(null);
      fail("NULL is not a valid UnLocode");
    });
  }

  @Test
  public void testIdString() throws Exception {
    assertEquals("ABCDE", new UnLocode("AbcDe").getUnlocode());
  }

  @Test
  public void testEquals() throws Exception {
    UnLocode allCaps = new UnLocode("ABCDE");
    UnLocode mixedCase = new UnLocode("aBcDe");

    assertTrue(allCaps.equals(mixedCase));
    assertTrue(mixedCase.equals(allCaps));
    assertTrue(allCaps.equals(allCaps));

    assertFalse(allCaps.equals(null));
    assertFalse(allCaps.equals(new UnLocode("FGHIJ")));
  }

  @Test
  public void testHashCode() throws Exception {
    UnLocode allCaps = new UnLocode("ABCDE");
    UnLocode mixedCase = new UnLocode("aBcDe");

    assertEquals(allCaps.hashCode(), mixedCase.hashCode());  
  }
  
  private void assertValid(String unlocode) {
    new UnLocode(unlocode);
  }

  private void assertInvalid(String unlocode) {
    assertThrows(IllegalArgumentException.class, () -> {
      new UnLocode(unlocode);
      fail("The combination [" + unlocode + "] is not a valid UnLocode");
    });
  }

}
