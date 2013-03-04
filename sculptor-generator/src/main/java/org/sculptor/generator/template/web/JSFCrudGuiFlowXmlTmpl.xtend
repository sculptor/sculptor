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

class JSFCrudGuiFlowXmlTmpl {


def static String flowXml(GuiApplication it) {
	'''
	«it.this.modules.userTasks.typeSelect(CreateTask).forEach[createFlowXml(it)]»
	«it.this.modules.userTasks.typeSelect(UpdateTask).forEach[updateFlowXml(it)]»
	«it.this.modules.userTasks.typeSelect(ViewTask).forEach[viewFlowXml(it)]»
	«it.this.modules.userTasks.typeSelect(DeleteTask).forEach[deleteFlowXml(it)]»
	«it.this.modules.userTasks.typeSelect(ListTask).forEach[listFlowXml(it)]»
	«IF this.modules.userTasks.notExists(e | e.gapClass) »
		«createFlowsDir(it)»
	«ENDIF»
	'''
}

def static String createFlowsDir(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/flows/readme.txt", 'TO_WEBROOT', '''
	It is required to have a WEB-INF/flows directory.
	This file can be removed when some other files has been generated in the 
	flows directory.
	'''
	)
	'''
	'''
}

def static String createFlowXml(CreateTask it) {
	'''
	«createFlowDefinitionBase(it)»
	«IF gapClass»
		«flowDefinitionImpl(it)»
	«ENDIF»
	'''
}


def static String createFlowDefinitionBase(CreateTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/" + name + (gapClass ? "-base" : "-flow") + ".xml", 'TO_GEN_WEBROOT', '''
	<?xml version="1.0" encoding="UTF-8"?>
	<flow xmlns="http://www.springframework.org/schema/webflow"
				xmlns:ns0="http://www.w3.org/2001/XMLSchema-instance"
				ns0:schemaLocation="http://www.springframework.org/schema/webflow http://www.springframework.org/schema/webflow/spring-webflow-2.0.xsd"
				start-state="«startStateName(it)»">

		«flowAttributeTag(it)»
		«flowInputTag(it)»
		«onStartFlowTag(it)»
		«startStateTag(it)»		
		«confirmStateTag(it)»				
		«it.this.subTaskTransitions.filter(e|e.to.metaType == CreateTask) .forEach[subflowForCreate(it)]»
		«it.this.subTaskTransitions.filter(e|e.to.metaType == UpdateTask) .forEach[subflowForUpdate(it)]»
		«it.this.subTaskTransitions.filter(e|e.to.metaType == ViewTask) .forEach[subflowForView(it)]»

		<decision-state id="cancelDecision">
			<!-- When the flow is a top level flow we redirect to the first page, otherwise we finish the flow and return to parent flow. -->
			<if test="flowExecutionContext.activeSession.root" then="redirectFinish" else="finish"/>
		</decision-state>
		«endStateTag(it)»			
	</flow>
	'''
	)
	'''
	'''
}



def static String updateFlowXml(UpdateTask it) {
	'''
	«updateFlowDefinitionBase(it)»
	«IF gapClass»
		«flowDefinitionImpl(it)»
	«ENDIF»
	'''
}

def static String updateFlowDefinitionBase(UpdateTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/" + name + (gapClass ? "-base" : "-flow") + ".xml", 'TO_GEN_WEBROOT', '''
	<?xml version="1.0" encoding="UTF-8"?>
	<flow xmlns="http://www.springframework.org/schema/webflow"
		xmlns:ns0="http://www.w3.org/2001/XMLSchema-instance"
		ns0:schemaLocation="http://www.springframework.org/schema/webflow http://www.springframework.org/schema/webflow/spring-webflow-2.0.xsd"
		start-state="«startStateName(it)»">

		«flowAttributeTag(it)»
		«flowInputTag(it)»
		«onStartFlowTag(it)»
		«startStateTag(it)»
		«confirmStateTag(it)»
		«it.this.subTaskTransitions.filter(e|e.to.metaType == CreateTask) .forEach[subflowForCreate(it)]»
		«it.this.subTaskTransitions.filter(e|e.to.metaType == UpdateTask) .forEach[subflowForUpdate(it)]»
		«it.this.subTaskTransitions.filter(e|e.to.metaType == ViewTask) .forEach[subflowForView(it)]»
		«endStateTag(it)»			
	</flow>
	'''
	)
	'''
	'''
}


def static String viewFlowXml(ViewTask it) {
	'''
	«viewFlowDefinitionBase(it) »
	«IF gapClass»
		«flowDefinitionImpl(it)»
	«ENDIF»
	'''
}

def static String viewFlowDefinitionBase(ViewTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/" + name + (gapClass ? "-base" : "-flow") + ".xml", 'TO_GEN_WEBROOT', '''
	<?xml version="1.0" encoding="UTF-8"?>
	<flow xmlns="http://www.springframework.org/schema/webflow"
		xmlns:ns0="http://www.w3.org/2001/XMLSchema-instance"
		ns0:schemaLocation="http://www.springframework.org/schema/webflow
		http://www.springframework.org/schema/webflow/spring-webflow-2.0.xsd"
		start-state="«startStateName(it)»">

		«flowAttributeTag(it)»
		«flowInputTag(it)»
		«onStartFlowTag(it)»
		«startStateTag(it)»
		«it.this.subTaskTransitions.filter(e|e.to.metaType == ViewTask) .forEach[subflowForViewFromView(it)]»
		«endStateTag(it)»
	</flow>
	'''
	)
	'''
	'''
}


def static String deleteFlowXml(DeleteTask it) {
	'''
	«IF this.deleteDOWith != null»
		«deleteFlowDefinitionBase(it) »
		«IF gapClass»
			«flowDefinitionImpl(it)»
		«ENDIF»
	«ENDIF»
	'''
}

def static String deleteFlowDefinitionBase(DeleteTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/" + name + (gapClass ? "-base" : "-flow") + ".xml", 'TO_GEN_WEBROOT', '''
	<?xml version="1.0" encoding="UTF-8"?>
	<flow xmlns="http://www.springframework.org/schema/webflow"
		xmlns:ns0="http://www.w3.org/2001/XMLSchema-instance"
		ns0:schemaLocation="http://www.springframework.org/schema/webflow
		http://www.springframework.org/schema/webflow/spring-webflow-2.0.xsd"
		start-state="«startStateName(it)»">

		«flowAttributeTag(it)»
		«flowInputTag(it)»
		«onStartFlowTag(it)»
		«startStateTag(it)»
		«endStateTag(it)»
	</flow>
	'''
	)
	'''
	'''
}


def static String listFlowXml(ListTask it) {
	'''
	«IF this.searchDOWith != null»
		«listFlowDefinitionBase(it)»
		«IF gapClass»
			«flowDefinitionImpl(it)»
		«ENDIF»
	«ENDIF»
	'''
}

def static String listFlowDefinitionBase(ListTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/" + name + (gapClass ? "-base" : "-flow") + ".xml", 'TO_GEN_WEBROOT', '''
	<?xml version="1.0" encoding="UTF-8"?>
	<flow xmlns="http://www.springframework.org/schema/webflow"
		xmlns:ns0="http://www.w3.org/2001/XMLSchema-instance"
		ns0:schemaLocation="http://www.springframework.org/schema/webflow
		http://www.springframework.org/schema/webflow/spring-webflow-2.0.xsd"
		start-state="«startStateName(it)»">

		«flowAttributeTag(it)»
		«flowInputTag(it)»
		«onStartFlowTag(it)»
		«startStateTag(it)»
		
		<subflow-state id="view" subflow="«module.name»/view«for.name»">
			<input name="id" value="requestParameters.id"/>
			<transition on="finish" to="list"/>
		</subflow-state>
		«IF this.isUpdateSubTaskAvailable() »
		<subflow-state id="update" subflow="«module.name»/update«for.name»">
			<input name="id" value="requestParameters.id"/>
			<transition on="finish" to="list"/>
		</subflow-state>
		«ENDIF »
		«IF this.isDeleteSubTaskAvailable() »
		<subflow-state id="delete" subflow="«module.name»/delete«for.name»">
			<input name="id" value="requestParameters.id"/>
			<transition on="finish" to="list"/>
		</subflow-state>
		«ENDIF »

	</flow>
	'''
	)
	'''
	'''
}

def static String flowDefinitionImpl(UserTask it) {
	'''
	'''
	fileOutput("WEB-INF/flows/" + module.name + "/" + name + "/" + name + "-flow.xml", 'TO_WEBROOT', '''
	<?xml version="1.0" encoding="UTF-8"?>
	<flow xmlns="http://www.springframework.org/schema/webflow"
		xmlns:ns0="http://www.w3.org/2001/XMLSchema-instance"
		ns0:schemaLocation="http://www.springframework.org/schema/webflow
		http://www.springframework.org/schema/webflow/spring-webflow-2.0.xsd"
		parent="«module.name»/«name»Base">
	</flow>
	'''
	)
	'''
	'''
}




def static String startStateName(CreateTask it) {
	'''input	'''
}
def static String startStateName(UpdateTask it) {
	'''input	'''
}
def static String startStateName(ViewTask it) {
	'''view	'''
}
def static String startStateName(DeleteTask it) {
	'''confirm	'''
}
def static String startStateName(ListTask it) {
	'''list	'''
}

def static String flowAttributeTag(UserTask it) {
	'''
	<attribute name="persistenceContext" value="supports"/>
	'''
}

def static String flowInputTag(CreateTask it) {
	'''	'''
}

def static String flowInputTag(UpdateTask it) {
	'''
	«IF this.findDOWith != null »
	<input name="id" required="true"/>
	«ELSE»
	<input name="«for.name»" value="flashScope.«for.name»" required="true"/>
	«ENDIF»
	'''
}

def static String flowInputTag(ViewTask it) {
	'''
	<input name="id"/>
	<input name="«for.name»" />
	'''
}

def static String flowInputTag(DeleteTask it) {
	'''
	<input name="id" required="true"/>
	'''
}

def static String flowInputTag(ListTask it) {
	'''	'''
}

def static String onStartFlowTag(UserTask it) {
	'''
	<on-start>
	<!-- create the backing form object -->
	<evaluate expression="«this.name»Action.createForm(flowRequestContext)"/>
	<!-- Load things into the form -->
			<evaluate expression="«this.name»Action.loadForm(flowRequestContext)"/>
	</on-start>
	'''
}

def static String onStartFlowTag(DeleteTask it) {
	'''

	'''
}

def static String onStartFlowTag(ListTask it) {
	'''
	<on-start>
	<!-- create the backing form object -->
	<evaluate expression="«this.name»Action.createForm(flowRequestContext)"/>
	</on-start>
	'''
}


def static String startStateTag(CreateTask it) {
	'''
	<view-state id="input" model="«name»Form" view="/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/input.xhtml">
	<transition on="submit" to="confirm">
		<evaluate expression="«this.name»Action.confirm(flowRequestContext)"/>
	</transition>		
	«cancelTransitionTag(it)»			
	«it.this.subTaskTransitions.filter(e | e.to.metaType == CreateTask || e.to.metaType == UpdateTask || e.to.metaType == ViewTask) .forEach[transitionToSubflow(it)(true)]»
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base) .forEach[transitionToRemoveChild(it)(this)]»
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base) .forEach[transitionToAddExistingChild(it)(this)]»
	</view-state>
	'''
}

def static String startStateTag(UpdateTask it) {
	'''
	<view-state id="input" model="«name»Form" view="/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/input.xhtml">
	<transition on="submit" to="confirm">
		<evaluate expression="«this.name»Action.confirm(flowRequestContext)"/>
	</transition>
	«cancelTransitionTag(it)»
	«it.this.subTaskTransitions.filter(e | e.to.metaType == CreateTask || e.to.metaType == UpdateTask || e.to.metaType == ViewTask) .forEach[transitionToSubflow(it)(true)]»
	/*TODO - should e.forReference.isRemoveAvailable be on gui meta model instead? */
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).forEach[transitionToRemoveChild(it)(this)]»
	/*TODO - hmm, perhaps not the right way to use the 'CreateTask' subTaskTansitions for addin existing childs, but it will work for now */
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base) .forEach[transitionToAddExistingChild(it)(this)]»
	</view-state>
	'''
}

def static String startStateTag(ViewTask it) {
	'''
	<view-state id="view" model="«this.name»Form" view="/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/view.xhtml">		
	«cancelTransitionTag(it)»
	«it.this.subTaskTransitions.filter(e | e.to.metaType == ViewTask) .forEach[transitionToSubflow(it)(true)]»
	</view-state>
	'''
}

def static String startStateTag(DeleteTask it) {
	'''
	<view-state id="confirm" view="/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/confirm.xhtml">
	<on-render>
		<evaluate expression="«this.name»Action.findById(flowRequestContext)"/>
	</on-render>
	<transition on="submit" to="finish">
		<evaluate expression="«this.name»Action.delete(flowRequestContext)"/>
	</transition>
	«cancelTransitionTag(it)»
	</view-state>
	'''
}

def static String startStateTag(ListTask it) {
	'''
	<view-state id="list" model="«this.name»Form" view="/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/list.xhtml">
	<on-render>
		<evaluate expression="«this.name»Action.findAll(flowRequestContext)"/>
	</on-render>
	<transition on="view" to="view"/>
	«IF this.isUpdateSubTaskAvailable() »
	<transition on="update" to="update"/>
	«ENDIF »
	«IF this.isDeleteSubTaskAvailable() »
	<transition on="delete" to="delete"/>
	«ENDIF »
	</view-state>
	'''
}

def static String confirmStateTag(CreateTask it) {
	'''
	<view-state id="confirm" view="/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/confirm.xhtml">
	<transition on="submit" to="finish">
		<evaluate expression="«this.name»Action.save(flowRequestContext)"/>
	</transition>
	«cancelTransitionTag(it)»
	<transition on="back" to="input"/>
	</view-state>
	'''
}

def static String confirmStateTag(UpdateTask it) {
	'''
	<view-state id="confirm" view="/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/confirm.xhtml">
	<transition on="submit" to="finish">
		<evaluate expression="«this.name»Action.save(flowRequestContext)"/>
	</transition>
	«cancelTransitionTag(it)»
	<transition on="back" to="input">
	</transition>
	</view-state>
	'''
}


def static String transitionToSubflow(SubTaskTransition it, boolean addActionHooks) {
	'''
	<transition on="«resolveTransitionEventName()»"
			to="«resolveSubFlowId()»" validate="false">
	«IF addActionHooks»
	<evaluate expression="«this.from.name»Action.«resolvePrepareMethodName()»(flowRequestContext)"/>
	«ENDIF»
	</transition>
	'''
}


def static String transitionToRemoveChild(ReferenceViewProperty it, UserTask fromTask) {
	'''
	<transition on="«resolveRemoveTransitionEventName()»" to="input" validate="false">
	<evaluate expression="«fromTask.name»Action.«resolveRemoveChildMethodName()»(flowRequestContext)"/>
	</transition>
	'''
}



def static String transitionToAddExistingChild(ReferenceViewProperty it, UserTask fromTask) {
	'''
	«IF isAddSubTaskAvailable() »
	<transition on="«resolveAddExistingChildEventName()»" to="input" validate="false">
	<evaluate expression="«fromTask.name»Action.«resolveAddExistingChildMethodName()»(flowRequestContext)"/>
	</transition>
	«ENDIF»
	'''
}


def static String subflowForCreate(SubTaskTransition it) {
	'''
	«IF this.to.metaType == CreateTask»
	<subflow-state id="«resolveSubFlowId()»" subflow="«to.module.name»/«to.name»">
	<output name="«to.for.name»" value="flashScope.«to.for.name»"/>
	<transition on="finish" to="input">
		<evaluate expression="«from.name»Action.«resolveAddChildMethodName()»(flowRequestContext)"/>
	</transition>
	</subflow-state>
	«ENDIF»
	'''
}

def static String subflowForUpdate(SubTaskTransition it) {
	'''
	«IF this.to.metaType == UpdateTask »
	<subflow-state id="«resolveSubFlowId()»" subflow="«to.module.name»/«to.name»">
	<input name="«to.for.name»" value="flashScope.«to.for.name»"/>
	<output name="«to.for.name»" value="flashScope.«to.for.name»"/>
	<transition on="finish" to="input">
		<evaluate expression="«from.name»Action.«resolveUpdateChildMethodName()»(flowRequestContext)"/>
	</transition>
	</subflow-state>
	«ENDIF»
	'''
}

def static String subflowForView(SubTaskTransition it) {
	'''
	<subflow-state id="«resolveSubFlowId()»" subflow="«to.module.name»/«to.name»">
	<input name="«to.for.name»" value="flashScope.«to.for.name»"/>
	<transition on="finish" to="input"/>
	</subflow-state>
	'''
}

def static String subflowForViewFromView(SubTaskTransition it) {
	'''
	<subflow-state id="«resolveSubFlowId()»" subflow="«to.module.name»/«to.name»">
	<input name="«to.for.name»" value="flashScope.«to.for.name»"/>
	<transition on="finish" to="view"/>
	</subflow-state>
	'''
}


def static String cancelTransitionTag(UserTask it) {
	'''
	<transition on="cancel" to="finish" bind="false"/>
	'''
}
def static String cancelTransitionTag(CreateTask it) {
	'''
	<transition on="cancel" to="cancelDecision" bind="false"/>
	'''
}
def static String cancelTransitionTag(UpdateTask it) {
	'''
	<transition on="cancel" to="finish" bind="false">
	<evaluate expression="«this.name»Action.cancel(flowRequestContext)"/>
	</transition>
	'''
}

def static String endStateTag(CreateTask it) {
	'''
	<end-state id="redirectFinish" view="externalRedirect:contextRelative:/"/>
	<end-state id="finish" view="/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/finish.xhtml">
	<output name="«for.name»" value="flashScope.«for.name»"/>
	</end-state>
	'''
}

def static String endStateTag(UpdateTask it) {
	'''
	<end-state id="finish" view="/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/finish.xhtml">
	<output name="«for.name»" value="flashScope.«for.name»"/>
	</end-state>
	'''
}

def static String endStateTag(ViewTask it) {
	'''
	<end-state id="finish" />
	'''
}

def static String endStateTag(DeleteTask it) {
	'''
	<end-state id="finish" view="/WEB-INF/«IF !gapClass»generated/«ENDIF»flows/«module.name»/«name»/finish.xhtml"/>
	'''
}
}
