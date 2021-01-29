package org.sculptor.dddsample.location.domain;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class LocationTest {

  @Test
  public void testEquals() {
    // Same UN locode - equal
    assertTrue(new Location("test-name", new UnLocode("ATEST")).
        equals(new Location("test-name", new UnLocode("ATEST"))));

    // Different UN locodes - not equal
    assertFalse(new Location("test-name", new UnLocode("ATEST")).
         equals(new Location("test-name", new UnLocode("TESTB"))));

    // Always equal to itself
    Location location = new Location("test-name", new UnLocode("ATEST"));
    assertTrue(location.equals(location));

    // Never equal to null
    assertFalse(location.equals(null));

    // Special UNKNOWN location is equal to itself
    assertTrue(Location.UNKNOWN.equals(Location.UNKNOWN));

    try {
      new Location(null, null);
      fail("Should not allow any null constructor arguments");
    } catch (IllegalArgumentException expected) {}
  }

}
