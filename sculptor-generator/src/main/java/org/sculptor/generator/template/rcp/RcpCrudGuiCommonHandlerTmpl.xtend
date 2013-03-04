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

class RcpCrudGuiCommonHandlerTmpl {



def static String selectInMainHandler(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".handler.SelectInMainViewHandler") , '''
	«javaHeader()»
	package «getRichClientPackage("common")».handler;

/**
 * Handler for opening current selection in MainView
 *
 */
	public class SelectInMainViewHandler ^extends org.eclipse.core.commands.AbstractHandler {
		
	«selectInMainConstructor(it)»
	«selectInMainEnabled(it)»
	«selectInMainExecute(it)»
	}
	'''
	)
	'''
	'''
}

def static String selectInMainConstructor(GuiApplication it) {
	'''
		public SelectInMainViewHandler() {
		}
	'''
}

def static String selectInMainEnabled(GuiApplication it) {
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

def static String selectInMainExecute(GuiApplication it) {
	'''
		public Object execute(org.eclipse.core.commands.ExecutionEvent event) throws org.eclipse.core.commands.ExecutionException {
			org.eclipse.jface.viewers.IStructuredSelection currentSelection = (org.eclipse.jface.viewers.IStructuredSelection) org.eclipse.ui.handlers.HandlerUtil.getCurrentSelection(event);
			«getRichClientPackage("common")».ui.MainView mainView = («getRichClientPackage("common")».ui.MainView) org.eclipse.ui.handlers.HandlerUtil.getActiveWorkbenchWindow(event).getActivePage().findView(
				«getRichClientPackage("common")».ui.MainView.ID); 
			mainView.filter(currentSelection);
			return null;
		}
	'''
}

}
