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

package org.sculptor.generator.template.web

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class JSFCrudGuiJavaTmpl {


def static String flowJava(GuiApplication it) {
	'''
	/*«it.groupByTarget().forEach[flowJavaPropertyEditorBase(it)]» */
	«it.this.modules.userTasks.typeSelect(CreateTask).forEach[createFlowJava(it)]»
	«it.this.modules.userTasks.typeSelect(UpdateTask).forEach[updateFlowJava(it)]»
	«it.this.modules.userTasks.typeSelect(ViewTask).forEach[viewFlowJava(it)]»
	«it.this.modules.userTasks.typeSelect(DeleteTask).forEach[deleteFlowJava(it)]»
	«it.this.modules.userTasks.typeSelect(ListTask).forEach[listFlowJava(it)]»
	'''
}

def static String flowJava(UserTask it) {
	'''
	'''
}



def static String createFlowJava(CreateTask it) {
	'''
	«JSFCrudGuiJavaForm::flowJavaForm(it)»
	«createFlowJavaActionBase(it)»
	«IF gapClass»
		«flowJavaActionImpl(it)»
	«ENDIF»

	/*«flowJavaPropertyEditorRegistrar(it)» */
	'''
}


def static String createFlowJavaActionBase(CreateTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Action" + (gapClass ? "Base" : "")) , '''
	«javaHeader()»
	package «this.module.getWebPackage()»;
	«IF !gapClass»
	@org.springframework.stereotype.Component
	«ENDIF»
	public «IF gapClass»abstract «ENDIF»class «name.toFirstUpper()»Action«IF gapClass»Base«ENDIF» {

	«createFormMethod(it)»
	«repositoryProperty(it) FOR this.for»

	«loadFormMethod(it)»
		«it.getReferencesPropertiesChildrenToSelect().forEach[getReferenceItems(it)]»

		«saveMethod(it)»
	«confirmMethod(it)»
	
	«it.this.subTaskTransitions.reject(e|e.to.metaType == AddTask) .forEach[subflowStartMethod(it)]»
	«it.this.subTaskTransitions.filter(e|e.to.metaType == CreateTask || e.to.metaType == UpdateTask) .forEach[subflowReturnMethod(it)]»
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p|p.base) .forEach[removeChildMethodAction(it)]»
	/*TODO - howto represent a setting of an existing instance? */
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p|p.base) .forEach[addExistingChildMethodAction(it)]»
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p|p.base) .forEach[findExistingReference(it)]»
	«putModelInFlashScope(it) FOR for»
	«putModelInFlowScope(it) FOR for»
	«formObjectMethod(it)»

	«it.this.getUsedServices().forEach[serviceProperty(it)]»
	
	«actionHook(it)»
	}
	'''
	)
	'''
	'''
}


def static String updateFlowJava(UpdateTask it) {
	'''
	«JSFCrudGuiJavaForm::flowJavaForm(it)»
	«updateFlowJavaActionBase(it)»

	«IF gapClass»
		«flowJavaActionImpl(it)»

	«ENDIF»

	/*«flowJavaPropertyEditorRegistrar(it)» */
	'''
}


def static String updateFlowJavaActionBase(UpdateTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getWebPackage() + "." + name.toFirstUpper() + "Action" + (gapClass ? "Base" : "")) -, '''
	«javaHeader()»
	package «module.getWebPackage()»;
	«IF !gapClass»
	@org.springframework.stereotype.Component
	«ENDIF»
	public «IF gapClass»abstract «ENDIF»class «name.toFirstUpper()»Action«IF gapClass»Base«ENDIF» {

	«createFormMethod(it)»
	«repositoryProperty(it)»

	«loadFormMethod(it)»
		/*
		«it.getReferencesPropertiesToSelect().collect(prop | prop.reference).forEach[getReferenceItems(it)]»
			*/
		«it.getReferencesPropertiesChildrenToSelect().forEach[getReferenceItems(it)]»

	«cancelMethod(it)»
	«saveMethod(it)»
	«confirmMethod(it)»
	«getId(it) FOR for»
	«it.this.subTaskTransitions.reject(e|e.to.metaType == AddTask) .forEach[subflowStartMethod(it)]»
	«it.this.subTaskTransitions.filter(e|e.to.metaType == CreateTask || e.to.metaType == UpdateTask) .forEach[subflowReturnMethod(it)]»
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base) .forEach[removeChildMethodAction(it)]»
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base) .forEach[addExistingChildMethodAction(it)]»
		«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p|p.base) .forEach[findExistingReference(it)]»
	«getModelFromScope(it) FOR for»
	«putModelInFlashScope(it) FOR for»
	«putModelInFlowScope(it) FOR for»
	«formObjectMethod(it)»

		«it.this.getUsedServices().forEach[serviceProperty(it)]»
		
		«actionHook(it)»
	}
	'''
	)
	'''
	'''
}


def static String viewFlowJava(ViewTask it) {
	'''
	«JSFCrudGuiJavaForm::flowJavaForm(it)»
	«viewFlowJavaActionBase(it)»
	«IF gapClass»
		«flowJavaActionImpl(it)»
	«ENDIF»

	/*«flowJavaPropertyEditorRegistrar(it)» */
	'''
}

def static String viewFlowJavaActionBase(ViewTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Action" + (gapClass ? "Base" : "")) -, '''
	«javaHeader()»
	package «this.module.getWebPackage()»;
	«IF !gapClass»
	@org.springframework.stereotype.Component
	«ENDIF»

	public «IF gapClass»abstract «ENDIF»class «name.toFirstUpper()»Action«IF gapClass»Base«ENDIF» {
	«createFormMethod(it)»
	«repositoryProperty(it) FOR for»
	«getId(it) FOR for»
	«loadFormMethod(it)»
	«it.this.subTaskTransitions .forEach[subflowStartMethod(it)]»
	«putModelInFlashScope(it) FOR for»
	«it.this.getUsedServices().forEach[serviceProperty(it)]»
	
	«actionHook(it)»
	}
	'''
	)
	'''
	'''
}

def static String deleteFlowJava(DeleteTask it) {
	'''
	«IF this.deleteDOWith != null»
	«deleteFlowJavaActionBase(it)»
	«IF gapClass»
		«flowJavaActionImpl(it)»
	«ENDIF»
	/*«flowJavaPropertyEditorRegistrar(it)» */
	«ENDIF»
	'''
}

def static String deleteFlowJavaActionBase(DeleteTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getWebPackage() + "." + name.toFirstUpper() + "Action" + (gapClass ? "Base" : "")) -, '''
	«javaHeader()»
	package «module.getWebPackage()»;
	«IF !gapClass»
	@org.springframework.stereotype.Component
	«ENDIF»

	public «IF gapClass»abstract «ENDIF»class «name.toFirstUpper()»Action«IF gapClass»Base«ENDIF» {
	«repositoryProperty(it)»
	«getModelFromScope(it) FOR for»
	«putModelInFlashScope(it) »
	«getId(it) FOR for»
	/*«deleteFlowCreateFormObjectWithFindById(it) FOR for » */
	«deleteFlowFindById(it) »

	«IF this.deleteDOWith != null»
	public String delete(org.springframework.webflow.execution.RequestContext ctx) « ExceptionTmpl::throws(it) FOR deleteDOWith» {
		«for.getIdAttributeType()» id = getId(ctx);
		«for.getDomainPackage()».«for.name» entity = 
		«IF for.isPersistent()»
		getRepository().get(«for.getDomainPackage()».«for.name».class, id);
		«ELSEIF findDOWith != null»
			«findDOWith.service.name.toFirstLower()».«findDOWith.name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get(), «ENDIF»id);
		«ELSE»
		   /*TODO what if the object isn't persistent and doesn't have findById? */
		      null;
		«ENDIF»
		«deleteDOWith.service.name.toFirstLower()».«deleteDOWith.name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get(), «ENDIF»entity);
		putModelInFlashScope(ctx, "«for.name»", entity);
		return "success";
	}

	«ENDIF»

	«it.this.getUsedServices().forEach[serviceProperty(it)]»
	
	«actionHook(it)»
	}
	'''
	)
	'''
	'''
}
/*
def static String deleteFlowCreateFormObjectWithFindById(DomainObject it) {
	'''
		protected Object createFormObject(org.springframework.webflow.execution.RequestContext ctx) {
			try {
				findById(ctx);
				return getFormObjectAccessor(ctx).getCurrentFormObject();
			} catch (Exception e) {
				// Create an empty, fake, to be able to bind errors, findById will be invoked again
	        	return new «fakeObjectInstantiatorClass()»<«getDomainPackage()».«name»>(«getDomainPackage()».«name».class).createFakeObject();
	        }
			}
	'''
}
 */
def static String deleteFlowFindById(DeleteTask it) {
	'''
		public String findById(org.springframework.webflow.execution.RequestContext ctx) « IF findDOWith != null »«ExceptionTmpl::throws(it) FOR findDOWith»«ENDIF» {
			«for.getDomainPackage()».«for.name» entity = null;
			«for.getIdAttributeType()» id = getId(ctx);
			if (id != null) {
				«IF findDOWith != null»
				entity = «IF for.^extends != null» («for.getDomainPackage()».«for.name») «ENDIF»«findDOWith.service.name.toFirstLower()».«findDOWith.name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get(), «ENDIF»id);
				«IF !findDOWith.hasNotFoundException()»
					if (entity == null) {
						throw new IllegalArgumentException("Didn't find «for.name» with id: " + id);
					}
				«ENDIF»
				«ELSEIF for.isPersistent()»
				entity = repository.get(«for.getDomainPackage()».«for.name».class, id);
				«ENDIF»
			} else {
				entity = («for.getDomainPackage()».«for.name») ctx.getFlowScope().get("«for.name»");
				if (entity == null) {
					throw new IllegalArgumentException("Both id and flowScope '«for.name»' is null");
				}
			}
			ctx.getFlowScope().put("«for.name.toFirstLower()»", entity);
			return "success";
		}
	'''
}

def static String listFlowJava(ListTask it) {
	'''
	«IF this.searchDOWith != null»
		«JSFCrudGuiJavaForm::flowJavaForm(it)»
		
		«listFlowJavaActionBase(it)»
		«IF gapClass»
			«flowJavaActionImpl(it)»
		«ENDIF»
		/*«flowJavaPropertyEditorRegistrar(it)» */
	«ENDIF»
	'''
}

def static String listFlowJavaActionBase(ListTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getWebPackage() + "." + name.toFirstUpper() + "Action" + (gapClass ? "Base" : "")) -, '''
	«javaHeader()»
	package «module.getWebPackage()»;
	«IF !gapClass»
	@org.springframework.stereotype.Component
	«ENDIF»
	public «IF gapClass»abstract «ENDIF»class «name.toFirstUpper()»Action«IF gapClass»Base«ENDIF» {
	«createFormMethod(it)»
	«repositoryProperty(it) FOR for»
	«getModelFromScope(it) FOR for»
	«putModelInFlashScope(it) FOR for»

	«IF this.searchDOWith != null»
		«IF searchDOWith.isPagedResult()»
			«listFlowJavaActionPagedFindAll(it)»
		«ELSE»
			«listFlowJavaActionFindAll(it)»
		«ENDIF»
	«ENDIF»

	«it.this.getUsedServices().forEach[serviceProperty(it)]»

	«formObjectMethod(it) FOR this»
	
	«actionHook(it)»

	}
	'''
	)
	'''
	'''
}

def static String listFlowJavaActionFindAll(ListTask it) {
	'''
	public String findAll(org.springframework.webflow.execution.RequestContext ctx) « ExceptionTmpl::throws(it) FOR searchDOWith» {
		«IF for.isPersistent()»
		repository.clear();
			«ENDIF»
		«IF searchDOWith.domainObjectType == for»
		java.util.List<«for.getDomainPackage()».«for.name»> all«for.name.plural()» = «searchDOWith.service.name.toFirstLower()».«searchDOWith.name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get()«ENDIF»);
		«ELSE»
		java.util.List<«for.getDomainPackage()».«for.^extends.name»> all = «searchDOWith.service.name.toFirstLower()».«searchDOWith.name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get()«ENDIF»);
		java.util.List<«for.getDomainPackage()».«for.name»> all«for.name.plural()» = new java.util.ArrayList<«for.getDomainPackage()».«for.name»>();
		for («for.^extends.getDomainPackage()».«for.^extends.name» «for.^extends.name.toFirstLower()» : all) {
			if («for.^extends.name.toFirstLower()» instanceof «for.getDomainPackage()».«for.name») {
				all«for.name.plural()».add((«for.getDomainPackage()».«for.name») «for.^extends.name.toFirstLower()»);
			}
		}
		«ENDIF»
		formObject(ctx).setAll«for.name.plural()»(all«for.name.plural()»);
		return "success";
	}
	'''
}

def static String listFlowJavaActionPagedFindAll(ListTask it) {
	'''
	public String findAll(org.springframework.webflow.execution.RequestContext ctx) « ExceptionTmpl::throws(it) FOR searchDOWith» {
		«IF for.isPersistent()»
			repository.clear();
		«ENDIF»
		«name.toFirstUpper()»Form form = formObject(ctx);
		boolean countTotalPages = form.getPagedResult() == null
				|| !form.getPagedResult().isTotalCounted();
			«getJavaType("PagingParameter")» pagingParameter = «getJavaType("PagingParameter")».pageAccess(
				    «getJavaType("PagingParameter")».DEFAULT_PAGE_SIZE, form.getPageNumber(),
				    countTotalPages);
			«searchDOWith.getTypeName()» pagedResult = «searchDOWith.service.name.toFirstLower()».«searchDOWith.name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get(), «ENDIF»pagingParameter);
				
		«IF searchDOWith.domainObjectType == for»
		form.setPagedResult(pagedResult);
		«ELSE»
		java.util.List<«for.getDomainPackage()».«for.^extends.name»> all = pagedResult.getValues();
		java.util.List<«for.getDomainPackage()».«for.name»> all«for.name.plural()» = new java.util.ArrayList<«for.getDomainPackage()».«for.name»>();
		for («for.^extends.getDomainPackage()».«for.^extends.name» «for.^extends.name.toFirstLower()» : all) {
			if («for.^extends.name.toFirstLower()» instanceof «for.getDomainPackage()».«for.name») {
				all«for.name.plural()».add((«for.getDomainPackage()».«for.name») «for.^extends.name.toFirstLower()»);
			}
		}
		«searchDOWith.getTypeName()» pagedResult«for.name.plural()» = new «searchDOWith.getTypeName()»(all«for.name.plural()», 
			pagedResult.getStartRow(), pagedResult.getRowCount(), pagedResult.getPageSize(), 
			pagedResult.getTotalRows(),	pagedResult.getAdditionalResultRows());
		
		form.setPagedResult(pagedResult«for.name.plural()»);
		«ENDIF»
		
		return "success";
	}
	'''
}


def static String subflowReturnMethod(SubTaskTransition it) {
	'''
	public String «resolveChildMethodName(this)»(org.springframework.webflow.execution.RequestContext ctx) {
	«this.from.name.toFirstUpper()»Form form = formObject(ctx);
		«this.to.for.getDomainPackage()».«this.to.for.name» flashScopeValue = («this.to.for.getDomainPackage()».«this.to.for.name») ctx.getFlashScope().get("«this.to.for.name»");
	if (flashScopeValue != null) {
		«IF isMany() »
		form.add«this.forReference.name.toFirstUpper().singular()»(flashScopeValue);
		«ELSE »
		form.set«this.forReference.name.toFirstUpper().singular()»(flashScopeValue);
		«ENDIF »
	}
	return "success";
	}
	'''
}


def static String subflowStartMethod(SubTaskTransition it) {
	'''
	public String «resolvePrepareMethodName(this)»(org.springframework.webflow.execution.RequestContext ctx) {
	«IF this.to.metaType != CreateTask»
		«this.from.name.toFirstUpper()»Form form = formObject(ctx);
		«IF isMany() »
			Integer index = ctx.getRequestParameters().getInteger("index", -1);
			«this.to.for.getDomainPackage()».«this.to.for.name» flashScopeValue = «IF this.to.for.^extends != null»(«this.to.for.getDomainPackage()».«this.to.for.name») «ENDIF»form.get«this.forReference.name.toFirstUpper()»().get(index);
		«ELSE »
			«this.to.for.getDomainPackage()».«this.to.for.name» flashScopeValue = «IF this.to.for.^extends != null»(«this.to.for.getDomainPackage()».«this.to.for.name») «ENDIF»form.get«this.forReference.name.toFirstUpper()»();
		«ENDIF »
		putModelInFlashScope(ctx, "«this.to.for.name»", flashScopeValue);
	«ENDIF»
	return "success";
	}
	'''
}

def static String removeChildMethodAction(ReferenceViewProperty it) {
	'''
	public String «resolveRemoveChildMethodName(this)»(org.springframework.webflow.execution.RequestContext ctx) {
	«IF isMany()»
		Integer index = ctx.getRequestParameters().getInteger("index", -1);
		formObject(ctx).remove«this.reference.name.toFirstUpper().singular()»(index);
	«ELSE »
		formObject(ctx).remove«this.reference.name.toFirstUpper().singular()»();
	«ENDIF »
	return "success";
	}
	'''
}


def static String addExistingChildMethodAction(ReferenceViewProperty it) {
	'''
	«IF isAddSubTaskAvailable() »
	public String «resolveAddExistingChildMethodName(this)»(org.springframework.webflow.execution.RequestContext ctx) {
	«this.userTask.name.toFirstUpper()»Form form = formObject(ctx);
	«reference.to.getIdAttributeType()» id = form.get«resolveSelectedExistingChildIdAttributeName(this).toFirstUpper()»();
	if (id == null) {
		// nothing selected
		return "success";
	}
		«this.target.getDomainPackage()».«this.target.name» existing = «resolveReferenceName("findExisting", this, "")»(ctx, id);
	«IF isMany() »
	form.add«this.reference.name.toFirstUpper().singular()»(existing);
	«ELSE »
	form.set«this.reference.name.toFirstUpper().singular()»(existing);
	«ENDIF »
	return "success";
	}
	«ENDIF»
	'''
}
def static String findExistingReference(ReferenceViewProperty it) {
	'''
	protected «this.target.getDomainPackage()».«this.target.name» «resolveReferenceName("findExisting", this, "")»(org.springframework.webflow.execution.RequestContext ctx, «reference.to.getIdAttributeType()» id) {
		«IF reference.to.isPersistent()»
			return getRepository().get(«this.target.getDomainPackage()».«this.target.name».class, id);
		«ELSEIF reference.to.getFindByIdMethod() != null»
			return «reference.to.getFindByIdMethod().service.name.toFirstLower()».«reference.to.getFindByIdMethod().name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get(), «ENDIF»id);        
		«ELSE»
			/*TODO what to do if reference isn't persistent and hasn't a findById service? */
			throw new RuntimeException("Can't find reference to object, either by repository or service. Manual code needed, override me [«resolveReferenceName("findExisting", this, "")»(...)]in subclass.");
		«ENDIF»
	}
	'''
}

def static String repositoryProperty(Object it) {
	'''
		private «conversationDomainObjectRepositoryInterface()» repository;

		protected «conversationDomainObjectRepositoryInterface()» getRepository() {
			return repository;
		}

		/**
			* Dependency injection
			*/
		@org.springframework.beans.factory.annotation.Autowired
		public void setRepository(«conversationDomainObjectRepositoryInterface()» repository) {
			this.repository = repository;
		}

	'''
}

def static String getModelFromScope(DomainObject it) {
	'''
	protected «getDomainPackage()».«name» getModelFromScope(org.springframework.webflow.execution.RequestContext ctx) {
		«getDomainPackage()».«name» model = («getDomainPackage()».«name») ctx.getFlashScope().get("«name»");
		if (model == null) {
			model = («getDomainPackage()».«name») ctx.getFlowScope().get("«name»");
		}
		if (model == null) {
			throw new IllegalArgumentException("No model named '«name»' in scope ");
		}
	return model;
	}
	'''
}
def static String putModelInFlashScope(Object it) {
	'''
	protected void putModelInFlashScope(org.springframework.webflow.execution.RequestContext ctx, String key, Object model) {
	ctx.getFlashScope().put(key, model);
	}
	'''
}
def static String putModelInFlowScope(Object it) {
	'''
	protected void putModelInFlowScope(org.springframework.webflow.execution.RequestContext ctx, String key, Object model) {
	ctx.getFlowScope().put(key, model);
	}
	'''
}

def static String getId(DomainObject it) {
	'''
	protected «getIdAttributeType()» getId(org.springframework.webflow.execution.RequestContext ctx) {
	   Object id = ctx.getFlowScope().get("id");
	   return (id != null ? new «getIdAttributeType()»(id.toString()) : null);
		}
	'''
}



def static String serviceProperty(Service it) {
	'''
	private «this.getServiceapiPackage()».«this.name» «this.name.toFirstLower()»;
	protected «this.getServiceapiPackage()».«this.name» get«this.name»() {
		return «this.name.toFirstLower()»;
	}
	/**
	 * Dependency injection
	 */
	«IF !isEar()»
		@org.springframework.beans.factory.annotation.Autowired
	«ELSE»
	@javax.annotation.Resource(name="«name.toFirstLower()»Proxy")
	«ENDIF»
	public void set«this.name»(«this.getServiceapiPackage()».«this.name» service) {
		this.«this.name.toFirstLower()» = service;
	}
	'''
}

/*
def static String requiredReferencesConditions(DomainObject it) {
	'''
	«FOR requiredReference  : getRequiredReferences()»
	if (is«requiredReference.name.toFirstUpper()»ReferenceRequired(ctx)) {
		«IF requiredReference.isMany()»
	    requiredList.add("«resolveRequiredIdAttributeName(requiredReference)»");
		«ELSE»
	    requiredList.add("«resolveRequiredIdAttributeName(requiredReference)»");
		«ENDIF»
	}
	«ENDFOR»
	'''
}
 */

def static String flowJavaActionImpl(UserTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Action"), 'TO_SRC', '''
	«javaHeader()»
	package «this.module.getWebPackage()»;

	@org.springframework.stereotype.Component
	public class «name.toFirstUpper()»Action ^extends «name.toFirstUpper()»ActionBase {
	«actionHook(it)»
	}
	'''
	)
	'''
	'''
}

def static String flowJavaValidatorImpl(UserTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Validator"), 'TO_SRC', '''
	«javaHeader()»
	package «module.getWebPackage()»;
	@org.springframework.stereotype.Component
	public class «name.toFirstUpper()»FormValidator {
	public void validateInput(«module.getWebPackage()».«name.toFirstUpper()»Form form, org.springframework.binding.validation.ValidationContext) {
		// TODO implement
	}
	}
	'''
	)
	'''
	'''
}

def static String validateRequiredField(Attribute it, String fieldName) {
	'''
		«IF !this.nullable && !isSystemAttribute() && !isPrimitive()»
		«IF getTypeName() == "String"»
		if (org.apache.commons.lang.StringUtils.isEmpty(form.get«fieldName.toFirstUpper()»())) {
		«ELSE»
		if (form.get«fieldName.toFirstUpper()»() == null) {
		«ENDIF»
			errors.rejectValue("«fieldName»", "required");
		}
		«ENDIF»
	'''
}
def static String validateField(Attribute it, String fieldName) {
	'''
		«IF getTypeName() == "String" && !isSystemAttribute()»
		if(form.get«fieldName.toFirstUpper()»() != null && form.get«fieldName.toFirstUpper()»().length() > «getDatabaseLength()») {
		errors.rejectValue("«fieldName»", "error.value.too.long",new Object[]{"«getDatabaseLength()»"},"Max length is {0}");
		}
		«ENDIF»
	'''
}

def static String cancelMethod(UserTask it) {
	'''
		public String cancel(org.springframework.webflow.execution.RequestContext ctx) {
	        «for.getDomainPackage()».«for.name» model = formObject(ctx).getOriginalModel();
			if (model == null) {
				// loadForm failed, nothing to revert
				return "success";
			}
			«IF for.isPersistent()»
			if (model.getId() != null) {
				getRepository().revert(model);
			}
			«ENDIF»
			return "success";
		}
	'''
}


def static String saveMethod(UserTask it) {
	'''
	«val saveOperation = it.getPrimaryServiceOperation()»
	public String save(org.springframework.webflow.execution.RequestContext ctx) « IF saveOperation != null »«ExceptionTmpl::throws(it) FOR saveOperation»«ENDIF» {
	«name.toFirstUpper()»Form form = formObject(ctx);
	«for.getDomainPackage()».«this.for.name» model = form.toModel();
	«IF saveOperation != null »
	putModelInFlashScope(ctx, "«for.name»", «saveOperation.service.name.toFirstLower()».«saveOperation.name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get(), «ENDIF»model));
	«ELSE»
	putModelInFlashScope(ctx, "«for.name»", model);
	«ENDIF»
	return "success";
	}
	'''
}

def static String formObjectMethod(UserTask it) {
	'''
	protected «name.toFirstUpper()»Form formObject(org.springframework.webflow.execution.RequestContext ctx) {
	return («name.toFirstUpper()»Form) ctx.getFlowScope().get("«name»Form");
	}
	'''
}

def static String confirmMethod(UserTask it) {
	'''
	public String confirm(org.springframework.webflow.execution.RequestContext ctx) {
	«name.toFirstUpper()»Form form = formObject(ctx);


	«for.getDomainPackage()».«for.name» model = form.toConfirmModel();

	form.setConfirmDraft(model);
	return "success";
	}
	'''
}

def static String loadFormMethod(ViewTask it) {
	'''
	public String loadForm(org.springframework.webflow.execution.RequestContext ctx) « IF this.findDOWith != null »«ExceptionTmpl::throws(it) FOR this.findDOWith»«ENDIF» {

	«for.getDomainPackage()».«for.name» entity = null;
	«for.getIdAttributeType()» id = getId(ctx);
	if (id != null) {
		«IF this.findDOWith != null»
		entity = «IF for.^extends != null» («for.getDomainPackage()».«for.name») «ENDIF»«findDOWith.service.name.toFirstLower()».«this.findDOWith.name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get(), «ENDIF»id);
			«IF !findDOWith.hasNotFoundException()»
				if (entity == null) {
					throw new IllegalArgumentException("Didn't find «for.name» with id: " + id);
				}
			«ENDIF»
		«ELSEIF for.isPersistent()»
		entity = repository.get(«for.getDomainPackage()».«for.name».class, id);
		«ELSE»
		entity = null;
		throw new RuntimeException("Can't load domain object «for.name» since neither repository or service are available. Manual code needed");
		«ENDIF»
	} else {
		entity = («for.getDomainPackage()».«for.name») ctx.getFlowScope().get("«for.name»");
		if (entity == null) {
			throw new IllegalArgumentException("Both id and flowScope '«for.name»' is null");
		}
	}

	«name.toFirstUpper()»Form form = formObject(ctx);
		form.fromModel(entity);

	return "success";
	}

	private «name.toFirstUpper()»Form formObject(org.springframework.webflow.execution.RequestContext ctx) {
	return («name.toFirstUpper()»Form) ctx.getFlowScope().get("«name»Form");
	}
	'''
}
def static String loadFormMethod(CreateTask it) {
	'''
	public String loadForm(org.springframework.webflow.execution.RequestContext ctx) {
		«val itemsReferences = it.this.getReferencesPropertiesChildrenToSelect()»
		«IF !itemsReferences.isEmpty»
		«name.toFirstUpper()»Form form = formObject(ctx);
		«FOR ref : itemsReferences»
		form.set«ref.target.name.toFirstUpper()»Items(get«ref.target.name.toFirstUpper()»Items());
		«ENDFOR»
		«ENDIF»
		return "success";
	}
	'''
}
def static String loadFormMethod(UpdateTask it) {
	'''
	public String loadForm(org.springframework.webflow.execution.RequestContext ctx)
	«IF this.findDOWith != null»«ExceptionTmpl::throws(it) FOR findDOWith»«ENDIF» {
		«IF this.findDOWith != null»
		«for.getIdAttributeType()» id = getId(ctx);
		if (id == null) {
			throw new IllegalArgumentException("No 'id' in scope: " + ctx);
		}
	«for.getDomainPackage()».«for.name» model = «IF for.^extends != null» («for.getDomainPackage()».«for.name») «ENDIF»«findDOWith.service.name.toFirstLower()».«this.findDOWith.name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get(), «ENDIF»id);
	«IF !findDOWith.hasNotFoundException()»
		if (model == null) {
			throw new IllegalArgumentException("Didn't find «for.name» with id: " + id);
		}
	«ENDIF»
	putModelInFlashScope(ctx, "«for.name»", model);
		«ELSE»
	«for.getDomainPackage()».«for.name» model = getModelFromScope(ctx);
		«ENDIF»

	        «name.toFirstUpper()»Form form = formObject(ctx);
		form.fromModel(model);

		«FOR viewRef : this.getReferencesPropertiesChildrenToSelect()»
		form.set«viewRef.target.name.toFirstUpper()»Items(get«viewRef.target.name.toFirstUpper()»Items());
		«ENDFOR»

		form.setNextEnabled(true);
		return "success";

	}
	'''
}

def static String createFormMethod(UserTask it) {
	'''
	public String createForm(org.springframework.webflow.execution.RequestContext ctx) {
	ctx.getFlowScope().put("«name»Form", new «name.toFirstUpper()»Form());
		return "success";
	}
	'''
}


def static String getReferenceItems(ReferenceViewProperty it) {
	'''
	«val addTask = it.getRelatedAddTask()»
	protected java.util.List<javax.faces.model.SelectItem> get«target.name.toFirstUpper()»Items() {
			
		«IF addTask.getPrimaryServiceOperation().isPagedResult()»
			/*This solution should probably be changed. */
			// fetch all pages
			java.util.List<«getExtendsClassNameIfExists(reference.to)»> all = new java.util.ArrayList<«getExtendsClassNameIfExists(reference.to)»>(); 
			int pageSize = 500;
			int maxPages = 20;
			for (int i = 1; i <= maxPages; i++) {
				boolean countTotalPages = (i == 1);
				«getJavaType("PagingParameter")» pagingParameter = «getJavaType("PagingParameter")».pageAccess(pageSize, i, countTotalPages);
				«getJavaType("PagedResult")»<? ^extends «getExtendsClassNameIfExists(reference.to)»> pagedResult = «addTask.getPrimaryService().name.toFirstLower()».«addTask.getPrimaryServiceOperation().name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get(), «ENDIF»pagingParameter);
				if (pagedResult.isTotalCounted()) {
				    maxPages = pagedResult.getTotalPages();
				}
				all.addAll(pagedResult.getValues());
			}
		«ELSE»
			java.util.Collection<? ^extends «getExtendsClassNameIfExists(reference.to)»> all = «addTask.getPrimaryService().name.toFirstLower()».«addTask.getPrimaryServiceOperation().name»(«IF isServiceContextToBeGenerated()»«serviceContextStoreClass()».get()«ENDIF»);
		«ENDIF»
			java.util.List<javax.faces.model.SelectItem> items = new java.util.ArrayList<javax.faces.model.SelectItem>();
			for («getExtendsClassNameIfExists(reference.to)» each : all) {
				if (each instanceof «target.getDomainPackage()».«target.name») {
					«target.getDomainPackage()».«target.name» domainObject = («target.getDomainPackage()».«target.name») each;
				String label = «itemLabel(it)("domainObject") FOR reference.to »;
				items.add(new javax.faces.model.SelectItem(domainObject.getId(),label));
			}
		}
			return items;
		}
	'''
}

def static String itemLabel(DomainObject it, String prefix) {
	'''
	String.valueOf(«IF hasNaturalKey()»
	«FOR key SEPARATOR ' + " | " + ' : getAllNaturalKeys()»
		«IF key.isEnumReference() »
		«prefix».get«key.name.toFirstUpper()»()
		«ELSEIF key.metaType == Reference »
			«itemLabel(it)(prefix + ".get" + key.name.toFirstUpper() + "()") FOR ((Reference) key).to»
		«ELSE»
		«prefix».get«key.name.toFirstUpper()»()
		«ENDIF»
	«ENDFOR»
	«ELSEIF getConstructorParameters().filter(p | p.metaType == Attribute || p.isEnumReference()).size > 0 »
	«val params = it.this.getConstructorParameters().filter(p | p.metaType == Attribute || p.isEnumReference())»
		«FOR param SEPARATOR ' + " | " + ' : params»
		«prefix».get«param.name.toFirstUpper()»()
		«ENDFOR»
	«ELSE»
	«val atts = it.this.getAllNonSystemAttributes()»
		«FOR att SEPARATOR ' + " | " + ' : atts»
		«prefix».get«att.name.toFirstUpper()»()
		«ENDFOR»
	«ENDIF»)
	'''
}

/*Extension point to generate more stuff in Action classes.
	Use AROUND JSFCrudGuiJavaTmpl::actionHook FOR UserTask
	in SpecialCases.xpt */
def static String actionHook(UserTask it) {
	'''
	'''
}
}
