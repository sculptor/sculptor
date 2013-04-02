package org.sculptor.examples.library.person.repositoryimpl;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sculptor.examples.library.person.repositoryimpl.PersonRepositoryBase;
import org.sculptor.examples.library.person.domain.Person;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for Person
 */
@Repository("personRepository")
public class PersonRepositoryImpl extends PersonRepositoryBase {
    public PersonRepositoryImpl() {
    }

    @Override
    public List<Person> findPersonByName(String name) {
        List<String> names = Arrays.asList(name.split(" "));
        Map<String, Object> parameters = new HashMap<String, Object>();
        parameters.put("names", names);
        return findByQuery("Person.findPersonByName", parameters);
    }
}

