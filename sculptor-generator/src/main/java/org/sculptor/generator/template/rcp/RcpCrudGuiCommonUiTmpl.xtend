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

class RcpCrudGuiCommonUiTmpl {



def static String commonUi(GuiApplication it) {
	'''
	«collapseAction(it)»
	«emptyDetailsPage(it)»
	«mainView(it)»
	«IF isGapClassToBeGenerated("", "MainView")»
		«gapMainView(it)»
	«ENDIF»
	«perspective(it)»
	«IF isGapClassToBeGenerated("", "Perspective")»
		«gapPerspective(it)»
	«ENDIF»
	'''
}

def static String collapseAction(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".ui.CollapseAction") , '''
	«javaHeader()»
	package «getRichClientPackage("common")».ui;

/**
 * Action for collapsing all nodes in a tree viewer
 * 
 */
	public class CollapseAction ^extends org.eclipse.jface.action.Action {

		private org.eclipse.jface.viewers.AbstractTreeViewer treeViewer;
		private Object treeObject;
		private int expandToLevel;

		public CollapseAction(org.eclipse.jface.viewers.AbstractTreeViewer viewer, String tooltipText, int expandToLevel, Object treeObject) {
			super(tooltipText, org.eclipse.jface.action.IAction.AS_PUSH_BUTTON);
			this.expandToLevel = expandToLevel;
			this.treeObject = treeObject;
			initialize(viewer, tooltipText);
		}

		public CollapseAction(org.eclipse.jface.viewers.AbstractTreeViewer viewer, String tooltipText) {
			super(tooltipText, org.eclipse.jface.action.IAction.AS_PUSH_BUTTON);
			expandToLevel = 0;
			treeObject = null;
			initialize(viewer, tooltipText);
		}

		private void initialize(org.eclipse.jface.viewers.AbstractTreeViewer viewer, String tooltipText) {
			setToolTipText(tooltipText);
			setImageDescriptor(«getRichClientPackage()».«name.toFirstUpper()»Plugin.DESC_COLLAPSE_ALL_IMAGE);
			treeViewer = viewer;
		}

		@Override
		public void run() {
			if (treeViewer == null) {
				return;
			} else if ((treeObject != null) && (expandToLevel > 0)) {
				// Redraw modification needed to avoid flicker
				// Collapsing to a specific level does not work
				treeViewer.getControl().setRedraw(false);
				treeViewer.collapseAll();
				treeViewer.expandToLevel(treeObject, 1);
				treeViewer.getControl().setRedraw(true);
			} else {
				treeViewer.collapseAll();
			}
		}

	}
	'''
	)
	'''
	'''
}

def static String emptyDetailsPage(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".ui.EmptyDetailsPage") , '''
	«javaHeader()»
	package «getRichClientPackage("common")».ui;

/**
 * This is an empty details page that can be shown when no details are
 * avialable.
 * 
 */
	public class EmptyDetailsPage implements org.eclipse.ui.forms.IDetailsPage {

		private org.eclipse.ui.forms.IManagedForm managedForm;

		/**
			* Create the details page
			*/
		public EmptyDetailsPage() {
			// Create the details page
		}

		/**
			* Initialize the details page
			* 
			* @param form
			*/
		public void initialize(org.eclipse.ui.forms.IManagedForm form) {
			managedForm = form;
		}

		/**
			* Create contents of the details page
			* 
			* @param parent
			*/
		public void createContents(org.eclipse.swt.widgets.Composite parent) {
			org.eclipse.ui.forms.widgets.FormToolkit toolkit = managedForm.getToolkit();
			final org.eclipse.swt.layout.GridLayout layout = new org.eclipse.swt.layout.GridLayout();
			layout.marginWidth = 0;
			layout.marginHeight = 0;
			parent.setLayout(layout);

			org.eclipse.swt.widgets.Label info = toolkit.createLabel(parent, «getMessagesClass()».emptyDetailsPageInfo, org.eclipse.swt.SWT.NONE);
			info.setAlignment(org.eclipse.swt.SWT.CENTER);
			info.setLayoutData(new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.CENTER, org.eclipse.swt.SWT.CENTER, true, true));
			info.setForeground(org.eclipse.swt.widgets.Display.getCurrent().getSystemColor(org.eclipse.swt.SWT.COLOR_INFO_FOREGROUND));
		}

		public void dispose() {
		}

		public void setFocus() {
		}

		private void update() {
		}

		public boolean setFormInput(Object input) {
			return false;
		}

		public void selectionChanged(org.eclipse.ui.forms.IFormPart part, org.eclipse.jface.viewers.ISelection selection) {
			update();
		}

		public void commit(boolean onSave) {
		}

		public boolean isDirty() {
			return false;
		}

		public boolean isStale() {
			return false;
		}

		public void refresh() {
			update();
		}

	}
	'''
	)
	'''
	'''
}

def static String gapMainView(GuiApplication it) {
	'''
	«val className = it."MainView"»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".ui." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage("common")».ui;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String mainView(GuiApplication it) {
	'''
	«val className = it."MainView" + gapSubclassSuffix("MainView")»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".ui." + className) , '''
	«javaHeader()»
	package «getRichClientPackage("common")».ui;

/**
 * Main view for the application.
 * 
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.ui.part.ViewPart implements org.eclipse.ui.ISaveablePart {

		public static final String ID = MainView.class.getName();

		private org.eclipse.ui.forms.widgets.FormToolkit toolkit;
		private NavigationMasterDetail masterDetail;
		
		private «fw("richclient.util.SelectionProviderIntermediate")» mainSelectionProvider = new «fw("richclient.util.SelectionProviderIntermediate")»();

		/**
			* Create contents of the view part
			* 
			*/
		@Override
		public void createPartControl(org.eclipse.swt.widgets.Composite parent) {
			getSite().setSelectionProvider(mainSelectionProvider);
			
			toolkit = new org.eclipse.ui.forms.widgets.FormToolkit(org.eclipse.swt.widgets.Display.getCurrent());
			org.eclipse.swt.widgets.Composite container = toolkit.createComposite(parent, org.eclipse.swt.SWT.NONE);
			container.setLayout(new org.eclipse.swt.layout.FillLayout());
			toolkit.paintBordersFor(container);

			org.eclipse.ui.forms.widgets.ScrolledForm form = toolkit.createScrolledForm(container);
			org.eclipse.swt.widgets.Composite body = form.getBody();
			toolkit.paintBordersFor(body);

			org.eclipse.ui.forms.ManagedForm managedForm = new org.eclipse.ui.forms.ManagedForm(toolkit, form) {
				@Override
				public void dirtyStateChanged() {
				    super.dirtyStateChanged();
				    «className».this.dirtyStateChanged();
				}
			};

			masterDetail = new NavigationMasterDetail(mainSelectionProvider);
			masterDetail.createContent(managedForm);
			masterDetail.registerContextMenu(getSite());
			
			createActions();
			initializeToolBar();
			initializeMenu();
		}
		
		@Override
		public void setFocus() {
			masterDetail.setFocus();
		}

		protected void createActions() {
		}

		protected void initializeToolBar() {
		}

		protected void initializeMenu() {
		}

		public void doSave(org.eclipse.core.runtime.IProgressMonitor monitor) {
			masterDetail.doSave(monitor);
		}
		
		public boolean isSaveOnCloseNeeded() {
			return isDirty();
		}

		public void dirtyStateChanged() {
			firePropertyChange(org.eclipse.ui.ISaveablePart.PROP_DIRTY);
		}

		public boolean isDirty() {
			return masterDetail.isDirty();
		}

		public boolean isSaveAsAllowed() {
			return false;
		}
		
		public void doSaveAs() {
		}
		
		@Override
		public void dispose() {
			if (masterDetail != null) {
				masterDetail.dispose();
			}
		}
		
		public void filter(org.eclipse.jface.viewers.IStructuredSelection selection) {
			masterDetail.filter(selection);
		}
	}
	'''
	)
	'''
	'''
}

def static String gapPerspective(GuiApplication it) {
	'''
	«val className = it."Perspective"»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".ui." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage("common")».ui;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String perspective(GuiApplication it) {
	'''
	«val className = it."Perspective" + gapSubclassSuffix("Perspective")»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".ui." + className) , '''
	«javaHeader()»
	package «getRichClientPackage("common")».ui;

	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» implements org.eclipse.ui.IPerspectiveFactory {

		public void createInitialLayout(org.eclipse.ui.IPageLayout layout) {
			layout.setEditorAreaVisible(false);
		}
	}
	'''
	)
	'''
	'''
}
}
