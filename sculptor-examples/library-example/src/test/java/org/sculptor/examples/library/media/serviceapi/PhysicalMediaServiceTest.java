package org.sculptor.examples.library.media.serviceapi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.util.List;

import org.sculptor.examples.library.media.domain.Book;
import org.sculptor.examples.library.media.domain.PhysicalMedia;
import org.sculptor.examples.library.media.serviceapi.LibraryService;
import org.sculptor.examples.library.media.serviceapi.PhysicalMediaService;
import org.sculptor.examples.library.media.serviceapi.PhysicalMediaServiceTestBase;
import org.junit.Test;
import org.sculptor.examples.library.media.domain.Library;
import org.sculptor.framework.accessimpl.jpa.JpaHelper;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Spring based transactional test with DbUnit support.
 */
public class PhysicalMediaServiceTest extends AbstractDbUnitJpaTests implements PhysicalMediaServiceTestBase {
    private PhysicalMediaService physicalMediaService;
    private LibraryService libraryService;

    @Autowired
    public void setPhysicalMediaService(PhysicalMediaService physicalMediaService) {
        this.physicalMediaService = physicalMediaService;
    }

    @Autowired
    public void setLibraryService(LibraryService libraryService) {
        this.libraryService = libraryService;
    }

    @Override
    protected String getDataSetFile() {
        // use same testdata as for LibraryService
        if (JpaHelper.isJpaProviderEclipselink(getEntityManager())) {
            return "dbunit/LibraryServiceTest_eclipselink.xml";
        }
        // datanucleus bug. PrimaryKeyJoinColumn is not working correctly for entities inherited from mappedsuperclass
        // TODO: report to datanucleus issue tracker
        else if (JpaHelper.isJpaProviderDataNucleus(getEntityManager())) {
            return "dbunit/LibraryServiceTest_datanucleus.xml";
        }
        return "dbunit/LibraryServiceTest.xml";
    }

    @Test
    public void testSave() throws Exception {
        int before = countRowsInTable(PhysicalMedia.class);
        Library library = libraryService.findById(getServiceContext(), new Long(1));
        PhysicalMedia media = new PhysicalMedia();
        media.setLibrary(library);
        media.setStatus("A");
        media.setLocation("abcdef");
        media = physicalMediaService.save(getServiceContext(), media);
        assertEquals(before + 1, countRowsInTable(PhysicalMedia.class));
    }

    @Test
    public void testSaveWithBook() throws Exception {
        int before = countRowsInTable(Book.class);
        PhysicalMedia media = new PhysicalMedia();
        media.setStatus("A");
        media.setLocation("abcdef");
        // possible bug in openjpa
        // TODO: report to openjpa
        if (JpaHelper.isJpaProviderOpenJpa(getEntityManager()))
        	media = physicalMediaService.save(getServiceContext(), media);
        media.addMedia(new Book("book1", "123456"));
        media.addMedia(new Book("book2", "654321"));
        media = physicalMediaService.save(getServiceContext(), media);
        assertEquals(before + 2, countRowsInTable(Book.class));
    }

    @Test
    public void testDelete() throws Exception {
        int before = countRowsInTable(PhysicalMedia.class);
        PhysicalMedia media = physicalMediaService.findById(getServiceContext(), new Long(1));
        physicalMediaService.delete(getServiceContext(), media);
        assertEquals(before - 1, countRowsInTable(PhysicalMedia.class));
    }

    @Test
    public void testFindAll() throws Exception {
        List<PhysicalMedia> all = physicalMediaService.findAll(getServiceContext());
        assertEquals(6, all.size());
    }

    @Test
    public void testFindById() throws Exception {
        PhysicalMedia media = physicalMediaService.findById(getServiceContext(), new Long(1));
        assertNotNull(media);
        assertEquals("abc123", media.getLocation());
    }
}
