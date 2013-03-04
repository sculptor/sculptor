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

class RcpCrudGuiPreferencesTmpl {



def static String preferences(GuiApplication it) {
	'''
	«preferenceInitializer(it)»
	«IF isGapClassToBeGenerated("", "PreferenceInitializer")»
		«gapPreferenceInitializer(it)»
	«ENDIF»
	«generalPreferencePage(it)»
	«IF isGapClassToBeGenerated("", "GeneralPreferencePage")»
		«gapGeneralPreferencePage(it)»
	«ENDIF»
			
	'''
} 

def static String gapPreferenceInitializer(GuiApplication it) {
	'''
	«val className = it."PreferenceInitializer"»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage()»;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String preferenceInitializer(GuiApplication it) {
	'''
	«val className = it."PreferenceInitializer" + gapSubclassSuffix("PreferenceInitializer")»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className) , '''
	«javaHeader()»
	package «getRichClientPackage()»;

	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer {
		
		public «className»() {
		}

	public void initializeDefaultPreferences() {
		org.eclipse.core.runtime.preferences.IEclipsePreferences defaults = new org.eclipse.core.runtime.preferences.DefaultScope()
				.getNode(«getRichClientPackage()».«name.toFirstUpper()»Plugin.PLUGIN_ID);
		defaults.putBoolean(«fw("richclient.login.LoginDialog")».AUTO_LOGIN_PREFERENCE, false);
	}

	}
	'''
	)
	'''
	'''
}


def static String gapGeneralPreferencePage(GuiApplication it) {
	'''
	«val className = it."GeneralPreferencePage"»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage()»;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String generalPreferencePage(GuiApplication it) {
	'''
	«val className = it."GeneralPreferencePage" + gapSubclassSuffix("GeneralPreferencePage")»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className) , '''
	«javaHeader()»
	package «getRichClientPackage()»;

/**
 * This class controls all aspects of the application's execution
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.jface.preference.FieldEditorPreferencePage implements
		org.eclipse.ui.IWorkbenchPreferencePage {

	«generalPreferencePageConstructor(it)»
	«generalPreferencePageFieldEditors(it)»
	«generalPreferencePagePerformOk(it)»
		
	}
	'''
	)
	'''
	'''
}

def static String generalPreferencePageConstructor(GuiApplication it) {
	'''
	private org.eclipse.ui.preferences.ScopedPreferenceStore preferences;

	public GeneralPreferencePage() {
		super(GRID);
		this.preferences = new org.eclipse.ui.preferences.ScopedPreferenceStore(new org.eclipse.core.runtime.preferences.ConfigurationScope(),
				«getRichClientPackage()».«name.toFirstUpper()»Plugin.PLUGIN_ID);
		setPreferenceStore(preferences);
	}

	public void init(org.eclipse.ui.IWorkbench workbench) {
	}
	
	protected org.eclipse.ui.preferences.ScopedPreferenceStore getPreferences() {
			return preferences;
		}
	'''
}

def static String generalPreferencePageFieldEditors(GuiApplication it) {
	'''
	@Override
		protected void createFieldEditors() {
		org.eclipse.jface.preference.BooleanFieldEditor boolEditor = new org.eclipse.jface.preference.BooleanFieldEditor(«fw("richclient.login.LoginDialog")».AUTO_LOGIN_PREFERENCE,
				«getRichClientPackage()».Messages.generalPrefeferences_auto_login, getFieldEditorParent());
		addField(boolEditor);
		}
	'''
}

def static String generalPreferencePagePerformOk(GuiApplication it) {
	'''
	@Override
	public boolean performOk() {
		try {
			preferences.save();
		} catch (java.io.IOException e) {
		    org.eclipse.core.runtime.Status status = new org.eclipse.core.runtime.Status(org.eclipse.core.runtime.IStatus.ERROR, «fw("richclient.SculptorFrameworkPlugin")».PLUGIN_ID, e.getMessage(), e);
	        org.eclipse.jface.util.Policy.getLog().log(status);
		}
		return super.performOk();
	}
	'''
}


}
