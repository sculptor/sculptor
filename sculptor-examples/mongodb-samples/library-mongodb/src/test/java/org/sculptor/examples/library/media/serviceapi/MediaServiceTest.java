package org.sculptor.examples.library.media.serviceapi;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.sculptor.framework.context.SimpleJUnitServiceContextFactory.getServiceContext;

import java.util.List;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.sculptor.examples.library.media.domain.LibraryTestData;
import org.sculptor.examples.library.media.domain.Media;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class MediaServiceTest implements MediaServiceTestBase {

	@Autowired
	private MediaService mediaService;

	@Autowired
	private LibraryTestData testData;
	@Autowired
	private DbManager dbManager;

	@BeforeEach
	public void initialData() throws Exception {
		testData.saveInitialData();
	}

	@AfterEach
	public void dropDatabase() {
		dbManager.getDB().dropDatabase();
	}

	@Override
	@Test
	public void testFindAll() throws Exception {
		List<Media> all = mediaService.findAll(getServiceContext());
		assertEquals(3, all.size());
	}
}
