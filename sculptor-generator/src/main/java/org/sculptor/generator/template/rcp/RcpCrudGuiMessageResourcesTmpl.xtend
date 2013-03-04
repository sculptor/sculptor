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

class RcpCrudGuiMessageResourcesTmpl {



def static String messageResources(GuiApplication it) {
	'''
	«commonResourcesProperties(it)»
	«commonResourcesJava(it)»
	«it.modules.forEach[moduleResourcesProperties(it)]»
	«it.modules.forEach[moduleResourcesJava(it)]»

	«pluginProperties(it)»
	'''
}

def static String commonResourcesProperties(GuiApplication it) {
	'''
	'''
	fileOutput("i18n/messages" + getResourceBundleLocaleSuffix() + ".properties", 'TO_GEN_RESOURCES', '''
	breadCrumb_separator=\ >
	breadCrumb_update=Edit
	breadCrumb_add=Add
	newButton=New
	editButton=Edit
	removeButton=Remove
	remove_question=Remove {0} from {1}
	remove_question_title=Remove
	addButton_one=Select
	addButton_many=Add
	readJob=Retrieving {0}
	deleteJob=Deleting {0}
	updateJob=Saving {0}
	createJob=Saving {0}
	fetchChildrenJob=Fetching children of '{0}'
	errorNode=Not Available
	emptyDetailsPageInfo=This node has no information
	newWizardPage_initFromSelected=Init From Selected Element
	newWizardPage_title=New {0}
	newWizardPage_reference={0} ({1}) reference
	newWizardPage_reference_many={0} ({1}) references
	detailsPage_reference={0} ({1}) reference
	detailsPage_reference_many={0} ({1}) references
	booleanSelect_false=no
	booleanSelect_true=yes
	validation_required={0} is required
	validation_too_long={0} is too long. Max is {1}.
	validation_invalidFormat=Invalid format of {0}
	format_datePattern=yyyy-MM-dd
	format_dateTimePattern=yyyy-MM-dd HH:mm:ss
	delete_question=Delete {0} {1}?
	delete_title=Confirm Delete
	listView_filter_label=Find
	listView_clear_filter_tooltip=Clear Text Filter
	listView_columns_adjust=Adjust Column Widths
	listView_columns_choose=Choose Columns
	listView_columns_refresh=Refresh
	navigationMasterDetail_title=«name.toFirstUpper().toPresentation()»
	save_question=You have unsaved changes. Do you want to save your changes?
	save_question_title=Save
	generalPrefeferences_auto_login=Login automatically at startup
	initErrorTitle=Initialization Error
	initErrorMessage=Failed to initialize application or connect to server.\nMore information is available in error log.\nApplication will be closed.

	«systemExceptionClass().replaceAll("\\.", "_")»=System error
	org_fornax_cartridges_sculptor_framework_errorhandling_OptimisticLockingException=The information was updated by another user. Please redo your changes.
	org_fornax_cartridges_sculptor_framework_errorhandling_ValidationException=Validation error

	«domainObjectsWithoutTaskProperties(it)»
	'''
	)
	'''
	'''
}

def static String commonResourcesJava(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage() + ".Messages") , '''
	«javaHeader()»
	package «getRichClientPackage()»;

/**
 * Common message resources.
 */
	public class Messages ^extends org.eclipse.osgi.util.NLS {
		private static final String BUNDLE_NAME = "i18n.messages"; //$NON-NLS-1$
		public static String breadCrumb_separator;
		public static String breadCrumb_update;
		public static String breadCrumb_add;
		public static String newButton;
		public static String editButton;
		public static String removeButton;
		public static String remove_question;
		public static String remove_question_title;
		public static String addButton_one;
		public static String addButton_many;
		public static String readJob;
		public static String deleteJob;
		public static String updateJob;
		public static String createJob;
		public static String fetchChildrenJob;
		public static String errorNode;
		public static String emptyDetailsPageInfo;
		public static String newWizardPage_initFromSelected;
		public static String newWizardPage_title;
		public static String newWizardPage_reference;
		public static String newWizardPage_reference_many;
		public static String detailsPage_reference;
		public static String detailsPage_reference_many;
		public static String booleanSelect_false;
		public static String booleanSelect_true;
		public static String validation_required;
		public static String validation_too_long;
		public static String validation_invalidFormat;
		public static String format_datePattern;
		public static String format_dateTimePattern;
		public static String delete_question;
		public static String delete_title;
		public static String listView_filter_label;
		public static String listView_clear_filter;
		public static String listView_columns_adjust;
		public static String listView_columns_choose;
		public static String listView_columns_refresh;
		public static String navigationMasterDetail_title;
		public static String save_question;
		public static String save_question_title;
		public static String generalPrefeferences_auto_login;
		public static String initErrorTitle;
		public static String initErrorMessage;

		«domainObjectsWithoutTaskJava(it)»

		static {
			// initialize resource bundle
			org.eclipse.osgi.util.NLS.initializeMessages(BUNDLE_NAME, Messages.class);
		}

		protected Messages() {
		}

		public static String getString(String key) {
			try {
				java.lang.reflect.Field field = Messages.class.getField(key);
				return (String) field.get(null);
			} catch (Exception e) {
				String value = "NLS missing message: " + key + " in: " + BUNDLE_NAME; //$NON-NLS-1$ //$NON-NLS-2$
				// TODO log
				return value;
			}
		}
	}
	'''
	)
	'''
	'''
}

def static String domainObjectsWithoutTaskProperties(GuiApplication it) {
	'''
	«val domainObjectsWithTask  = it.modules.userTasks.for.toSet()»
	«val allViewProperties  = it.modules.userTasks.viewProperties»
	«LET allViewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).target. addAll(allViewProperties.typeSelect(EnumViewProperty).reference.to).
	addAll(allViewProperties.typeSelect(BasicTypeViewProperty).reference.to).toSet().
	reject(e|domainObjectsWithTask.contains(e))
	AS domainObjectsWithoutTask »
	«IF !domainObjectsWithoutTask.isEmpty »

	# Referenced Domain Objects without direct UserTask,
	# i.e. not belonging to a specific GuiModule
	«it.domainObjectsWithoutTask.sortBy(e|e.name) .forEach[resourcesProperties(it)]»
	«ENDIF »
	'''
}

def static String domainObjectsWithoutTaskJava(GuiApplication it) {
	'''
	«val domainObjectsWithTask  = it.modules.userTasks.for.toSet()»
	«val allViewProperties  = it.modules.userTasks.viewProperties»
	«LET allViewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).target. addAll(allViewProperties.typeSelect(EnumViewProperty).reference.to).
	addAll(allViewProperties.typeSelect(BasicTypeViewProperty).reference.to).toSet().
	reject(e|domainObjectsWithTask.contains(e))
	AS domainObjectsWithoutTask »
	«IF !domainObjectsWithoutTask.isEmpty »

		// Referenced Domain Objects without direct UserTask,
		// i.e. not belonging to a specific GuiModule
	«it.domainObjectsWithoutTask.sortBy(e|e.name) .forEach[resourcesJava(it)]»
	«ENDIF »
	'''
}

def static String moduleResourcesProperties(GuiModule it) {
	'''
	'''
	fileOutput("i18n/" + name + "Messages" + getResourceBundleLocaleSuffix() + ".properties", 'TO_GEN_RESOURCES', '''

	«resourcesProperties(it) FOREACH userTasks.for.addAll(userTasks.for.filter(e|e.^extends != null).collect(e|e.^extends)).
	toSet().sortBy(e|e.name) »

	«it.userTasks.typeSelect(CreateTask).forEach[newWizardProperties(it)]»

	«moduleApplicationExceptionResources(it) »

	'''
	)
	'''
	'''
}

def static String moduleResourcesJava(GuiModule it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + name.toFirstUpper() + "Messages") , '''
	«javaHeader()»
	package «getRichClientPackage()»;

/**
 * Message resources for the «name» module.
 */
	public class «name.toFirstUpper()»Messages ^extends «application.getRichClientPackage()».Messages {
		private static final String BUNDLE_NAME = "i18n.«name»Messages"; //$NON-NLS-1$

		«resourcesJava(it) FOREACH userTasks.for.addAll(userTasks.for.filter(e|e.^extends != null).collect(e|e.^extends)).
		toSet().sortBy(e|e.name) »

		«it.userTasks.typeSelect(CreateTask).forEach[newWizardJava(it)]»

		static {
			// initialize resource bundle
			org.eclipse.osgi.util.NLS.initializeMessages(BUNDLE_NAME, «name.toFirstUpper()»Messages.class);
		}

		protected «name.toFirstUpper()»Messages() {
		}

		public static String getString(String key) {
			try {
				java.lang.reflect.Field field = «name.toFirstUpper()»Messages.class.getField(key);
				return (String) field.get(null);
			} catch (Exception e) {
				String value = "NLS missing message: " + key + " in: " + BUNDLE_NAME; //$NON-NLS-1$ //$NON-NLS-2$
				// TODO log
				return value;
			}
		}
	}
	'''
	)
	'''
	'''
}

def static String resourcesProperties(DomainObject it) {
	'''
	# «name»
	«getMessagesKey()»=«name.toPresentation()»
	«getMessagesKey()»_plural=«name.plural().toPresentation()»
	«it.getAllAttributes() .forEach[resourcesProperties(it)(this)]»
	«it.getAllBasicTypeReferences() .forEach[basicTypeResourcesProperties(it)(this)]»
	«it.getAllReferences().filter(ref | ref.to.metaType != BasicType) .forEach[resourcesProperties(it)(this)]»
	'''
}

def static String resourcesJava(DomainObject it) {
	'''
// «name»
	public static String «getMessagesKey()»;
	public static String «getMessagesKey()»_plural;
	«it.getAllAttributes() .forEach[resourcesJava(it)(this)]»
	«it.getAllBasicTypeReferences() .forEach[basicTypeResourcesJava(it)(this)]»
	«it.getAllReferences().filter(ref | ref.to.metaType != BasicType) .forEach[resourcesJava(it)(this)]»
	'''
}

def static String resourcesProperties(Attribute it, DomainObject d) {
	'''
	«d.getMessagesKey()»_«name»=«name.toFirstUpper().toPresentation()»
	'''
}

def static String resourcesJava(Attribute it, DomainObject d) {
	'''
	public static String «d.getMessagesKey()»_«name»;
	'''
}

def static String basicTypeResourcesProperties(Reference it, DomainObject d) {
	'''
	«FOR att  : to.getAllNonSystemAttributes()»
	«d.getMessagesKey()»_«name»_«att.name»=«name.toFirstUpper().toPresentation()» «att.name.toPresentation()»
	«ENDFOR»
	«FOR enumRef  : to.getAllEnumReferences()»
	«d.getMessagesKey()»_«name»_«enumRef.name»=«name.toFirstUpper().toPresentation()» «enumRef.name.toPresentation()»
	«ENDFOR»
	'''
}

def static String basicTypeResourcesJava(Reference it, DomainObject d) {
	'''
	«FOR att  : to.getAllNonSystemAttributes()»
	public static String «d.getMessagesKey()»_«name»_«att.name»;
	«ENDFOR»
	«FOR enumRef  : to.getAllEnumReferences()»
	public static String «d.getMessagesKey()»_«name»_«enumRef.name»;
	«ENDFOR»
	'''
}

def static String resourcesProperties(Reference it, DomainObject d) {
	'''
	«IF to.metaType == Enum»
	«d.getMessagesKey()»_«name»=«name.toFirstUpper().toPresentation()»
	«ELSE»
	«d.getMessagesKey()»_«name»=«name.toFirstUpper().toPresentation()»
	«ENDIF»
	'''
}

def static String resourcesJava(Reference it, DomainObject d) {
	'''
	«IF to.metaType == Enum»
	public static String «d.getMessagesKey()»_«name»;
	«ELSE»
	public static String «d.getMessagesKey()»_«name»;
	«ENDIF»
	'''
}

def static String resourcesProperties(Enum it) {
	'''
	# «name»
	«getMessagesKey()»=«name.toPresentation()»
	«getMessagesKey()».plural=«name.plural().toPresentation()»
	«it.values .forEach[resourcesProperties(it)(this)]»
	'''
}

def static String resourcesJava(Enum it) {
	'''
// «name»
	public static String «getMessagesKey()»_«name»;
	public static String «getMessagesKey()»_«name»_plural;
	«it.values .forEach[resourcesJava(it)(this)]»
	'''
}

def static String resourcesProperties(EnumValue it, DomainObject d) {
	'''
	«d.getMessagesKey()»_«name»=«name.toFirstUpper().toPresentation()»
	'''
}

def static String resourcesJava(EnumValue it, DomainObject d) {
	'''
	public static String «d.getMessagesKey()»_«name»;
	'''
}

def static String newWizardProperties(CreateTask it) {
	'''
	new«for.name»WizardPage_description=Create a new «for.name.toPresentation()»
	'''
}

def static String newWizardJava(CreateTask it) {
	'''
		public static String new«for.name»WizardPage_description;
	'''
}

def static String moduleApplicationExceptionResources(GuiModule it) {
	'''
	# ApplicationException
		«FOR exc  : getApplicationExceptions()»
	#«exc.replaceAll("\\.", "_")»=«exc»
		«ENDFOR»
	'''
}

def static String messageSourceDependencyProperty(Object it) {
	'''
		private org.springframework.context.MessageSource messages;

		protected org.springframework.context.MessageSource getMessages() {
			return messages;
		}

		/**
			* Dependency injection
			*/
		@org.springframework.beans.factory.annotation.Autowired
		public void setMessages(org.springframework.context.MessageSource messages) {
			this.messages = messages;
		}
	'''
}

def static String pluginProperties(GuiApplication it) {
	'''
	'''
	fileOutput("plugin.properties", 'TO_GEN_ROOT', '''
	«pluginPropertiesContent(it)»
	'''
	)
	'''
	'''
}

def static String pluginPropertiesContent(GuiApplication it) {
	'''
	productName=«name.toPresentation()» Product
	aboutText=«name.toPresentation()» \n\n\n\nSilk icons: http://www.famfamfam.com/lab/icons/silk/

	fileMenuLabel=File
	fileMenuMnemonic=F
	exitMenuItemLabel=Exit
	exitMenuItemMnemonic=x
	listMenuLabel=List
	openInNewMenuItemLabel=Open in New Window
	openInNewMenuItemMnemonic=N
	progressMenuItemLabel=Progress
	resetPerspectiveMenuItemLabel=Reset Perspective
	preferencesMenuItemLabel=Preferences
	preferencesGeneral=General
	aboutMenuItemLabel=About
	aboutMenuItemMnemonic=A
	newMenuItemLabel=New
	deleteMenuItemLabel=Delete

	collapseAllCommandName=Collapse All
	showprogressCommandName=Show Progress View
	selectInMainViewCommandName=Edit

	mainViewName=Main
	«it.modules.userTasks.typeSelect(ListTask).forEach[pluginPropertiesViewName(it)]»
	«it.modules.userTasks.filter(e | e.getPrimaryServiceOperation() != null).forEach[pluginPropertiesCommandName(it)]»
	«it.modules.userTasks.typeSelect(CreateTask).forEach[pluginPropertiesWizardName(it)]»

	'''
}

def static String pluginPropertiesViewName(ListTask it) {
	'''
	list«for.name»ViewName=List «for.name.plural().toPresentation()»	'''
}

def static String pluginPropertiesCommandName(UserTask it) {
	'''	'''
}

def static String pluginPropertiesCommandName(CreateTask it) {
	'''
	new«for.name»CommandName=«for.name»	'''
}

def static String pluginPropertiesCommandName(ListTask it) {
	'''
	showList«for.name»ViewCommandName=«for.name.plural().toPresentation()»	'''
}

def static String pluginPropertiesWizardName(CreateTask it) {
	'''
	new«for.name»WizardName=New «for.name»	'''
}
}
