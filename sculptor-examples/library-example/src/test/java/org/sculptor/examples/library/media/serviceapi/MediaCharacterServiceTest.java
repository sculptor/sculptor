package org.sculptor.examples.library.media.serviceapi;

import static org.junit.Assert.assertEquals;

import java.util.List;

import org.sculptor.examples.library.media.serviceapi.MediaCharacterService;
import org.sculptor.examples.library.media.serviceapi.MediaCharacterServiceTestBase;
import org.junit.Test;
import org.sculptor.examples.library.media.domain.MediaCharacter;
import org.sculptor.framework.accessimpl.jpa.JpaHelper;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Spring based transactional test with DbUnit support.
 */
public class MediaCharacterServiceTest extends AbstractDbUnitJpaTests implements MediaCharacterServiceTestBase {

    private MediaCharacterService mediaCharacterService;

    @Autowired
    public void setMediaCharacterService(MediaCharacterService mediaCharacterService) {
        this.mediaCharacterService = mediaCharacterService;
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
        List<MediaCharacter> all = mediaCharacterService.findAll(getServiceContext());
        assertEquals(2, all.size());
    }
}
