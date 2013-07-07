package org.sculptor.dddsample.cargo.domain;

import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;
import static org.sculptor.dddsample.location.domain.SampleLocations.GOTHENBURG;
import static org.sculptor.dddsample.location.domain.SampleLocations.HAMBURG;
import static org.sculptor.dddsample.location.domain.SampleLocations.HANGZOU;
import static org.sculptor.dddsample.location.domain.SampleLocations.HONGKONG;
import static org.sculptor.dddsample.location.domain.SampleLocations.MELBOURNE;
import static org.sculptor.dddsample.location.domain.SampleLocations.NEWYORK;
import static org.sculptor.dddsample.location.domain.SampleLocations.ROTTERDAM;
import static org.sculptor.dddsample.location.domain.SampleLocations.SHANGHAI;
import static org.sculptor.dddsample.location.domain.SampleLocations.STOCKHOLM;
import static org.sculptor.dddsample.location.domain.SampleLocations.TOKYO;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

import junit.framework.TestCase;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.carrier.domain.CarrierMovementId;
import org.sculptor.dddsample.location.domain.Location;

public class CargoTest extends TestCase {
  private Set<HandlingEvent> events;

  public void testlastKnownLocationUnknownWhenNoEvents() throws Exception {
    Cargo cargo = new Cargo(trackingId("XYZ"), STOCKHOLM, MELBOURNE);

    assertEquals(Location.UNKNOWN, cargo.lastKnownLocation());
  }

  public void testlastKnownLocationReceived() throws Exception {
    Cargo cargo = populateCargoReceivedStockholm();

    assertEquals(STOCKHOLM, cargo.lastKnownLocation());
  }

  public void testlastKnownLocationClaimed() throws Exception {
    Cargo cargo = populateCargoClaimedMelbourne();

    assertEquals(MELBOURNE, cargo.lastKnownLocation());
  }

  public void testlastKnownLocationUnloaded() throws Exception {
    Cargo cargo = populateCargoOffHongKong();

    assertEquals(HONGKONG, cargo.lastKnownLocation());
  }

  public void testlastKnownLocationloaded() throws Exception {
    Cargo cargo = populateCargoOnHamburg();

    assertEquals(HAMBURG, cargo.lastKnownLocation());
  }

  public void testAtFinalLocation() throws Exception {
    Cargo cargo = populateCargoOffMelbourne();

    assertTrue(cargo.hasArrived());
  }

  public void testNotAtFinalLocationWhenNotUnloaded() throws Exception {
    Cargo cargo = populateCargoOnHongKong();

    assertFalse(cargo.hasArrived());
  }

  public void testEquality() throws Exception {
    Cargo c1 = new Cargo(trackingId("ABC"), STOCKHOLM, HONGKONG);
        Cargo c2 = new Cargo(trackingId("CBA"), STOCKHOLM, HONGKONG);
        Cargo c3 = new Cargo(trackingId("ABC"), STOCKHOLM, MELBOURNE);
        Cargo c4 = new Cargo(trackingId("ABC"), STOCKHOLM, HONGKONG);

    assertTrue("Cargos should be equal when TrackingIDs are equal", c1.equals(c4));
    assertTrue("Cargos should be equal when TrackingIDs are equal", c1.equals(c3));
    assertTrue("Cargos should be equal when TrackingIDs are equal", c3.equals(c4));
    assertFalse("Cargos are not equal when TrackingID differ", c1.equals(c2));
  }

  @Override
protected void setUp() throws Exception {
    events = new HashSet<HandlingEvent>();
  }

  public void testIsUnloadedAtFinalDestination() throws Exception {
    assertFalse(new Cargo().isUnloadedAtDestination());

    Cargo cargo = setUpCargoWithItinerary(HANGZOU, TOKYO, NEWYORK);
    assertFalse(cargo.isUnloadedAtDestination());

    // Adding an event unrelated to unloading at final destination
    events.add(
      new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.RECEIVE, HANGZOU, null));
    cargo.getEvents().addAll(events);
    assertFalse(cargo.isUnloadedAtDestination());

    CarrierMovement cm1 = new CarrierMovement(new CarrierMovementId("CM1"), HANGZOU, NEWYORK);

    // Adding an unload event, but not at the final destination
    events.add(
      new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.UNLOAD, TOKYO, cm1));
    cargo.getEvents().addAll(events);
    assertFalse(cargo.isUnloadedAtDestination());

    // Adding an event in the final destination, but not unload
    events.add(
      new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.CUSTOMS, NEWYORK, null));
    cargo.getEvents().addAll(events);
    assertFalse(cargo.isUnloadedAtDestination());

    // Finally, cargo is unloaded at final destination
    events.add(
      new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.UNLOAD, NEWYORK, cm1));
    cargo.getEvents().addAll(events);
    assertTrue(cargo.isUnloadedAtDestination());
  }

  private Cargo populateCargoReceivedStockholm() throws Exception {
    final Cargo cargo = new Cargo(trackingId("XYZ"), STOCKHOLM, MELBOURNE);

    HandlingEvent he = new HandlingEvent(cargo, getDate("2007-12-01"), new DateTime(), Type.RECEIVE, STOCKHOLM, null);
    events.add(he);
    cargo.getEvents().addAll(events);

    return cargo;
  }

  private Cargo populateCargoClaimedMelbourne() throws Exception {
    final Cargo cargo = populateCargoOffMelbourne();

    events.add(new HandlingEvent(cargo, getDate("2007-12-09"), new DateTime(), Type.CLAIM, MELBOURNE, null));
    cargo.getEvents().addAll(events);

    return cargo;
  }

  private Cargo populateCargoOffHongKong() throws Exception {
    final Cargo cargo = new Cargo(trackingId("XYZ"), STOCKHOLM, MELBOURNE);

    final CarrierMovement stockholmToHamburg = new CarrierMovement(
       new CarrierMovementId("CAR_001"), STOCKHOLM, HAMBURG);

    events.add(new HandlingEvent(cargo, getDate("2007-12-01"), new DateTime(), Type.LOAD, STOCKHOLM, stockholmToHamburg));
    events.add(new HandlingEvent(cargo, getDate("2007-12-02"), new DateTime(), Type.UNLOAD, HAMBURG, stockholmToHamburg));

    final CarrierMovement hamburgToHongKong = new CarrierMovement(
       new CarrierMovementId("CAR_001"), HAMBURG, HONGKONG);

    events.add(new HandlingEvent(cargo, getDate("2007-12-03"), new DateTime(), Type.LOAD, HAMBURG, hamburgToHongKong));
    events.add(new HandlingEvent(cargo, getDate("2007-12-04"), new DateTime(), Type.UNLOAD, HONGKONG, hamburgToHongKong));

    cargo.getEvents().addAll(events);
    return cargo;
  }

  private Cargo populateCargoOnHamburg() throws Exception {
    final Cargo cargo = new Cargo(trackingId("XYZ"), STOCKHOLM, MELBOURNE);

    final CarrierMovement stockholmToHamburg = new CarrierMovement(
       new CarrierMovementId("CAR_001"), STOCKHOLM, HAMBURG);

    events.add(new HandlingEvent(cargo, getDate("2007-12-01"), new DateTime(), Type.LOAD, STOCKHOLM, stockholmToHamburg));
    events.add(new HandlingEvent(cargo, getDate("2007-12-02"), new DateTime(), Type.UNLOAD, HAMBURG, stockholmToHamburg));

    final CarrierMovement hamburgToHongKong = new CarrierMovement(
       new CarrierMovementId("CAR_001"), HAMBURG, HONGKONG);

    events.add(new HandlingEvent(cargo, getDate("2007-12-03"), new DateTime(), Type.LOAD, HAMBURG, hamburgToHongKong));

    cargo.getEvents().addAll(events);
    return cargo;
  }

  private Cargo populateCargoOffMelbourne() throws Exception {
    final Cargo cargo = new Cargo(trackingId("XYZ"), STOCKHOLM, MELBOURNE);

    final CarrierMovement stockholmToHamburg = new CarrierMovement(
       new CarrierMovementId("CAR_001"), STOCKHOLM, HAMBURG);

    events.add(new HandlingEvent(cargo, getDate("2007-12-01"), new DateTime(), Type.LOAD, STOCKHOLM, stockholmToHamburg));
    events.add(new HandlingEvent(cargo, getDate("2007-12-02"), new DateTime(), Type.UNLOAD, HAMBURG, stockholmToHamburg));

    final CarrierMovement hamburgToHongKong = new CarrierMovement(
       new CarrierMovementId("CAR_001"), HAMBURG, HONGKONG);

    events.add(new HandlingEvent(cargo, getDate("2007-12-03"), new DateTime(), Type.LOAD, HAMBURG, hamburgToHongKong));
    events.add(new HandlingEvent(cargo, getDate("2007-12-04"), new DateTime(), Type.UNLOAD, HONGKONG, hamburgToHongKong));

    final CarrierMovement hongKongToMelbourne = new CarrierMovement(
       new CarrierMovementId("CAR_001"), HONGKONG, MELBOURNE);

    events.add(new HandlingEvent(cargo, getDate("2007-12-05"), new DateTime(), Type.LOAD, HONGKONG, hongKongToMelbourne));
    events.add(new HandlingEvent(cargo, getDate("2007-12-07"), new DateTime(), Type.UNLOAD, MELBOURNE, hongKongToMelbourne));

    cargo.getEvents().addAll(events);
    return cargo;
  }

  private Cargo populateCargoOnHongKong() throws Exception {
    final Cargo cargo = new Cargo(trackingId("XYZ"), STOCKHOLM, MELBOURNE);

    final CarrierMovement stockholmToHamburg = new CarrierMovement(
       new CarrierMovementId("CAR_001"), STOCKHOLM, HAMBURG);

    events.add(new HandlingEvent(cargo, getDate("2007-12-01"), new DateTime(), Type.LOAD, STOCKHOLM, stockholmToHamburg));
    events.add(new HandlingEvent(cargo, getDate("2007-12-02"), new DateTime(), Type.UNLOAD, HAMBURG, stockholmToHamburg));

    final CarrierMovement hamburgToHongKong = new CarrierMovement(
       new CarrierMovementId("CAR_001"), HAMBURG, HONGKONG);

    events.add(new HandlingEvent(cargo, getDate("2007-12-03"), new DateTime(), Type.LOAD, HAMBURG, hamburgToHongKong));
    events.add(new HandlingEvent(cargo, getDate("2007-12-04"), new DateTime(), Type.UNLOAD, HONGKONG, hamburgToHongKong));

    final CarrierMovement hongKongToMelbourne = new CarrierMovement(
       new CarrierMovementId("CAR_001"), HONGKONG, MELBOURNE);

    events.add(new HandlingEvent(cargo, getDate("2007-12-05"), new DateTime(), Type.LOAD, HONGKONG, hongKongToMelbourne));

    cargo.getEvents().addAll(events);
    return cargo;
  }

  public void testIsMisdirected() throws Exception {
    //A cargo with no itinerary is not misdirected
        Cargo cargo = new Cargo(trackingId("TRKID"), SHANGHAI, GOTHENBURG);
    assertFalse(cargo.isMisdirected());

    cargo = setUpCargoWithItinerary(SHANGHAI, ROTTERDAM, GOTHENBURG);

    //A cargo with no handling events is not misdirected
    assertFalse(cargo.isMisdirected());

    Collection<HandlingEvent> handlingEvents = new ArrayList<HandlingEvent>();

    CarrierMovement abc = new CarrierMovement(new CarrierMovementId("ABC"), SHANGHAI, ROTTERDAM);
    CarrierMovement def = new CarrierMovement(new CarrierMovementId("DEF"), ROTTERDAM, GOTHENBURG);
    CarrierMovement ghi = new CarrierMovement(new CarrierMovementId("GHI"), ROTTERDAM, NEWYORK);

    //Happy path
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(10), new DateTime(20), Type.RECEIVE, SHANGHAI, null));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(30), new DateTime(40), Type.LOAD, SHANGHAI, abc));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(50), new DateTime(60), Type.UNLOAD, ROTTERDAM, abc));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(70), new DateTime(80), Type.LOAD, ROTTERDAM, def));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(90), new DateTime(100), Type.UNLOAD, GOTHENBURG, def));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(110), new DateTime(120), Type.CLAIM, GOTHENBURG, null));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(130), new DateTime(140), Type.CUSTOMS, GOTHENBURG, null));

    events.addAll(handlingEvents);
    cargo.getEvents().addAll(events);
    assertFalse(cargo.isMisdirected());

    //Try a couple of failing ones

    cargo = setUpCargoWithItinerary(SHANGHAI, ROTTERDAM, GOTHENBURG);
    handlingEvents = new ArrayList<HandlingEvent>();

    handlingEvents.add(new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.RECEIVE, HANGZOU, null));
    events.addAll(handlingEvents);
    cargo.getEvents().addAll(events);
    assertTrue(cargo.isMisdirected());


    cargo = setUpCargoWithItinerary(SHANGHAI, ROTTERDAM, GOTHENBURG);
    handlingEvents = new ArrayList<HandlingEvent>();

    handlingEvents.add(new HandlingEvent(cargo, new DateTime(10), new DateTime(20), Type.RECEIVE, SHANGHAI, null));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(30), new DateTime(40), Type.LOAD, SHANGHAI, abc));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(50), new DateTime(60), Type.UNLOAD, ROTTERDAM, abc));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(70), new DateTime(80), Type.LOAD, ROTTERDAM, ghi));

    events.addAll(handlingEvents);
    cargo.getEvents().addAll(events);
    assertTrue(cargo.isMisdirected());


    cargo = setUpCargoWithItinerary(SHANGHAI, ROTTERDAM, GOTHENBURG);
    handlingEvents = new ArrayList<HandlingEvent>();

    handlingEvents.add(new HandlingEvent(cargo, new DateTime(10), new DateTime(20), Type.RECEIVE, SHANGHAI, null));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(30), new DateTime(40), Type.LOAD, SHANGHAI, abc));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(50), new DateTime(60), Type.UNLOAD, ROTTERDAM, abc));
    handlingEvents.add(new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.CLAIM, ROTTERDAM, null));

    events.addAll(handlingEvents);
    cargo.getEvents().addAll(events);
    assertTrue(cargo.isMisdirected());
  }

  private Cargo setUpCargoWithItinerary(Location origin, Location midpoint, Location destination) {
    Cargo cargo = new Cargo(trackingId("CARGO1"), origin, destination);

    CarrierMovement cm = new CarrierMovement(
      new CarrierMovementId("ABC"), origin, destination);

    Itinerary itinerary = new Itinerary(
      Arrays.asList(
        new Leg(cm, origin, midpoint),
        new Leg(cm, midpoint, destination)
      )
    );

    cargo.attachItinerary(itinerary);
    return cargo;
  }

  /**
   * Parse an ISO 8601 (YYYY-MM-DD) String to Date
   *
   * @param isoFormat String to parse.
   * @return Created date instance.
   * @throws ParseException Thrown if parsing fails.
   */
  private DateTime getDate(String isoFormat) throws ParseException {
    final DateTimeFormatter df = DateTimeFormat.forPattern("yyyy-MM-dd");
    return df.parseDateTime(isoFormat);
  }
}
