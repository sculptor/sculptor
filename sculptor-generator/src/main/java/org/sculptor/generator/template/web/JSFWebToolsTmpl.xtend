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

class JSFWebToolsTmpl {


def static String webTools(GuiApplication it) {
	'''
	«functionsJava(it)»
	«dateConverter(it)»
	«IF getDateTimeLibrary() == "joda"»
		«jodaDateTimeConverter(it)("LocalDate")»
		«jodaDateTimeConverter(it)("DateTime")»
	«ENDIF»
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
/*«isNullMethod(it) »
	«isNotNullMethod(it) » */
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

def static String breadCrumbMethod(GuiApplication it) {
	'''
		public static java.util.List<BreadCrumbElement> breadCrumb(org.springframework.webflow.execution.FlowExecutionContext ctx, java.util.PropertyResourceBundle msg) {
			java.util.List<BreadCrumbElement> breadCrumbList = new java.util.ArrayList<BreadCrumbElement>();
			if (ctx == null || !ctx.isActive()) {
				return breadCrumbList;
			}
			org.springframework.webflow.execution.FlowSession flowSession = ctx.getActiveSession();
			if (flowSession == null) {
				return breadCrumbList;
			}
			while (flowSession != null) {
				breadCrumbList.add(createBreadCrumbElement(flowSession.getDefinition(),msg));
				// continue with parent flow, if there is any parent
				flowSession = flowSession.getParent();
			}

			java.util.Collections.reverse(breadCrumbList);

			return breadCrumbList;
		}
	'''
}

def static String breadCrumbFactoryMethod(GuiApplication it) {
	'''
	private static BreadCrumbElement createBreadCrumbElement(
			org.springframework.webflow.definition.FlowDefinition definition, java.util.PropertyResourceBundle msg) {
			String flowId = definition.getId();
			FlowIdentifier flowIdentifier = new FlowIdentifier(flowId);
			String crudOperation = (containsKey(msg, "breadCrumb." + flowIdentifier.action())) ?
				msg.getString("breadCrumb." + flowIdentifier.action()) : flowIdentifier.action();
			String domainObjectKey = "breadCrumb." +
				flowIdentifier.domainObjectName();
			if ("list".equals(flowIdentifier.action()))
				domainObjectKey += ".plural";
			String domainObjectName = (containsKey(msg, domainObjectKey)) ?
				(String) msg.getString(domainObjectKey) : flowIdentifier.domainObjectName();
			return new BreadCrumbElement(flowId, crudOperation, domainObjectName);
		}

		/**
			* This method is not necessary when using Java 1.6
			*/
		private static boolean containsKey(java.util.PropertyResourceBundle msg, String key) {
			try {
				msg.getString(key);
				return true;
			} catch (java.util.MissingResourceException e) {
				return false;
			}
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

/*TODO: Consider moving this to framework instead */
def static String dateConverter(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(this.basePackage + ".util." + subPackage("web") + ".DateConverter") , '''
	«javaHeader()»
	package «basePackage».util.«subPackage("web")»;
	public class DateConverter implements javax.faces.convert.Converter {

	private String pattern;

	public DateConverter() {
		setPattern(null);
	}

	public Object getAsObject(javax.faces.context.FacesContext context, javax.faces.component.UIComponent component, String text) throws javax.faces.convert.ConverterException {
		precondition(context, component);
		if (!org.springframework.util.StringUtils.hasText(text)) {
				    // Treat empty String as null value.
				    return null;
			}
		String format = getPattern();
		if (format == null) {
			// if pattern is not specified, we get it from the messages bundle
			format = getDefaultPattern(context);
		}
		try {
		    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(format);
		    return sdf.parseObject(text);
		} catch (java.text.ParseException e) {
				javax.faces.application.FacesMessage message =
				    new javax.faces.application.FacesMessage(getResorceBundleText(context,
				            "typeMismatch.java.util.Date"));
				throw new javax.faces.convert.ConverterException(message);
			}
	}

	public String getAsString(javax.faces.context.FacesContext context, javax.faces.component.UIComponent component, Object object) throws javax.faces.convert.ConverterException {
		precondition(context, component);
		if (!(component instanceof javax.faces.component.UIOutput) || object==null) {
			return null;
		}

		String format = getPattern();
		if (format == null) {
			// if pattern is not specified, we get it from the messages bundle
			format = getDefaultPattern(context);
		}
		java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(format);
		return sdf.format(object);
	}

	private void precondition(javax.faces.context.FacesContext context, javax.faces.component.UIComponent component) {
			if (context == null) {
				throw new NullPointerException("facesContext");
			}
			if (component == null) {
				throw new NullPointerException("uiComponent");
			}
		}

	private String getDefaultPattern(javax.faces.context.FacesContext context) {
		return getResorceBundleText(context, "format.DateTimePattern");
	}

	private String getResorceBundleText(javax.faces.context.FacesContext context, String key) {
	    java.util.ResourceBundle bundle = java.util.ResourceBundle.getBundle("i18n.messages",context.getViewRoot().getLocale());
		if (bundle == null) {
			return null;
		}
		return bundle.getString(key);
	}

	public String getPattern() {
		return pattern;
	}

	public void setPattern(String pattern) {
		this.pattern = pattern;
	}

	}
	'''
	)
	'''
	'''
}

/*TODO: Consider moving this to framework instead */
def static String jodaDateTimeConverter(GuiApplication it, String type) {
	'''
	'''
	fileOutput(javaFileName(this.basePackage + ".util." + subPackage("web") + "." + type + "Converter") , '''
	«javaHeader()»
	package «basePackage».util.«subPackage("web")»;

	public class «type»Converter implements javax.faces.convert.Converter {
		private String pattern;

		public «type»Converter() {
			setPattern(null);
		}

		private org.joda.time.format.DateTimeFormatter getFormatter(javax.faces.context.FacesContext context) {
			String format = getPattern();
			if (format == null) {
				format = getDefaultPattern(context);
			}
			return org.joda.time.format.DateTimeFormat.forPattern(format);
		}

		public Object getAsObject(javax.faces.context.FacesContext context, javax.faces.component.UIComponent component,
			String text) throws javax.faces.convert.ConverterException {
			precondition(context, component);
			try {
				if (!org.springframework.util.StringUtils.hasText(text)) {
				    // Treat empty String as null value.
				    return null;
				} else {
					«IF type == "LocalDate"»
				    return new org.joda.time.LocalDate(getFormatter(context).parseDateTime(text));
				    «ELSE»
				    return getFormatter(context).parseDateTime(text);
				    «ENDIF»
				}
			} catch (IllegalArgumentException e) {
				javax.faces.application.FacesMessage message =
				    new javax.faces.application.FacesMessage(getResorceBundleText(context,
				            "typeMismatch.org.joda.time.«type»"));
				throw new javax.faces.convert.ConverterException(message);
			}
		}

		public String getAsString(javax.faces.context.FacesContext context, javax.faces.component.UIComponent component,
			Object object) throws javax.faces.convert.ConverterException {
			precondition(context, component);
			if (!(component instanceof javax.faces.component.UIOutput) || object == null) {
				return null;
			}

			try {
				org.joda.time.«type» value = (org.joda.time.«type») object;
				String result = (value != null ? value.toString(getFormatter(context)) : "");
				return result;
			} catch (IllegalArgumentException iae) {
				javax.faces.application.FacesMessage message =
				    new javax.faces.application.FacesMessage(getResorceBundleText(context,
				            "typeMismatch.org.joda.time.«type»"));
				throw new javax.faces.convert.ConverterException(message);
			}
		}

		private void precondition(javax.faces.context.FacesContext context, javax.faces.component.UIComponent component) {
			if (context == null) {
				throw new NullPointerException("facesContext");
			}
			if (component == null) {
				throw new NullPointerException("uiComponent");
			}
		}

		private String getDefaultPattern(javax.faces.context.FacesContext context) {
			«IF type == "LocalDate"»
		return getResorceBundleText(context, "format.DatePattern");
			«ELSE»
		return getResorceBundleText(context, "format.«type»Pattern");
			«ENDIF»
	}

		private String getResorceBundleText(javax.faces.context.FacesContext context, String key) {
	    java.util.ResourceBundle bundle = java.util.ResourceBundle.getBundle("i18n.messages",context.getViewRoot().getLocale());
		if (bundle == null) {
			return null;
		}
		return bundle.getString(key);
	}

		public String getPattern() {
			return pattern;
		}

		public void setPattern(String pattern) {
			this.pattern = pattern;
		}
	}
	'''
	)
	'''
	'''
}


}
