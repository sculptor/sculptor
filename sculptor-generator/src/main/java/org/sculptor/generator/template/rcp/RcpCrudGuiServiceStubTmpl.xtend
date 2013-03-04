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

class RcpCrudGuiServiceStubTmpl {



def static String serviceStub(GuiApplication it) {
	'''
	«val allUsedServices = it.groupByTarget().getUsedServices().toSet().typeSelect(Service)»
	«it.allUsedServices.forEach[serviceStub(it)]»
	«it.allUsedServices .filter(e | isGapClassToBeGenerated(e.module.name, e.name + "Stub")).forEach[gapServiceStub(it)]»
	'''
} 

def static String gapServiceStub(Service it) {
	'''
	«val className = it.name + "Stub"»
	'''
	fileOutput(javaFileName(module.getServicestubPackage() + "." + className), 'TO_SRC', '''
	«javaHeader()»
	package «module.getServicestubPackage()»;

	«serviceStubSpringAnnotation(it)»
	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String serviceStub(Service it) {
	'''
	«val className = it.name + "Stub" + gapSubclassSuffix(module, name + "Stub")»
	'''
	fileOutput(javaFileName(module.getServicestubPackage() + "." + className) , '''
	«javaHeader()»
	package «module.getServicestubPackage()»;

	«IF !className.endsWith("Base")»
	«serviceStubSpringAnnotation(it)»
	«ENDIF»
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» implements «getServiceapiPackage()».«name» {

	«serviceStubConstructor(it)»
	«serviceStubInitialize(it)»
	«serviceStubMap(it)»
	
	«it.operations.filter(e|e.isListStubOperation()).forEach[listStubOperation(it)]»
	«it.operations.filter(e|e.isPagedStubOperation()).forEach[pagedStubOperation(it)]»
	«it.operations.filter(e|e.isSaveStubOperation()).forEach[saveStubOperation(it)]»
	«it.operations.filter(e|e.isDeleteStubOperation()).forEach[deleteStubOperation(it)]»
	«it.operations.filter(e|e.isFindByIdStubOperation()).forEach[findByIdStubOperation(it)]»
	«it.operations.filter(e|e.isPopulateStubOperation()).forEach[populateStubOperation(it)]»
	«notImplementedOperation(it) FOREACH operations.filter(op | op.isPublicVisibility()). reject(op | op.isListStubOperation() || op.isPagedStubOperation() || op.isSaveStubOperation() || 
			op.isDeleteStubOperation() || op.isFindByIdStubOperation() || op.isPopulateStubOperation()) »
	
	«serviceStubGetId(it)»
	«serviceStubSetId(it)»

	}
	'''
	)
	'''
	'''
}

def static String serviceStubSpringAnnotation(Service it) {
	'''
	@org.springframework.stereotype.Service("«name.toFirstLower()»")
	'''
}


def static String serviceStubConstructor(Service it) {
	'''
	«val className = it.name + "Stub" + gapSubclassSuffix(module, name + "Stub")»
		public «className»() {
			initialize();
		}
	'''
}

def static String serviceStubMap(Service it) {
	'''
		private java.util.Map<String, Object> all = new java.util.concurrent.ConcurrentHashMap<String, Object>();
		protected java.util.Map<String, Object> getAllStubObjects() {
			return all;
		}
	'''
}

def static String serviceStubInitialize(Service it) {
	'''
		protected void initialize() {
			java.util.Set<«Object»> initial = new java.util.HashSet<«Object»>();
			populateInitial(initial);
			for (Object each : initial) {
				if (internalGetId(each) == null) {
					internalSetId(each, idSequence.incrementAndGet());
				}
				this.all.put(each.getClass().getSimpleName() + "#" + internalGetId(each), each);
			}
		}
		
		/**
			* Override this in sub class and add initial objects to the parameter
			*/
		protected void populateInitial(java.util.Set<Object> all) {
		}
	'''
}

def static String listStubOperation(ServiceOperation it) {
	'''
		@SuppressWarnings("unchecked")
		public «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[ServiceTmpl::paramTypeAndName(it)]») « EXPAND templates::common::Exception::throws» {
			return new java.util.ArrayList(this.all.values());
		}
	'''
}

def static String pagedStubOperation(ServiceOperation it) {
	'''
		@SuppressWarnings("unchecked")
		public «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[ServiceTmpl::paramTypeAndName(it)]») « EXPAND templates::common::Exception::throws» {
			return new «getTypeName()»(new java.util.ArrayList(this.all.values()), 0, 100, 100);
		}
	'''
}

def static String saveStubOperation(ServiceOperation it) {
	'''
		public «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[ServiceTmpl::paramTypeAndName(it)]») « EXPAND templates::common::Exception::throws» {
			if («stubOperationParameter().name».getId() == null) {
				internalSetId(«stubOperationParameter().name», idSequence.incrementAndGet());
			}
			this.all.put("«stubOperationParameter().domainObjectType.name»#" + «stubOperationParameter().name».getId(), «stubOperationParameter().name»);
			«IF domainObjectType != null »
				return «stubOperationParameter().name»;
			«ENDIF»
		}
	'''
}

def static String deleteStubOperation(ServiceOperation it) {
	'''
		public «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[ServiceTmpl::paramTypeAndName(it)]») « EXPAND templates::common::Exception::throws» {
			this.all.remove("«stubOperationParameter().domainObjectType.name»#" + «stubOperationParameter().name».getId());
		}
	'''
}

def static String findByIdStubOperation(ServiceOperation it) {
	'''
		public «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[ServiceTmpl::paramTypeAndName(it)]») « EXPAND templates::common::Exception::throws» {
			«domainObjectType.getDomainPackage()».«domainObjectType.name» found = («domainObjectType.getDomainPackage()».«domainObjectType.name») this.all.get(
				"«domainObjectType.name»#" + «stubOperationParameter().name»);
			if (found == null) {
				«IF getExceptions().isEmpty»
				throw new IllegalArgumentException("«domainObjectType.name» not found for id: " + «stubOperationParameter().name»);
				«ELSE»
				throw new «getExceptions().toList().first()»("«domainObjectType.name» not found for id: " + «stubOperationParameter().name»);
				«ENDIF»
			}
			return found;
		}
	'''
}

def static String populateStubOperation(ServiceOperation it) {
	'''
	«val entityParam = it.stubOperationParameter()»
		public «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[ServiceTmpl::paramTypeAndName(it)]») « EXPAND templates::common::Exception::throws» {
			try {
			«FOR ref : domainObjectType.references»
				«entityParam.name».get«ref.name.toFirstUpper()»();
			«ENDFOR»
			} catch (RuntimeException asExpected) {}
			
			«FOR ref : domainObjectType.references»
				«entityParam.name».get«ref.name.toFirstUpper()»();
			«ENDFOR»
			
			return entity;
		}
	'''
}

def static String notImplementedOperation(ServiceOperation it) {
	'''
		public «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[ServiceTmpl::paramTypeAndName(it)]») « EXPAND templates::common::Exception::throws» {
			throw new UnsupportedOperationException("«name» not implemented in stub");
		}
	'''
}

def static String serviceStubGetId(Service it) {
	'''
		private java.io.Serializable internalGetId(Object domainObject) {
			if (org.apache.commons.beanutils.PropertyUtils.isReadable(domainObject, "id")) {
				try {
				    return (java.io.Serializable) org.apache.commons.beanutils.PropertyUtils.getProperty(domainObject, "id");
				} catch (Exception e) {
				    throw new IllegalArgumentException("Can't get id property of domainObject: " + domainObject);
				} 
			} else {
				// no id property, don't know if it is new
				throw new IllegalArgumentException("No id property in domainObject: " + domainObject);
			}
		}
	'''
}

def static String serviceStubSetId(Service it) {
	'''
		private java.util.concurrent.atomic.AtomicLong idSequence = new java.util.concurrent.atomic.AtomicLong(100L);

		protected void internalSetId(Object domainObject, Long id) {
			try {
				java.lang.reflect.Field field = findIdField(domainObject.getClass());
				field.setAccessible(true);
				field.set(domainObject, id);
			} catch (Exception e) {
				throw new IllegalArgumentException(
				    "Can't get id field of domainObject: " + domainObject);
			}
		}

	private java.lang.reflect.Field findIdField(Class<?> clazz) throws NoSuchFieldException {
		try {
			return clazz.getDeclaredField("id");
		} catch (NoSuchFieldException e) {
			if (clazz.getSuperclass() == null) {
				throw e;
			} else {
				return findIdField(clazz.getSuperclass());
			}
		}
	}
	'''
}

}
