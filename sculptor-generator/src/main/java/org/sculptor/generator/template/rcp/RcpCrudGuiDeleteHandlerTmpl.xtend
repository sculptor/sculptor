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

class RcpCrudGuiDeleteHandlerTmpl {



def static String deleteHandler(GuiApplication it) {
	'''
	«it.modules.forEach[deleteHandler(it)]»
	'''
} 

def static String deleteHandler(GuiModule it) {
	'''
	«it.userTasks.typeSelect(DeleteTask).filter(e | e.getPrimaryServiceOperation() != null).forEach[deleteHandler(it)]»
	'''
}

def static String deleteHandler(DeleteTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".handler.Delete" + for.name + "Handler") , '''
	«javaHeader()»
	package «module.getRichClientPackage()».handler;

/**
 * A handler for deleting a «for.name».
 * 
 */
	public class Delete«for.name»Handler ^extends org.eclipse.core.commands.AbstractHandler {
		
	«deleteHandlerConstructor(it)»
	«RcpCrudGuiMessageResources::messageSourceDependencyProperty(it)»
	«deleteHandlerEnabled(it)»
	«deleteHandlerExecute(it)»
	}
	'''
	)
	'''
	'''
}

def static String deleteHandlerConstructor(DeleteTask it) {
	'''
		private «module.getRichClientPackage()».data.Rich«for.name»Repository repository;
		public Delete«for.name»Handler() {
			repository = «module.application.getRichClientPackage()».«module.application.name.toFirstUpper()»Plugin.getDefault().getRepository(«module.getRichClientPackage()».data.Rich«for.name»Repository.class);
			messages = (org.springframework.context.MessageSource) «module.application.getRichClientPackage()».«module.application.name.toFirstUpper()»Plugin.getDefault()
				.getSpringContext().getBean("messageSource");
		}
	'''
}

def static String deleteHandlerEnabled(DeleteTask it) {
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

def static String deleteHandlerExecute(DeleteTask it) {
	'''
		@SuppressWarnings("unchecked")
		public Object execute(org.eclipse.core.commands.ExecutionEvent event) throws org.eclipse.core.commands.ExecutionException {
			final org.eclipse.jface.viewers.IStructuredSelection selection = (org.eclipse.jface.viewers.IStructuredSelection) org.eclipse.ui.handlers.HandlerUtil.getCurrentSelection(event);
			if (selection.isEmpty()) {
				return null;
			}
			
			org.eclipse.ui.IWorkbenchWindow window = org.eclipse.ui.handlers.HandlerUtil.getActiveWorkbenchWindowChecked(event);
			
			String question;
			if (selection.size() == 1) {
				«module.getRichClientPackage()».data.Rich«for.name» obj = («module.getRichClientPackage()».data.Rich«for.name») selection.getFirstElement();
				org.eclipse.ui.model.IWorkbenchAdapter adapter = 
				    (org.eclipse.ui.model.IWorkbenchAdapter) org.eclipse.core.runtime.Platform.getAdapterManager().getAdapter(obj, org.eclipse.ui.model.IWorkbenchAdapter.class);
				String objLabel = (adapter == null ? String.valueOf(obj.getId()) : adapter.getLabel(obj));
				question = org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».delete_question, objLabel);
			} else {
				String objLabels = "";
				for (java.util.Iterator iter = selection.iterator(); iter.hasNext();) {
				    «module.getRichClientPackage()».data.Rich«for.name» obj = («module.getRichClientPackage()».data.Rich«for.name») iter.next();
				    org.eclipse.ui.model.IWorkbenchAdapter adapter = 
				        (org.eclipse.ui.model.IWorkbenchAdapter) org.eclipse.core.runtime.Platform.getAdapterManager().getAdapter(obj, org.eclipse.ui.model.IWorkbenchAdapter.class);
				    String objLabel = (adapter == null ? String.valueOf(obj.getId()) : adapter.getLabel(obj));
				    objLabels += objLabel;
				    if (iter.hasNext()) {
				        objLabels += ", ";
				    }
				}
				question = org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».delete_question, objLabels);
			}
			boolean answerYes = org.eclipse.jface.dialogs.MessageDialog.openConfirm(window.getShell(), «getMessagesClass()».delete_title, question);

			if (answerYes) {
				org.eclipse.core.runtime.jobs.Job job = new «fw("richclient.errorhandling.ExceptionAwareJob")»(
					org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».deleteJob, «getMessagesClass()».«for.getMessagesKey()»), messages) {
				    @Override
				    protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor) {
				        monitor.beginTask(getName(), selection.size());
				        for (java.util.Iterator iter = selection.iterator(); iter.hasNext();) {
				            «module.getRichClientPackage()».data.Rich«for.name» obj = («module.getRichClientPackage()».data.Rich«for.name») iter.next();
				            repository.delete(obj);
				            monitor.worked(1);
				        }
				        monitor.done();
				        return org.eclipse.core.runtime.Status.OK_STATUS;
				    }
				};
				job.schedule();
				
			}

			return null;
		}
	'''
}

}
