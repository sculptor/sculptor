package org.sculptor.examples.library.person.mapper;

import org.sculptor.examples.library.person.domain.Person;

import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;

public class PersonMapper extends PersonMapperBase {

	private static final PersonMapper instance = new PersonMapper();

	protected PersonMapper() {
	}

	public static PersonMapper getInstance() {
		return instance;
	}

	@Override
	public Person toDomain(DBObject from) {
		if (from == null) {
			return null;
		}
		// backwards compatibility, converting from old name structure to new
		if (!from.containsField("name") && from.containsField("firstName") && from.containsField("lastName")) {
			BasicDBObject name = new BasicDBObject();
			name.put("first", from.get("firstName"));
			name.put("last", from.get("lastName"));
			from.put("name", name);
		}
		return super.toDomain(from);
	}

	@Override
	public DBObject toData(Person from) {
		return super.toData(from);
	}

}
