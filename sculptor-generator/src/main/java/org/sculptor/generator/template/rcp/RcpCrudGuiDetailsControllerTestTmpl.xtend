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

class RcpCrudGuiDetailsControllerTestTmpl {



def static String detailsControllerTest(GuiApplication it) {
	'''
	«it.modules.forEach[detailsControllerTest(it)]»
	'''
} 

def static String detailsControllerTest(GuiModule it) {
	'''
	«it.userTasks.typeSelect(UpdateTask).forEach[detailsControllerTest(it)]»
	'''
}

def static String detailsControllerTest(UpdateTask it) {
	'''
	«detailsControllerTestBase(it)»
	«detailsControllerTestImpl(it)»
	'''
}

def static String detailsControllerTestBase(UpdateTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".controller." +for.name + "DetailsControllerTestBase"), 'TO_GEN_SRC_TEST', '''
	«javaHeader()»
	package «module.getRichClientPackage()».controller;

	public abstract class «for.name»DetailsControllerTestBase {

	«setUpBeforeClass(it)»
	«setUp(it)»
	«tearDown(it)»
	«(it)^abstractCreateInput»
	«(it)^abstractPopulateFormSuccess»
	«updateSuccess(it)»
	
	«targetToModelBinding(it)»
	«modelToTargetBinding(it)»
	«createTargetObservables(it)»
	«createSimpleExpectations(it)»
	
	«it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).reject(e | e.isSingleSelectAddSubTask()).forEach[subtasks(it)]»

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

def static String setUp(UpdateTask it) {
	'''
		private org.jmock.Mockery mockery = new org.jmock.Mockery();
		private org.eclipse.ui.forms.IManagedForm form;
		private «module.getRichClientPackage()».controller.«for.name»DetailsPresentation presentation;
		private «module.getRichClientPackage()».data.Rich«for.name»Repository repository;
		private org.eclipse.core.runtime.IProgressMonitor monitor;
		private «module.getRichClientPackage()».controller.«for.name»DetailsController controller;
		
		@org.junit.Before
		public void setUp() throws Exception {
			controller = new «module.getRichClientPackage()».controller.«for.name»DetailsController();
			controller.setMessages(new «fw("richclient.util.MessageSourceStub")»());
			controller.setObjectFactory(new «module.getRichClientPackage()».data.Rich«for.name»«gapSubclassSuffix(this, "Rich" + for.name)».Factory() {
				@Override
				public «module.getRichClientPackage()».data.Rich«for.name» create() {
				    return new «module.getRichClientPackage()».data.Rich«for.name»() {};
				}
			});
			
			repository = mockery.mock(«module.getRichClientPackage()».data.Rich«for.name»Repository.class);
			form = mockery.mock(org.eclipse.ui.forms.IManagedForm.class);
			presentation = mockery.mock(«module.getRichClientPackage()».controller.«for.name»DetailsPresentation.class);
			monitor = mockery.mock(org.eclipse.core.runtime.IProgressMonitor.class);
			
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

def static String abstractCreateInput(UpdateTask it) {
	'''
		/**
			* Subclass will return object to update.
			*/
		protected abstract «module.getRichClientPackage()».data.Rich«for.name» createInput();
	'''
}


def static String abstractPopulateFormSuccess(UpdateTask it) {
	'''
		/**
			* Subclass populates the valid form values.
			*/
		protected abstract void populateFormSuccess(java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables);
	'''
}

def static String updateSuccess(UpdateTask it) {
	'''
	«val properties = it.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty)»
		@org.junit.Test
		public void updateSuccess() throws Exception {
			final java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables = createTargetObservables();
			
			«IF findDOWith != null »
			final java.util.concurrent.CountDownLatch findLatch = new java.util.concurrent.CountDownLatch(1);
			final org.jmock.lib.action.CustomAction findCountdownLatch = new org.jmock.lib.action.CustomAction("Countdown latch") {
				public Object invoke(org.jmock.api.Invocation invocation) {
				    findLatch.countDown();
				    return null;
				}
			};
			«ENDIF»
			
			«IF properties.exists(e|e.isChangeable()) && getPrimaryServiceOperation() != null»
			final java.util.concurrent.CountDownLatch saveLatch = new java.util.concurrent.CountDownLatch(1);
			final org.jmock.lib.action.CustomAction saveCountdownLatch = new org.jmock.lib.action.CustomAction("Countdown latch") {
				public Object invoke(org.jmock.api.Invocation invocation) {
				    saveLatch.countDown();
				    return null;
				}
			};
			«ENDIF»
			
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				    ignoring(form);
				    ignoring(monitor);
				    
				    one(repository).addObserver(controller);
				    «IF findDOWith != null »
				    one(repository).«findDOWith.name»(with(any(Long.class)));
				    will(findCountdownLatch);
				    «ENDIF»
				    
				    atLeast(1).of(presentation).resetForm();
				    «IF !viewProperties.typeSelect(ReferenceViewProperty).reject(e | e.isSingleSelectAddSubTask()).isEmpty»
				    atLeast(1).of(presentation).showMainTask();
				    «ENDIF»
				    
				    atLeast(1).of(presentation).getTargetObservables();
				    will(returnValue(targetObservables));
				 
				    «IF properties.exists(e|e.isChangeable())»
				    atLeast(1).of(presentation).dirtyStateChanged();
				    	«IF getPrimaryServiceOperation() != null»
				    one(repository).«getPrimaryServiceOperation().name»(with(any(«module.getRichClientPackage()».data.Rich«for.name».class)));
				    will(saveCountdownLatch);
				    	«ENDIF»
				    «ELSE»
				    // nothing to udpate, can't change
				    never(presentation).dirtyStateChanged();
				    «ENDIF»
				}
			});
			
			controller.setRepository(repository);
			
			controller.presentationCreated(presentation);
			«module.getRichClientPackage()».data.Rich«for.name» input = createInput();
			controller.setFormInput(input);
			«IF findDOWith != null »
			findLatch.await(2, java.util.concurrent.TimeUnit.SECONDS);
			«ENDIF»
			junit.framework.Assert.assertNotSame("Expect clone", input, controller.getModel());
			
			«FOR prop  : properties»
			junit.framework.Assert.assertEquals(input.get«prop.name.toFirstUpper()»(), targetObservables.get("«prop.name»").getValue());
			«ENDFOR»
			
			junit.framework.Assert.assertFalse("Haven't started yet, shouldn't be dirty", controller.isDirty());
			
			populateFormSuccess(targetObservables);
			
			«FOR prop  : properties»
			junit.framework.Assert.assertEquals(targetObservables.get("«prop.name»").getValue(), controller.getModel().get«prop.name.toFirstUpper()»());
			«ENDFOR»
			
			«IF properties.exists(e|e.isChangeable())»
			junit.framework.Assert.assertTrue("It should have been changed", controller.isDirty());
				«IF conversationRoot»
			controller.doSave(monitor);
					«IF getPrimaryServiceOperation() != null»
			saveLatch.await(3, java.util.concurrent.TimeUnit.SECONDS);		
					«ENDIF»
			«fw("richclient.util.HeadlessRealm")».processDisplayEvents();
			junit.framework.Assert.assertFalse(controller.isDirty());
				«ENDIF»
			«ELSE»
			// nothing to udpate, can't change
			junit.framework.Assert.assertFalse("It can't be changed", controller.isDirty());
			«ENDIF»
			
			mockery.assertIsSatisfied();
		}
	'''
}


def static String targetToModelBinding(UpdateTask it) {
	'''
		@org.junit.Test
		public void targetToModelBinding() throws Exception {
			final java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables = createTargetObservables();
			
			createSimpleExpectations(targetObservables);
			
			controller.setRepository(repository);
			
			controller.presentationCreated(presentation);
			«module.getRichClientPackage()».data.Rich«for.name» input = createInput();
			controller.setFormInput(input);
			
			verifyTargetToModelBinding(controller.getModel(), targetObservables);
		}
		
		protected abstract void verifyTargetToModelBinding(«module.getRichClientPackage()».data.Rich«for.name» model, java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables);
	'''
}

def static String modelToTargetBinding(UpdateTask it) {
	'''
		@org.junit.Test
		public void modelToTargetBinding() throws Exception {
			final java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables = createTargetObservables();
			
			createSimpleExpectations(targetObservables);
			
			controller.setRepository(repository);
			
			controller.presentationCreated(presentation);
			«module.getRichClientPackage()».data.Rich«for.name» input = createInput();
			controller.setFormInput(input);
			
			verifyModelToTargetBinding(controller.getModel(), targetObservables);
		}
		
		protected abstract void verifyModelToTargetBinding(«module.getRichClientPackage()».data.Rich«for.name» model, java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables);
	'''
}

def static String createTargetObservables(UpdateTask it) {
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

def static String createSimpleExpectations(UpdateTask it) {
	'''
		protected void createSimpleExpectations(final java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables) {
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				    ignoring(form);
				    ignoring(monitor);
				    ignoring(repository);
				    
				    atLeast(0).of(presentation).resetForm();
				    
				    atLeast(0).of(presentation).getTargetObservables();
				    will(returnValue(targetObservables));
				    
				    «IF !viewProperties.typeSelect(ReferenceViewProperty).reject(e | e.isSingleSelectAddSubTask()).isEmpty»
				    atLeast(0).of(presentation).showMainTask();
				    «ENDIF»
				    
				    atLeast(0).of(presentation).dirtyStateChanged();
				 
				}
			});
		}
	'''
}


def static String subtasks(ReferenceViewProperty it) {
	'''
	«createSubtaskObject(it)»
	«IF isCreateSubTaskAvailable() && isChangeable()»
		«createSubtask(it)»
	«ENDIF»
	«IF isUpdateSubTaskAvailable()»
		«updateSubtask(it)»
	«ENDIF»
	«IF isChangeable()»
		«removeSubtask(it)»
	«ENDIF»
	'''
}

def static String createSubtaskObject(ReferenceViewProperty it) {
	'''
		protected «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» create«resolveReferenceName()»SubtaskObject() {
			return new «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»() {};
		}
	'''
}

def static String createSubtask(ReferenceViewProperty it) {
	'''
		@SuppressWarnings("unchecked")
		@org.junit.Test
		public void new«resolveReferenceName()»Subtask() throws Exception {
			final java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables = createTargetObservables();
			
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				    ignoring(form);
				    ignoring(monitor);
				    
				    one(repository).addObserver(controller);
				    «IF userTask.metaType == UpdateTask && ((UpdateTask) userTask).findDOWith != null »
				    one(repository).«((UpdateTask) userTask).findDOWith.name»(with(any(Long.class)));
				    «ENDIF»
				    
				    atLeast(1).of(presentation).resetForm();
				    atLeast(1).of(presentation).showMainTask();
				    
				    atLeast(1).of(presentation).getTargetObservables();
				    will(returnValue(targetObservables));
				 
				    atLeast(1).of(presentation).dirtyStateChanged();
				    
				    one(presentation).showNew«resolveReferenceName()»Subtask(with(any(«fw("richclient.controller.ParentOfSubtask")».class)));
				    
				    one(presentation).set«resolveReferenceName()»Selection(with(any(org.eclipse.jface.viewers.IStructuredSelection.class)));
				}
			});
			
			controller.setRepository(repository);
			
			controller.presentationCreated(presentation);
			«userTask.module.getRichClientPackage()».data.Rich«userTask.for.name» input = createInput();
			controller.setFormInput(input);

			controller.new«resolveReferenceName()»Subtask();
			
			«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» subtaskObject = create«resolveReferenceName()»SubtaskObject();
			((«fw("richclient.controller.ParentOfSubtask")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»>) controller.getCurrentSubtask()).subtaskCompleted(subtaskObject);
			
			«fw("richclient.util.HeadlessRealm")».processDisplayEvents();
			junit.framework.Assert.assertTrue(controller.isDirty());
			«IF isMany()»
			junit.framework.Assert.assertTrue(controller.getModel().get«resolveReferenceName()»().contains(subtaskObject));
			«ELSE»
			junit.framework.Assert.assertEquals(subtaskObject, controller.getModel().get«resolveReferenceName()»());
			«ENDIF»
			mockery.assertIsSatisfied();
		}
	'''
}

def static String updateSubtask(ReferenceViewProperty it) {
	'''
		@SuppressWarnings("unchecked")
		@org.junit.Test
		public void edit«resolveReferenceName()»Subtask() throws Exception {
			final «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» subtaskObject = create«resolveReferenceName()»SubtaskObject();
			
			final java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables = createTargetObservables();
			
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				    ignoring(form);
				    ignoring(monitor);
				    
				    one(repository).addObserver(controller);
				    «IF userTask.metaType == UpdateTask && ((UpdateTask) userTask).findDOWith != null »
				    one(repository).«((UpdateTask) userTask).findDOWith.name»(with(any(Long.class)));
				    «ENDIF»
				    
				    atLeast(1).of(presentation).resetForm();
				    atLeast(1).of(presentation).showMainTask();
				    
				    atLeast(1).of(presentation).getTargetObservables();
				    will(returnValue(targetObservables));
				 
				    atLeast(1).of(presentation).dirtyStateChanged();
				    
				    one(presentation).get«resolveReferenceName()»Selection();
				    will(returnValue(new org.eclipse.jface.viewers.StructuredSelection(subtaskObject)));
				    
				    one(presentation).showEdit«resolveReferenceName()»Subtask(with(any(«fw("richclient.controller.ParentOfSubtask")».class)), with(same(subtaskObject)));
				    
				}
			});
			
			controller.setRepository(repository);
			
			controller.presentationCreated(presentation);
			«userTask.module.getRichClientPackage()».data.Rich«userTask.for.name» input = createInput();
			«IF isMany()»
			input.get«resolveReferenceName()»().add(subtaskObject);
			int size = input.get«resolveReferenceName()»().size();
			«ELSE»
			input.set«resolveReferenceName()»(subtaskObject);
			«ENDIF»
			controller.setFormInput(input);

			controller.edit«resolveReferenceName()»Subtask();
			((«fw("richclient.controller.ParentOfSubtask")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»>) controller.getCurrentSubtask()).subtaskCompleted(subtaskObject);
			
			«fw("richclient.util.HeadlessRealm")».processDisplayEvents();
			junit.framework.Assert.assertTrue(controller.isDirty());
			«IF isMany()»
			junit.framework.Assert.assertTrue(controller.getModel().get«resolveReferenceName()»().contains(subtaskObject));
			junit.framework.Assert.assertEquals(size, controller.getModel().get«resolveReferenceName()»().size());
			«ELSE»
			junit.framework.Assert.assertEquals(subtaskObject, controller.getModel().get«resolveReferenceName()»());
			«ENDIF»
			
			mockery.assertIsSatisfied();
		}
	'''
}

def static String removeSubtask(ReferenceViewProperty it) {
	'''
		@SuppressWarnings("unchecked")
		@org.junit.Test
		public void remove«resolveReferenceName()»Subtask() throws Exception {
			final «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» subtaskObject = create«resolveReferenceName()»SubtaskObject();
			
			final java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables = createTargetObservables();
			
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				    ignoring(form);
				    ignoring(monitor);
				    
				    one(repository).addObserver(controller);
				    «IF userTask.metaType == UpdateTask && ((UpdateTask) userTask).findDOWith != null »
				    one(repository).«((UpdateTask) userTask).findDOWith.name»(with(any(Long.class)));
				    «ENDIF»
				    atLeast(1).of(presentation).resetForm();
				    atLeast(1).of(presentation).showMainTask();
				    
				    atLeast(1).of(presentation).getTargetObservables();
				    will(returnValue(targetObservables));
				 
				    atLeast(1).of(presentation).dirtyStateChanged();
				    
				    one(presentation).get«resolveReferenceName()»Selection();
				    will(returnValue(new org.eclipse.jface.viewers.StructuredSelection(subtaskObject)));
				    
				    one(presentation).showRemove«resolveReferenceName()»Subtask(with(any(«fw("richclient.controller.ParentOfSubtask")».class)), with(same(subtaskObject)));
				    
				}
			});
			
			controller.setRepository(repository);
			
			controller.presentationCreated(presentation);
			«userTask.module.getRichClientPackage()».data.Rich«userTask.for.name» input = createInput();
			«IF isMany()»
			input.get«resolveReferenceName()»().add(subtaskObject);
			int size = input.get«resolveReferenceName()»().size();
			«ELSE»
			input.set«resolveReferenceName()»(subtaskObject);
			«ENDIF»
			controller.setFormInput(input);

			controller.remove«resolveReferenceName()»Subtask();
			((«fw("richclient.controller.ParentOfSubtask")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»>) controller.getCurrentSubtask()).subtaskCompleted(subtaskObject);
			
			«IF (isMany() && reference.required) || (!isMany() && !isNullable())»
				«IF relatedUserTaskGroupsIncludingSubclassSiblings().size > 1»
					// TODO mandatory validation of reference to subclasses to are not 
					// supported yet.
				«ELSE»
				// mandatory reference, validation failure expected, and therefore not dirty
				junit.framework.Assert.assertFalse(controller.isDirty());
				«ENDIF»
			«ELSE»
	        junit.framework.Assert.assertTrue(controller.isDirty());
	    «ENDIF»
	    
			«IF isMany()»
			junit.framework.Assert.assertFalse(controller.getModel().get«resolveReferenceName()»().contains(subtaskObject));
			junit.framework.Assert.assertEquals(size - 1, controller.getModel().get«resolveReferenceName()»().size());
			«ELSE»
			junit.framework.Assert.assertNull(controller.getModel().get«resolveReferenceName()»());
			«ENDIF»
			
			«fw("richclient.util.HeadlessRealm")».processDisplayEvents();
			mockery.assertIsSatisfied();
		}
	'''
}


def static String detailsControllerTestImpl(UpdateTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".controller." +for.name + "DetailsControllerTest"), 'TO_SRC_TEST', '''
	«javaHeader()»
	package «module.getRichClientPackage()».controller;

	public class «for.name»DetailsControllerTest ^extends «for.name»DetailsControllerTestBase {
	«createInput(it)»
	«populateFormSuccess(it)»
	«verifyTargetToModelBinding(it)»
	«verifyModelToTargetBinding(it)»
	
	}
	'''
	)
	'''
	'''
}

def static String createInput(UpdateTask it) {
	'''
	«val properties = it.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty)»
		@Override
		protected «module.getRichClientPackage()».data.Rich«for.name» createInput() {
			«module.getRichClientPackage()».data.Rich«for.name» input = new «module.getRichClientPackage()».data.Rich«for.name»() {};
			// TODO populate inital object
			«FOR prop  : properties»
			// input.set«prop.name.toFirstUpper()»(...);
			«ENDFOR»
			return input;
		}
	'''
}

def static String populateFormSuccess(UpdateTask it) {
	'''
	«val properties = it.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty) .filter(e|e.isChangeable())»
		@Override
		protected void populateFormSuccess(Map<String, IObservableValue> targetObservables) {
			«IF properties.isEmpty»
			// no properties are changeable
			«ELSE»
			// TODO change some properties
				«FOR prop  : properties»
			// targetObservables.get("«prop.name»").setValue(...);
				«ENDFOR»
			«ENDIF»
		}
	'''
}

def static String verifyTargetToModelBinding(UpdateTask it) {
	'''
	«val properties = it.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty) .filter(e|e.isChangeable())»
		@Override
		protected void verifyTargetToModelBinding(«module.getRichClientPackage()».data.Rich«for.name» model, java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables) {
		«IF properties.isEmpty»
			// no properties are changeable
		«ELSE»    
			// TODO modify target (gui widget) and verify that model is changed correctly
			«FOR prop  : properties»
			// targetObservables.get("«prop.name»").setValue(...);
			// junit.framework.Assert.assertEquals("Expected «prop.name» to change", 
			//        targetObservables.get("«prop.name»").getValue(), model.get«prop.name.toFirstUpper()»());
			«ENDFOR»
		«ENDIF»
		}
	'''
}

def static String verifyModelToTargetBinding(UpdateTask it) {
	'''
	«val properties = it.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty)»
		@Override
		protected void verifyModelToTargetBinding(«module.getRichClientPackage()».data.Rich«for.name» model, java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables) {
			// TODO modify model and verify that target (gui widget) is changed correctly
			«FOR prop  : properties»
			// model.set«prop.name.toFirstUpper()»(...);
			// junit.framework.Assert.assertEquals("Expected «prop.name» to change",
			//        model.get«prop.name.toFirstUpper()»(), targetObservables.get("«prop.name»").getValue());
			«ENDFOR»
		}
	'''
}
}
