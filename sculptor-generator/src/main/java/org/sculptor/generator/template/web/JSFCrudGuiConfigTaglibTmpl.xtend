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

class JSFCrudGuiConfigTaglibTmpl {



def static String appTaglib(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/generated/config/application.taglib.xml", 'TO_GEN_WEBROOT', '''
	«appTaglibContent(it)»
	'''
	)
	'''
	'''
}

def static String appTaglibContent(GuiApplication it) {
	'''
	<?xml version="1.0" encoding="iso-8859-1"?>
	<!DOCTYPE facelet-taglib PUBLIC "-//Sun Microsystems, Inc.//DTD Facelet Taglib 1.0//EN" "facelet-taglib_1_0.dtd">
	<facelet-taglib>
	<namespace>ApplicationTaglib</namespace>
	«breadCrumb(it)»
	«isOfType(it)»
	«resolveSystemExceptionErrorCode(it)»
	«resolveSystemExceptionMessage(it)»
	«dateConverter(it)»
		«IF getDateTimeLibrary() == "joda"»
		«localDateConverter(it)»
		«dateTimeConverter(it)»
		«ENDIF»
	</facelet-taglib>
	'''
}

def static String breadCrumb(GuiApplication it) {
	'''
	<function>
		<function-name>breadCrumb</function-name>
			<function-class>«basePackage».util.web.«name»Functions</function-class>
			<function-signature>java.util.List breadCrumb(org.springframework.webflow.execution.FlowExecutionContext,java.util.PropertyResourceBundle)</function-signature>
	</function>
	'''
}

def static String isOfType(GuiApplication it) {
	'''
	<function>
		<function-name>isOfType</function-name>
			<function-class>«basePackage».util.web.«name»Functions</function-class>
			<function-signature>boolean isOfType(java.lang.Object,java.lang.String)</function-signature>
	</function>
	'''
}

def static String resolveSystemExceptionErrorCode(GuiApplication it) {
	'''
	<function>
		<function-name>resolveSystemExceptionErrorCode</function-name>
			<function-class>«fw("web.errorhandling.ExceptionUtil")»</function-class>
			<function-signature>String resolveSystemExceptionErrorCode(java.lang.Throwable)</function-signature>
	</function>
	'''
}

def static String resolveSystemExceptionMessage(GuiApplication it) {
	'''
	<function>
		<function-name>resolveSystemExceptionMessage</function-name>
			<function-class>«fw("web.errorhandling.ExceptionUtil")»</function-class>
			<function-signature>String resolveSystemExceptionMessage(java.lang.Throwable)</function-signature>
	</function>
	'''
}

def static String dateConverter(GuiApplication it) {
	'''
	<tag>
		<tag-name>dateConverter</tag-name>
		<converter>
				<converter-id>DateConverter</converter-id>
			</converter>
		</tag>
	'''
}

def static String localDateConverter(GuiApplication it) {
	'''
		<tag>
		<tag-name>localDateConverter</tag-name>
		<converter>
				<converter-id>LocalDateConverter</converter-id>
			</converter>
		</tag>
	'''
}

def static String dateTimeConverter(GuiApplication it) {
	'''
		<tag>
		<tag-name>dateTimeConverter</tag-name>
		<converter>
				<converter-id>DateTimeConverter</converter-id>
			</converter>
		</tag>
	'''
}
}
