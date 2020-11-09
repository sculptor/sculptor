package org.sculptor.examples.library.media.domain;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.sculptor.examples.library.media.domain.MediaCharacterBuilder.mediaCharacter;

import java.time.LocalDateTime;
import java.util.Date;

import org.sculptor.examples.library.media.domain.Book;
import org.junit.Test;

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
