package org.sculptor.examples.library.media.serviceapi;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.sculptor.examples.library.media.serviceapi.MediaService;
import org.sculptor.examples.library.media.serviceapi.MediaServiceTestBase;
import org.sculptor.examples.library.media.domain.Media;
import org.sculptor.framework.accessimpl.jpa.JpaHelper;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Spring based transactional test with DbUnit support.
 */
public class MediaServiceTest extends AbstractDbUnitJpaTests implements MediaServiceTestBase {

    private MediaService mediaService;

    @Autowired
    public void setMediaService(MediaService mediaService) {
        this.mediaService = mediaService;
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
    public void testFindAll() throws Exception {
        List<Media> all = mediaService.findAll(getServiceContext());
        assertEquals(3, all.size());
    }
}
