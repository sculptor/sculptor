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

class JSFGuiInfrastructureJavaTmpl {


def static String infrastructureJava(GuiApplication it) {
	'''
	«requiredHelperJava(it) »
	«flowIdentifierJava(it) »
	'''
}

def static String requiredHelperJava(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(this.basePackage + ".util." + subPackage("web") + ".RequiredHelper") , '''
	«javaHeader()»
	package «basePackage».util.«subPackage("web")»;	

	public class RequiredHelper {
		public static boolean isReferenceRequired(String[] potentialParentFlowNames) {
		return isReferenceRequired(org.springframework.webflow.execution.RequestContextHolder.getRequestContext(), potentialParentFlowNames);
	}
		public static boolean isReferenceRequired(org.springframework.webflow.execution.RequestContext ctx, String[] potentialParentFlowNames) {
			org.springframework.webflow.execution.FlowSession parentSession = ctx.getFlowExecutionContext().
				getActiveSession().getParent();
			
			if (parentSession == null) {
				// no parent flow, i.e. this is the root flow, the reference is required
				return true;
			} else {
				// nested flow, check parent
				String flowId = parentSession.getDefinition().getId();

				// the naming convention for the flowId is "listPerson-flow"
				FlowIdentifier flowIdentifier = new FlowIdentifier(flowId);

				String domainObjectName = flowIdentifier.domainObjectName();

				for (int i = 0; i < potentialParentFlowNames.length; i++) {
				    if (potentialParentFlowNames[i].equals(domainObjectName)) {
				        // match! the parent flow is the other end on the reference, i.e.
				        // this reference isn't required since it is going to be fulfilled
				        // by parent flow
				        return false;
				    }
				}

				// no match found, i.e. the parent flow isn't the other end on the reference, it is required
				return true;
			}
		}
	}
	'''
	)
	'''
	'''
}

def static String flowIdentifierJava(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(this.basePackage + ".util." + subPackage("web") + ".FlowIdentifier") , '''
	«javaHeader()»
	package «basePackage».util.«subPackage("web")»;
	class FlowIdentifier {
	private String action;
	private String domainObjectName;
	private String flowId;
	FlowIdentifier(String flowId) {
				this.flowId = flowId;	
		// the naming convention for the flowId is "media/listPerson"
			String[] parts = flowId.split("/");
			if (parts.length != 2) {
				throw new IllegalArgumentException("Strange flow id: " + flowId);
			}
			action = parts[1].split("\\p{Upper}")[0];
			if (action == null || action.equals("")) {
				throw new IllegalArgumentException("Strange flow id: " + flowId);
			}
			domainObjectName = parts[1].substring(action.length());
			if (domainObjectName == null || domainObjectName.equals("")) {
				throw new IllegalArgumentException("Strange flow id: " + flowId);
			}
	}
	String action() {
				return this.action;	
	}
	String domainObjectName() {
		return this.domainObjectName;
	}
	String flowId() {
		return this.flowId;
	}
	}
	'''
	)
	'''
	'''
}
}
