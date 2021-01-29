package org.sculptor.dddsample.cargo.domain;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.fail;

public class LegTest {

  @Test
  public void testConstructor() throws Exception {
    try {
      new Leg(null,null,null);
      fail("Should not accept null constructor arguments");
    } catch (IllegalArgumentException expected) {}
  }
}
