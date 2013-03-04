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

class RcpCrudGuiCreateControllerTestTmpl {



def static String createControllerTest(GuiApplication it) {
	'''
	«it.modules.forEach[createControllerTest(it)]»
	'''
} 

def static String createControllerTest(GuiModule it) {
	'''
	«it.userTasks.typeSelect(CreateTask).forEach[createControllerTest(it)]»
	'''
}

def static String createControllerTest(CreateTask it) {
	'''
	«createControllerTestBase(it)»
	«createControllerTestImpl(it)»
	'''
}

def static String createControllerTestBase(CreateTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".controller.New" +for.name + "ControllerTestBase"), 'TO_GEN_SRC_TEST', '''
	«javaHeader()»
	package «module.getRichClientPackage()».controller;

	public abstract class New«for.name»ControllerTestBase {

	«setUpBeforeClass(it)»
	«setUp(it)»
	«(it)^abstractPopulateFormSuccess»
	«newSuccess(it)»
	«(it)^abstractCreateSelectedObject»
	«newFromSelectionSuccess(it)»
	
	«createTargetObservables(it)»
	
	}
	'''
	)
	'''
	'''
}

def static String setUpBeforeClass(UserTask it) {
	'''
		@org.junit.BeforeClass
		public static void setUpBeforeClass() throws Exception {
			«fw("richclient.util.HeadlessRealm")».useAsDefault();
		}
	'''
}

def static String setUp(CreateTask it) {
	'''
		private org.jmock.Mockery mockery = new org.jmock.Mockery();
		private «module.getRichClientPackage()».controller.New«for.name»Presentation presentation;
		private «module.getRichClientPackage()».data.Rich«for.name»Repository repository;
		private «module.getRichClientPackage()».controller.New«for.name»Controller controller;
		
		@org.junit.Before
		public void setUp() throws Exception {
			controller = new «module.getRichClientPackage()».controller.New«for.name»Controller();
			controller.setMessages(new «fw("richclient.util.MessageSourceStub")»());
			controller.setObjectFactory(new «module.getRichClientPackage()».data.Rich«for.name».Factory() {
				@Override
				public «module.getRichClientPackage()».data.Rich«for.name» create() {
				    return new «module.getRichClientPackage()».data.Rich«for.name»() {};
				}
			});
			
			repository = mockery.mock(«module.getRichClientPackage()».data.Rich«for.name»Repository.class);
			presentation = mockery.mock(«module.getRichClientPackage()».controller.New«for.name»Presentation.class);
			
			«fw("richclient.util.HeadlessRealm")».processDisplayEvents();
		}
	'''
}

def static String tearDown(UpdateTask it) {
	'''
		@org.junit.After
		public void tearDown() throws Exception {
			«fw("richclient.util.HeadlessRealm")».processDisplayEvents();
		}
	'''
}

def static String abstractPopulateFormSuccess(CreateTask it) {
	'''
		/**
			* Subclass populates the valid form values.
			*/
		protected abstract void populateFormSuccess(java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables);
	'''
}

def static String newSuccess(CreateTask it) {
	'''
	«val properties = it.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty)»
		@org.junit.Test
		public void updateSuccess() throws Exception {
			final java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables = createTargetObservables();
			
			«IF getPrimaryServiceOperation() != null»
			final java.util.concurrent.CountDownLatch latch = new java.util.concurrent.CountDownLatch(1);
			final org.jmock.lib.action.CustomAction countdownLatch = new org.jmock.lib.action.CustomAction("Countdown latch") {
				public Object invoke(org.jmock.api.Invocation invocation) {
				    latch.countDown();
				    return null;
				}
			};
			«ENDIF»
			
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				    atLeast(1).of(presentation).setPageComplete(with(any(Boolean.class)));
				    
				    atLeast(1).of(presentation).getTargetObservables();
				    will(returnValue(targetObservables));
				    
				    allowing(presentation).setErrorMessage(with(any(String.class)));
				    allowing(presentation).hasErrorMessage();
				    allowing(presentation).clearErrorMessage();
				    allowing(presentation).setMessage(with(any(String.class)), with(any(Integer.class)));
				 
				 «IF getPrimaryServiceOperation() != null»
				    one(repository).«getPrimaryServiceOperation().name»(with(any(«module.getRichClientPackage()».data.Rich«for.name».class)));
				    will(countdownLatch);
				 «ENDIF»
				}
			});
			
			controller.setRepository(repository);
			
			controller.pageCreated(presentation);
			
			populateFormSuccess(targetObservables);
			
			«FOR prop  : properties»
			junit.framework.Assert.assertEquals(targetObservables.get("«prop.name»").getValue(), controller.getModel().get«prop.name.toFirstUpper()»());
			«ENDFOR»
			
			controller.performFinish();
			
			«IF getPrimaryServiceOperation() != null»
			latch.await(3, java.util.concurrent.TimeUnit.SECONDS);
			«ENDIF»
			«fw("richclient.util.HeadlessRealm")».processDisplayEvents();
			
			mockery.assertIsSatisfied();
		}
	'''
}

def static String abstractCreateSelectedObject(CreateTask it) {
	'''
		/**
			* Subclass will return selected object.
			*/
		protected abstract «module.getRichClientPackage()».data.Rich«for.name» createSelectedObject();
	'''
}


def static String newFromSelectionSuccess(CreateTask it) {
	'''
	«val properties = it.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty)»
		@org.junit.Test
		public void newFromSelectionSuccess() throws Exception {
			final java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables = createTargetObservables();
			
			«IF getPrimaryServiceOperation() != null»
			final java.util.concurrent.CountDownLatch latch = new java.util.concurrent.CountDownLatch(1);
			final org.jmock.lib.action.CustomAction countdownLatch = new org.jmock.lib.action.CustomAction("Countdown latch") {
				public Object invoke(org.jmock.api.Invocation invocation) {
				    latch.countDown();
				    return null;
				}
			};
			«ENDIF»
			
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				    atLeast(1).of(presentation).setPageComplete(with(any(Boolean.class)));
				    
				    atLeast(1).of(presentation).getTargetObservables();
				    will(returnValue(targetObservables));
				    
				    allowing(presentation).setErrorMessage(with(any(String.class)));
				    allowing(presentation).hasErrorMessage();
				    allowing(presentation).clearErrorMessage();
				    allowing(presentation).setMessage(with(any(String.class)), with(any(Integer.class)));
				    allowing(presentation).resetForm();
				 
				«IF getPrimaryServiceOperation() != null»
				    one(repository).«getPrimaryServiceOperation().name»(with(any(«module.getRichClientPackage()».data.Rich«for.name».class)));
				    will(countdownLatch);
				«ENDIF»
				}
			});
			
			controller.setRepository(repository);
			«module.getRichClientPackage()».data.Rich«for.name» selectedObject = createSelectedObject();
			controller.setSelection(new org.eclipse.jface.viewers.StructuredSelection(selectedObject));
			
			controller.pageCreated(presentation);
			
			controller.copyFromSelection();
			
			junit.framework.Assert.assertNotSame("Expected copy", selectedObject, controller.getModel());
			
			«FOR prop  : properties»
			junit.framework.Assert.assertEquals(selectedObject.get«prop.name.toFirstUpper()»(), controller.getModel().get«prop.name.toFirstUpper()»());
			«ENDFOR»
			
			«FOR prop  : properties»
			junit.framework.Assert.assertEquals(selectedObject.get«prop.name.toFirstUpper()»(), targetObservables.get("«prop.name»").getValue());
			«ENDFOR»
			
			controller.performFinish();
			
			«IF getPrimaryServiceOperation() != null»
			latch.await(3, java.util.concurrent.TimeUnit.SECONDS);
			«ENDIF»
			«fw("richclient.util.HeadlessRealm")».processDisplayEvents();
			
			mockery.assertIsSatisfied();
		}
	'''
}


def static String createTargetObservables(CreateTask it) {
	'''
	«val properties = it.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty)»
		protected java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> createTargetObservables() {
			java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> result = new java.util.HashMap<String, org.eclipse.core.databinding.observable.value.IObservableValue>();
		«FOR prop  : properties»
			result.put("«prop.name»", new org.eclipse.core.databinding.observable.value.WritableValue());
			«IF prop.getAttributeType() == "Date"»
			result.put("«prop.name»Defined", new org.eclipse.core.databinding.observable.value.WritableValue());
			«ENDIF»
		«ENDFOR»
			return result;
		}
	'''
}




def static String createControllerTestImpl(CreateTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".controller.New" +for.name + "ControllerTest"), 'TO_SRC_TEST', '''
	«javaHeader()»
	package «module.getRichClientPackage()».controller;

	public class New«for.name»ControllerTest ^extends New«for.name»ControllerTestBase {
	«populateFormSuccess(it)»
	«createSelectedObject(it)»
	
	}
	'''
	)
	'''
	'''
}

def static String populateFormSuccess(CreateTask it) {
	'''
	«val properties = it.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty)»
		@Override
		protected void populateFormSuccess(java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables) {
			// TODO define necessary properties
			«FOR prop  : properties»
			// targetObservables.get("«prop.name»").setValue(...);
			«ENDFOR»
		}
	'''
}

def static String createSelectedObject(CreateTask it) {
	'''
	«val properties = it.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty)»
		@Override
		protected «module.getRichClientPackage()».data.Rich«for.name» createSelectedObject() {
			«module.getRichClientPackage()».data.Rich«for.name» input = new «module.getRichClientPackage()».data.Rich«for.name»() {};
			// TODO populate selected object
			«FOR prop  : properties»
			// input.set«prop.name.toFirstUpper()»(...);
			«ENDFOR»
			return input;
		}
	'''
}
}
