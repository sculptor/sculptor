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

class JSFGuiResourceBundleTmpl {


def static String resourceBundle(GuiApplication it) {
	'''
	«messagesResourceBundle(it) »
	«defaultMessagesResourceBundle(it) »
	«it.modules.forEach[moduleMessagesResourceBundle(it)]»
	'''
}

def static String messagesResourceBundle(GuiApplication it) {
	'''
	'''
	fileOutput("i18n/messages" + getResourceBundleLocaleSuffix() + ".properties", 'TO_GEN_RESOURCES', '''
	# Navigation texts
	navigation.title={0} Client
	navigation.create=Create {0}
	navigation.list=List all {0}

	# Welcome (index) page
	welcome.header=Welcome to the {0} client

	# List page
	list.header=List of {0}
	list.actions=actions
	list.edit=edit
	list.delete=delete
	list.pageLabel=Page:
	list.maxPagesLabel=of:

	# View page
	view.header=Detailed view of {0}
	view.header.withId=with id: {0}
	view.fieldsLegend={0} fields
	view.ok=Ok

	# Create and Update page
	create.formHeader=Create new {0}
	update.formHeader=Update {0}
	create.confirmHeader=Create {0} confirmation
	update.confirmHeader=Update {0} confirmation
	create.doneHeader={0} created with id: {1}
	update.doneHeader={0} with id {1} updated
	createUpdate.fieldsLegend={0} fields
	createUpdate.cancel=Cancel
	createUpdate.back=<- Back
	createUpdate.next=Next ->
	createUpdate.subflowView=View
	createUpdate.subflowUpdate=Edit
	createUpdate.subflowDelete=Remove
	createUpdate.subflowCreate=Create {0}
	createUpdate.selectLabel=
	createUpdate.unselectedOption=--Select existing {0}
	createUpdate.unselectedOptionWithoutParam=--Select existing
	createUpdate.addExisting=Add
	createUpdate.setExisting=Set
	createUpdate.unselectedEnumOption=--Select {0}
	create.save=Save
	update.save=Save

	# Delete page
	delete.header=Are you sure you want to delete {0}
	delete.header.withId=with id: {0}
	delete.doneHeader=Deleted {0} with id: {1}
	delete.no=No
	delete.yes=Yes

	# Error page
	error.header=An internal fault occurred

	# Texts from DSL model
	model.application.name=«name»
	«val domainObjectsWithTask  = it.modules.userTasks.for.toSet()»
	«val allViewProperties  = it.modules.userTasks.viewProperties»
	«LET allViewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).target. addAll(allViewProperties.typeSelect(EnumViewProperty).reference.to).
	addAll(allViewProperties.typeSelect(BasicTypeViewProperty).reference.to).toSet().
	reject(e|domainObjectsWithTask.contains(e))
	AS domainObjectsWithoutTask »
	«IF !domainObjectsWithoutTask.isEmpty »

	# Referenced Domain Objects without direct UserTask,
	# i.e. not belonging to a specific GuiModule
	«it.domainObjectsWithoutTask.sortBy(e|e.name) .forEach[resources(it)]»
	«ENDIF »

	«formatResources(it)»

	«defaultResources(it)»

	'''
	)
	'''
	'''
}

def static String moduleMessagesResourceBundle(GuiModule it) {
	'''
	'''
	fileOutput("i18n/" + name + "Messages" + getResourceBundleLocaleSuffix() + ".properties", 'TO_GEN_RESOURCES', '''
	# Domain Objects
	«resources(it) FOREACH userTasks.for.addAll(userTasks.for.filter(e|e.^extends != null).collect(e|e.^extends)).
	toSet().sortBy(e|e.name) »
	«moduleApplicationExceptionResources(it) »
	'''
	)
	'''
	'''
}

def static String moduleApplicationExceptionResources(GuiModule it) {
	'''
	# ApplicationException
		«FOR exc  : getApplicationExceptions()»
	#«exc»=«exc»
		«ENDFOR»
	'''
}

def static String defaultMessagesResourceBundle(GuiApplication it) {
	'''
	'''
	fileOutput("i18n/defaultMessages.properties", 'TO_GEN_RESOURCES', '''
	«defaultResources(it)»
	'''
	)
	'''
	'''
}

def static String resources(DomainObject it) {
	'''
	# «name»
	model.DomainObject.«name»=«name.toPresentation()»
	model.DomainObject.«name».plural=«name.plural().toPresentation()»
	«it.getAllAttributes() .forEach[resources(it)(this)]»
	«it.getBasicTypeReferences() .forEach[basicTypeResources(it)(this)]»
	«it.references.filter(ref | ref.to.metaType != BasicType) .forEach[resources(it)]»
	'''
}

def static String resources(Attribute it, DomainObject d) {
	'''
	model.DomainObject.«d.name».«name»=«name.toFirstUpper().toPresentation()»
	'''
}

def static String basicTypeResources(Reference it, DomainObject d) {
	'''
	«FOR att  : to.getAllNonSystemAttributes()»
	model.DomainObject.«d.name».«name».«att.name»=«name.toFirstUpper().toPresentation()» «att.name.toPresentation()»
	«ENDFOR»
	«FOR enumRef  : to.getAllEnumReferences()»
	model.DomainObject.«d.name».«name».«enumRef.name»=«name.toFirstUpper().toPresentation()» «enumRef.name.toPresentation()»
	«ENDFOR»
	'''
}

def static String resources(Reference it) {
	'''
	«IF to.metaType == Enum»
	model.DomainObject.«from.name».«name»=«name.toFirstUpper().toPresentation()»
	«ELSE»
	model.DomainObject.«from.name».«name»=«name.toFirstUpper().toPresentation()» ({0}) « ((isOneToMany() || isManyToMany()) ? 'references': 'reference')»
	«ENDIF»
	'''
}

def static String resources(Enum it) {
	'''
	# «name»
	model.DomainObject.«name»=«name.toPresentation()»
	model.DomainObject.«name».plural=«name.plural().toPresentation()»
	«it.values .forEach[resources(it)(this)]»
	'''
}

def static String resources(EnumValue it, DomainObject d) {
	'''
	model.DomainObject.«d.name».«name»=«name.toFirstUpper().toPresentation()»
	'''
}

def static String defaultResources(GuiApplication it) {
	'''
	# Bread Crumb
	breadCrumb.list=List
	breadCrumb.create=Create
	breadCrumb.update=Edit
	breadCrumb.view=View
	breadCrumb.delete=Delete

	«IF isJSFCrudGuiToBeGenerated()»
	«FOR item- : modules.userTasks.for.addAll(modules.userTasks.for.filter(e|e.^extends != null).collect(e|e.^extends)). toSet().sortBy(e|e.name)»
	breadCrumb.«item.name»=«item.name.toPresentation()»
	breadCrumb.«item.name».plural=«item.name.plural().toPresentation()»
	«ENDFOR»
	«ENDIF»

	# SystemException
	«systemExceptionClass()»=System error ({0}), <br/>caused by: {1}«IF isHighlightMissingMessageResources()» [??? «systemExceptionClass()»]«ENDIF»

	# ApplicationException
	«fw("errorhandling.OptimisticLockingException")»=The information was updated by another user. Please redo your changes.

	# Validation errors
	required=Required«IF isHighlightMissingMessageResources()» [??? required]«ENDIF»
	typeMismatch=Invalid type«IF isHighlightMissingMessageResources()» [??? typeMismatch]«ENDIF»
	typeMismatch.java.lang.Integer=Invalid number«IF isHighlightMissingMessageResources()» [??? typeMismatch.java.lang.Integer]«ENDIF»
	typeMismatch.java.lang.Long=Invalid number«IF isHighlightMissingMessageResources()» [??? typeMismatch.java.lang.Long]«ENDIF»
	typeMismatch.java.math.Double=Invalid decimal number«IF isHighlightMissingMessageResources()» [??? typeMismatch.java.math.Double]«ENDIF»
	typeMismatch.java.math.BigDecimal=Invalid decimal number«IF isHighlightMissingMessageResources()» [??? typeMismatch.java.math.BigDecimal]«ENDIF»
	typeMismatch.java.util.Date=Invalid date«IF isHighlightMissingMessageResources()» [??? typeMismatch.java.util.Date]«ENDIF»
	«IF getDateTimeLibrary() == "joda"»
	typeMismatch.org.joda.time.LocalDate=Invalid date«IF isHighlightMissingMessageResources()» [??? typeMismatch.org.joda.time.LocalDate]«ENDIF»
	typeMismatch.org.joda.time.DateTime=Invalid date/time«IF isHighlightMissingMessageResources()» [??? typeMismatch.org.joda.time.DateTime]«ENDIF»
	«ENDIF»
	«IF isJSFCrudGuiToBeGenerated()»
	required.reference={0} reference is required
/*See http://www.jsf-faq.com/faqs/faces-messages.html#126
	and http://forum.java.sun.com/thread.jspa?threadID=677420&messageID=9483204
 */
	org.apache.myfaces.Date.INVALID=Invalid date«IF isHighlightMissingMessageResources()» [??? typeMismatch.java.util.Date]«ENDIF»
	javax.faces.component.UIInput.CONVERSION=Conversion error occurred«IF isHighlightMissingMessageResources()» [??? javax.faces.component.UIInput.CONVERSION]«ENDIF»
	javax.faces.component.UIInput.REQUIRED=Required«IF isHighlightMissingMessageResources()» [??? javax.faces.component.UIInput.REQUIRED]«ENDIF»
	javax.faces.component.UISelectOne.INVALID=Value is not a a valid option«IF isHighlightMissingMessageResources()» [??? javax.faces.component.UISelectOne.INVALID]«ENDIF»
	javax.faces.component.UISelectMany.INVALID=Value is not a valid option«IF isHighlightMissingMessageResources()» [??? javax.faces.component.UISelectMany.INVALID]«ENDIF»
	javax.faces.validator.NOT_IN_RANGE=Specified attribute is not between the expected values of {0} and {1}«IF isHighlightMissingMessageResources()» [??? javax.faces.validator.NOT_IN_RANGE]«ENDIF»
	javax.faces.validator.DoubleRangeValidator.MAXIMUM=Value is greater than allowable maximum of '{0}'«IF isHighlightMissingMessageResources()» [??? javax.faces.validator.DoubleRangeValidator.MAXIMUM]«ENDIF»
	javax.faces.validator.DoubleRangeValidator.MINIMUM=Value is less than allowable minimum of '{0}'«IF isHighlightMissingMessageResources()» [??? javax.faces.validator.DoubleRangeValidator.MINIMUM]«ENDIF»
	javax.faces.validator.DoubleRangeValidator.TYPE=Value is not of the correct type«IF isHighlightMissingMessageResources()» [??? javax.faces.validator.DoubleRangeValidator.TYPE]«ENDIF»
	javax.faces.validator.LengthValidator.MAXIMUM=Value is greater than allowable maximum of '{0}'«IF isHighlightMissingMessageResources()» [??? javax.faces.validator.LengthValidator.MAXIMUM]«ENDIF»
	javax.faces.validator.LengthValidator.MINIMUM=Value is less than allowable minimum of '{0}'«IF isHighlightMissingMessageResources()» [??? javax.faces.validator.LengthValidator.MINIMUM]«ENDIF»
	javax.faces.validator.LongRangeValidator.MAXIMUM=Value is greater than allowable maximum of '{0}'«IF isHighlightMissingMessageResources()» [??? javax.faces.validator.LongRangeValidator.MAXIMUM]«ENDIF»
	javax.faces.validator.LongRangeValidator.MINIMUM=Value is less than allowable minimum of '{0}'«IF isHighlightMissingMessageResources()» [??? javax.faces.validator.LongRangeValidator.MINIMUM]«ENDIF»
	javax.faces.validator.LongRangeValidator.TYPE=Value is not of the correct type«IF isHighlightMissingMessageResources()» [??? javax.faces.validator.LongRangeValidator.TYPE]«ENDIF»
	«ENDIF»
	error.value.too.long=Max length is {0}«IF isHighlightMissingMessageResources()» [??? error.value.too.long]«ENDIF»
	«fw("errorhandling.ValidationException")»=Validation error
	'''
}

def static String formatResources(GuiApplication it) {
	'''
	# format patterns
	format.DatePattern=yyyy-MM-dd
	format.DateTimePattern=yyyy-MM-dd HH:mm
	format.booleanTrue=yes
	format.booleanFalse=no
	'''
}



}
