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

package org.sculptor.generator.template.common

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Module
import sculptormetamodel.Operation

class ExceptionTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties

	def String applicationExceptions(Module it) {
		val webServiceExceptions = it.getAllGeneratedWebServiceExceptions()
		'''
		«FOR exc : it.getAllGeneratedExceptions().filter[e | !webServiceExceptions.contains(e)]»
			«applicationException(it, exc)»
		«ENDFOR»
		«FOR exc : webServiceExceptions»
			«webServiceApplicationException(it, exc)»
		«ENDFOR»
		'''
	}
	
	def String applicationException(Module it, String exceptionName) {
		fileOutput(javaFileName(it.getExceptionPackage() + "." + exceptionName), OutputSlot::TO_GEN_SRC, '''
		«javaHeader()»
		package «it.getExceptionPackage()»;

		public class «exceptionName» extends «applicationExceptionClass()» {
		«serialVersionUID(it) »
			private static final String CLASS_NAME = «exceptionName».class.getSimpleName();
			private static final String CLASS_FULL_NAME = «exceptionName».class.getName();

			public «exceptionName»(String m, java.io.Serializable... messageParameter) {
				super(«getProperty("exception.code.format")», m);
				setMessageParameters(messageParameter);
			}

			public «exceptionName»(«it.errorCodeType()» errorCode, String m, java.io.Serializable... messageParameter) {
				super(«getProperty("exception.code.formatWithParam")», m);
				setMessageParameters(messageParameter);
			}
		}
		'''
		)
	}
	
	
	def String webServiceApplicationException(Module it, String exceptionName) {
		fileOutput(javaFileName(it.getExceptionPackage() + "." + exceptionName), OutputSlot::TO_GEN_SRC, '''
		«javaHeader()»
		package «it.getExceptionPackage()»;

		public class «exceptionName» extends Exception {
		«serialVersionUID(it) »
			public static final String ERROR_CODE = «exceptionName».class.getName();
			private String errorCode;

			public «exceptionName»(String m) {
				super(m);
				this.errorCode = ERROR_CODE;
			}
			
			public «exceptionName»(String m, java.io.Serializable... messageParameters) {
				super(m + formatMessageParameters(messageParameters));
				this.errorCode = ERROR_CODE;
			}
			
			public String getErrorCode() {
				return errorCode;
			}
				
			private static String formatMessageParameters(java.io.Serializable[] messageParameters) {
				if (messageParameters == null || messageParameters.length == 0) {
					return "";
				}
				StringBuilder buf = new StringBuilder();
				buf.append(" (");
				for (int i = 0; i < messageParameters.length; i++) {
					if (i != 0) {
					    buf.append(";");
					}
					buf.append(messageParameters[i]);
				}
				buf.append(")");
				return buf.toString();
			}
			

		}
		'''
		)
	}
	
	
	def String throwsDecl(Operation it) {
		'''
			«IF !(it.getThrows() != null && it.getThrows().isEmpty)»throws «FOR exc : it.exceptions SEPARATOR ", "»«exc»«ENDFOR»«ENDIF»
		'''
	}
	
	def String serialVersionUID(Object it) {
		'''
			private static final long serialVersionUID = 1L;
		'''
	}

}
