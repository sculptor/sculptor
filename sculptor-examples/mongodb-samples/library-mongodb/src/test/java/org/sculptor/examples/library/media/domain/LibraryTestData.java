package org.sculptor.examples.library.media.domain;

import static org.sculptor.examples.library.person.domain.PersonName.personName;
import static org.sculptor.examples.library.person.domain.Ssn.ssn;

import org.apache.commons.lang3.time.DateUtils;
import org.sculptor.examples.library.person.domain.Country;
import org.sculptor.examples.library.person.domain.Gender;
import org.sculptor.examples.library.person.domain.Person;
import org.sculptor.examples.library.person.domain.PersonRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class LibraryTestData {

	private static final String[] DATE_PATTERNS = { "yyyy-MM-dd" };

	@Autowired
	private LibraryRepository libraryRepository;
	@Autowired
	private PhysicalMediaRepository physicalMediaRepository;
	@Autowired
	private MediaRepository mediaRepository;
	@Autowired
	private MediaCharacterRepository mediaCharacterRepository;
	@Autowired
	private PersonRepository personRepository;

	private String libraryId;
	private String physicalMediaId1;

	public void saveInitialData() throws Exception {
		Person p1 = new Person(Gender.MALE, ssn("123456", Country.US));
		p1.setBirthDate(DateUtils.parseDate("1953-05-16", DATE_PATTERNS));
		p1.setName(personName("Pierce", "Brosnan"));
		p1 = personRepository.save(p1);

		Library library = new Library("LibraryServiceTest");
		library = libraryRepository.save(library);
		libraryId = library.getId();

		PhysicalMedia pm1 = new PhysicalMedia();
		pm1.setLocation("abc123");
		pm1.setStatus("A");
		pm1.setLibraryId(libraryId);
		pm1 = physicalMediaRepository.save(pm1);
		physicalMediaId1 = pm1.getId();
		library.getMediaIds().add(pm1.getId());

		PhysicalMedia pm2 = new PhysicalMedia();
		pm2.setLocation("abc456");
		pm2.setStatus("A");
		pm2.setLibraryId(libraryId);
		pm2 = physicalMediaRepository.save(pm2);
		library.getMediaIds().add(pm2.getId());

		// we have added physicalMedia to the library
		libraryRepository.save(library);

		Movie m1 = new Movie("Pippi Långstrump i Söderhavet", "abc");
		m1.setPlayLength(82);
		m1.getPhysicalMediaIds().add(pm1.getId());
		m1 = (Movie) mediaRepository.save(m1);
		pm1.getMediaIds().add(m1.getId());
		pm1 = physicalMediaRepository.save(pm1);

		Movie m2 = new Movie("Die Another Day", "dfe");
		m2.setPlayLength(82);
		m2.setCategory(Genre.ACTION);
		m2.getEngagements().add(new Engagement("Actor", p1));
		m2.getPhysicalMediaIds().add(pm2.getId());
		m2 = (Movie) mediaRepository.save(m2);
		pm2.getMediaIds().add(m2.getId());
		pm2 = physicalMediaRepository.save(pm2);

		Movie m3 = new Movie("Some bonus", "ghi");
		m3.setPlayLength(5);
		m3.getPhysicalMediaIds().add(pm2.getId());
		m3 = (Movie) mediaRepository.save(m3);
		pm2.getMediaIds().add(m3.getId());
		pm2 = physicalMediaRepository.save(pm2);

		MediaCharacter c1 = new MediaCharacter("Pippi");
		c1.getExistsInMediaIds().add(m1.getId());
		c1 = mediaCharacterRepository.save(c1);
		m1.getMediaCharactersIds().add(c1.getId());
		m1 = (Movie) mediaRepository.save(m1);

		MediaCharacter c2 = new MediaCharacter("James Bond");
		c2.getPlayedByIds().add(p1.getId());
		c2.getExistsInMediaIds().add(m2.getId());
		c2 = mediaCharacterRepository.save(c2);
		m2.getMediaCharactersIds().add(c2.getId());
		m2 = (Movie) mediaRepository.save(m2);

	}

	public String getLibraryId() {
		return libraryId;
	}

	public String getPhysicalMediaId1() {
		return physicalMediaId1;
	}

}
