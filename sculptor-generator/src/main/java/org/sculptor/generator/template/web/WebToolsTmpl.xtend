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

class WebToolsTmpl {


def static String webTools(GuiApplication it) {
	'''
	«tagFunctions(it)»
	'''
}

def static String tagFunctions(GuiApplication it) {
	'''
	«functionsJava(it)»
	«functionsTagDef(it)»
	'''
}

def static String functionsJava(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(this.basePackage + ".util." + subPackage("web") + "." + name + "Functions") , '''
	«javaHeader()»
	package «basePackage».util.«subPackage("web")»;
	public class «name»Functions {
	«isOfTypeMethod(it) »
	«isNullMethod(it) »
	«isNotNullMethod(it) »
	«breadCrumbMethod(it) »
	«breadCrumbInnerClass(it)»
	«breadCrumbFactoryMethod(it)»
	}
	'''
	)
	'''
	'''
}

def static String isOfTypeMethod(GuiApplication it) {
	'''
		@SuppressWarnings("unchecked")
		public static boolean isOfType(Object domainObject, String type) {
			if (domainObject == null) {
				return false;
			}
			if (type == null) {
				throw new IllegalArgumentException("Unspecified class name.");
			}
			try {
				Class typeClass = Class.forName(type);
			
				return typeClass.isAssignableFrom(domainObject.getClass());
			} catch (ClassNotFoundException e) {
				throw new IllegalArgumentException("Invalid class name: " + type);
			}
		}
	'''
}

def static String isNullMethod(GuiApplication it) {
	'''
	public static boolean isNull(Object obj) {
	    return obj == null;
	}
	'''
}

def static String isNotNullMethod(GuiApplication it) {
	'''
	public static boolean isNotNull(Object obj) {
	    return !isNull(obj);
	}
	'''
}

def static String breadCrumbMethod(GuiApplication it) {
	'''
		public static java.util.List breadCrumb(org.springframework.webflow.execution.FlowExecutionContext ctx) {
			List<BreadCrumbElement> breadCrumbList = new java.util.ArrayList<BreadCrumbElement>(); 
			if (ctx == null || !ctx.isActive()) {
				return breadCrumbList;
			}
			org.springframework.webflow.execution.FlowSession flowSession = ctx.getActiveSession();
			if (flowSession == null) {
				return breadCrumbList;
			}
			while (flowSession != null) {
				breadCrumbList.add(createBreadCrumbElement(flowSession.getDefinition()));
				// continue with parent flow, if there is any parent
				flowSession = flowSession.getParent();
			}
			
			java.util.Collections.reverse(breadCrumbList);
			
			return breadCrumbList;
		}
	'''
}

def static String functionsTagDef(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/tld/" + name + "Functions.tld", 'TO_GEN_WEBROOT', '''
	<?xml version="1.0" encoding="UTF-8" ?>
	<taglib xmlns="http://java.sun.com/xml/ns/j2ee"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee web-jsptaglibrary_2_0.xsd"
	version="2.0">
	<description>A tag library that defines static functions for the «name» application.</description>
	<tlib-version>1.0</tlib-version>
	<short-name>«name»FunctionTagLibrary</short-name>
	<uri>/«name»FunctionLibrary</uri>
	«tagIsOfTypeFunction(it)»
	«tagIsNullFunction(it)»
	«tagIsNotNullFunction(it)»
	«tagBreadCrumbFunction(it)»
	</taglib>
	'''
	)
	'''
	'''
}

def static String tagIsOfTypeFunction(GuiApplication it) {
	'''
	<function>
		<name>isOfType</name>
		<function-class>
			«basePackage + ".util." + subPackage("web") + "." + name + "Functions"»</function-class>
		<function-signature>boolean isOfType(java.lang.Object, java.lang.String)</function-signature>
	</function>
	'''
}

def static String tagIsNullFunction(GuiApplication it) {
	'''
	<function>
		<name>isNull</name>
		<function-class>
			«basePackage + ".util." + subPackage("web") + "." + name + "Functions"»</function-class>
		<function-signature>boolean isNull(java.lang.Object)</function-signature>
	</function>
	'''
}

def static String tagIsNotNullFunction(GuiApplication it) {
	'''
	<function>
		<name>isNotNull</name>
		<function-class>
			«basePackage + ".util." + subPackage("web") + "." + name + "Functions"»</function-class>
		<function-signature>boolean isNotNull(java.lang.Object)</function-signature>
	</function>
	'''
}

def static String tagBreadCrumbFunction(GuiApplication it) {
	'''
	<function>
		<name>breadCrumb</name>
		<function-class>
			«basePackage + ".util." + subPackage("web") + "." + name + "Functions"»</function-class>
		<function-signature>java.util.List breadCrumb(org.springframework.webflow.execution.FlowExecutionContext)</function-signature>
	</function>
	'''
}

def static String breadCrumbFactoryMethod(GuiApplication it) {
	'''
		private static BreadCrumbElement createBreadCrumbElement(org.springframework.webflow.definition.FlowDefinition definition) {
			String flowId = definition.getId();
		FlowIdentifier flowIdentifier = new FlowIdentifier(flowId);
			String crudOperation = flowIdentifier.action();
			String domainObjectName = flowIdentifier.domainObjectName();
			return new BreadCrumbElement(flowId, crudOperation, domainObjectName);
		}
	'''
}

def static String breadCrumbInnerClass(GuiApplication it) {
	'''
		public static class BreadCrumbElement {
			private String flowId;
			private String domainObjectName;
			private String crudOperation;

			public BreadCrumbElement(String flowId, String crudOperation, String domainObjectName) {
				this.flowId = flowId;
				this.domainObjectName = domainObjectName;
				this.crudOperation = crudOperation;
			}

			public String getFlowId() {
				return flowId;
			}

			public String getCrudOperation() {
				return crudOperation;
			}

			public String getDomainObjectName() {
				return domainObjectName;
			}
		}
	'''
}
}
