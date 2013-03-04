package org.sculptor.generator.template.rest

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class ResourceTmpl {

def static String resource(Resource it) {
	'''
	«resourceBase(it)»
	«IF gapClass»
		«resourceSubclass(it)»
	«ENDIF»
	'''
}

def static String resourceBase(Resource it) {
	'''
	'''
	fileOutput(javaFileName(getRestPackage() + "." + name + (gapClass ? "Base" : "")), '''
	«javaHeader()»
	package «getRestPackage()»;

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
	public «IF gapClass»abstract «ENDIF»class «name»«IF gapClass»Base«ENDIF» «^extendsLitteral()» {

		public «name»«IF gapClass»Base«ENDIF»() {
		}
		
		«IF isServiceContextToBeGenerated()»
		«serviceContext(it)»
		«ENDIF»
		
		«initBinder(it)»
		
		«delegateServices(it) »
			
		«it.operations.reject(op | op.isImplementedInGapClass()).forEach[resourceMethod(it)]»
		
		«it.operations.filter(op | op.isImplementedInGapClass()) .forEach[resourceAbstractMethod(it)]»
		
		«it.operations.filter(e|e.httpMethod == HttpMethod::POST || e.httpMethod == HttpMethod::PUT).forEach[resourceMethodFromForm(it)]»
		
		«handleExceptions(it)»
		
		«resourceHook(it) FOR this»
	}
	'''
	)
	'''
	'''
}

def static String resourceSubclass(Resource it) {
	'''
	'''
	fileOutput(javaFileName(getRestPackage() + "." + name), 'TO_SRC', '''
	«javaHeader()»
	package «getRestPackage()»;

/**
 * Implementation of «name».
 */
	«springControllerAnnotation(it)»
	public class «name» ^extends «name»Base {

		public «name»() {
		}

		«it.operations.filter(op | op.isImplementedInGapClass()) .forEach[resourceMethod(it)]»

	}
	'''
	)
	'''
	'''
}

def static String initBinder(Resource it) {
	'''
	«val primaryDomainObject = it.operations.filter(e|e.httpMethod == HttpMethod::GET && e.domainObjectType != null).collect(e|e.domainObjectType).first()»
	@org.springframework.web.bind.annotation.InitBinder
		protected void initBinder(org.springframework.web.bind.WebDataBinder binder) throws Exception {
			binder.registerCustomEditor(String.class, new org.springframework.beans.propertyeditors.StringTrimmerEditor(false));
			«IF isJpaProviderAppEngine() && primaryDomainObject != null»
				binder.registerCustomEditor(com.google.appengine.api.datastore.Key.class, new «primaryDomainObject.name»IdKeyEditor());
			«ENDIF»
		}
		
	    «IF isJpaProviderAppEngine() && primaryDomainObject != null»
	    	«gaeKeyIdPropertyEditor(it) FOR primaryDomainObject»
	    «ENDIF»
	'''
}

def static String gaeKeyIdPropertyEditor(DomainObject it) {
	'''
		private static class «name»IdKeyEditor ^extends java.beans.PropertyEditorSupport {
			@Override
			public void setAsText(String text) {
				if (text == null) {
				    setValue(null);
				} else {
				    com.google.appengine.api.datastore.Key key = com.google.appengine.api.datastore.KeyFactory.createKey(
				    	«getDomainPackage()».«name».class.getSimpleName(), Long.valueOf(text));
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

def static String serviceContext(Resource it) {
	'''
		protected «fw("errorhandling.ServiceContext")» serviceContext() {
			return «fw("errorhandling.ServiceContextStore")».get();
		}
	'''
}

def static String springControllerAnnotation(Resource it) {
	'''
	@org.springframework.stereotype.Controller
	'''
}

def static String delegateServices(Resource it) {
	'''
	«FOR delegateService  : getDelegateServices()»
			@org.springframework.beans.factory.annotation.Autowired
			private «getServiceapiPackage(delegateService)».«delegateService.name» «delegateService.name.toFirstLower()»;

			protected «getServiceapiPackage(delegateService)».«delegateService.name» get«delegateService.name»() {
				return «delegateService.name.toFirstLower()»;
			}
		«ENDFOR»
	'''
}

def static String resourceMethod(ResourceOperation it) {
	'''
	«IF formatJavaDoc() == "" »
	«formatJavaDoc()»
	«ELSEIF delegate != null »
		/**
			* Delegates to {@link «getServiceapiPackage(delegate.service)».«delegate.service.name»#«delegate.name»}
			*/
		«ENDIF »
		«resourceMethodAnnotation(it)(false)»
		«resourceMethodSignature(it)» {
		«IF isImplementedInGapClass() »
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

def static String resourceMethodSignature(ResourceOperation it) {
	'''
	«getVisibilityLitteral()» «IF returnString != null»String«ELSE»«getTypeName()»«ENDIF» «name»(«it.parameters SEPARATOR ", ".forEach[annotatedParamTypeAndName(it)(this, false)]») « EXPAND ExceptionTmpl::throws»
	'''
}

def static String resourceMethodFromForm(ResourceOperation it) {
	'''
	«IF !hasHint("headers") || (getHint("headers") != "content-type=application/x-www-form-urlencoded")»
		/**
			* This method is needed for form data «httpMethod.toString()». Delegates to {@link #«name»}
			*/
		«resourceMethodAnnotation(it)(true)»
		«getVisibilityLitteral()» «IF returnString != null»String«ELSE»«getTypeName()»«ENDIF» «name»FromForm(«it.parameters SEPARATOR ",".forEach[annotatedParamTypeAndName(it)(this, true)]») « EXPAND ExceptionTmpl::throws» {
			«IF returnString != null || getTypeName() != "void"»return «ENDIF»«name»(«FOR p SEPARATOR ", " : parameters»«p.name»«ENDFOR»);
		}
		«ENDIF»
	'''
}

def static String resourceMethodHandWritten(ResourceOperation it) {
	'''
	«val postOperation = it.resource.operations.selectFirst(e | e.httpMethod == HttpMethod::POST)»
	«val putOperation = it.resource.operations.selectFirst(e | e.httpMethod == HttpMethod::PUT)»
	«val modelMapParam = it.parameters.selectFirst(e|e.type == "ModelMap")»
	«IF name == "createForm" && returnString != null && modelMapParam != null && postOperation != null»
		«resourceCreateFormMethodHandWritten(it)(modelMapParam, postOperation)»
	«ELSEIF name == "updateForm" && returnString != null && modelMapParam != null»
		«resourceUpdateFormMethodHandWritten(it)(modelMapParam, putOperation)»
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

def static String resourceCreateFormMethodHandWritten(ResourceOperation it, Parameter modelMapParam, ResourceOperation postOperation) {
	'''
	«val firstParam = it.postOperation.parameters.first()»
		«IF firstParam.domainObjectType != null »
			«firstParam.domainObjectType.getDomainPackage()».«firstParam.domainObjectType.name» «firstParam.name» = new «firstParam.domainObjectType.getDomainPackage()».«firstParam.domainObjectType.name»(); 
			«modelMapParam.name».addAttribute("«firstParam.name»", «firstParam.name»);
		«ENDIF»
		return "«returnString»";
	'''
}

def static String resourceUpdateFormMethodHandWritten(ResourceOperation it, Parameter modelMapParam, ResourceOperation putOperation) {
	'''
	«val firstParam  = it.putOperation.parameters.first()»
	«LET resource.operations .selectFirst(e | e.httpMethod == HttpMethod::GET && e.domainObjectType != null && e.domainObjectType == firstParam.domainObjectType && e.type == null && e.collectionType == null)
		AS getOperation »
	«val findByIdOperation  = it.getOperation.delegate»
			«IF findByIdOperation == null »
				// TODO: can't update due to no matching findById method in service
			«ELSE »
				«findByIdOperation.getTypeName()» «firstParam.name» =
				get«findByIdOperation.service.name»().«findByIdOperation.name»(«FOR parameter SEPARATOR ", " : findByIdOperation.parameters»«IF parameter.getTypeName() == serviceContextClass()
					»serviceContext()«ELSE»«parameter.name»«ENDIF»«ENDFOR»);
				«modelMapParam.name».addAttribute("«firstParam.name»", «firstParam.name»);
			«ENDIF »
			return "«returnString»";
	'''
}



def static String resourceMethodValidation(ResourceOperation it) {
	'''
	'''
}

def static String resourceMethodDelegation(ResourceOperation it) {
	'''
	«IF httpMethod == HttpMethod::DELETE && path.contains("{id}") && parameters.notExists(e|e.name == "id") && parameters.exists(e | e.domainObjectType != null) »
		«resourceMethodDeleteDelegation(it)»
	«ELSE »
		«IF delegate.getTypeName() != "void"»«delegate.getTypeName()» result = «ENDIF»
	    	«delegate.service.name.toFirstLower()».«delegate.name»(«FOR parameter SEPARATOR ", " : delegate.parameters»«IF parameter.getTypeName() == serviceContextClass()
	            	»serviceContext()«ELSE»«parameter.name»«ENDIF»«ENDFOR»);
		«ENDIF»
	'''
}

def static String resourceMethodDeleteDelegation(ResourceOperation it) {
	'''
		«val findByIdOperation - = it.delegate.service.operations.filter(e|e.domainObjectType != null && e.collectionType == null && e.parameters.exists(p|p.type == e.domainObjectType.getIdAttributeType())).first() »
			«IF findByIdOperation == null »
				// TODO: can't delete due to no matching findById method in service
			«ELSE »
				«findByIdOperation.getTypeName()» deleteObj =
				«delegate.service.name.toFirstLower()».«findByIdOperation.name»(«FOR parameter SEPARATOR ", " : findByIdOperation.parameters»«IF parameter.getTypeName() == serviceContextClass()
					»serviceContext()«ELSE»«parameter.name»«ENDIF»«ENDFOR»);
				«delegate.service.name.toFirstLower()».«delegate.name»(«FOR parameter SEPARATOR ", " : delegate.parameters»«IF parameter.getTypeName() == serviceContextClass()
					»serviceContext()«ELSE»deleteObj«ENDIF»«ENDFOR»);
			«ENDIF »
	'''
}

def static String resourceMethodReturn(ResourceOperation it) {
	'''
	«IF returnString != null && returnString.contains("{id}")»
			return String.format("«returnString.replacePlaceholder("{id}", "%s") »", result.getId()«IF isJpaProviderAppEngine()».getId()«ENDIF»);
		«ELSEIF returnString != null»
			return "«returnString»";
		«ELSEIF getTypeName() != "void"»
			return result;
		«ENDIF»
	'''
}

def static String resourceMethodModelMapResult(ResourceOperation it) {
	'''
	«val modelMapParam = it.parameters.selectFirst(e|e.type == "ModelMap")»
		«IF modelMapParam != null && delegate.getTypeName() != "void"»
			«modelMapParam.name».addAttribute("result", result);
		«ENDIF»
	'''
}

def static String resourceAbstractMethod(ResourceOperation it) {
	'''
		/* 
		«resourceMethodAnnotation(it)(false) »
		«resourceMethodSignature(it)» */
	«getVisibilityLitteral()» abstract «IF returnString != null»String«ELSE»«getTypeName()»«ENDIF» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]») « EXPAND ExceptionTmpl::throws»;
	'''
}

def static String resourceMethodAnnotation(ResourceOperation it, boolean formDataHeader) {
	'''@org.springframework.web.bind.annotation.RequestMapping(value = "«path»", method=org.springframework.web.bind.annotation.RequestMethod.«httpMethod.toString()»«
	IF formDataHeader», headers = "content-type=application/x-www-form-urlencoded"«ELSEIF hasHint("headers")», headers = "«getHint("headers")»"«ENDIF»« IF hasHint("params")», params = "«getHint("params")»"«ENDIF»)«
	ENDDEFINE»

def static String generatedName(ResourceOperation it) {
	'''
	«IF returnString != null»"«getHint('return')»"«ELSE»""«ENDIF»
	'''
}

def static String paramTypeAndName(Parameter it) {
	'''
	«getTypeName()» «name»
	'''
}

/*Must format this carefully because it is included in comment */
def static String annotatedParamTypeAndName(Parameter it, ResourceOperation op, boolean formData) {
	'''« IF op.httpMethod == HttpMethod::DELETE && domainObjectType != null && domainObjectType.getIdAttribute() != null && op.path.contains("{id}")
	»@org.springframework.web.bind.annotation.PathVariable("id") «domainObjectType.getIdAttributeType()» id« ELSE
	»«IF op.path.contains("{" + name + "}") »@org.springframework.web.bind.annotation.PathVariable("«name»") «
	ELSEIF formData && domainObjectType != null
	»@org.springframework.web.bind.annotation.ModelAttribute("«name»") « ELSEIF domainObjectType != null
	»@org.springframework.web.bind.annotation.RequestBody « ELSEIF isRestRequestParameter()
	»@org.springframework.web.bind.annotation.RequestParam("«name»") « ENDIF
	»«getTypeName()» «name»« ENDIF
»	'''
}

def static String handleExceptions(Resource it) {
	'''
	«val allExceptions = it.operations.filter(e | e.throws != null).collect(e | e.getExceptions()).flatten().toSet()»
		«it.allExceptions.filter(e|e.endsWith("NotFoundException")).forEach[handleNotFoundException(it)]»
	«handleIllegalArgumentException(it) FOR "java.lang.IllegalArgumentException"»
	«handleIllegalArgumentException(it) FOR fw("errorhandling.ValidationException")»
	«handleSystemException(it) FOR fw("errorhandling.SystemException")»
	«IF operations.exists(e | e.httpMethod == HttpMethod::POST || e.httpMethod == HttpMethod::PUT || e.httpMethod == HttpMethod::DELETE)»
		«handleOptimisticLockingException(it) FOR fw("errorhandling.OptimisticLockingException")»
	«ENDIF»
	'''
}

def static String handleNotFoundException(String it) {
	'''
		@org.springframework.web.bind.annotation.ExceptionHandler
		public void handleException(«this» e, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
			response.sendError(org.springframework.http.HttpStatus.NOT_FOUND.value(), e.getMessage());
		}
	'''
}

def static String handleOptimisticLockingException(String it) {
	'''
		@org.springframework.web.bind.annotation.ExceptionHandler
		public void handleException(«this» e, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
			response.sendError(org.springframework.http.HttpStatus.CONFLICT.value(), e.getMessage());
		}
	'''
}

def static String handleIllegalArgumentException(String it) {
	'''
		@org.springframework.web.bind.annotation.ExceptionHandler
		public void handleException(«this» e, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
			response.sendError(org.springframework.http.HttpStatus.BAD_REQUEST.value(), e.getMessage());
		}
	'''
}

def static String handleSystemException(String it) {
	'''
		@org.springframework.web.bind.annotation.ExceptionHandler
		public void handleException(«this» e, javax.servlet.http.HttpServletResponse response) throws java.io.IOException {
			response.sendError(org.springframework.http.HttpStatus.SERVICE_UNAVAILABLE.value(), e.getMessage());
		}
	'''
}


/*Extension point to generate more stuff in service implementation.
	User AROUND ResourceTmpl::resourceHook FOR Resource
	in SpecialCases.xpt */
def static String resourceHook(Resource it) {
	'''
	'''
}
}
