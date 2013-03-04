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

package org.sculptor.generator.template.repository

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class AccessObjectTmpl {

def static String command(RepositoryOperation it) {
	'''
		«commandInterface(it)»
		«commandImpl(it)»
	'''
}


def static String commandInterface(RepositoryOperation it) {
	'''
	'''
	fileOutput(javaFileName(getAccessapiPackage(repository.aggregateRoot.module) + "." + getAccessObjectName()), '''
	«javaHeader()»
	package «getAccessapiPackage(repository.aggregateRoot.module)»;

	«IF formatJavaDoc() == "" »
/**
 * <p>
 * Access object for «repository.name».«name».
 * </p>
 * <p>
 * Command design pattern. Set input parameters with the
 * setter methods. {@link #execute Execute}
 * the command«IF getTypeName() != "void"» and retrieve the {@link #getResult result}«ENDIF».
 * </p>
 *
 */
	«ELSE »
	«formatJavaDoc()»
	«ENDIF »
	public interface «getAccessObjectName()» «IF getAccessObjectInterfaceExtends() != ''» ^extends «getAccessObjectInterfaceExtends()» «ENDIF»{

		«it.parameters.reject(e|e.isPagingParameter()).forEach[interfaceParameterSetter(it)]»

		void execute() «ExceptionTmpl::throws(it)»;

		«IF getTypeName() != "void"»
		/**
			* The result of the command.
			*/
		«getAccessObjectResultTypeName()» getResult();
		«ENDIF»

	}
	'''
	)
	'''
	'''
}

def static String interfaceParameterSetter(Parameter it) {
	'''

		void set«name.toFirstUpper()»(«getTypeName()» «name»);
	'''
}

def static String commandImpl(RepositoryOperation it) {
	'''
		«commandImplBase(it)»
		«commandImplSubclass(it)»
	'''
}

def static String commandImplBase(RepositoryOperation it) {
	'''
	'''
	fileOutput(javaFileName(getAccessimplPackage(repository.aggregateRoot.module) + "." + getAccessObjectName() + "ImplBase"), '''
	«javaHeader()»
	package «getAccessimplPackage(repository.aggregateRoot.module)»;

/**
 * <p>
 * Generated base class for implementation of Access object for «repository.name».«name».
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 *
 */
	public abstract class «getAccessObjectName()»ImplBase ^extends «getAccessBase()»
	implements «getAccessapiPackage(repository.aggregateRoot.module)».«getAccessObjectName()» {

	«IF jpa()»
		«IF isSpringToBeGenerated() »
			«IF isJpaProviderHibernate()»
				«jpaHibernateTemplate(it)»
			«ENDIF»
			«jpaTemplate(it)»
		«ENDIF»
	«ENDIF»
	
		«it.parameters.reject(e|e.isPagingParameter()).forEach[parameterAttribute(it)]»

		«IF getTypeName() != "void"»
		private «getAccessObjectResultTypeName()» result;
		«ENDIF»

		«it.parameters.reject(e|e.isPagingParameter()).forEach[parameterAccessors(it)]»

	«IF hasPagingParameter()»
		«pageableProperties(it)»
	«ENDIF»

		«IF !getExceptions().isEmpty»
		public void execute() «ExceptionTmpl::throws(it)» {
			try {
				super.execute();
			«FOR exc : getExceptions()»
			} catch («exc» e) {
				throw e;
			«ENDFOR»
			} catch («applicationExceptionClass()» e) {
				// other ApplicationException not expected, wrap it in a RuntimeException
				throw new RuntimeException(e);
			}
		}
		«ENDIF»

		«IF getTypeName() != "void"»
		/**
			* The result of the command.
			*/
		public «getAccessObjectResultTypeName()» getResult() {
			return this.result;
		}

		protected void setResult(«getAccessObjectResultTypeName()» result) {
			this.result = result;
		}
		«ENDIF»

	}
	'''
	)
	'''
	'''
}

def static String pageableProperties(RepositoryOperation it) {
	'''
		private int firstResult = -1;
		private int maxResult = 0;

		protected int getFirstResult() {
			return firstResult;
		}

		public void setFirstResult(int firstResult) {
			this.firstResult = firstResult;
		}

		protected int getMaxResult() {
			return maxResult;
		}

		public void setMaxResult(int maxResult) {
			this.maxResult = maxResult;
		}
	'''
}

def static String jpaTemplate(RepositoryOperation it) {
	'''
		private org.springframework.orm.jpa.JpaTemplate jpaTemplate;
		
		/**
			* creates the JpaTemplate to be used in AccessObject for convenience
			*
			* @return Spring JpaTemplate
			*/
		protected org.springframework.orm.jpa.JpaTemplate getJpaTemplate() {
			if (jpaTemplate == null) {
				jpaTemplate = new org.springframework.orm.jpa.JpaTemplate(getEntityManager());
			}
			return jpaTemplate;
		}
	'''
}

def static String jpaHibernateTemplate(RepositoryOperation it) {
	'''
		private org.springframework.orm.hibernate3.HibernateTemplate hibernateTemplate;
		
		/**
			* creates the HibernateTemplate to be used in AccessObject for convenience
			*
			* @return Spring HibernateTemplate
			*/
		protected org.springframework.orm.hibernate3.HibernateTemplate getHibernateTemplate() {
			if (hibernateTemplate == null) {
				hibernateTemplate = new org.springframework.orm.hibernate3.HibernateTemplate(
				    «fw("accessimpl.jpahibernate.HibernateSessionHelper")».getHibernateSession(getEntityManager()).getSessionFactory());
			}
			return hibernateTemplate;
		}
	'''
}

def static String commandImplSubclass(RepositoryOperation it) {
	'''
	'''
	fileOutput(javaFileName(getAccessimplPackage(repository.aggregateRoot.module) + "." + getAccessObjectName() + "Impl"), 'TO_SRC', '''
	«javaHeader()»
	package «getAccessimplPackage(repository.aggregateRoot.module)»;

/**
 * Implementation of Access object for «repository.name».«name».
 *
 */
	public class «getAccessObjectName()»Impl ^extends «getAccessObjectName()»ImplBase {

			«performExecute(it)»

	}
	'''
	)
	'''
	'''
}

def static String performExecute(RepositoryOperation it) {
	'''
	public void performExecute() «ExceptionTmpl::throws(it)» {
			// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«getAccessObjectName()»Impl not implemented");
		}
	'''
}

def static String parameterAttribute(Parameter it) {
	'''
		private «getTypeName()» «name»;
	'''
}

def static String parameterAccessors(Parameter it) {
	'''
		«parameterGetter(it)»
		«parameterSetter(it)»
	'''
}

def static String parameterGetter(Parameter it) {
	'''
		public «getTypeName()» get«name.toFirstUpper()»() {
			return «name»;
		};
	'''
}

def static String parameterSetter(Parameter it) {
	'''
		public void set«name.toFirstUpper()»(«getTypeName()» «name») {
			this.«name» = «name»;
		};
	'''
}

}
