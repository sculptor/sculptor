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

class JSFCrudGuiFlowJsfTmpl {


def static String flowJsf(GuiApplication it) {
	'''
	«it.this.modules.userTasks.forEach[taskJsf(it)]»
	«errorJsf(it)»
	/*«formErrorsInc(it) » */
	'''
}

/*Kind of abstract method, not used, concrete implementations 
	for subclasses of UserTask are defined */
def static String taskJsf(UserTask it) {
	'''
	'''
}

def static String taskJsf(CreateTask it) {
	'''
	«createTaskJsfForm(it)»
	«createTaskJsfFormInc(it)»
	«createTaskJsfConfirm(it)»
	«createTaskJsfConfirmInc(it)»
	«createTaskJsfDone(it)»
	'''
}

def static String taskJsf(UpdateTask it) {
	'''
	«updateTaskJsfForm(it)»
	«updateTaskJsfFormInc(it)»
	«updateTaskJsfConfirm(it)»
	«updateTaskJsfConfirmInc(it)»
	«updateTaskJsfDone(it)»
	'''
}

def static String createTaskJsfForm(CreateTask it) {
	'''
	«createUpdateTaskJsfForm(it)»
	'''
}

def static String updateTaskJsfForm(UpdateTask it) {
	'''
	«createUpdateTaskJsfForm(it)»
	'''
}

def static String faceletsXmlns(Object it) {
	'''
 xmlns="http://www.w3.org/1999/xhtml" xmlns:ui="http://java.sun.com/jsf/facelets" xmlns:f="http://java.sun.com/jsf/core" xmlns:t="http://myfaces.apache.org/tomahawk" xmlns:h="http://java.sun.com/jsf/html" xmlns:c="http://java.sun.com/jstl/core" xmlns:sf="http://www.springframework.org/tags/faces" xmlns:a="ApplicationTaglib"
	'''
}

def static String docType(Object it) {
	'''
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	'''
}

def static String createUpdateTaskJsfForm(UserTask it) {
	'''
	«IF gapClass»
		«createUpdateTaskJsfFormGap(it)»
	«ELSE»
		«createUpdateTaskJsfFormGen(it)»
	«ENDIF»
	'''
}

def static String createUpdateTaskJsfFormGap(UserTask it) {
	'''
	'''
	fileOutput("WEB-INF/flows/" + module.name + "/" + name + "/input.xhtml", 'TO_WEBROOT', '''
	«createUpdateTaskJsfFormContent(it)»
	'''
	)
	'''
	'''
}

def static String createUpdateTaskJsfFormGen(UserTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/input.xhtml", 'TO_GEN_WEBROOT', '''
	«createUpdateTaskJsfFormContent(it)»
	'''
	)
	'''
	'''
}

def static String createUpdateTaskJsfFormContent(UserTask it) {
	'''
	«docType(it)»
	<html «faceletsXmlns(it)»>
	<body>
		<ui:composition template="/WEB-INF/common/template.xhtml">
			<ui:define name="content">
				<h1><h:outputFormat value="#{msg['«taskType».formHeader']}">
						<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name»']}" />
					</h:outputFormat></h1>
				<ui:include src="/WEB-INF/generated/flows/«module.name»/«name»/input_include.html" />
			</ui:define>
		</ui:composition>
	</body>
	</html>
	'''
}

def static String createTaskJsfFormInc(CreateTask it) {
	'''
	«createUpdateTaskJsfFormInc(it)»
	'''
}

def static String updateTaskJsfFormInc(UpdateTask it) {
	'''
	«createUpdateTaskJsfFormInc(it)»
	'''
}

def static String createUpdateTaskJsfFormInc(UserTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/input_include.html", 'TO_GEN_WEBROOT', '''
	<h:form «faceletsXmlns(it)»>
	<div id="formInputFields">
		<h:messages globalOnly="true" styleClass="errorList" />
		<fieldset>
			<legend>
				<h:outputFormat value="#{msg['createUpdate.fieldsLegend']}">
					<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name»']}" />
				</h:outputFormat>
			</legend>
			<table>
			«jsfInputFields(it)»
			</table>
		</fieldset>
	</div>
	<div id="formReferences">
		«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base) -.forEach[formReference(it)(name + "Form") ]»
	</div>
	«formActionButtons(it)»
	</h:form>
	'''
	)
	'''
	'''
}

def static String createTaskJsfConfirm(CreateTask it) {
	'''
	«createUpdateTaskJsfConfirm(it)»
	'''
}
def static String updateTaskJsfConfirm(UpdateTask it) {
	'''
	«createUpdateTaskJsfConfirm(it)»
	'''
}

def static String createUpdateTaskJsfConfirm(UserTask it) {
	'''
	«IF gapClass»
		«createUpdateTaskJsfConfirmGap(it)»
	«ELSE»
		«createUpdateTaskJsfConfirmGen(it)»
	«ENDIF»
	'''
}

def static String createUpdateTaskJsfConfirmGap(UserTask it) {
	'''
	'''
	fileOutput("WEB-INF/flows/" + module.name + "/" + name + "/confirm.xhtml", 'TO_WEBROOT', '''
	«createUpdateTaskJsfConfirmContent(it)»
	'''
	)
	'''
	'''
}

def static String createUpdateTaskJsfConfirmGen(UserTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/confirm.xhtml", 'TO_GEN_WEBROOT', '''
	«createUpdateTaskJsfConfirmContent(it)»
	'''
	)
	'''
	'''
}

def static String createUpdateTaskJsfConfirmContent(UserTask it) {
	'''
	«docType(it)»
	<html «faceletsXmlns(it)»>
	<body>
		<ui:composition template="/WEB-INF/common/template.xhtml">
			<ui:define name="content">
				<h1><h:outputFormat value="#{msg['«taskType».confirmHeader']}">
						<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name»']}" />
					</h:outputFormat></h1>
				<ui:include src="/WEB-INF/generated/flows/«module.name»/«name»/confirm_include.html" />
			</ui:define>
		</ui:composition>
	</body>
	</html>
	'''
}

def static String createTaskJsfConfirmInc(CreateTask it) {
	'''
	«createUpdateTaskJsfConfirmInc(it)»
	'''
}
def static String updateTaskJsfConfirmInc(UpdateTask it) {
	'''
	«createUpdateTaskJsfConfirmInc(it)»
	'''
}

def static String createUpdateTaskJsfConfirmInc(UserTask it) {
	'''
	«val isUpdateTask = it.metaType == UpdateTask»
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/confirm_include.html", 'TO_GEN_WEBROOT', '''
	<h:form «faceletsXmlns(it)» prependId="false" >
	
	<h:messages globalOnly="true" styleClass="errorList" />
	
	<c:set var="viewDomainObjectLinkToReferences" value="false" />
	<c:set var="viewDomainObjectSystemAttribute" value="«isUpdateTask»" />
	
	<ui:include src="/WEB-INF/generated/flows/«module.name»/view«for.name»DomainObject.html">
		<ui:param name="«for.name.toFirstLower()»" value="#{«name»Form.confirmDraft}" />
		«FOR ref : viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base)»
		<ui:param name="«ref.name»" value="#{«name»Form.«ref.name»}" />
		«ENDFOR»
	</ui:include>
	
	<div id="formActionButtons">
		<h:commandButton action="back" value="#{msg['createUpdate.back']}" id="back"/>
		<h:commandButton action="cancel" value="#{msg['createUpdate.cancel']}" id="cancel"/>
		<h:commandButton action="submit" value="#{msg['«taskType».save']}" id="save" «IF isUpdateTask»disabled="#{(!«name»Form.nextEnabled || !empty facesContext.maximumSeverity) ? 'true' : 'false'}" «ENDIF»/>		
	</div>
	</h:form>
	'''
	)
	'''
	'''
}

def static String createTaskJsfDone(CreateTask it) {
	'''
	«createUpdateTaskJsfDone(it)»
	'''
}
def static String updateTaskJsfDone(UpdateTask it) {
	'''
	«createUpdateTaskJsfDone(it)»
	'''
}

def static String createUpdateTaskJsfDone(UserTask it) {
	'''
	«IF gapClass»
		«createUpdateTaskJsfDoneGap(it)»
	«ELSE»
		«createUpdateTaskJsfDoneGen(it)»
	«ENDIF»
	'''
}

def static String createUpdateTaskJsfDoneGap(UserTask it) {
	'''
	'''
	fileOutput("WEB-INF/flows/" + module.name + "/" + name + "/finish.xhtml", 'TO_WEBROOT', '''
	«createUpdateTaskJsfDoneContent(it)»
	'''
	)
	'''
	'''
}

def static String createUpdateTaskJsfDoneGen(UserTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/finish.xhtml", 'TO_GEN_WEBROOT', '''
	«createUpdateTaskJsfDoneContent(it)»
	'''
	)
	'''
	'''
}

def static String createUpdateTaskJsfDoneContent(UserTask it) {
	'''
	«docType(it)»
	<html «faceletsXmlns(it)»>
	<body>
		<ui:composition template="/WEB-INF/common/template.xhtml">
			<ui:define name="content">
				<h1><h:outputFormat value="#{msg['«this.taskType».doneHeader']}">
						<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name»']}" />
						<f:param value="#{«for.name».id}" />
					</h:outputFormat>
				</h1>
			</ui:define>
		</ui:composition>
	</body>
	</html>	
	'''
}

def static String taskJsf(ViewTask it) {
	'''
	«IF gapClass»
		«taskJsfGap(it)»
	«ELSE»
		«taskJsfGen(it)»
	«ENDIF»
	
	«viewTaskJsfInc(it)»
	«viewDomainObjectJsfInc(it)»
	'''
}

def static String taskJsfGap(ViewTask it) {
	'''
	'''
	fileOutput("WEB-INF/flows/" + module.name + "/" + name + "/view.xhtml", 'TO_WEBROOT', '''
	«taskJsfContent(it)»
	'''
	)
	'''
	'''
}

def static String taskJsfGen(ViewTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/view.xhtml", 'TO_GEN_WEBROOT', '''
	«taskJsfContent(it)»
	'''
	)
	'''
	'''
}

def static String taskJsfContent(ViewTask it) {
	'''
	«docType(it)»
	<html «faceletsXmlns(it)»>
	<body>
		<ui:composition template="/WEB-INF/common/template.xhtml">
			<ui:define name="content">
				<h1><h:outputFormat value="#{msg['view.header']}">
						<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name»']}" />
					</h:outputFormat>#{" "}
					<c:if test="#{«name»Form.domainObject.id != null}">
						<h:outputFormat value="#{msg['view.header.withId']}">
							<f:param value="#{«name»Form.domainObject.id}" />
						</h:outputFormat>
					</c:if>
				</h1>
				<ui:include src="/WEB-INF/generated/flows/«module.name»/«name»/view_include.html" />
			</ui:define>
		</ui:composition>
	</body>
	</html>
	'''
}

def static String viewTaskJsfInc(ViewTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/view_include.html", 'TO_GEN_WEBROOT', '''
	<h:form «faceletsXmlns(it)»>
	
	<h:messages globalOnly="true" styleClass="errorList" />
	
	<ui:fragment rendered="#{empty facesContext.maximumSeverity}">
		<c:set var="viewDomainObjectLinkToReferences" value="true" />
		<c:set var="viewDomainObjectSystemAttribute" value="true" />
		
		<ui:include src="/WEB-INF/generated/flows/«module.name»/view«for.name»DomainObject.html">
			<ui:param name="«for.name.toFirstLower()»" value="#{«name»Form.domainObject}" />
			«FOR ref : viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base)»
			<ui:param name="«ref.name»" value="#{«name»Form.«ref.name»}" />
			«ENDFOR»
		</ui:include>
	</ui:fragment>
	
	<div id="formActionButtons">
		<h:commandButton action="cancel" value="#{msg['view.ok']}" id="ok" />
	</div>
	</h:form>
	'''
	)
	'''
	'''
}

def static String taskJsf(DeleteTask it) {
	'''
	«deleteTaskJsfConfirm(it)»
	«deleteTaskJsfConfirmInc(it)»
	«deleteTaskJsfDone(it)»
	'''
}

def static String deleteTaskJsfConfirm(DeleteTask it) {
	'''
	«IF gapClass»
		«deleteTaskJsfConfirmGap(it)»
	«ELSE»
		«deleteTaskJsfConfirmGen(it)»
	«ENDIF»
	'''
}

def static String deleteTaskJsfConfirmGap(DeleteTask it) {
	'''
	'''
	fileOutput("WEB-INF/flows/" + module.name + "/" + name + "/confirm.xhtml", 'TO_WEBROOT', '''
	«deleteTaskJsfConfirmContent(it)»
	'''
	)
	'''
	'''
}

def static String deleteTaskJsfConfirmGen(DeleteTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/confirm.xhtml", 'TO_GEN_WEBROOT', '''
	«deleteTaskJsfConfirmContent(it)»
	'''
	)
	'''
	'''
}

def static String deleteTaskJsfConfirmContent(DeleteTask it) {
	'''
	«docType(it)»
	<html «faceletsXmlns(it)»>
	<body>
		<ui:composition template="/WEB-INF/common/template.xhtml">
			<ui:define name="content">
				<h1><h:outputFormat value="#{msg['delete.header']}">
						<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name»']}" />
					</h:outputFormat>#{" "}
					<c:if test="#{«name»Form.id != null}">
						<h:outputFormat value="#{msg['delete.header.withId']}">
							<f:param value="#{«name»Form.id}" />
						</h:outputFormat>
					</c:if>
				</h1>
				<ui:include src="/WEB-INF/generated/flows/«module.name»/«name»/confirm_include.html" />
			</ui:define>
		</ui:composition>
	</body>
	</html>
	'''
}

def static String deleteTaskJsfConfirmInc(DeleteTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/confirm_include.html", 'TO_GEN_WEBROOT', '''
	<h:form «faceletsXmlns(it)»>
	
	<h:messages globalOnly="true" styleClass="errorList" />
	
	<ui:fragment rendered="#{empty facesContext.maximumSeverity}">
		<c:set var="viewDomainObjectLinkToReferences" value="false" />
		<c:set var="viewDomainObjectSystemAttribute" value="true" />
		
		<ui:include src="/WEB-INF/generated/flows/«module.name»/view«for.name»DomainObject.html">
			<ui:param name="«for.name.toFirstLower()»" value="#{«for.name.toFirstLower()»}" />
			«FOR ref : viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base)»
			<ui:param name="«ref.name»" value="#{«for.name.toFirstLower()».«ref.name»}" />
			«ENDFOR»
		</ui:include>
	</ui:fragment>
	
	<div id="formActionButtons">
		<h:commandButton action="submit" value="#{msg['delete.yes']}" id="yes" disabled="#{empty facesContext.maximumSeverity ? 'false' : 'true'}" />
		<h:commandButton action="cancel" value="#{msg['delete.no']}" id="no"/>
	</div>
	</h:form>
	'''
	)
	'''
	'''
}

def static String deleteTaskJsfDone(DeleteTask it) {
	'''
	«IF gapClass»
		«deleteTaskJsfDoneGap(it)»
	«ELSE»
		«deleteTaskJsfDoneGen(it)»
	«ENDIF»
	'''
}

def static String deleteTaskJsfDoneGap(DeleteTask it) {
	'''
	'''
	fileOutput("WEB-INF/flows/" + module.name + "/" + name + "/finish.xhtml", 'TO_WEBROOT', '''
	«deleteTaskJsfDoneContent(it)»
	'''
	)
	'''
	'''
}

def static String deleteTaskJsfDoneGen(DeleteTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/finish.xhtml", 'TO_GEN_WEBROOT', '''
	«deleteTaskJsfDoneContent(it)»
	'''
	)
	'''
	'''
}

def static String deleteTaskJsfDoneContent(DeleteTask it) {
	'''
	«docType(it)»
	<html «faceletsXmlns(it)»>
	<body>
		<ui:composition template="/WEB-INF/common/template.xhtml">
			<ui:define name="content">
				<h1><h:outputFormat value="#{msg['delete.doneHeader']}">
						<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name»']}" />
						<f:param value="#{«for.name».id}" />
					</h:outputFormat>
				</h1>
			</ui:define>
		</ui:composition>
	</body>
	</html>
	'''
}

def static String taskJsf(ListTask it) {
	'''
	«listTaskJsf(it)»
	«listTaskJsfInc(it)»
	'''
}

def static String listTaskJsf(ListTask it) {
	'''
	«IF gapClass»
		«listTaskJsfGap(it)»
	«ELSE»
		«listTaskJsfGen(it)»
	«ENDIF»
	'''
}

def static String listTaskJsfGap(ListTask it) {
	'''
	'''
	fileOutput("WEB-INF/flows/" + module.name + "/" + name + "/list.xhtml", 'TO_WEBROOT', '''
	«listTaskJsfContent(it)»	
	'''
	)
	'''
	'''
}

def static String listTaskJsfGen(ListTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/list.xhtml", 'TO_GEN_WEBROOT', '''
	«listTaskJsfContent(it)»	
	'''
	)
	'''
	'''
}

def static String listTaskJsfContent(ListTask it) {
	'''
	«docType(it)»
	<html «faceletsXmlns(it)»>
	<body>
		<ui:composition template="/WEB-INF/common/template.xhtml">
			<ui:define name="content">
				<h1><h:outputFormat value="#{msg['list.header']}">
						<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name».plural']}" />
					</h:outputFormat></h1>
				<ui:include src="/WEB-INF/generated/flows/«module.name»/«name»/list_include.html" />
			</ui:define>
		</ui:composition>
	</body>
	</html>
	'''
}

def static String listTaskJsfInc(ListTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "/list_include.html", 'TO_GEN_WEBROOT', '''
	<h:form «faceletsXmlns(it)»>
	<h:messages globalOnly="true" styleClass="errorList" />
	<t:dataTable value="#{«name»Form.all«for.name.plural()»}" var="«for.name.toFirstLower()»" styleClass="list">
		<t:column styleClass="idCell">
			<f:facet name="header">
				#{msg«resolveModuleName()»['model.DomainObject.«for.name».id']}
			</f:facet>
			<h:commandLink action="view" value="#{«for.name.toFirstLower()».id}">
		    	<f:param name="id" value="#{«for.name.toFirstLower()».id}" />
		    </h:commandLink>
		</t:column>
	«FOR prop : viewProperties.reject(p | p.isSystemAttribute())»
		<t:column>
			<f:facet name="header">
				#{msg«resolveModuleName()»['model.DomainObject.«for.name».«prop.getDOPropertyPath()»']}
			</f:facet>
			«jsfOutputField(it)(false) FOR prop»
		</t:column>
	«ENDFOR»
	«IF isUpdateSubTaskAvailable() || isDeleteSubTaskAvailable()»
		<t:column styleClass="actionCell">
		    <f:facet name="header">
		        <h:outputText value="#{msg['list.actions']}"/>
		    </f:facet>
		    |
		    «IF isUpdateSubTaskAvailable()»
		    <h:commandLink action="update">
		    	<f:param name="id" value="#{«for.name.toFirstLower()».id}" />
		    	<h:graphicImage value="/img/update.png" alt="Edit" title="#{msg['list.edit']}" style="border:none;"/>
		    </h:commandLink>
		    |
		    «ENDIF»
		    «IF isDeleteSubTaskAvailable()»
		    <h:commandLink action="delete">
		    	<f:param name="id" value="#{«for.name.toFirstLower()».id}" />
		    	<h:graphicImage value="/img/delete.png" alt="Delete" title="#{msg['list.delete']}" style="border:none;"/>
		    </h:commandLink>
		    |
		    «ENDIF»
		</t:column>
	«ENDIF»
	</t:dataTable>
	«IF searchDOWith.isPagedResult()»
		«listTaskPaging(it)»
	«ENDIF»
	</h:form>
	'''
	)
	'''
	'''
}

def static String listTaskPaging(ListTask it) {
	'''
	<c:if test="${not «name»Form.emptyResult}" >
		<div id="paging">
			<br/>	
			<h:outputLabel for="pageNumber" value="#{msg['list.pageLabel']}" />
			<h:inputText id="pageNumber" label="#{msg['list.pageLabel']}" value="#{«name»Form.pageNumber}" />
			<c:if test="${«name»Form.totalPagesCounted}" >
				#{msg['list.maxPagesLabel']} #{«name»Form.totalPages}
			</c:if>
			<br/>
		</div>
	</c:if>
	'''
}

def static String jsfInputFields(UserTask it) {
	'''
	«FOR prop : viewProperties.reject(p | p.metaType == ReferenceViewProperty || p.metaType == DerivedReferenceViewProperty || p.isSystemAttribute())»
		«jsfInputField(it)((metaType == CreateTask) || prop.isChangeable()) FOR prop»
	«ENDFOR»
	'''
}

def static String jsfInputField(ViewDataProperty it, boolean editable) {
	'''
	«IF editable»
		«jsfInputField(it)»
	«ELSE»
		«nonEditableField(it)»
	«ENDIF»
	'''
}

def static String jsfInputField(EnumViewProperty it, boolean editable) {
	'''
	«IF editable»
		«selectEnumItems(it)»
	«ELSE»
		«nonEditableEnumField(it)»
	«ENDIF»
	'''
}

def static String jsfInputField(ViewDataProperty it) {
	'''
	«val for = it.this.userTask.for.name.toFirstLower()»
	<tr>
		<td class="headingCell">
			<h:outputLabel for="«for»_«name»" value="#{msg«resolveModuleName()»['«this.messageKey»']}" />:
		</td>
		<td>
			<«resolveJSFInputComponent(true)» id="«for»_«name»" label="#{msg«resolveModuleName()»['«this.messageKey»']}" value="#{«this.userTask.name»Form.«name»}" «IF this.isNullable()==false»required="true"«ENDIF»>
			«IF getTypeName() == "String" && !isSystemAttribute()»
				<f:validateLength maximum="«getDatabaseLength()»" />
			«ENDIF»
			  «resolveJSFInputConverterTag()»
			</«resolveJSFInputComponent(false)»>
			<h:message for="«for»_«name»" showSummary="true" showDetail="false" styleClass="fieldError" />
		</td>
	</tr>
	'''
}

/*TODO: Can't be correct, converter? See jsfOutputField  */
def static String nonEditableField(ViewDataProperty it) {
	'''
	<tr>
		<td>
			#{msg«resolveModuleName()»['«this.messageKey»']}:
		</td>
		<td>
			#{«this.userTask.name»Form.«name»}
		</td>
	</tr>
	'''
}

def static String jsfOutputField(ViewDataProperty it, boolean messageFor) {
	'''
	«IF getAttributeType() == "boolean" || getAttributeType() == "Boolean"»
		<h:outputText value="#{msg[«this.userTask.for.name.toFirstLower()».«this.getDOPropertyPath()» ? 'format.booleanTrue' : 'format.booleanFalse']}" «IF messageFor»id="«this.getDOPropertyPath().replaceAll("\\.", "_")»"«ENDIF»/>
	«ELSEIF resolveJSFOutputConverterTag() != '' »
		<h:outputText value="#{«this.userTask.for.name.toFirstLower()».«this.getDOPropertyPath()»}" «IF messageFor»id="«this.getDOPropertyPath().replaceAll("\\.", "_")»"«ENDIF»>
			«resolveJSFOutputConverterTag()»
		</h:outputText>
	«ELSE»
		<h:outputText value="#{«this.userTask.for.name.toFirstLower()».«this.getDOPropertyPath()»}" «IF messageFor»id="«this.getDOPropertyPath().replaceAll("\\.", "_")»"«ENDIF»/>
	«ENDIF»
	«IF messageFor»
		<h:message for="«this.getDOPropertyPath().replaceAll("\\.", "_")»" showSummary="true" showDetail="false" styleClass="fieldError" />
	«ENDIF»
	'''
}

def static String jsfOutputField(EnumViewProperty it) {
	'''
	«IF isNullable()»<c:if test='#{«this.userTask.for.name.toFirstLower()».«this.getDOPropertyPath()»} != ""'>«ENDIF»
	<c:set var="«this.getDOPropertyPath().replaceAll("\\.", "")»Name" value="#{'model.DomainObject.«this.reference.to.name».'}#{«this.userTask.for.name.toFirstLower()».«this.getDOPropertyPath()»}" />
	«IF isNullable()»</c:if>«ENDIF»
	<h:outputText value="#{msg[«this.getDOPropertyPath().replaceAll("\\.", "")»Name]}" id="«this.getDOPropertyPath()»"/>
	<h:message for="«this.getDOPropertyPath()»" showSummary="true" showDetail="false" styleClass="fieldError" />
	'''
}

def static String jsfOutputProperty(ViewDataProperty it, String property) {
	'''
	«IF getAttributeType() == "boolean" || getAttributeType() == "Boolean"»
		<h:outputText value="#{msg[«property» ? 'format.booleanTrue' : 'format.booleanFalse']}" />
	«ELSEIF resolveJSFOutputConverterTag() != '' »
		<h:outputText value="#{«property»}">
			«resolveJSFOutputConverterTag()»
		</h:outputText>
	«ELSE»
		#{«property»}
	«ENDIF»
	'''
}

def static String jsfOutputProperty(EnumViewProperty it, String property) {
	'''
	«IF isNullable()»<c:if test='#{«property»} != ""'>«ENDIF»
	<c:set var="«this.getDOPropertyPath().replaceAll("\\.", "")»Name" value="#{'model.DomainObject.«this.reference.to.name».'}#{«property»}" />
	«IF isNullable()»</c:if>«ENDIF»
	#{msg[«this.getDOPropertyPath().replaceAll("\\.", "")»Name]}
	'''
}

def static String selectEnumItems(EnumViewProperty it) {
	'''
	«val for = it.this.userTask.for.name.toFirstLower()»
	<tr>
		<td class="headingCell">
			<h:outputLabel for="«for»_«name»" value="#{msg«resolveModuleName()»['«this.messageKey»']}" />:
		</td>
		<td>
			<t:selectOneMenu id="«for»_«name»" value="#{«this.userTask.name»Form.«name»}" «IF this.isNullable()==false»required="true" «ENDIF»>
				«IF this.isNullable()»<f:selectItem itemLabel="" itemValue="#{null}" />«ENDIF»
				<t:selectItems value="#{«this.userTask.name»Form.«name»Items}" var="«name»Item"
					itemLabel="#{msg[«name»Item.label]}" itemValue="#{«name»Item.value}" />
			</t:selectOneMenu>
			<h:message for="«for»_«name»" showSummary="true" showDetail="false" styleClass="fieldError" />
		</td>
	</tr>
	'''
}

def static String nonEditableEnumField(EnumViewProperty it) {
	'''
	<tr>
		<td>
			#{msg«resolveModuleName()»['«this.messageKey»']}:
		</td>
		<td>
			#{«this.userTask.name»Form.«name»}
		</td>
	</tr>
	'''
}

def static String viewDomainObjectJsfInc(ViewTask it) {
	'''
	'''
	fileOutput("WEB-INF/generated/flows/" + module.name + "/" + name + "DomainObject.html", 'TO_GEN_WEBROOT', '''
	<div «faceletsXmlns(it)»>
	<div id="formInputFields">
		<fieldset>
			<legend>
				<h:outputFormat value="#{msg['view.fieldsLegend']}">
					<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name»']}" />
				</h:outputFormat>
			</legend>
			<table>
			«FOR prop : viewProperties.reject(p | p.metaType == ReferenceViewProperty || p.metaType == DerivedReferenceViewProperty)»
				«viewField(it) FOR prop»
			«ENDFOR»
			</table>
		</fieldset>
	</div>
	«IF !viewProperties.typeSelect(ReferenceViewProperty).isEmpty»
	<div id="formReferences">
		<c:choose>
		<c:when test="${viewDomainObjectLinkToReferences == 'true'}">
		«it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).forEach[viewReference(it)(true)]»
		</c:when>
		<c:otherwise>
		«it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).forEach[viewReference(it)(false)]»
		</c:otherwise>
		</c:choose>
	</div>
	«ENDIF»
	</div>
	'''
	)
	'''
	'''
}

def static String viewField(ViewDataProperty it) {
	'''
	«IF isSystemAttribute()»<c:if test="${viewDomainObjectSystemAttribute}" >«ENDIF»
		<tr>
			<td class="headingCell">#{msg«resolveModuleName()»['model.DomainObject.«this.userTask.for.name».«getDOPropertyPath()»']}:</td>
			<td>«jsfOutputField(it)(true) FOR this»</td>
		</tr>
	«IF isSystemAttribute()»</c:if>«ENDIF»
	'''
}

def static String viewReference(ReferenceViewProperty it, boolean links) {
	'''
	<fieldset>
	«formReferenceLegend(it) »
	<table class="references">
	«viewReferenceThead(it) »
	<tbody>
	«IF isMany()»
		«val item = it.reference.name.singular()»
		<t:dataList value="#{«reference.name»}" var="«item»Item" rowIndexVar="«item»Index">
		«IF reference.to.^abstract»
		<ui:fragment rendered="#{a:isOfType(«item»Item, '«target.getDomainPackage()».«target.name»')}">
		«ENDIF»
		<tr>
			<td>
				«IF links»
				<h:commandLink action="«resolveViewTransitionEventName()»" value="#{«item»Item.id}">
			    	<f:param name="index" value="#{«item»Index}" />
			    </h:commandLink>
			    «ELSE»
			    #{«item»Item.id}
				«ENDIF»
			</td>
			«FOR prop : previewProperties»
			<td>
				«IF links»
				<h:commandLink action="«resolveViewTransitionEventName()»">
			    	<f:param name="index" value="#{«item»Index}" />
			    	«jsfOutputProperty(it)(item + "Item." + prop.getDOPropertyPath()) FOR prop»
			    </h:commandLink>
			    «ELSE»
			    «jsfOutputProperty(it)(item + "Item." + prop.getDOPropertyPath()) FOR prop»
				«ENDIF»
			</td>
			«ENDFOR»
		</tr>
		«IF reference.to.^abstract»
		</ui:fragment>
		«ENDIF»
		</t:dataList>
	«ELSE»
		<c:if test="#{«reference.name» != null}">
			«IF reference.to.^abstract»
		<c:if test="#{a:isOfType(«reference.name», '«target.getDomainPackage()».«target.name»')}">
			«ENDIF»
		<tr>
			<td>
				«IF links»
				<h:commandLink action="«resolveViewTransitionEventName()»" value="#{«reference.name».id}">
				   	
				</h:commandLink>
				«ELSE»
				#{«reference.name».id}
				«ENDIF»
			</td>
			«FOR prop : previewProperties»
			<td>
			«IF links»
			<h:commandLink action="«resolveViewTransitionEventName()»">
				«jsfOutputProperty(it)(reference.name + "." + prop.getDOPropertyPath()) FOR prop»
			</h:commandLink>
			«ELSE»
				«jsfOutputProperty(it)(reference.name + "." + prop.getDOPropertyPath()) FOR prop»
			«ENDIF»
			</td>
			«ENDFOR»
		</tr>
			«IF reference.to.^abstract»
		</c:if>
			«ENDIF»
		</c:if>
	«ENDIF»
	</tbody>
	</table>
	</fieldset>
	'''
}

def static String viewReferenceThead(ReferenceViewProperty it) {
	'''
	<thead>
	<tr>
		<th>#{msg«resolveModuleName()»['model.DomainObject.«target.name».id']}</th>
		«FOR prop : previewProperties»
		<th>#{msg«resolveModuleName()»['«prop.messageKey»']}</th>
		«ENDFOR»
	</tr>
	</thead>
	'''
}

def static String errorJsf(GuiApplication it) {
	'''
	'''
	fileOutput("error.xhtml", 'TO_WEBROOT', '''
	«JSFCrudGuiFlowJsf::docType(it)»
	<html «faceletsXmlns(it)»>
	<body>
		<ui:composition template="/WEB-INF/common/template.xhtml">
			<ui:define name="content">
				<h1>#{msg['error.header']}</h1>
				<p><span class="errors">
					<c:if test="#{exception == null}">
						<h:outputFormat value="#{msg['«systemExceptionClass()»']}"
							escape="false">
							 <f:param value="page.error" />
							 <f:param value="" />
						</h:outputFormat>
					</c:if>
					<c:if test="#{exception != null}">
						<h:outputFormat value="#{msg['«systemExceptionClass()»']}"
							escape="false">
							 <f:param value="${a:resolveSystemExceptionErrorCode(exception)}" />
							 <f:param value="${a:resolveSystemExceptionMessage(exception)}" />
						</h:outputFormat>
					</c:if>
				</span></p>
			</ui:define>
		</ui:composition>
	</body>
	</html>
	'''
	)
	'''
	'''
}

/*
def static String formReferenceAbstractHiddenField(ReferenceViewProperty it) {
	'''
	«IF reference.to.^abstract && !isMany() »
		<form:hidden path="selected«name.singular().toFirstUpper()»" />
	«ENDIF»
	'''
}
 */

def static String formReference(ReferenceViewProperty it, String formName) {
	'''
	<fieldset>
	«formReferenceLegend(it)»
	«selectNewOrExistingButtons(it)("create", formName)»
	<table class="references">
	<thead>
		<tr>
			<th>#{msg«resolveModuleName()»['model.DomainObject.«target.name».id']}</th>
			«FOR prop : previewProperties»
			<th>#{msg«resolveModuleName()»['«prop.messageKey»']}</th>
			«ENDFOR»
			<th></th>
		</tr>
	</thead>
	<tbody>
	«IF isMany()»
		
		«val item = it.reference.name.singular()»
		<t:dataList value="#{«formName».«reference.name»}" var="«item»Item" rowIndexVar="«item»Index">
		«IF reference.to.^abstract»
		<ui:fragment rendered="#{a:isOfType(«item»Item, '«target.getDomainPackage()».«target.name»')}">
		«ENDIF»
		<tr>
		
		<td>	
			#{«reference.name.singular()»Item.id}
		</td>
		«FOR prop : previewProperties»
		<td>
			«jsfOutputProperty(it)(reference.name.singular() + "Item." + prop.getDOPropertyPath()) FOR prop»
		</td>
		«ENDFOR»
		<td class="actionCell">
			|
			<h:commandLink action="«resolveViewTransitionEventName()»" value="#{msg['createUpdate.subflowView']}">
				<f:param name="index" value="#{«item»Index}" />
			</h:commandLink>
			|
			«IF isUpdateSubTaskAvailable() »
			<h:commandLink action="«resolveUpdateTransitionEventName()»" value="#{msg['createUpdate.subflowUpdate']}">
				<f:param name="index" value="#{«item»Index}" />
			</h:commandLink>
			|
			«ENDIF»
			<h:commandLink action="«resolveRemoveTransitionEventName()»" value="#{msg['createUpdate.subflowDelete']}">
				<f:param name="index" value="#{«item»Index}" />
			</h:commandLink>
			|
		</td>
		</tr>
		«IF reference.to.^abstract»
		</ui:fragment>
		«ENDIF»
		</t:dataList>
		
	«ELSE»
		
		«IF reference.to.^abstract»
		<c:if test="#{a:isOfType(«formName».«reference.name», '«target.getDomainPackage()».«target.name»')}">
		«ENDIF»
		
		<c:if test="#{«formName».«reference.name» != null}">
		<tr>
			<td>#{«formName».«reference.name».id}</td>
			«FOR prop : previewProperties»
			<td>
			«jsfOutputProperty(it)(formName + "." + reference.name + "." + prop.getDOPropertyPath()) FOR prop»
			</td>
			«ENDFOR»
			<td class="actionCell">
				|
				<h:commandLink action="«resolveViewTransitionEventName()»" value="#{msg['createUpdate.subflowView']}" />
				|
				<h:commandLink action="«resolveRemoveTransitionEventName()»" value="#{msg['createUpdate.subflowDelete']}"/>
				|
			</td>
		</tr>
		</c:if>
		
		«IF reference.to.^abstract»
		</c:if>
		«ENDIF»
		
	«ENDIF»
	</tbody>
	</table>
	</fieldset>
	'''
}

def static String formReferenceLegend(ReferenceViewProperty it) {
	'''
	<legend>
		<h:outputFormat value="#{msg«resolveModuleName(this.userTask)»['model.DomainObject.«reference.from.name».«reference.name»']}">
			<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«target.name»']}" />
		</h:outputFormat>
	</legend>
	'''
}

def static String selectNewOrExistingButtons(ReferenceViewProperty it, String eventPrefix, String formName) {
	'''
	<c:if test="«selectNewOrExistingButtonsRuntimeCondition(it)(eventPrefix, formName)»">
		«val notChangeable  = it.!isMany() && !reference.changeable»
		«IF notChangeable »
		<c:choose>
		<c:when test="#{«formName».«reference.name» == null}">
		«ENDIF»
	«IF isCreateSubTaskAvailable() »
	<p style="text-align: right;">
		<h:commandLink action="«resolveCreateTransitionEventName()»">
			<h:outputFormat value="#{msg['createUpdate.subflow«eventPrefix.toFirstUpper()»']}">
				<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«target.name»']}" />
			</h:outputFormat>		
		</h:commandLink>
	</p>		
	«ENDIF »
	«IF isAddSubTaskAvailable() »
	<span class="headerButtonContainer">
		#{msg['createUpdate.selectLabel']}
		«selectExistingItems(it)(formName)»
		«IF isMany() »
		<h:commandButton value="#{msg['createUpdate.addExisting']}" id="«resolveAddExistingChildEventName()»" action="«resolveAddExistingChildEventName()»" />		
		«ELSE»
		<h:commandButton value="#{msg['createUpdate.setExisting']}" id="«resolveAddExistingChildEventName()»" action="«resolveAddExistingChildEventName()»" 
			«IF reference.to.^abstract»  onclick="this.form.selected«reference.name.singular().toFirstUpper()».value=this.form.«resolveSelectedExistingChildIdAttributeName()».options[this.form.«resolveSelectedExistingChildIdAttributeName()».selectedIndex].value" «ENDIF»/>		
		«ENDIF»
	</span>
	«ENDIF»
		«IF notChangeable »
		</c:when>
		<c:otherwise>
	/*<form:hidden path="«resolveSelectedExistingChildIdAttributeName()»"/> */
		</c:otherwise>
		</c:choose>
		«ENDIF»
	</c:if>
	'''
}

def static String selectNewOrExistingButtonsRuntimeCondition(ReferenceViewProperty it, String eventPrefix, String formName) {
	'''
	${flowExecutionContext.activeSession.root or 
				(flowExecutionContext.activeSession.parent.definition.id != '«userTask.module.name»/create«target.name»' and
				 flowExecutionContext.activeSession.parent.definition.id != '«userTask.module.name»/update«target.name»')
	}	'''
}


def static String selectExistingItems(ReferenceViewProperty it, String formName) {
	'''
		<t:selectOneMenu id="ref_«resolveSelectedExistingChildIdAttributeName()»" value="#{«formName».«resolveSelectedExistingChildIdAttributeName()»}">
					<f:selectItem itemLabel="#{msg['createUpdate.unselectedOptionWithoutParam']} #{msg«resolveModuleName()»['model.DomainObject.«target.name»']}" itemValue="" />
					<f:selectItems value="#{«formName».«target.name.toFirstLower()»Items}" />
				</t:selectOneMenu>
				<h:message for="ref_«resolveSelectedExistingChildIdAttributeName()»" showSummary="true" showDetail="false" styleClass="fieldError" />
	'''
}

def static String formActionButtons(UserTask it) {
	'''
	<div id="formActionButtons">
	«IF metaType == UpdateTask»
	<h:commandButton action="submit" value="#{msg['createUpdate.next']}" id="next" disabled="#{!«name»Form.nextEnabled}" />
	«ELSE»
	<h:commandButton action="submit" value="#{msg['createUpdate.next']}" id="next" />
	«ENDIF»
	<sf:commandButton action="cancel" value="#{msg['createUpdate.cancel']}" id="cancel"/>
	</div>
	'''
}
}
