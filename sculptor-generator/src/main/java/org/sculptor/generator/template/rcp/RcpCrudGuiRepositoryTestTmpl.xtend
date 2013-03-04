/*
 * Copyright 2008 The Fornax Project Team, including the original 
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

package org.sculptor.generator.template.rcp

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class RcpCrudGuiRepositoryTestTmpl {



def static String repositoryTest(GuiApplication it) {
	'''
	«it.groupByTarget().forEach[repositoryTest(it)]»
	'''
} 

def static String repositoryTest(UserTaskGroup it) {
	'''
	/*At least findAll must exist */
	«IF getListTaskPrimaryServiceOperation() != null && for.getFindAllMethod() != null»
		«repositoryTestBase(it)»
		«repositoryTestImpl(it)»
	«ENDIF»
	'''
}

def static String repositoryTestBase(UserTaskGroup it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".data.Rich" + for.name + "RepositoryTestBase"), 'TO_GEN_SRC_TEST', '''
	«javaHeader()»
	package «module.getRichClientPackage()».data;

	public abstract class Rich«for.name»RepositoryTestBase {

	«repositoryTestBaseSetUpBeforeClass(it)»
	«repositoryTestBaseSetUp(it)»
	«repositoryTestBaseTearDown(it)»
	«repositoryTestBaseCreateNewObject(it)»
	«repositoryTestBaseCreateExistingObject(it)»
	
	«IF getListTaskPrimaryServiceOperation() != null && for.getFindAllMethod() != null»
		«repositoryTestBaseGetAll(it)»

		«IF getUpdateTaskPrimaryServiceOperation() != null»    
		    «repositoryTestBaseSaveExisting(it)»
		    
		    «IF getDeleteTaskPrimaryServiceOperation() != null»
				«repositoryTestBaseDelete(it)»
			«ENDIF»
			«ENDIF»
			«IF getCreateTaskPrimaryServiceOperation() != null»
				«repositoryTestBaseSaveNew(it)»
			«ENDIF»
	«ENDIF»
	}
	'''
	)
	'''
	'''
}

def static String repositoryTestBaseSetUpBeforeClass(UserTaskGroup it) {
	'''
		@org.junit.BeforeClass
		public static void setUpBeforeClass() throws Exception {
			«fw("richclient.util.HeadlessRealm")».useAsDefault();
		}
	'''
}

def static String repositoryTestBaseSetUp(UserTaskGroup it) {
	'''
		private «fw("richclient.util.SpringInitializer")» spring;
		private «module.getRichClientPackage()».data.Rich«for.name»Repository repository;
		
		private org.jmock.Mockery mockery = new org.jmock.Mockery();
		private java.util.Observer observer;
		
		@org.junit.Before
		public void setUp() throws Exception {
			spring = new «fw("richclient.util.SpringInitializer")»(getClass().getClassLoader()) {
				@Override
				protected String getSpringConfig() {
				    return "/applicationContext-test.xml";
				}
			};
			spring.start();
			repository = spring.getBeanFromSimpleClassName(«module.getRichClientPackage()».data.Rich«for.name»Repository.class);
			
			observer = mockery.mock(java.util.Observer.class);
			repository.addObserver(observer);
		}
		
		protected «fw("richclient.util.SpringInitializer")» getSpring() {
			return spring;
		}
	'''
}

def static String repositoryTestBaseTearDown(UserTaskGroup it) {
	'''
		@org.junit.After
		public void tearDown() throws Exception {
			spring.stop();
			if (repository != null) {
				repository.deleteObserver(observer);
			}
		}
	'''
}

def static String repositoryTestBaseCreateNewObject(UserTaskGroup it) {
	'''
		protected abstract «module.getRichClientPackage()».data.Rich«for.name» createNewObject();
	'''
}

def static String repositoryTestBaseCreateExistingObject(UserTaskGroup it) {
	'''
		protected abstract «module.getRichClientPackage()».data.Rich«for.name» createExistingObject();
	'''
}

def static String repositoryTestBaseGetAll(UserTaskGroup it) {
	'''
	«val operation = it.getListTaskPrimaryServiceOperation() != null ? getListTaskPrimaryServiceOperation() : for.getFindAllMethod()»
		@org.junit.Test
		public void «operation.name»() throws Exception {
			// expectations
			mockery.checking(new org.jmock.Expectations() {{
				allowing(observer).update(with(any(java.util.Observable.class)), with(any(«fw("richclient.data.DataEvent")».class)));
			}});
			
			«IF operation.hasPagingParameter()»
			java.util.List<«module.getRichClientPackage()».data.Rich«for.name»> all = repository.«operation.name»(«getJavaType("PagingParameter")».pageAccess(20)).getValues();
			«ELSE»
			java.util.List<«module.getRichClientPackage()».data.Rich«for.name»> all = repository.«operation.name»();
			«ENDIF»
			junit.framework.Assert.assertNotNull(all);
			
			mockery.assertIsSatisfied();
		}
	'''
}

def static String repositoryTestBaseSaveNew(UserTaskGroup it) {
	'''
	«val operation = it.getCreateTaskPrimaryServiceOperation()»
	«val getAllOperation = it.getListTaskPrimaryServiceOperation() != null ? getListTaskPrimaryServiceOperation() : for.getFindAllMethod()»
		@org.junit.Test
		public void saveNew() throws Exception {
			final «module.getRichClientPackage()».data.Rich«for.name» obj = createNewObject();
			
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				    atLeast(1).of(observer).update(with(any(java.util.Observable.class)), with(any(«fw("richclient.data.DataEvent")».class)));
				}
			});
			
			
			«IF getAllOperation.hasPagingParameter()»
			int sizeBefore = repository.«getAllOperation.name»(«getJavaType("PagingParameter")».pageAccess(20)).getValues().size();
			repository.«operation.name»(obj);
			java.util.List<«module.getRichClientPackage()».data.Rich«for.name»> all = repository.«getAllOperation.name»(«getJavaType("PagingParameter")».pageAccess(20)).getValues();
			«ELSE»
			int sizeBefore = repository.«getAllOperation.name»().size();
			repository.«operation.name»(obj);
			java.util.List<«module.getRichClientPackage()».data.Rich«for.name»> all = repository.«getAllOperation.name»();
			«ENDIF»
			junit.framework.Assert.assertEquals(sizeBefore + 1, all.size());
			
			mockery.assertIsSatisfied();
		}
	'''
}

def static String repositoryTestBaseSaveExisting(UserTaskGroup it) {
	'''
	«val operation = it.getUpdateTaskPrimaryServiceOperation()»
	«val getAllOperation = it.getListTaskPrimaryServiceOperation() != null ? getListTaskPrimaryServiceOperation() : for.getFindAllMethod()»
		@org.junit.Test
		public void saveExisting() throws Exception {
			final «module.getRichClientPackage()».data.Rich«for.name» obj = createExistingObject();
			
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				    atLeast(1).of(observer).update(with(any(java.util.Observable.class)), with(any(«fw("richclient.data.DataEvent")».class)));
				}
			});
			
			«IF getAllOperation.hasPagingParameter()»
			int sizeBefore = repository.«getAllOperation.name»(«getJavaType("PagingParameter")».pageAccess(20)).getValues().size();
			repository.«operation.name»(obj);
			java.util.List<«module.getRichClientPackage()».data.Rich«for.name»> all = repository.«getAllOperation.name»(«getJavaType("PagingParameter")».pageAccess(20)).getValues();
			«ELSE»
			int sizeBefore = repository.«getAllOperation.name»().size();
			repository.«operation.name»(obj);
			java.util.List<«module.getRichClientPackage()».data.Rich«for.name»> all = repository.«getAllOperation.name»();
			«ENDIF»
			junit.framework.Assert.assertEquals(sizeBefore, all.size());
			
			mockery.assertIsSatisfied();
		}
	'''
}

def static String repositoryTestBaseDelete(UserTaskGroup it) {
	'''
	«val aTask = it.userTasks.typeSelect(DeleteTask).first()»
	«val saveOperation = it.getUpdateTaskPrimaryServiceOperation() != null ? getUpdateTaskPrimaryServiceOperation() : getCreateTaskPrimaryServiceOperation()»
	«val getAllOperation = it.getListTaskPrimaryServiceOperation() != null ? getListTaskPrimaryServiceOperation() : for.getFindAllMethod()»
		@org.junit.Test
		public void delete() throws Exception {
			final «module.getRichClientPackage()».data.Rich«for.name» obj = createExistingObject();
			
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				    atLeast(1).of(observer).update(with(any(java.util.Observable.class)), with(any(«fw("richclient.data.DataEvent")».class)));
				}
			});
			
			«IF getAllOperation.hasPagingParameter()»
			int sizeBefore = repository.«getAllOperation.name»(«getJavaType("PagingParameter")».pageAccess(20)).getValues().size();
			repository.«aTask.getPrimaryServiceOperation().name»(obj);
			java.util.List<«module.getRichClientPackage()».data.Rich«for.name»> all = repository.«getAllOperation.name»(«getJavaType("PagingParameter")».pageAccess(20)).getValues();
			«ELSE»
			int sizeBefore = repository.«getAllOperation.name»().size();
			repository.«aTask.getPrimaryServiceOperation().name»(obj);
			java.util.List<«module.getRichClientPackage()».data.Rich«for.name»> all = repository.«getAllOperation.name»();
			«ENDIF»
			junit.framework.Assert.assertEquals(sizeBefore - 1, all.size());
			
			mockery.assertIsSatisfied();
		}
	'''
}


def static String repositoryTestImpl(UserTaskGroup it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".data.Rich" + for.name + "RepositoryTest"), 'TO_SRC_TEST', '''
	«javaHeader()»
	package «module.getRichClientPackage()».data;

	public class Rich«for.name»RepositoryTest ^extends Rich«for.name»RepositoryTestBase {

	«repositoryTestImplCreateNewObject(it) FOR this»
	«repositoryTestImplCreateExistingObject(it) FOR this»

	}
	'''
	)
	'''
	'''
}

def static String repositoryTestImplCreateNewObject(UserTaskGroup it) {
	'''
		@Override
		protected «module.getRichClientPackage()».data.Rich«for.name» createNewObject() {
			«module.getRichClientPackage()».data.Rich«for.name» input = new «module.getRichClientPackage()».data.Rich«for.name»();
			// TODO populate input
			«FOR prop  : getAggregatedViewProperties().reject(p | p.isSystemAttribute()).reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty)»
			// input.set«prop.name.toFirstUpper()»(...);
			«ENDFOR»
			return input;
		}
	'''
}

def static String repositoryTestImplCreateExistingObject(UserTaskGroup it) {
	'''
	«val operation = it.getListTaskPrimaryServiceOperation() != null ? getListTaskPrimaryServiceOperation() : for.getFindAllMethod()»
		@Override
		protected «module.getRichClientPackage()».data.Rich«for.name» createExistingObject() {
		«module.getRichClientPackage()».data.Rich«for.name» input = new «module.getRichClientPackage()».data.Rich«for.name»();
		«IF operation != null»
		// TODO add obj in ServiceStub
		«operation.service.getServiceapiPackage()».«operation.service.name» service = getSpring().getBeanFromSimpleClassName(«operation.service.getServiceapiPackage()».«operation.service.name».class);
		«for.getDomainPackage()».«for.name» domainObj = service.«operation.name»(«IF isServiceContextToBeGenerated()»null«ENDIF»).iterator().next();
		input.fromDomainObject(domainObj);
		«ENDIF»        
			return input;
		}
	'''
}
}
