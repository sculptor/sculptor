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

class RcpCrudGuiListViewHandlerTmpl {



def static String listViewHandler(GuiApplication it) {
	'''
	«it.modules.forEach[listViewHandler(it)]»
	'''
} 

def static String listViewHandler(GuiModule it) {
	'''
	«it.userTasks.typeSelect(ListTask).forEach[listViewHandler(it)]»
	'''
}

def static String listViewHandler(ListTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".handler.ShowList" + for.name + "ViewHandler") , '''
	«javaHeader()»
	package «module.getRichClientPackage()».handler;

/**
 * Handler for opening the List«for.name»View
 * 
 */
	public class ShowList«for.name»ViewHandler ^extends org.eclipse.core.commands.AbstractHandler {
		
	«listViewHandlerConstructor(it)»
	«listViewHandlerEnabled(it)»
	«listViewHandlerExecute(it)»
	}
	'''
	)
	'''
	'''
}

def static String listViewHandlerConstructor(ListTask it) {
	'''
		public ShowList«for.name»ViewHandler() {
		}
	'''
}

def static String listViewHandlerEnabled(ListTask it) {
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

def static String listViewHandlerExecute(ListTask it) {
	'''
		public Object execute(org.eclipse.core.commands.ExecutionEvent event) throws org.eclipse.core.commands.ExecutionException {
			try {
				org.eclipse.ui.IWorkbenchWindow window = org.eclipse.ui.handlers.HandlerUtil.getActiveWorkbenchWindow(event);
				window.getActivePage().showView(«module.getRichClientPackage()».ui.List«for.name»View.ID);
				return null;
			} catch (org.eclipse.ui.PartInitException e) {
				throw new RuntimeException(e);
			}
		}
	'''
}

}
