package org.sculptor.dddsample.location.domain;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * A few locations for easy testing.
 */
public class SampleLocations {
	
  public static final Location HONGKONG = new Location("Hongkong", new UnLocode("CNHKG"));
  public static final Location MELBOURNE = new Location("Melbourne", new UnLocode("AUMEL"));
  public static final Location STOCKHOLM = new Location("Stockholm", new UnLocode("SESTO"));
  public static final Location HELSINKI = new Location("Helsinki", new UnLocode("FIHEL"));
  public static final Location CHICAGO = new Location("Chicago", new UnLocode("USCHI"));
  public static final Location TOKYO = new Location("Tokyo", new UnLocode("JNTKO"));
  public static final Location HAMBURG = new Location("Hamburg", new UnLocode("DEHAM"));
  public static final Location SHANGHAI = new Location("Shanghai", new UnLocode("CNSHA"));
  public static final Location ROTTERDAM = new Location("Rotterdam", new UnLocode("NLRTM"));
  public static final Location GOTHENBURG = new Location("Göteborg", new UnLocode("SEGOT"));
  public static final Location HANGZOU = new Location("Hangzhou", new UnLocode("CNHGH"));
  public static final Location NEWYORK = new Location("New York", new UnLocode("USNYC"));

  public static final Map<UnLocode, Location> ALL = new HashMap<UnLocode, Location>();

  static {
    for (Field field : SampleLocations.class.getDeclaredFields()) {
      if (field.getType().equals(Location.class)) {
        try {
          Location location = (Location) field.get(null);
          ALL.put(location.getUnLocode(), location);
        } catch (IllegalAccessException e) {
          throw new RuntimeException(e);
        }
      }
    }
  }

  public static List<Location> getAll() {
    return new ArrayList<Location>(ALL.values());
  }

  public static Location lookup(UnLocode unLocode) {
    return ALL.get(unLocode);
  }

}
