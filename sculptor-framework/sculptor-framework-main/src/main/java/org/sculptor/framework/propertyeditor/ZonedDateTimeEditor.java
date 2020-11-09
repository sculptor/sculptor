package org.sculptor.framework.propertyeditor;

import java.beans.PropertyEditorSupport;
import java.time.Instant;
import java.time.ZonedDateTime;
import java.util.TimeZone;

public class ZonedDateTimeEditor extends PropertyEditorSupport {
	@Override
	public void setAsText(String value) throws IllegalArgumentException {
		long longVal = Long.parseLong(value);
		ZonedDateTime result = ZonedDateTime.ofInstant(Instant.ofEpochMilli(longVal), TimeZone.getDefault().toZoneId());
		setValue(result);
	}

}
