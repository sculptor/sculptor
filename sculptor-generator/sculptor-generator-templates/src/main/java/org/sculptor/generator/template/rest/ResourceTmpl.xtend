/*
 * Copyright 2014 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.template.rest

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.common.ExceptionTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.DomainObject
import sculptormetamodel.HttpMethod
import sculptormetamodel.Parameter
import sculptormetamodel.Resource
import sculptormetamodel.ResourceOperation

@ChainOverridable
class ResourceTmpl {

	@Inject private var ExceptionTmpl exceptionTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def String resource(Resource it) {
	'''
	«resourceBase(it)»
	«IF gapClass»
		«resourceSubclass(it)»
	«ENDIF»
	'''
}

def String resourceBase(Resource it) {
	fileOutput(javaFileName(it.getRestPackage() + "." + name + (if (gapClass) "Base" else "")), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «it.getRestPackage()»;

/// Sculptor code formatter imports ///

	«IF gapClass»
	/**
	 * Generated base class for implementation of «name».
	 * <p>Make sure that subclass defines the following annotations:
	 * <pre>
	«springControllerAnnotation(it)»
	 * </pre>
	 */
	«ELSE»
	/**
	 * Resource Implementation of «name».
	 */
	«springControllerAnnotation(it)»
	«ENDIF»
	public «IF gapClass»abstract «ENDIF»class «name»«IF gapClass»Base«ENDIF» «it.extendsLitteral()» {

		public «name»«IF gapClass»Base«ENDIF»() {
		}
		
		«IF isServiceContextToBeGenerated()»
			«serviceContext(it)»
		«ENDIF»
		
		«initBinder(it)»
		
		«delegateServices(it)»
		
		«it.operations.filter(op | !op.isImplementedInGapClass()).map[resourceMethod(it)].join()»
		
		«it.operations.filter(op | op.isImplementedInGapClass()) .map[resourceAbstractMethod(it)].join()»
		
		«it.operations.filter(e|e.httpMethod == HttpMethod::POST || e.httpMethod == HttpMethod::PUT).map[resourceMethodFromForm(it)].join()»
		
		«handleExceptions(it)»
		
		«resourceHook(it)»
	}
	'''
	)
}

def String resourceSubclass(Resource it) {
	fileOutput(javaFileName(it.getRestPackage() + "." + name), OutputSlot::TO_SRC, '''
	«javaHeader()»
	package «it.getRestPackage()»;

/// Sculptor code formatter imports ///

	/**
	 * Implementation of «name».
	 */
	«springControllerAnnotation(it)»
	public class «name» extends «name»Base {

		public «name»() {
		}

		«it.operations.filter(op | op.isImplementedInGapClass()) .map[resourceMethod(it)].join()»

	}
	'''
	)
}

def String initBinder(Resource it) {
	val primaryDomainObject = it.operations.filter(e|e.httpMethod == HttpMethod::GET && e.domainObjectType != null).map(e|e.domainObjectType).head
	'''
	@org.springframework.web.bind.annotation.InitBinder
		protected void initBinder(org.springframework.web.bind.WebDataBinder binder) throws Exception {
			binder.registerCustomEditor(String.class, new org.springframework.beans.propertyeditors.StringTrimmerEditor(false));
			«IF isJpaProviderAppEngine() && primaryDomainObject != null»
				binder.registerCustomEditor(com.google.appengine.api.datastore.Key.class, new «primaryDomainObject.name»IdKeyEditor());
			«ENDIF»
		}
		
		«IF isJpaProviderAppEngine() && primaryDomainObject != null»
			«gaeKeyIdPropertyEditor(primaryDomainObject)»
		«ENDIF»
	'''
}

def String gaeKeyIdPropertyEditor(DomainObject it) {
	'''
		private static class «name»IdKeyEditor extends java.beans.PropertyEditorSupport {
			@Override
			public void setAsText(String text) {
				if (text == null) {
				    setValue(null);
				} else {
				    com.google.appengine.api.datastore.Key key = com.google.appengine.api.datastore.KeyFactory.createKey(
				    	«it.getDomainPackage()».«name».class.getSimpleName(), Long.valueOf(text));
				    setValue(key);
				}
			}

			@Override
			public String getAsText() {
				com.google.appengine.api.datastore.Key key = (com.google.appengine.api.datastore.Key) getValue();
				return (key == null ? null : String.valueOf(key.getId()));
			}
		}
	'''
}

def String serviceContext(Resource it) {
	'''
		protected «fw("context.ServiceContext")» serviceContext() {
			return «fw("context.ServiceContextStore")».get();
		}
	'''
}

def String springControllerAnnotation(Resource it) {
	'''
	@org.springframework.stereotype.Controller
	'''
}

def String delegateServices(Resource it) {
	'''
	«FOR delegateService : it.getDelegateServices()»
		@org.springframework.beans.factory.annotation.Autowired
		private «getServiceapiPackage(delegateService)».«delegateService.name» «delegateService.name.toFirstLower()»;

		protected «getServiceapiPackage(delegateService)».«delegateService.name» get«delegateService.name»() {
			return «delegateService.name.toFirstLower()»;
		}
	«ENDFOR»
	'''
}

def String resourceMethod(ResourceOperation it) {
	'''
		«IF it.formatJavaDoc() == "" »
			«it.formatJavaDoc()»
		«ELSEIF delegate != null »
			/**
			 * Delegates to {@link «getServiceapiPackage(delegate.service)».«delegate.service.name»#«delegate.name»}
			 */
		«ENDIF »
		«resourceMethodAnnotation(it, false)»
		«resourceMethodSignature(it)» {
		«IF it.isImplementedInGapClass() »
			«resourceMethodHandWritten(it)»
		«ELSEIF delegate == null»
			«resourceMethodReturn(it)»
		«ELSE»
			«resourceMethodValidation(it)»
			«resourceMethodDelegation(it)»
			«resourceMethodModelMapResult(it)»
			«resourceMethodReturn(it)»
		«ENDIF»
		}
	'''
}

def String resourceMethodSignature(ResourceOperation it) {
	'''
	«it.getVisibilityLitteral()» «IF returnString != null»String«ELSE»«it.getTypeName()»«ENDIF» «name»(«it.parameters.map[p | annotatedParamTypeAndName(p, it, false)].join(", ")») «exceptionTmpl.throwsDecl(it)»
	'''
}

def String resourceMethodFromForm(ResourceOperation it) {
	'''
	«IF !it.hasHint("headers") || (it.getHint("headers") != "content-type=application/x-www-form-urlencoded")»
		/**
		 * This method is needed for form data «httpMethod.toString()». Delegates to {@link #«name»}
		 */
		«resourceMethodAnnotation(it, true)»
		«it.getVisibilityLitteral()» «IF returnString != null»String«ELSE»«it.getTypeName()»«ENDIF» «name»FromForm(«it.parameters.map[p | annotatedParamTypeAndName(p, it, true)].join(",")») «exceptionTmpl.throwsDecl(it)» {
			«IF returnString != null || it.getTypeName() != "void"»return «ENDIF»«name»(«FOR p : parameters SEPARATOR ", "»«p.name»«ENDFOR»);
		}
	«ENDIF»
	'''
}

def String resourceMethodHandWritten(ResourceOperation it) {
	val postOperation = it.resource.operations.findFirst(e | e.httpMethod == HttpMethod::POST)
	val putOperation = it.resource.operations.findFirst(e | e.httpMethod == HttpMethod::PUT)
	val modelMapParam = it.parameters.findFirst(e | e.type == "ModelMap")
	'''
	«IF name == "createForm" && returnString != null && modelMapParam != null && postOperation != null»
		«resourceCreateFormMethodHandWritten(it, modelMapParam, postOperation)»
	«ELSEIF name == "updateForm" && returnString != null && modelMapParam != null && putOperation != null»
		«resourceUpdateFormMethodHandWritten(it, modelMapParam, putOperation)»
	«ELSE»
		// TODO Auto-generated method stub
		throw new UnsupportedOperationException("«name» not implemented");
		«IF modelMapParam != null »
			// «modelMapParam.name».addAttribute("result", result);
		«ENDIF »
		«IF returnString != null»// return "«returnString»";«ENDIF»
	«ENDIF»
	'''
}

def String resourceCreateFormMethodHandWritten(ResourceOperation it, Parameter modelMapParam, ResourceOperation postOperation) {
	'''
		«val firstParam = postOperation.parameters.head»
		«IF firstParam.domainObjectType != null »
			«firstParam.domainObjectType.getDomainPackage()».«firstParam.domainObjectType.name» «firstParam.name» = new «firstParam.domainObjectType.getDomainPackage()».«firstParam.domainObjectType.name»(); 
			«modelMapParam.name».addAttribute("«firstParam.name»", «firstParam.name»);
		«ENDIF»
		return "«returnString»";
	'''
}

def String resourceUpdateFormMethodHandWritten(ResourceOperation it, Parameter modelMapParam, ResourceOperation putOperation) {
	'''
		«val firstParam  = putOperation.parameters.head»
		«val getOperation = resource.operations.findFirst(e | e.httpMethod == HttpMethod::GET && e.domainObjectType != null && e.domainObjectType == firstParam.domainObjectType && e.type == null && e.collectionType == null)»
		«val findByIdOperation  = getOperation.delegate»
		«IF findByIdOperation == null»
			// TODO: can't update due to no matching findById method in service
		«ELSE »
			«findByIdOperation.getTypeName()» «firstParam.name» =
			get«findByIdOperation.service.name»().«findByIdOperation.name»(«FOR parameter : findByIdOperation.parameters SEPARATOR ", "»«IF parameter.getTypeName() == serviceContextClass()
				»serviceContext()«ELSE»«parameter.name»«ENDIF»«ENDFOR»);
			«modelMapParam.name».addAttribute("«firstParam.name»", «firstParam.name»);
		«ENDIF »
		return "«returnString»";
	'''
}

def String resourceMethodValidation(ResourceOperation it) {
	'''
	'''
}

def String resourceMethodDelegation(ResourceOperation it) {
	'''
	«IF httpMethod == HttpMethod::DELETE && path.contains("{id}") && !parameters.exists(e|e.name == "id") && parameters.exists(e | e.domainObjectType != null) »
		«resourceMethodDeleteDelegation(it)»
	«ELSE »
		«IF delegate.getTypeName() != "void"»«delegate.getTypeName()» result = «ENDIF»
			«delegate.service.name.toFirstLower()».«delegate.name»(«FOR parameter : delegate.parameters SEPARATOR ", "»«IF parameter.getTypeName() == serviceContextClass()
			»serviceContext()«ELSE»«parameter.name»«ENDIF»«ENDFOR»);
	«ENDIF»
	'''
}

def String resourceMethodDeleteDelegation(ResourceOperation it) {
	'''
		«val findByIdOperation = it.delegate.service.operations.filter(e|e.domainObjectType != null && e.collectionType == null && e.parameters.exists(p|p.type == e.domainObjectType.getIdAttributeType())).head »
		«IF findByIdOperation == null »
			// TODO: can't delete due to no matching findById method in service
		«ELSE »
			«findByIdOperation.getTypeName()» deleteObj =
			«delegate.service.name.toFirstLower()».«findByIdOperation.name»(«FOR parameter : findByIdOperation.parameters SEPARATOR ", "»«IF parameter.getTypeName() == serviceContextClass()
				»serviceContext()«ELSE»«parameter.name»«ENDIF»«ENDFOR»);
			«delegate.service.name.toFirstLower()».«delegate.name»(«FOR parameter : delegate.parameters SEPARATOR ", "»«IF parameter.getTypeName() == serviceContextClass()
				»serviceContext()«ELSE»deleteObj«ENDIF»«ENDFOR»);
		«ENDIF »
	'''
}

def String resourceMethodReturn(ResourceOperation it) {
	'''
		«IF returnString != null && returnString.contains("{id}")»
			return String.format("«returnString.replacePlaceholder("{id}", "%s") »", result.getId()«IF isJpaProviderAppEngine()».getId()«ENDIF»);
		«ELSEIF returnString != null»
			return "«returnString»";
		«ELSEIF it.getTypeName() != "void"»
			return result;
		«ENDIF»
	'''
}

def String resourceMethodModelMapResult(ResourceOperation it) {
	'''
		«val modelMapParam = it.parameters.findFirst(e|e.type == "ModelMap")»
		«IF modelMapParam != null && it.delegate.getTypeName() != "void"»
			«modelMapParam.name».addAttribute("result", result);
		«ENDIF»
	'''
}

def String resourceAbstractMethod(ResourceOperation it) {
	'''
		/* 
		«resourceMethodAnnotation(it, false)»
		«resourceMethodSignature(it)» */
		«it.getVisibilityLitteral()» abstract «IF returnString != null»String«ELSE»«it.getTypeName()»«ENDIF» «name»(«it.parameters.map[paramTypeAndName(it)].join(",")») «exceptionTmpl.throwsDecl(it)»;
	'''
}

def String resourceMethodAnnotation(ResourceOperation it, boolean formDataHeader) {
	'''
	@org.springframework.web.bind.annotation.RequestMapping(value = "«path»", method=org.springframework.web.bind.annotation.RequestMethod.«httpMethod.toString()»«
	IF formDataHeader», headers = "content-type=application/x-www-form-urlencoded"«ELSEIF it.hasHint("headers")», headers = "«it.getHint("headers")»"«ENDIF»« IF it.hasHint("params")», params = "«it.getHint("params")»"«ENDIF»)
	'''
}

def String generatedName(ResourceOperation it) {
	'''
	«IF returnString != null»"«it.getHint('return')»"«ELSE»""«ENDIF»
	'''
}

def String paramTypeAndName(Parameter it) {
	'''
	«it.getTypeName()» «name»
	'''
}

def String annotatedParamTypeAndName(Parameter it, ResourceOperation op, boolean formData) {
	'''
	«IF op.httpMethod == HttpMethod::DELETE && domainObjectType != null && domainObjectType.getIdAttribute() != null && op.path.contains("{id}")
		»@org.springframework.web.bind.annotation.PathVariable("id") «domainObjectType.getIdAttributeType()» id
	«ELSE»
		«IF op.path.contains("{" + name + "}")»
			@org.springframework.web.bind.annotation.PathVariable("«name»") 
		«ELSEIF formData && domainObjectType != null»
			@org.springframework.web.bind.annotation.ModelAttribute("«name»") 
		«ELSEIF domainObjectType != null»
			@org.springframework.web.bind.annotation.RequestBody 
		«ELSEIF it.isRestRequestParameter()»
			@org.springframework.web.bind.annotation.RequestParam("«name»") 
		«ENDIF»
		«it.getTypeName()» «name»
	«ENDIF»
	'''
}

def String handleExceptions(Resource it) {
	'''
	«val allExceptions = it.operations.filter(e | e.^throws != null).map(e | e.exceptions()).flatten.toSet()»
	«allExceptions.filter(e|e.endsWith("NotFoundException")).map[handleNotFoundException(it)].join()»
	«handleIllegalArgumentException("java.lang.IllegalArgumentException")»
	«handleIllegalArgumentException(fw("errorhandling.ValidationException"))»
	«handleSystemException(fw("errorhandling.SystemException"))»
	«IF operations.exists(e | e.httpMethod == HttpMethod::POST || e.httpMethod == HttpMethod::PUT || e.httpMethod == HttpMethod::DELETE)»
		«handleOptimisticLockingException(fw("errorhandling.OptimisticLockingException"))»
	«ENDIF»
	'''
}

def String handleNotFoundException(String it) {
	'''
		@org.springframework.web.bind.annotation.ExceptionHandler
		public void handleException(«it» e, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
			response.sendError(org.springframework.http.HttpStatus.NOT_FOUND.value(), e.getMessage());
		}
	'''
}

def String handleOptimisticLockingException(String it) {
	'''
		@org.springframework.web.bind.annotation.ExceptionHandler
		public void handleException(«it» e, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
			response.sendError(org.springframework.http.HttpStatus.CONFLICT.value(), e.getMessage());
		}
	'''
}

def String handleIllegalArgumentException(String it) {
	'''
		@org.springframework.web.bind.annotation.ExceptionHandler
		public void handleException(«it» e, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
			response.sendError(org.springframework.http.HttpStatus.BAD_REQUEST.value(), e.getMessage());
		}
	'''
}

def String handleSystemException(String it) {
	'''
		@org.springframework.web.bind.annotation.ExceptionHandler
		public void handleException(«it» e, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
			response.sendError(org.springframework.http.HttpStatus.SERVICE_UNAVAILABLE.value(), e.getMessage());
		}
	'''
}


/* Extension point to generate more stuff in service implementation.
 * User AROUND resourceTmpl.resourceHook FOR Resource in SpecialCases.xpt
 */
def String resourceHook(Resource it) {
	'''
	'''
}
}
