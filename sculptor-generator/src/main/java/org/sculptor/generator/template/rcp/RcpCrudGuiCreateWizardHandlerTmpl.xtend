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

class RcpCrudGuiCreateWizardHandlerTmpl {



def static String createWizardHandler(GuiApplication it) {
	'''
	«it.modules.forEach[createWizardHandler(it)]»
	'''
} 

def static String createWizardHandler(GuiModule it) {
	'''
	«it.userTasks.typeSelect(CreateTask).filter(e | e.getPrimaryServiceOperation() != null).forEach[createWizardHandler(it)]»
	'''
}

def static String createWizardHandler(CreateTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".handler.New" + for.name + "Handler") , '''
	«javaHeader()»
	package «module.getRichClientPackage()».handler;

/**
 * A handler for creating a new «for.name».
 * 
 */
	public class New«for.name»Handler ^extends org.eclipse.core.commands.AbstractHandler {
		
	«createWizardHandlerConstructor(it)»
	«createWizardHandlerEnabled(it)»
	«createWizardHandlerExecute(it)»
	}
	'''
	)
	'''
	'''
}

def static String createWizardHandlerConstructor(CreateTask it) {
	'''
		public New«for.name»Handler() {
		}
	'''
}

def static String createWizardHandlerEnabled(CreateTask it) {
	'''
		private boolean enabled = true;

		public boolean isEnabled() {
			return enabled;
		}

		public void setEnabled(boolean enabled) {
			this.enabled = enabled;
		}
	'''
}

def static String createWizardHandlerExecute(CreateTask it) {
	'''
		public Object execute(org.eclipse.core.commands.ExecutionEvent event) throws org.eclipse.core.commands.ExecutionException {
			try {
				«module.getRichClientPackage()».ui.New«for.name»Wizard wizard = («module.getRichClientPackage()».ui.New«for.name»Wizard) org.eclipse.ui.PlatformUI.getWorkbench().getNewWizardRegistry().findWizard(
				        «module.getRichClientPackage()».ui.New«for.name»Wizard.ID).createWizard();
				wizard.init(org.eclipse.ui.PlatformUI.getWorkbench(), (org.eclipse.jface.viewers.IStructuredSelection) org.eclipse.ui.handlers.HandlerUtil.getCurrentSelection(event));
				org.eclipse.jface.wizard.WizardDialog wizardDialog = new org.eclipse.jface.wizard.WizardDialog(org.eclipse.ui.handlers.HandlerUtil.getActiveShell(event), wizard);
				wizardDialog.create();
				wizardDialog.open();
			} catch (org.eclipse.core.runtime.CoreException e) {
				throw new org.eclipse.core.commands.ExecutionException(e.getMessage(), e);
			}
			return null;
		}
	'''
}

}
