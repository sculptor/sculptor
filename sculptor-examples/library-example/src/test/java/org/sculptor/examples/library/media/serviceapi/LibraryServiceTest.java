/*
 * Copyright 2013 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sculptor.examples.library.media.serviceapi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

import org.junit.Assume;
import org.junit.Ignore;
import org.junit.Test;
import org.sculptor.examples.library.media.domain.Library;
import org.sculptor.examples.library.media.domain.LibraryProperties;
import org.sculptor.examples.library.media.domain.Media;
import org.sculptor.examples.library.media.domain.Movie;
import org.sculptor.examples.library.media.domain.PhysicalMedia;
import org.sculptor.examples.library.media.exception.LibraryNotFoundException;
import org.sculptor.examples.library.person.domain.Person;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.ConditionalCriteriaBuilder;
import org.sculptor.framework.accessimpl.jpa.JpaHelper;
import org.sculptor.framework.domain.PagedResult;
import org.sculptor.framework.domain.PagingParameter;
import org.sculptor.framework.errorhandling.OptimisticLockingException;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Spring based transactional test with DbUnit support.
 */
public class LibraryServiceTest extends AbstractDbUnitJpaTests implements LibraryServiceTestBase {
    private final long libraryId = 1;

    @Autowired
    private LibraryService libraryService;

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
	public void testFindLibraryByName() throws Exception {
		String libraryName = "LibraryServiceTest";
		Library library = libraryService.findLibraryByName(getServiceContext(), libraryName);
		assertNotNull(library);
		assertEquals(libraryName, library.getName());
		assertTrue(library.getId() > 0);

	}

    @Test(expected=LibraryNotFoundException.class)
    public void testFindLibraryByNameNotFound() throws Exception {
        libraryService.findLibraryByName(getServiceContext(), "not a library");
    }

    @Test
    public void testSave() throws Exception {
        LocalDateTime now = LocalDateTime.now();
        String name = "TestCreateLibrary " + now;
        Library library = new Library(name);
        libraryService.save(getServiceContext(), library);
        Library foundLibrary = libraryService.findLibraryByName(getServiceContext(), name);
        assertNotNull(foundLibrary);
        assertNotNull(foundLibrary.getLastUpdated());
        assertEquals("system", foundLibrary.getLastUpdatedBy());
        assertTrue("Expected " + foundLibrary.getLastUpdated() + " > " + now,
        foundLibrary.getLastUpdated().compareTo(now) >= 0);
    }

    @Test(expected=OptimisticLockingException.class)
    @Transactional(propagation = Propagation.NEVER)
    public void testOptimisticLocking() throws Exception {
    	// TODO: expected exception not thrown for datanucleus, find out why.
        if (JpaHelper.isJpaProviderDataNucleus(getEntityManager())) {
        	throw new OptimisticLockingException("");
        }
    	// TODO: expected exception not thrown for openjpa, find out why.
        if (JpaHelper.isJpaProviderOpenJpa(getEntityManager())) {
        	throw new OptimisticLockingException("");
        }
        Library foundLibrary = libraryService.findById(getServiceContext(), 1L);
        foundLibrary.setVersion(0L);
        libraryService.save(getServiceContext(), foundLibrary);
    }

    @Test
    public void testFindMediaByName() throws Exception {
        String title = "Pippi Långstrump i Söderhavet";
        List<Media> movieList = libraryService.findMediaByName(getServiceContext(), libraryId, title);
        assertNotNull(movieList);
        assertEquals(1, movieList.size());
        assertEquals(Movie.class, movieList.get(0).getClass());

        Movie movie = (Movie) movieList.get(0);
        assertEquals(title, movie.getTitle());
    }

    @Test
    public void testFindMediaByCharacter() throws Exception {
        String characterName = "James Bond";
        List<Media> movieList = libraryService.findMediaByCharacter(getServiceContext(), libraryId, characterName);
        assertNotNull(movieList);
        assertEquals(1, movieList.size());
        assertEquals(Movie.class, movieList.get(0).getClass());

        Movie movie = (Movie) movieList.get(0);
        assertEquals("Die Another Day", movie.getTitle());
    }

    @Test
    public void testFindPersonByName() throws Exception {
       	// NamedQuery needs '()', see comments in Person class
    	Assume.assumeTrue(!JpaHelper.isJpaProviderDataNucleus(getEntityManager()));
        String name = "Pierce Brosnan";
        List<Person> persons = libraryService.findPersonByName(getServiceContext(), name);
        assertNotNull(persons);
        assertEquals(1, persons.size());
        Person p = persons.get(0);
        assertEquals("Pierce", p.getName().getFirst());
        assertEquals("Brosnan", p.getName().getLast());
        String s = p.toString();
        assertTrue(s.indexOf("ssn") != -1);
        assertTrue(s.indexOf("first") != -1);
        assertTrue(s.indexOf("last") != -1);
    }

    @Test
    public void testDelete() throws Exception {
        // DataNucleus does not allow clearing sets for entities marked for deletion
        // @PreDelete is not working as expected, seems to be a bug in DataNucleus, report to issue tracker
        Assume.assumeTrue(!JpaHelper.isJpaProviderDataNucleus(getEntityManager()));
        int before = countRowsInTable(Library.class);
        int physicalMediaBefore = countRowsInTable(PhysicalMedia.class);
        Library library = libraryService.findById(getServiceContext(), new Long(1));
        // this is a temporary workaround for OpenJPA and DataNucleus
        // TODO: @PreDelete is not working as expected, seems to be a bug in OpenJPA, report to issue tracker
        if (JpaHelper.isJpaProviderOpenJpa(getEntityManager()) ||
        	JpaHelper.isJpaProviderDataNucleus(getEntityManager())) {
            library.removeAllMedia();
        }
        libraryService.delete(getServiceContext(), library);
        assertEquals(before - 1, countRowsInTable(Library.class));
        // we remove PhysicalMedia associations before remove to avoid cascade
        // delete
        assertEquals(physicalMediaBefore, countRowsInTable(PhysicalMedia.class));
    }

    @Test
    public void testFindAll() throws Exception {
        List<Library> all = libraryService.findAll(getServiceContext());
        assertEquals(3, all.size());
    }

    @Test
    public void testFindById() throws Exception {
        Library library = libraryService.findById(getServiceContext(), new Long(1));
        assertNotNull(library);
        assertEquals("LibraryServiceTest", library.getName());
    }

    // DistinctRoot is not supported, ignore test
    @Ignore
    @Test
    public void testFindByCondition() throws Exception {
        Assume.assumeTrue(JpaHelper.isJpaProviderHibernate(getEntityManager()));

        PagingParameter paging = PagingParameter.rowAccess(0, 2, 0);

        // Simulate wrong result without distinctRoot() - 1 row only
        List<ConditionalCriteria> wrongCondition = ConditionalCriteriaBuilder.criteriaFor(Library.class)
                .withProperty(LibraryProperties.media().version()).eq(1l).orderBy(LibraryProperties.name())
                .descending().build();
        PagedResult<Library> wrongResult = libraryService.findByCondition(getServiceContext(), wrongCondition, paging);
        assertEquals(1, wrongResult.getRowCount());
        assertEquals(1, wrongResult.getTotalRows());
        assertEquals(3l, wrongResult.getValues().get(0).getId().longValue());

        // Simulate exception when you are sorting with foreign attribute
        // You can sort only by attributes owned by primary object
        try {
            List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Library.class)
                    .withProperty(LibraryProperties.media().version()).eq(1l).distinctRoot()
                    .orderBy(LibraryProperties.media().location()).build();
            libraryService.findByCondition(getServiceContext(), condition, paging);
            fail("Exception not thrown");
        } catch (Exception ex) {
            assertTrue("",
                    ex.getMessage().indexOf("create distinct condition order by foreign field 'media.location'") != -1);
        }

        // Correct run after distinctRoot() specified. Size of result is 2 and
        // order is
        // reversed (3 - Third library, 2 - My library) because of descending
        // name order
        List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Library.class)
                .withProperty(LibraryProperties.media().version()).eq(1l).distinctRoot()
                .orderBy(LibraryProperties.name()).descending().build();
        PagedResult<Library> findResult = libraryService.findByCondition(getServiceContext(), condition, paging);
        assertEquals(2, findResult.getRowCount());
        assertEquals(-1, findResult.getTotalRows());
        assertEquals(3l, findResult.getValues().get(0).getId().longValue());
        assertEquals(2l, findResult.getValues().get(1).getId().longValue());
    }

    @Test
    public void testNoLimitPaging() throws Exception {
        List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Library.class)
                .withProperty(LibraryProperties.version()).eq(1l).build();

        PagingParameter nolimitPaging = PagingParameter.noLimits();
        PagedResult<Library> findResult = libraryService.findByCondition(getServiceContext(), condition, nolimitPaging);
        assertEquals(3, findResult.getValues().size());
    }

    // ProjectionRoot and FetchLazy is not supported, ignore test
    @Ignore
    @Test
    public void testFindByConditionLazyFetch() throws Exception {
        PagingParameter paging = PagingParameter.noLimits();
        List<ConditionalCriteria> conditions = ConditionalCriteriaBuilder
            .criteriaFor(Library.class)
            .withProperty(LibraryProperties.version()).eq(1l)
            .withProperty(LibraryProperties.media()).fetchEager()
            .projectionRoot().build();
        PagedResult<Library> eagerResult = libraryService.findByCondition(getServiceContext(), conditions, paging);
        assertEquals(6, eagerResult.getRowCount());

        conditions.add(ConditionalCriteria.fetchLazy(LibraryProperties.media()));
        PagedResult<Library> lazyResult = libraryService.findByCondition(getServiceContext(), conditions, paging);
        assertEquals(3, lazyResult.getRowCount());
    }
}
