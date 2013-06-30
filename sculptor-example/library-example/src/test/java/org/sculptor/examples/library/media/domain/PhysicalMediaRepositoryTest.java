package org.sculptor.examples.library.media.domain;

import static org.junit.Assert.assertEquals;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;

import java.util.ArrayList;
import java.util.List;

import org.sculptor.examples.library.media.domain.PhysicalMedia;
import org.sculptor.examples.library.media.domain.PhysicalMediaProperties;
import org.sculptor.examples.library.media.domain.PhysicalMediaRepository;
import org.junit.Assume;
import org.junit.Test;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessimpl.jpa.JpaHelper;
import org.sculptor.framework.domain.PagedResult;
import org.sculptor.framework.domain.PagingParameter;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Spring based transactional test with DbUnit support.
 */
public class PhysicalMediaRepositoryTest extends AbstractDbUnitJpaTests {

    private PhysicalMediaRepository physicalMediaRepository;

    @Autowired
    public void setPhysicalMediaRepository(PhysicalMediaRepository physicalMediaRepository) {
        this.physicalMediaRepository = physicalMediaRepository;
    }

    @Override
    protected String getDataSetFile() {
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
    public void testFindByNestedCondition() throws Exception {
        List<ConditionalCriteria> conditionalCriteria = criteriaFor(PhysicalMedia.class).withProperty(
                PhysicalMediaProperties.library().name()).eq("LibraryServiceTest").build();
        PagingParameter pParam = PagingParameter.rowAccess(0, 100);
        PagedResult<PhysicalMedia> pResult = physicalMediaRepository.findByCondition(conditionalCriteria, pParam);
        assertEquals(2, pResult.getValues().size());
    }

    @Test
    public void testFindByNestedCondition2() throws Exception {
        List<ConditionalCriteria> conditionalCriteria = criteriaFor(PhysicalMedia.class).withProperty(
                PhysicalMediaProperties.library().name()).eq("LibraryServiceTest").and().withProperty(
                PhysicalMediaProperties.status()).eq("A").build();
        PagingParameter pParam = PagingParameter.rowAccess(0, 100);
        PagedResult<PhysicalMedia> pResult = physicalMediaRepository.findByCondition(conditionalCriteria, pParam);
        assertEquals(2, pResult.getValues().size());
    }

    @Test
    public void testFindByNestedCondition3() throws Exception {
        ConditionalCriteria condition1 = criteriaFor(PhysicalMedia.class).withProperty(
                PhysicalMediaProperties.library().name()).eq("LibraryServiceTest").buildSingle();
        ConditionalCriteria condition2 = criteriaFor(PhysicalMedia.class)
                .withProperty(PhysicalMediaProperties.status()).eq("A").buildSingle();
        ArrayList<ConditionalCriteria> conditionalCriteria = new ArrayList<ConditionalCriteria>();
        conditionalCriteria.add(condition1);
        conditionalCriteria.add(condition2);
        PagingParameter pParam = PagingParameter.rowAccess(0, 100);
        PagedResult<PhysicalMedia> pResult = physicalMediaRepository.findByCondition(conditionalCriteria, pParam);
        assertEquals(2, pResult.getValues().size());
    }

    @Test
    public void testFindByNestedCondition3WithCount() throws Exception {
    	// TODO: possible solution is to use JoinFetch to optimize query execution (didn't get it to work until now)
        Assume.assumeTrue(!JpaHelper.isJpaProviderEclipselink(getEntityManager()));
    	ConditionalCriteria condition1 = criteriaFor(PhysicalMedia.class).withProperty(
                PhysicalMediaProperties.library().name()).eq("LibraryServiceTest").buildSingle();
        ConditionalCriteria condition2 = criteriaFor(PhysicalMedia.class)
                .withProperty(PhysicalMediaProperties.status()).eq("A").buildSingle();
        ArrayList<ConditionalCriteria> conditionalCriteria = new ArrayList<ConditionalCriteria>();
        conditionalCriteria.add(condition1);
        conditionalCriteria.add(condition2);
        PagingParameter pParam = PagingParameter.rowAccess(0, 1, true);
        PagedResult<PhysicalMedia> pResult = physicalMediaRepository.findByCondition(conditionalCriteria, pParam);
        assertEquals(1, pResult.getValues().size());
        assertEquals(2, pResult.getTotalRows());
    }

    @Test
    public void testFindByNestedCondition4() throws Exception {
    	// hibernate seems not to support this nested condition
    	// TODO: watch hibernate issue HHH-5948
        Assume.assumeTrue(!JpaHelper.isJpaProviderHibernate(getEntityManager()));
    	// datanucleus seems not to support this nested condition
        Assume.assumeTrue(!JpaHelper.isJpaProviderDataNucleus(getEntityManager()));
    	// need a distinct query for openjpa and eclipselink to get the correct results
    	List<ConditionalCriteria> conditionalCriteria = criteriaFor(PhysicalMedia.class).withProperty(
                PhysicalMediaProperties.library().media().status()).eq("A").distinctRoot().build();
        PagingParameter pParam = PagingParameter.rowAccess(0, 1, true);
        PagedResult<PhysicalMedia> pResult = physicalMediaRepository.findByCondition(conditionalCriteria, pParam);
        assertEquals(6, pResult.getTotalRows());
    }
}
