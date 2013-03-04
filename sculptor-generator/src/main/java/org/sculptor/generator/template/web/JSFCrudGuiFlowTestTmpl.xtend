/*
 * Copyright 2007 The Fornax Project Team, including the original 
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

package org.sculptor.generator.template.web

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class JSFCrudGuiFlowTestTmpl {


def static String flowTest(GuiApplication it) {
	'''
	«it.modules.userTasks.forEach[flowTest(it)]»
	'''
}

def static String flowTest(UserTask it) {
	'''
	'''
}

def static String flowTest(CreateTask it) {
	'''
	«createUpdateFlowTestBase(it) »
	«createUpdateFlowTest(it) »
	'''
}

def static String flowTest(UpdateTask it) {
	'''
	«createUpdateFlowTestBase(it) »
	«createUpdateFlowTest(it) »
	'''
}

def static String flowTest(DeleteTask it) {
	'''
	«deleteFlowTestBase(it) »
	«deleteFlowTest(it) »
	'''
}

def static String flowTest(ListTask it) {
	'''
	«listFlowTestBase(it) »
	«listFlowTest(it) »
	'''
}

def static String flowTest(ViewTask it) {
	'''
	«viewFlowTestBase(it) »
	«viewFlowTest(it) »
	'''
}

def static String createUpdateFlowTest(UserTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Test"), 'TO_SRC_TEST', '''
	«javaHeader()»
	package «this.module.getWebPackage()»;

	public class «name.toFirstUpper()»Test ^extends «name.toFirstUpper()»TestBase {

	/**
	 * Populates the valid form values.
	 */
	protected void populateFormSuccess(«module.getWebPackage()».«name.toFirstUpper()»Form form) {
		// TODO Auto-generated method stub, remove next line and assign valid form values
			/*«populateFormObject(it) » */
	}
	
	/**
	 * Populates the invalid form values. It is possible to throw 
	 * UnsupportedOperationException to skip testFormSubmitError.
	 */
	protected void populateFormError(«module.getWebPackage()».«name.toFirstUpper()»Form form) {
		// TODO Auto-generated method stub, remove next line and assign some invalid form values
			/*«populateFormObject(it) » */
	}
	
	«IF (this.metaType == UpdateTask) && (((UpdateTask) this).findDOWith != null) »
	/**
	 * Creates the «for.name» object to update.
	 */
	protected «for.getDomainPackage()».«for.name» findById() {
		// TODO Auto-generated method stub, remove next line and create the «for.name» object to update
			return null;
	}
	«ENDIF »
	}
	
	'''
	)
	'''
	'''
}

def static String createUpdateFlowTestBase(UserTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "TestBase"), 'TO_GEN_SRC_TEST', '''
	«javaHeader()»
	package «this.module.getWebPackage()»;

	public abstract class «name.toFirstUpper()»TestBase ^extends org.springframework.webflow.test.execution.AbstractXmlFlowExecutionTests {

	«createUpdateFlowSetUp(it) »
	«createUpdateFlowTestStart(it) »	
	/* TODO a lot of work migrating from webflow 1 to 2
	«createUpdateFlowTestFormSubmitSuccess(it) »
	«createUpdateFlowTestFormSubmitError(it) »
	«createUpdateFlowTestFormCancel(it) »
	«createUpdateFlowTestConfirmSubmit(it) »
	«createUpdateFlowTestConfirmCancel(it) »
	 */
	«repositoryStub(it) »
	«getForm(it) »
	}	
	'''
	)
	'''
	'''
}

/*TODO refactor for webflow2 */
def static String createUpdateFlowTestFormSubmitSuccess(UserTask it) {
	'''
		public void testFormSubmitSuccess() {
			// set up
			testStartFlow();
			
			«IF getPrimaryService() != null »
			// expectations
			mockery.checking(new org.jmock.Expectations() {{
				never(«getPrimaryService().name.toFirstLower()»);
			}});
			«ENDIF »
			
			// execute
			«module.getWebPackage()».«name.toFirstUpper()»Form form = («name.toFirstUpper()»Form) getFlowAttribute("«name»Form");
			assertNotNull(form);
			populateFormSuccess(form);
			org.springframework.webflow.execution.support.ApplicationView view = applicationView(signalEvent("submit"));
			
			// verify
			assertCurrentStateEquals("confirm");
			assertViewNameEquals("/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/confirm.xhtml", view);
			«IF getPrimaryService() != null »
			mockery.assertIsSatisfied();
			«ENDIF»
		}
		
		/**
			* Subclass populates the valid form values.
			*/
		//protected abstract void populateFormSuccess(«module.getWebPackage()».«name.toFirstUpper()»Form form);


	'''
}

/*TODO refactor for webflow2 */
def static String createUpdateFlowTestFormSubmitError(UserTask it) {
	'''
		public void testFormSubmitError() {
			// set up
			testStartFlow();
			
			«IF getPrimaryService() != null »
			// expectations
			mockery.checking(new org.jmock.Expectations() {{
				never(«getPrimaryService().name.toFirstLower()»);
			}});
			«ENDIF »
			
			// execute
			«module.getWebPackage()».«name.toFirstUpper()»Form form = («name.toFirstUpper()»Form) getFlowAttribute("«name»Form");
			assertNotNull(form);
			try {
				populateFormError(form);
			} catch (UnsupportedOperationException e) {
				// Subclass may throw UnsupportedOperationException to skip this test method
				return;
			}
			signalEvent("submit");
			assertCurrentStateEquals("input");
			«IF getPrimaryService() != null »
			mockery.assertIsSatisfied();
			«ENDIF »
		}
		
		/**
			* Subclass populates the invalid form values.
			* Subclass may throw UnsupportedOperationException 
			* to skip testFormSubmitError.
			*/
		protected abstract void populateFormError(«module.getWebPackage()».«name.toFirstUpper()»Form form);
			
	'''
}

/*TODO refactor for webflow2 */
def static String createUpdateFlowTestFormCancel(UserTask it) {
	'''
		public void testFormCancel() {
			// set up
			testStartFlow();
			
			// expectations
			mockery.checking(new org.jmock.Expectations() {{
			«IF getPrimaryService() != null »
				never(«getPrimaryService().name.toFirstLower()»);
		«ENDIF »            
			}});
			
			// execute
			signalEvent("cancel", new org.springframework.webflow.test.MockParameterMap());
			
			// verify
			assertFlowExecutionEnded();
			mockery.assertIsSatisfied();
		}
	'''
}

/*TODO refactor for webflow2 */
def static String createUpdateFlowTestConfirmSubmit(UserTask it) {
	'''
		public void testConfirmSubmit() {
			// set up        
			testFormSubmitSuccess();

			«IF getPrimaryServiceOperation()  != null »        
			// expectations
			mockery.checking(new org.jmock.Expectations() {{
				one(«getPrimaryService().name.toFirstLower()»).«getPrimaryServiceOperation().name»(«IF isServiceContextToBeGenerated()»with(any(«serviceContextClass()».class)), «ENDIF»with(any(«for.getDomainPackage()».«for.name».class)));
			}});
			«ENDIF »
				    
			// execute
			org.springframework.webflow.execution.support.ApplicationView view = applicationView(signalEvent("submit"));
			
			// verify
			assertFlowExecutionEnded();
			assertViewNameEquals("/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/finish.xhtml", view);
			«IF getPrimaryService() != null »        
			mockery.assertIsSatisfied();
			«ENDIF »
		}
	'''
}

/*TODO refactor for webflow2 */
def static String createUpdateFlowTestConfirmCancel(UserTask it) {
	'''
		public void testConfirmCancel() {
			// set up        
			testFormSubmitSuccess();
			
			// expectations
			mockery.checking(new org.jmock.Expectations() {{
			«IF getPrimaryService() != null »
				never(«getPrimaryService().name.toFirstLower()»);
			«ENDIF »   
			}});
			
			// execute
			signalEvent("cancel");
			
			// verify        
			assertFlowExecutionEnded();
			mockery.assertIsSatisfied();
		}
	'''
}


def static String populateFormObject(UserTask it) {
	'''
	«it.this.viewProperties.reject(e|e.isSystemAttribute()).reject(p | p.metaType == DerivedReferenceViewProperty) .forEach[populateFormObjectProperty(it)]»
	'''
}

def static String populateFormObjectProperty(ViewDataProperty it) {
	'''
	«val editable  = it.(userTask.metaType == CreateTask) || isChangeable()»
	«IF editable »
		«IF isNullable()»// «ENDIF»«populateFormObjectPropertyImpl(it) »
	«ENDIF »
	'''
}

def static String populateFormObjectPropertyImpl(ViewDataProperty it) {
	'''
	form.set«name.toFirstUpper()»(null);
	'''
}

def static String populateFormObjectPropertyImpl(ReferenceViewProperty it) {
	'''
	«IF isRequired() »
	form.setRequired«name.toFirstUpper()»(null);
	«ENDIF»
	'''
}

/*TODO refactor for webflow2 */
def static String deleteFlowTestConfirmSubmit(DeleteTask it) {
	'''
		public void testConfirmSubmit() {
			// set up        
			testStartFlow();

			// expectations
			mockery.checking(new org.jmock.Expectations() {{
			«IF getPrimaryServiceOperation() != null »        
				one(«getPrimaryService().name.toFirstLower()»).«getPrimaryServiceOperation().name»(«IF isServiceContextToBeGenerated()»with(any(«serviceContextClass()».class)), «ENDIF»with(any(«for.getDomainPackage()».«for.name».class)));
			«ENDIF »
			}});
				    
			// execute
			org.springframework.webflow.execution.support.ApplicationView view = applicationView(signalEvent("submit"));
			
			// verify
			assertFlowExecutionEnded();
			assertViewNameEquals("/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/finish.xhtml", view);
			mockery.assertIsSatisfied();
		}
	'''
}

/*TODO refactor for webflow2 */
def static String deleteFlowTestConfirmCancel(DeleteTask it) {
	'''
		public void testConfirmCancel() {
			// set up        
			testStartFlow();
			
			«IF getPrimaryService() != null »
			// expectations
			mockery.checking(new org.jmock.Expectations() {{
				never(«getPrimaryService().name.toFirstLower()»);
			}});
			«ENDIF »
			
			// execute
			org.springframework.webflow.execution.support.ApplicationView view = applicationView(signalEvent("cancel"));
			
			// verify        
			assertFlowExecutionEnded();
			assertViewNameEquals("/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/finish.xhtml", view);
			«IF getPrimaryService() != null »        
			mockery.assertIsSatisfied();
			«ENDIF »
		}
	'''
}

def static String fakeFindById(UserTask it) {
	'''
		private «fakeObjectInstantiatorClass()»<«for.getDomainPackage()».«for.name»> fakeObjectInstantiator = new «fakeObjectInstantiatorClass()»<«for.getDomainPackage()».«for.name»>(«for.getDomainPackage()».«for.name».class);
		
		/**
			* Creates the «for.name» object to «taskType».
			* It doesn't matter what instance we use. This method 
			* creates a fake instance using reflection, since 
			* default constructor might not be visible.
			*/
		protected «for.getDomainPackage()».«for.name» findById() {
			return fakeObjectInstantiator.createFakeObject();
		}
	'''
}

def static String createUpdateFlowSetUp(UserTask it) {
	'''
		private org.jmock.Mockery mockery = new org.jmock.Mockery();
		«FOR service : this.getUsedServices()»
	private «service.getServiceapiPackage()».«service.name» «service.name.toFirstLower()»;
	«ENDFOR»
		«IF metaType == UpdateTask »
		private org.springframework.webflow.core.collection.MutableAttributeMap flowInput;
		«ENDIF »

		public void setUp() throws Exception {
	    «IF metaType == UpdateTask »
			flowInput = new org.springframework.webflow.core.collection.LocalAttributeMap();
				«IF ((UpdateTask) this).findDOWith == null »
				flowInput.put("«for.name»", new «fakeObjectInstantiatorClass()»<«for.getDomainPackage()».«for.name»>(«for.getDomainPackage()».«for.name».class).createFakeObject());
				«ELSE »
		    flowInput.put("id", new «for.getIdAttributeType()»("17"));
				«ENDIF »
			«ENDIF »
		«FOR service : this.getUsedServices()»
		«service.name.toFirstLower()» = mockery.mock(«service.getServiceapiPackage()».«service.name».class);
		«ENDFOR» 
			super.setUp();
		}
		
		«createUpdateRegisterMockery(it) »
		
		«getFlowDefinitionResource(it) »
		
	'''
}


def static String getFlowDefinitionResource(UserTask it) {
	'''
		@Override
		protected org.springframework.webflow.config.FlowDefinitionResource getResource(
				org.springframework.webflow.config.FlowDefinitionResourceFactory resourceFactory) {
			return resourceFactory.createFileResource("src/main/webapp/WEB-INF/«IF gapClass»«ELSE»generated/«ENDIF»flows/«module.name»/«name»/«name»-flow.xml");
		}
		«IF gapClass»
	@Override
	protected org.springframework.webflow.config.FlowDefinitionResource[] getModelResources(org.springframework.webflow.config.FlowDefinitionResourceFactory resourceFactory) {
		FlowDefinitionResource base = new FlowDefinitionResource("«module.name»/«name»Base", new org.springframework.core.io.FileSystemResource(
				    new java.io.File("src/main/webapp/WEB-INF/generated/flows/«module.name»/«name»/«name»-base.xml")), null);
			return new org.springframework.webflow.config.FlowDefinitionResource[] {base};
				
	}
	«ENDIF»
	'''
}
def static String repositoryStub(UserTask it) {
	'''
	«repositoryStub(it)(false)»
	'''
}

def static String repositoryStub(UpdateTask it) {
	'''
	«repositoryStub(it)(findDOWith != null)»
	'''
}

def static String repositoryStub(DeleteTask it) {
	'''
	«repositoryStub(it)(findDOWith != null)»
	'''
}
def static String repositoryStub(UserTask it, boolean findById) {
	'''
	private «conversationDomainObjectRepositoryInterface()» repository = new RepositoryStub();
	
		private class RepositoryStub implements «conversationDomainObjectRepositoryInterface()» {

		«IF findById »
			@SuppressWarnings("unchecked")
			«ENDIF»
			public <T> T get(Class<T> clazz, java.io.Serializable id) {
				«IF findById »
				return (T) findById();
				«ELSE »
				return new «fakeObjectInstantiatorClass()»<T>(clazz).createFakeObject();
				«ENDIF »
			}

			public void revert(Object obj) {
			}
			
			public void clear() {
			}
		}
	'''
}

def static String createUpdateRegisterMockery(UserTask it) {
	'''
	«val subflowReferences  = it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base)»
		@Override
		protected void configureFlowBuilderContext(org.springframework.webflow.test.MockFlowBuilderContext builderContext) {
			builderContext.getFlowBuilderServices().setConversionService(new org.springframework.faces.model.converter.FacesConversionService());
		«name.toFirstUpper()»Action action = new «name.toFirstUpper()»Action();
			action.setRepository(repository);
			«FOR service : this.getUsedServices()»
			action.set«service.name»(«service.name.toFirstLower()»);
			«ENDFOR»
			builderContext.registerBean("«name»Action", action);    	
			builderContext.registerBean("webExceptionAdvice", new «webExceptionAdviceClass()»());
			«FOR service : this.getUsedServices()»
		builderContext.registerBean("«service.name.toFirstLower()»«IF isEar()»Proxy«ENDIF»", «service.name.toFirstLower()»);
		«ENDFOR»
			builderContext.registerBean("repository", repository);
			//builderContext.registerBean("messageSource", new org.springframework.context.support.StaticMessageSource());

		«FOR refProp : subflowReferences»
			«IF refProp.isCreateSubTaskAvailable() »
			getFlowDefinitionRegistry().registerFlowDefinition(stubSubflow("«refProp.getCreateTransition().to.name»-flow"));
			«ENDIF »
			«IF refProp.isUpdateSubTaskAvailable() »				
			getFlowDefinitionRegistry().registerFlowDefinition(stubSubflow("«refProp.getUpdateTransition().to.name»-flow"));
			«ENDIF »
			getFlowDefinitionRegistry().registerFlowDefinition(stubSubflow("«refProp.getViewTransition().to.name»-flow"));
		«ENDFOR»
	}
	
	«IF !subflowReferences.isEmpty »
		«stubSubflow(it) »
	«ENDIF »
	'''
}

def static String stubSubflow(UserTask it) {
	'''
		private org.springframework.webflow.engine.Flow stubSubflow(String subflowId) {
			org.springframework.webflow.engine.Flow subflow = new org.springframework.webflow.engine.Flow(subflowId);
			subflow.setInputMapper(new org.springframework.binding.mapping.Mapper() {
				public org.springframework.binding.mapping.MappingResults map(Object source, Object target) {
				    assertEquals("id of value 1 not provided as input", new «for.getIdAttributeType()»("1"), ((org.springframework.webflow.core.collection.AttributeMap) source).get("id"));
				    return null;
				}
			});

			// test responding to finish result
			new org.springframework.webflow.engine.EndState(subflow, "finish");
			return subflow;
		}
	'''
}
def static String getForm(UserTask it) {
	'''
		protected «module.getWebPackage()».«name.toFirstUpper()»Form getForm() {
			return («module.getWebPackage()».«name.toFirstUpper()»Form) getFlowAttribute("«name»Form");
		}

	'''
}

def static String createUpdateFlowTestStart(UserTask it) {
	'''
	'''
}

def static String createUpdateFlowTestStart(CreateTask it) {
	'''
	@SuppressWarnings("unchecked")
		public void testStartFlow() {
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
					«val refProperties = it.((List[ReferenceViewProperty]) getReferencesPropertiesChildrenToSelect().filterOutDuplicateReferenceViewProperty())»
	                «FOR refProp : refProperties»
	                	«val addTask = it.refProp.getRelatedAddTask()»
							atLeast(1).of(«addTask.getPrimaryService().name.toFirstLower()»).«addTask.getPrimaryServiceOperation().name»(«FOR param SEPARATOR ", " : addTask.getPrimaryServiceOperation().parameters»with(any(«param.getTypeName()».class))«ENDFOR»);
							«IF addTask.getPrimaryServiceOperation().isPagedResult()»
							will(returnValue(new «addTask.getPrimaryServiceOperation().getTypeName()»(new java.util.ArrayList(), 0, 100, 100)));
							«ELSE»
							will(returnValue(new java.util.ArrayList()));
							«ENDIF»
					«ENDFOR»
				}
			});
			startFlow(new org.springframework.webflow.test.MockExternalContext());
			assertCurrentStateEquals("input");
			mockery.assertIsSatisfied();
		}
	'''
}

def static String createUpdateFlowTestStart(UpdateTask it) {
	'''
	@SuppressWarnings("unchecked")
		public void testStartFlow() {
	    
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
					«IF findDOWith != null »
					«IF findDOWith.getExceptions().size > 0 »
				    try {
				    «ENDIF»
				    	one(«findDOWith.service.name.toFirstLower()»).«findDOWith.name»(
				    	«FOR param SEPARATOR ", " : findDOWith.parameters»with(any(«param.getTypeName()».class))«ENDFOR»
				    	);
				    «IF findDOWith.getExceptions().size > 0 »
				    }«FOR exc  : findDOWith.getExceptions()» 
				    catch («exc» e) {}«ENDFOR»
				    «ENDIF»
				    will(returnValue(findById()));
				    «ENDIF »
				    «val refProperties = it.((List[ReferenceViewProperty]) getReferencesPropertiesChildrenToSelect().filterOutDuplicateReferenceViewProperty())»
	                «FOR refProp : refProperties»
	                	«val addTask = it.refProp.getRelatedAddTask()»
							atLeast(1).of(«addTask.getPrimaryService().name.toFirstLower()»).«addTask.getPrimaryServiceOperation().name»(«FOR param SEPARATOR ", " : addTask.getPrimaryServiceOperation().parameters»with(any(«param.getTypeName()».class))«ENDFOR»);
							«IF addTask.getPrimaryServiceOperation().isPagedResult()»
							will(returnValue(new «addTask.getPrimaryServiceOperation().getTypeName()»(new java.util.ArrayList(), 0, 100, 100)));
							«ELSE»
							will(returnValue(new java.util.ArrayList()));
							«ENDIF»
					«ENDFOR»
				}
			});
			    
			startFlow(flowInput, new org.springframework.webflow.test.MockExternalContext());
			assertCurrentStateEquals("input");
 
			mockery.assertIsSatisfied();
		}
		
		«IF findDOWith != null »
		/**
			* Subclass will return «for.name» to update.
			*/
		protected abstract «for.getDomainPackage()».«for.name» findById();
		«ENDIF »
	'''
}

def static String deleteFlowTest(DeleteTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Test"), 'TO_SRC_TEST', '''
	package «this.module.getWebPackage()»;

	/**
	 * Test class for delete flow. All test methods are in 
	 * the generated base class.
	 */	
	public class «name.toFirstUpper()»Test ^extends «name.toFirstUpper()»TestBase {
		
	}
	
	'''
	)
	'''
	'''
}

def static String deleteFlowTestBase(DeleteTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "TestBase"), 'TO_GEN_SRC_TEST', '''
	«javaHeader()»
	package «this.module.getWebPackage()»;

	public abstract class «name.toFirstUpper()»TestBase ^extends org.springframework.webflow.test.execution.AbstractXmlFlowExecutionTests {

	«deleteFlowSetUp(it) »	
	«deleteFlowTestStart(it) » 
	/* TODO a lot of work migrating from webflow 1 to 2
	«deleteFlowTestConfirmSubmit(it) »
	«deleteFlowTestConfirmCancel(it) »
	 */
	«repositoryStub(it) »
	}	
	'''
	)
	'''
	'''
}
def static String deleteFlowSetUp(DeleteTask it) {
	'''
		private org.jmock.Mockery mockery = new org.jmock.Mockery();
		«IF getPrimaryService() != null »
		private «getPrimaryService().getServiceapiPackage()».«getPrimaryService().name» «getPrimaryService().name.toFirstLower()»;
		«ENDIF »
		private org.springframework.webflow.core.collection.MutableAttributeMap flowInput;

		public void setUp() throws Exception {
			flowInput = new org.springframework.webflow.core.collection.LocalAttributeMap();
			flowInput.put("id", new «for.getIdAttributeType()»("17"));
			«IF getPrimaryService() != null »    
	    «getPrimaryService().name.toFirstLower()» = mockery.mock(«getPrimaryService().getServiceapiPackage()».«getPrimaryService().name».class);
		«ENDIF »
			super.setUp();
		}
		
		
		@Override
		protected void configureFlowBuilderContext(org.springframework.webflow.test.MockFlowBuilderContext builderContext) {
			builderContext.getFlowBuilderServices().setConversionService(new org.springframework.faces.model.converter.FacesConversionService());	
		«name.toFirstUpper()»Action action = new «name.toFirstUpper()»Action();
			action.setRepository(repository);
			«IF getPrimaryServiceOperation() != null »
			action.set«getPrimaryService().name»(«getPrimaryService().name.toFirstLower()»);
			«ENDIF »
			builderContext.registerBean("«name»Action", action);
			builderContext.registerBean("webExceptionAdvice", new «webExceptionAdviceClass()»());
		«IF getPrimaryService() != null »
			builderContext.registerBean("«getPrimaryService().name.toFirstLower()»«IF isEar()»Proxy«ENDIF»", «getPrimaryService().name.toFirstLower()»);
		«ENDIF »
			builderContext.registerBean("repository", repository);
			//serviceRegistry.registerBean("messageSource", new org.springframework.context.support.StaticMessageSource());
	}

		
		«getFlowDefinitionResource(it) »
		
	'''
}

def static String deleteFlowTestStart(DeleteTask it) {
	'''
		public void testStartFlow() {
	    «IF findDOWith != null »
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
					«IF findDOWith.getExceptions().size > 0 »
				    try {
					«ENDIF»
				    	atLeast(1).of(«findDOWith.service.name.toFirstLower()»).«findDOWith.name»(
				    	«FOR param SEPARATOR ", " : findDOWith.parameters»with(any(«param.getTypeName()».class))«ENDFOR»
				    	);
					«IF findDOWith.getExceptions().size > 0 »
				    }«FOR exc  : findDOWith.getExceptions()» 
				    catch («exc» e) {}«ENDFOR»
				    «ENDIF»
				    will(returnValue(findById()));
				}
			});
			«ENDIF »    
			startFlow(flowInput, new org.springframework.webflow.test.MockExternalContext());
			assertCurrentStateEquals("confirm");
			«IF findDOWith != null »
			mockery.assertIsSatisfied();
			«ENDIF »
		}
		
		«IF findDOWith != null »
			«fakeFindById(it) »
		«ENDIF »
	'''
}

def static String listFlowTest(ListTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Test"), 'TO_SRC_TEST', '''
	«javaHeader()»
	package «this.module.getWebPackage()»;

	/**
	 * Test class for list flow. All test methods are in 
	 * the generated base class.
	 */	
	public class «name.toFirstUpper()»Test ^extends «name.toFirstUpper()»TestBase {
	
	}
	
	'''
	)
	'''
	'''
}
def static String listFlowTestBase(ListTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "TestBase"), 'TO_GEN_SRC_TEST', '''
	«javaHeader()»
	package «this.module.getWebPackage()»;

	public abstract class «name.toFirstUpper()»TestBase ^extends org.springframework.webflow.test.execution.AbstractXmlFlowExecutionTests {

	«listFlowSetUp(it) »	
	«listFlowTestStart(it) »
	«repositoryStub(it) »
	}	
	'''
	)
	'''
	'''
}

def static String listFlowSetUp(ListTask it) {
	'''
		private org.jmock.Mockery mockery = new org.jmock.Mockery();
	«IF getPrimaryService() != null »
		private «getPrimaryService().getServiceapiPackage()».«getPrimaryService().name» «getPrimaryService().name.toFirstLower()»;
		«ENDIF »

		public void setUp() throws Exception {
			«IF getPrimaryService() != null »    
	    «getPrimaryService().name.toFirstLower()» = mockery.mock(«getPrimaryService().getServiceapiPackage()».«getPrimaryService().name».class);
		«ENDIF »    
			super.setUp();
		}
		
		«listFlowRegisterMockServices(it) »
		
		«getFlowDefinitionResource(it) »
		
	'''
}

def static String listFlowRegisterMockServices(ListTask it) {
	'''
		@Override
		protected void configureFlowBuilderContext(org.springframework.webflow.test.MockFlowBuilderContext builderContext) {
			builderContext.getFlowBuilderServices().setConversionService(new org.springframework.faces.model.converter.FacesConversionService());
			«name.toFirstUpper()»Action action = new «name.toFirstUpper()»Action();
			action.setRepository(repository);
			«IF getPrimaryServiceOperation() != null »
			action.set«getPrimaryService().name»(«getPrimaryService().name.toFirstLower()»);
			«ENDIF »
			builderContext.registerBean("«name»Action", action);
		
			builderContext.registerBean("webExceptionAdvice", new «webExceptionAdviceClass()»());
			builderContext.registerBean("repository", repository);
			//builderContext.registerBean("messageSource", new org.springframework.context.support.StaticMessageSource());
			«IF getPrimaryService() != null »
			builderContext.registerBean("«getPrimaryService().name.toFirstLower()»«IF isEar()»Proxy«ENDIF»", «getPrimaryService().name.toFirstLower()»);
			«ENDIF »

		getFlowDefinitionRegistry().registerFlowDefinition(stubSubflow("«subTaskTransitions.filter(t | t.to.metaType == ViewTask).first().to.name»-flow"));
		«IF isUpdateSubTaskAvailable() »
		getFlowDefinitionRegistry().registerFlowDefinition(stubSubflow("«subTaskTransitions.filter(t | t.to.metaType == UpdateTask).first().to.name»-flow"));
		«ENDIF »
		«IF isDeleteSubTaskAvailable() »
		getFlowDefinitionRegistry().registerFlowDefinition(stubSubflow("«subTaskTransitions.filter(t | t.to.metaType == DeleteTask).first().to.name»-flow"));
		«ENDIF »
	}

	«stubSubflow(it) »
	'''
}

def static String listFlowTestStart(ListTask it) {
	'''
		public void testStartFlow() {
	    «IF getPrimaryServiceOperation() != null »
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				    one(«getPrimaryService().name.toFirstLower()»).«getPrimaryServiceOperation().name»(«FOR param SEPARATOR ", " : getPrimaryServiceOperation().parameters»with(any(«param.getTypeName()».class))«ENDFOR»);
				«IF getPrimaryServiceOperation().isPagedResult()»
				will(returnValue(new «getPrimaryServiceOperation().getTypeName()»(new java.util.ArrayList<«for.getDomainPackage()».«for.name»>(), 0, 100, 100)));
				«ELSE»
				will(returnValue(new java.util.ArrayList<«for.getDomainPackage()».«for.name»>()));
				«ENDIF»
				    
				    
				}
			});
			«ENDIF »    
			startFlow(new org.springframework.webflow.test.MockExternalContext());
			assertCurrentStateEquals("list");
			«IF getPrimaryService() != null »
			mockery.assertIsSatisfied();
			«ENDIF »
		}
		
	'''
}

def static String viewFlowTest(ViewTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Test"), 'TO_SRC_TEST', '''
	«javaHeader()»	
	package «this.module.getWebPackage()»;

	/**
	 * Test class for view flow. All test methods are in 
	 * the generated base class.
	 */	
	public class «name.toFirstUpper()»Test ^extends «name.toFirstUpper()»TestBase {
	
	}
	
	'''
	)
	'''
	'''
}

def static String viewFlowTestBase(ViewTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "TestBase"), 'TO_GEN_SRC_TEST', '''
	«javaHeader()»
	package «this.module.getWebPackage()»;

	public abstract class «name.toFirstUpper()»TestBase ^extends org.springframework.webflow.test.execution.AbstractXmlFlowExecutionTests {

	«viewFlowSetUp(it) »	
	«viewFlowTestStart(it) »
	«repositoryStub(it) »
	}	
	'''
	)
	'''
	'''
}

def static String viewFlowSetUp(ViewTask it) {
	'''
		private org.jmock.Mockery mockery = new org.jmock.Mockery();
	«IF getPrimaryServiceOperation() != null »
		private «getPrimaryService().getServiceapiPackage()».«getPrimaryService().name» «getPrimaryService().name.toFirstLower()»;
		«ENDIF »
		private org.springframework.webflow.core.collection.MutableAttributeMap flowInput;

		public void setUp() throws Exception {
			flowInput = new org.springframework.webflow.core.collection.LocalAttributeMap();
			«IF findDOWith == null »
				flowInput.put("«for.name»", new «fakeObjectInstantiatorClass()»<«for.getDomainPackage()».«for.name»>(«for.getDomainPackage()».«for.name».class).createFakeObject());
				«ELSE »
				flowInput.put("id", new «for.getIdAttributeType()»("17"));
				«ENDIF »
			«IF getPrimaryServiceOperation() != null »    
	    «getPrimaryService().name.toFirstLower()» = mockery.mock(«getPrimaryService().getServiceapiPackage()».«getPrimaryService().name».class);
		«ENDIF »    
			super.setUp();
		}
		
		@Override
		protected void configureFlowBuilderContext(org.springframework.webflow.test.MockFlowBuilderContext builderContext) {
			builderContext.getFlowBuilderServices().setConversionService(new org.springframework.faces.model.converter.FacesConversionService());
			«name.toFirstUpper()»Action action = new «name.toFirstUpper()»Action();
			action.setRepository(repository);
			«IF getPrimaryServiceOperation() != null »
			action.set«getPrimaryService().name»(«getPrimaryService().name.toFirstLower()»);
			«ENDIF »
			builderContext.registerBean("«name»Action", action);
			builderContext.registerBean("webExceptionAdvice", new «webExceptionAdviceClass()»());
			builderContext.registerBean("repository", repository);
			//serviceRegistry.registerBean("messageSource", new org.springframework.context.support.StaticMessageSource());
			«IF getPrimaryServiceOperation() != null »
			builderContext.registerBean("«getPrimaryService().name.toFirstLower()»«IF isEar()»Proxy«ENDIF»", «getPrimaryService().name.toFirstLower()»);
			«ENDIF »
	«val subflowReferences  = it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base)»
		«FOR refProp : subflowReferences»
			getFlowDefinitionRegistry().registerFlowDefinition(stubSubflow("«refProp.getViewTransition().to.name»-flow"));
		«ENDFOR»
	}
	
	«IF !subflowReferences.isEmpty »
	
		«stubSubflow(it) »
	«ENDIF »
	
		«getFlowDefinitionResource(it) »
		
	'''
}

def static String viewFlowTestStart(ViewTask it) {
	'''
		public void testStartFlow() {
	    «IF getPrimaryServiceOperation() != null »
			// expectations
			mockery.checking(new org.jmock.Expectations() {
				{
				«IF getPrimaryServiceOperation().getExceptions().size > 0 »
				    try {
				«ENDIF»
				    	atLeast(1).of(«getPrimaryService().name.toFirstLower()»).«getPrimaryServiceOperation().name»(
				    	«FOR param SEPARATOR ", " : getPrimaryServiceOperation().parameters»with(any(«param.getTypeName()».class))«ENDFOR»
				    	);
				«IF getPrimaryServiceOperation().getExceptions().size > 0 »
				    }«FOR exc  : getPrimaryServiceOperation().getExceptions()» 
				    catch («exc» e) {}«ENDFOR»
				«ENDIF»
				    will(returnValue(findById()));
				}
			});
			«ENDIF »    
			startFlow(flowInput, new org.springframework.webflow.test.MockExternalContext());
			assertCurrentStateEquals("view");
			«IF getPrimaryServiceOperation() != null »
			mockery.assertIsSatisfied();
			«ENDIF »
		}
		
		«IF getPrimaryServiceOperation() != null »
			«fakeFindById(it) »
		«ENDIF »
	'''
}



}
