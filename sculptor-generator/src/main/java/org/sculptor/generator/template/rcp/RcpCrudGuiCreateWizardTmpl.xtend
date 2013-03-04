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

class RcpCrudGuiCreateWizardTmpl {



def static String createWizard(GuiApplication it) {
	'''
	«it.modules.forEach[createWizard(it)]»
	'''
} 

def static String createWizard(GuiModule it) {
	'''
	«it.userTasks.typeSelect(CreateTask).forEach[createWizard(it)]»
	«it.userTasks.typeSelect(CreateTask) .filter(e | isGapClassToBeGenerated(e, "New" + e.for.name + "Wizard")).forEach[gapCreateWizard(it)]»
	'''
}

def static String gapCreateWizard(CreateTask it) {
	'''
	«val className = it."New" + for.name + "Wizard"»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className), 'TO_SRC', '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String createWizard(CreateTask it) {
	'''
	«val className = it."New" + for.name + "Wizard" + gapSubclassSuffix(this, "New" + for.name + "Wizard")»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.jface.wizard.Wizard implements org.eclipse.ui.INewWizard {
		public static final String ID = New«for.name»Wizard.class.getName();
		
	«createWizardConstructor(it)»
	«createWizardInit(it)»
	«createWizardAddPages(it)»
	«createWizardPerformFinish(it)»
	«createWizardPerformCancel(it)»

	}
	'''
	)
	'''
	'''
}

def static String createWizardConstructor(CreateTask it) {
	'''
	«val className = it."New" + for.name + "Wizard" + gapSubclassSuffix(this, "New" + for.name + "Wizard")»
		private org.eclipse.jface.resource.ImageDescriptor imageDescriptor = org.eclipse.ui.PlatformUI.getWorkbench().getSharedImages().getImageDescriptor(
				org.eclipse.ui.ISharedImages.IMG_TOOL_NEW_WIZARD);

		public «className»() {
			setDefaultPageImageDescriptor(imageDescriptor);
			setWindowTitle(org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».newWizardPage_title, «getMessagesClass()».«for.getMessagesKey()»));
		}
	'''
}

def static String createWizardInit(CreateTask it) {
	'''
		private New«for.name»WizardPage page;
		
		public void init(org.eclipse.ui.IWorkbench workbench, org.eclipse.jface.viewers.IStructuredSelection selection) {
			page =  «module.application.getRichClientPackage()».«module.application.name.toFirstUpper()»Plugin.getDefault().createPage(New«for.name»WizardPage.class);
			page.getController().setSelection(selection);
		}
		
		«IF isPossibleSubtask()»
		public void init(org.eclipse.ui.IWorkbench workbench, «fw("richclient.controller.ParentOfSubtask")»<«module.getRichClientPackage()».data.Rich«for.name»> subtaskParent, String parentTitle) {
			init(workbench, (org.eclipse.jface.viewers.IStructuredSelection) null);
			page.setSubtaskParent(subtaskParent, parentTitle);
		}
		«ENDIF»
	'''
}

def static String createWizardAddPages(CreateTask it) {
	'''
		@Override
		public void addPages() {
			super.addPages();
			addPage(page);
		}
	'''
}

def static String createWizardPerformFinish(CreateTask it) {
	'''
		@Override
		public boolean performFinish() {
			final boolean[] resultHolder = new boolean[1];
			org.eclipse.jface.operation.IRunnableWithProgress runnable = new org.eclipse.jface.operation.IRunnableWithProgress() {
				public void run(org.eclipse.core.runtime.IProgressMonitor monitor) throws java.lang.reflect.InvocationTargetException, InterruptedException {
				    monitor.beginTask(org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».updateJob, «getMessagesClass()».«for.getMessagesKey()»), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				    boolean result = ((«module.getRichClientPackage()».controller.New«for.name»Controller) page.getController()).performFinish();
				    resultHolder[0] = result;
				    monitor.done();
				}
			};
			try {
				getContainer().run(true, false, runnable);
			} catch (Exception e) {
				// will normally not happen, the controller is responsible for exceptions
				org.eclipse.core.runtime.Status status = new org.eclipse.core.runtime.Status(org.eclipse.core.runtime.IStatus.ERROR, «fw("richclient.SculptorFrameworkPlugin")».PLUGIN_ID, e.getMessage(), e);
				org.eclipse.jface.util.Policy.getLog().log(status);
				return false;
			}
			return resultHolder[0];
		}
	'''
}

def static String createWizardPerformCancel(CreateTask it) {
	'''
		@Override
		public boolean performCancel() {
			return ((«module.getRichClientPackage()».controller.New«for.name»Controller) page.getController()).performCancel();
		}
	'''
}
}
