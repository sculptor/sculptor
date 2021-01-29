package org.sculptor.examples.library.media.domain;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.sculptor.examples.library.media.domain.MediaCharacterBuilder.mediaCharacter;
import java.time.LocalDateTime;

public class BookBuilderTest {

	@Test
	public void assertBuild() {
		LocalDateTime now = LocalDateTime.now();
		Book book = BookBuilder.book()
			.createdBy("me")
			.createdDate(now)
			.title("Ender's Game")
			.isbn("Some-ISBN")
			.addMediaCharacter(mediaCharacter()
					.name("Ender")
					.build())
			.build();
		
		assertNotNull(book);
		assertEquals("me", book.getCreatedBy());
		assertEquals(now, book.getCreatedDate());
		assertEquals("Ender's Game", book.getTitle());
		assertEquals("Some-ISBN", book.getIsbn());
		assertEquals(1, book.getMediaCharacters().size());
	}
}
