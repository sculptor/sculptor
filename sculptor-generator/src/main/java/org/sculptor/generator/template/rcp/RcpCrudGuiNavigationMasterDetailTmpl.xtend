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

class RcpCrudGuiNavigationMasterDetailTmpl {



def static String navigationMasterDetail(GuiApplication it) {
	'''
	«navigationMasterDetailClass(it)»
	«IF isGapClassToBeGenerated("", "NavigationMasterDetail")»
		«gapNavigationMasterDetailClass(it)»
	«ENDIF»
	'''
}

def static String gapNavigationMasterDetailClass(GuiApplication it) {
	'''
	«val className = it."NavigationMasterDetail"»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".ui." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage("common")».ui;

	public class «className» ^extends «className»Base {
	public «className»(«fw("richclient.util.SelectionProviderIntermediate")» mainSelectionProvider) {
		super(mainSelectionProvider);
		}
	}
	'''
	)
	'''
	'''
}

def static String navigationMasterDetailClass(GuiApplication it) {
	'''
	«val className = it."NavigationMasterDetail" + gapSubclassSuffix("NavigationMasterDetail")»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".ui." + className) , '''
	«javaHeader()»
	package «getRichClientPackage("common")».ui;

	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.ui.forms.MasterDetailsBlock implements org.eclipse.ui.ISaveablePart, java.util.Observer {

		«navigationMasterDetailAttributes(it)»
	«navigationMasterDetailConstructor(it)»
	«navigationMasterDetailCreateContent(it)»
		«navigationMasterDetailSelectionProvider(it)»
	«navigationMasterDetailCreateMasterPart(it)»
		«navigationMasterDetailClassesOfInterest(it)»
	«navigationMasterDetailAddExpandTreeSelectionListener(it)»
	«navigationMasterDetailAddListViewSelectionListener(it)»    
		«navigationMasterDetailAddRepositoryObserver(it)»
		«navigationMasterDetailDispose(it)»
		«navigationMasterDetailDeleteRepositoryObserver(it)»
	«navigationMasterDetailCreateToolbar(it)»
	«navigationMasterDetailRegisterPages(it)»
	«navigationMasterDetailRegisterContextMenu(it)»
	«navigationMasterDetailMiscMethods(it)»
	«navigationMasterDetailOpenSaveQuestionDialog(it)»
	«navigationMasterDetailUpdateTitle(it)»
	«navigationMasterDetailUpdate(it)»
	«navigationMasterDetailSelect(it)»
	«navigationMasterDetailSelectionChangeListener(it)»
	«navigationMasterDetailRefresh(it)»

	}
	'''
	)
	'''
	'''
}

def static String navigationMasterDetailAttributes(GuiApplication it) {
	'''
	private static final String MENU_ID = "«getRichClientPackage()».NavigationTreeMenu";

		private «fw("richclient.util.SelectionProviderIntermediate")» mainSelectionProvider;
		
		private Object currentSelection;
		private org.eclipse.ui.forms.IManagedForm managedForm;
		private org.eclipse.jface.viewers.TreeViewer treeViewer;
		private org.eclipse.ui.forms.SectionPart sectionWithSelectionProviderPart;
		private «fw("richclient.tree.DeferredTreeUpdater")» updateUtil;
		private «fw("richclient.tree.TreeExpander")» treeExpander;
		
		private java.util.Map<«getRichClientPackage("common")».data.DomainObjectFolder, String> listViewIds = new java.util.HashMap<«getRichClientPackage("common")».data.DomainObjectFolder, String>();

	«FOR task : modules.userTasks.typeSelect(ListTask)»
	private «task.module.getRichClientPackage()».data.Rich«task.for.name»Repository «task.for.name.toFirstLower()»Repository;
	«ENDFOR»

		public enum ANSWER {
			YES, NO, CANCEL
		}
	'''
}

def static String navigationMasterDetailConstructor(GuiApplication it) {
	'''
	«val className = it."NavigationMasterDetail" + gapSubclassSuffix("NavigationMasterDetail")»
		public «className»(«fw("richclient.util.SelectionProviderIntermediate")» mainSelectionProvider) {
			this.mainSelectionProvider = mainSelectionProvider;
			«FOR task : modules.userTasks.typeSelect(ListTask)»
		«task.for.name.toFirstLower()»Repository = «getRichClientPackage()».«name.toFirstUpper()»Plugin.getDefault().getRepository(
			«task.module.getRichClientPackage()».data.Rich«task.for.name»Repository.class);
		«ENDFOR»
		initListViewIds();
		}
		
		private void initListViewIds() {
			«FOR task : modules.userTasks.typeSelect(ListTask)»
			listViewIds.put(«getRichClientPackage("common")».data.DomainObjectFolder.«task.for.name.toUpperCase()», «task.module.getRichClientPackage()».ui.List«task.for.name»View.ID);
			«ENDFOR»
		}
	'''
}

def static String navigationMasterDetailCreateContent(GuiApplication it) {
	'''
		@Override
		public void createContent(org.eclipse.ui.forms.IManagedForm managedForm) {
			super.createContent(managedForm);
			this.managedForm = managedForm;

			registerSelectionListener(mainSelectionProvider);
		}
	'''
}

def static String navigationMasterDetailSelectionProvider(GuiApplication it) {
	'''
		private void changeMainSelectionProvider() {
			if (mainSelectionProvider.getSelectionProviderDelegate() != getSelectionProvider()) {
				mainSelectionProvider.setSelectionProviderDelegate(getSelectionProvider());
			}
		}

		protected void registerSelectionListener(org.eclipse.jface.viewers.ISelectionProvider selectionProvider) {
			selectionProvider.addSelectionChangedListener(new SelectionChangeListener(managedForm));
		}

		public org.eclipse.jface.viewers.IPostSelectionProvider getSelectionProvider() {
			return treeViewer;
		}

		public org.eclipse.ui.forms.IFormPart getFormPartWithSelectionProvider() {
			return sectionWithSelectionProviderPart;
		}
	'''
}

def static String navigationMasterDetailCreateMasterPart(GuiApplication it) {
	'''
		protected void createMasterPart(org.eclipse.ui.forms.IManagedForm managedForm, org.eclipse.swt.widgets.Composite parent) {
			org.eclipse.ui.forms.widgets.FormToolkit toolkit = managedForm.getToolkit();
			toolkit.decorateFormHeading(managedForm.getForm().getForm());

			final org.eclipse.ui.forms.widgets.Section section = toolkit.createSection(parent, org.eclipse.ui.forms.widgets.ExpandableComposite.ED(it)
				    | org.eclipse.ui.forms.widgets.ExpandableComposite.TITLE_BAR);
			section.marginWidth = 5;
			section.marginHeight = 5;
			sectionWithSelectionProviderPart = new org.eclipse.ui.forms.SectionPart(section);
			section.setLayoutData(new org.eclipse.swt.layout.GridData(org.eclipse.swt.layout.GridData.FILL_BOTH));
			section.setText(«getMessagesClass()».navigationMasterDetail_title);

			org.eclipse.swt.widgets.Composite composite = toolkit.createComposite(section, org.eclipse.swt.SWT.NONE);
			composite.setLayout(new org.eclipse.swt.layout.GridLayout());
			toolkit.paintBordersFor(composite);
			section.setClient(composite);

			org.eclipse.swt.widgets.Tree tree = toolkit.createTree(composite, org.eclipse.swt.SWT.NONE);
			tree.setLayoutData(new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.FILL, true, true));
			treeViewer = new org.eclipse.jface.viewers.TreeViewer(tree);

			«fw("richclient.tree.DeferredTreeContentProvider")» contentProvider = new «fw("richclient.tree.DeferredTreeContentProvider")»();
			treeViewer.setContentProvider(contentProvider);
			treeViewer.setLabelProvider(org.eclipse.ui.model.WorkbenchLabelProvider.getDecoratingWorkbenchLabelProvider());
			treeViewer.setComparator(new org.eclipse.jface.viewers.ViewerComparator());
			treeViewer.setInput(«getRichClientPackage("common")».data.RootNode.INSTANCE);
			
			treeViewer.addSelectionChangedListener(new org.eclipse.jface.viewers.ISelectionChangedListener() {
				public void selectionChanged(org.eclipse.jface.viewers.SelectionChangedEvent event) {
				    changeMainSelectionProvider();
				}
			});
			
			treeExpander = new «fw("richclient.tree.TreeExpander")»(treeViewer);

			createSectionCoolBar(toolkit, section);

			createSectionToolbar(section, toolkit);

			updateUtil = new «fw("richclient.tree.DeferredTreeUpdater")»(treeViewer, classesOfInterest());
			addRepositoryObserver();

			addListViewSelectionListener();
			addExpandTreeSelectionListener();
		}
	'''
}

def static String navigationMasterDetailClassesOfInterest(GuiApplication it) {
	'''
		protected Class<?>[] classesOfInterest() {
			return new Class[] {
				«getRichClientPackage("common")».data.ModuleFolder.class, 
				«getRichClientPackage("common")».data.DomainObjectFolder.class,
				«FOR task SEPARATOR ", " : modules.userTasks.typeSelect(ListTask)»
			«task.module.getRichClientPackage()».data.Rich«task.for.name».class
			«ENDFOR»};
		}
	'''
}

def static String navigationMasterDetailAddExpandTreeSelectionListener(GuiApplication it) {
	'''
		private void addExpandTreeSelectionListener() {
			mainSelectionProvider.addPostSelectionChangedListener(new org.eclipse.jface.viewers.ISelectionChangedListener() {
				public void selectionChanged(org.eclipse.jface.viewers.SelectionChangedEvent event) {
				    if (event.getSource() == treeViewer) {
				        return;
				    }
				    org.eclipse.jface.viewers.IStructuredSelection selection = (org.eclipse.jface.viewers.IStructuredSelection) event.getSelection();
				    if (selection.size() == 1) {
				        if (updateUtil.isOfInterest(selection.getFirstElement())) {
				            treeExpander.expandSelect(new org.eclipse.jface.viewers.StructuredSelection(selection.getFirstElement()));
				        }
				    }
				}
			});
		}
	'''
}

def static String navigationMasterDetailAddListViewSelectionListener(GuiApplication it) {
	'''
		private void addListViewSelectionListener() {
			getSelectionProvider().addPostSelectionChangedListener(new org.eclipse.jface.viewers.ISelectionChangedListener() {
				public void selectionChanged(org.eclipse.jface.viewers.SelectionChangedEvent event) {
				    org.eclipse.jface.viewers.IStructuredSelection selection = (org.eclipse.jface.viewers.IStructuredSelection) event.getSelection();
				    if (selection.size() == 1) {
				        if (selection.getFirstElement() instanceof «getRichClientPackage("common")».data.DomainObjectFolder) {
				            «getRichClientPackage("common")».data.DomainObjectFolder current = («getRichClientPackage("common")».data.DomainObjectFolder) selection.getFirstElement();
				            String listViewId = listViewIds.get(current);
				            if (listViewId == null) {
				                return;
				            }
				            try {
				                org.eclipse.ui.IWorkbenchPart view = «getRichClientPackage()».«name.toFirstUpper()»Plugin.getDefault()
				                        .getWorkbench().getActiveWorkbenchWindow().getActivePage().showView(
				                                listViewId);
				                «getRichClientPackage()».«name.toFirstUpper()»Plugin.getDefault().getWorkbench().getActiveWorkbenchWindow()
				                        .getActivePage().bringToTop(view);
				            } catch (org.eclipse.ui.PartInitException e) {
				                org.eclipse.jface.dialogs.ErrorDialog.openError(org.eclipse.swt.widgets.Display.getCurrent().getActiveShell(),
				                        "Problem showing ListView: " + listViewId, e.getMessage(), new org.eclipse.core.runtime.Status(org.eclipse.core.runtime.Status.OK,
				                                «getRichClientPackage()».«name.toFirstUpper()»Plugin.PLUGIN_ID, "Problem showing ListView: " + listViewId,
				                                e));
				            }
				        }
				    }

				}
			});
		}
	'''
}

def static String navigationMasterDetailAddRepositoryObserver(GuiApplication it) {
	'''
		private void addRepositoryObserver() {
			«FOR task : modules.userTasks.typeSelect(ListTask)»
		«task.for.name.toFirstLower()»Repository.addObserver(this);
		«ENDFOR»
		}
	'''
}

def static String navigationMasterDetailDispose(GuiApplication it) {
	'''    
		public void dispose() {
			deleteRepositoryObserver();
		}
	'''
}

def static String navigationMasterDetailDeleteRepositoryObserver(GuiApplication it) {
	'''
		private void deleteRepositoryObserver() {
			«FOR task : modules.userTasks.typeSelect(ListTask)»
			if («task.for.name.toFirstLower()»Repository != null) {
				«task.for.name.toFirstLower()»Repository.deleteObserver(this);
			}
		«ENDFOR»
		}
	'''
}

def static String navigationMasterDetailCreateToolbar(GuiApplication it) {
	'''
		protected void createSectionCoolBar(org.eclipse.ui.forms.widgets.FormToolkit toolkit, final org.eclipse.ui.forms.widgets.Section section) {
			org.eclipse.swt.widgets.CoolBar coolBar = new org.eclipse.swt.widgets.CoolBar(section, org.eclipse.swt.SWT.NONE);
			section.setTextClient(coolBar);
			toolkit.adapt(coolBar, true, true);
			org.eclipse.swt.widgets.CoolItem newItem = new org.eclipse.swt.widgets.CoolItem(coolBar, org.eclipse.swt.SWT.PUSH);
			newItem.setText("Add");
		}

		protected void createSectionToolbar(org.eclipse.ui.forms.widgets.Section section, org.eclipse.ui.forms.widgets.FormToolkit toolkit) {
			org.eclipse.jface.action.ToolBarManager toolBarManager = new org.eclipse.jface.action.ToolBarManager(org.eclipse.swt.SWT.FLAT);
			org.eclipse.swt.widgets.ToolBar toolbar = toolBarManager.createControl(section);
			final org.eclipse.swt.graphics.Cursor handCursor = new org.eclipse.swt.graphics.Cursor(org.eclipse.swt.widgets.Display.getCurrent(), org.eclipse.swt.SWT.CURSOR_HAND);
			toolbar.setCursor(handCursor);
			// Cursor needs to be explicitly disposed
			toolbar.addDisposeListener(new org.eclipse.swt.events.DisposeListener() {
				public void widgetDisposed(org.eclipse.swt.events.DisposeEvent e) {
				    if (!handCursor.isDisposed()) {
				        handCursor.dispose();
				    }
				}
			});

			toolBarManager.add(new CollapseAction(treeViewer, "Collapse"));
			toolBarManager.add(new RefreshAction());

			toolBarManager.update(true);

			section.setTextClient(toolbar);
		}

		@Override
		protected void createToolBarActions(org.eclipse.ui.forms.IManagedForm managedForm) {
		}
	'''
}

def static String navigationMasterDetailRegisterPages(GuiApplication it) {
	'''
		@Override
		protected void registerPages(org.eclipse.ui.forms.DetailsPart detailsPart) {

			detailsPart.registerPage(«getRichClientPackage("common")».data.ModuleFolder.class, new EmptyDetailsPage());
			detailsPart.registerPage(«getRichClientPackage("common")».data.DomainObjectFolder.class, new EmptyDetailsPage());

			«FOR task : modules.userTasks.typeSelect(UpdateTask)»
			detailsPart.registerPage(«task.module.getRichClientPackage()».data.Rich«task.for.name».class, 
				    «getRichClientPackage()».«name.toFirstUpper()»Plugin.getDefault().createPage(«task.module.getRichClientPackage()».ui.«task.for.name»DetailsPage.class));
			«ENDFOR»

			sashForm.setWeights(new int[] { 1, 2 });
		}
	'''
}

def static String navigationMasterDetailRegisterContextMenu(GuiApplication it) {
	'''
		public void registerContextMenu(org.eclipse.ui.IWorkbenchPartSite site) {
			org.eclipse.jface.action.MenuManager menuMgr = new org.eclipse.jface.action.MenuManager();
			menuMgr.setRemoveAllWhenShown(true);
			menuMgr.addMenuListener(new org.eclipse.jface.action.IMenuListener() {
				public void menuAboutToShow(org.eclipse.jface.action.IMenuManager manager) {
				    fillContextMenu(manager);
				}
			});
			org.eclipse.swt.widgets.Menu menu = menuMgr.createContextMenu(treeViewer.getControl());
			treeViewer.getControl().setMenu(menu);
			site.registerContextMenu(MENU_ID, menuMgr, treeViewer);
		}

		protected void fillContextMenu(org.eclipse.jface.action.IMenuManager manager) {
			// Other plug-ins can contribute there actions here
			manager.add(new org.eclipse.jface.action.Separator(org.eclipse.ui.IWorkbenchActionConstants.MB_ADDITIONS));
		}
	'''
}

def static String navigationMasterDetailMiscMethods(GuiApplication it) {
	'''
		public void setFocus() {
			changeMainSelectionProvider();
			treeViewer.getControl().setFocus();
		}

		public void doSave(org.eclipse.core.runtime.IProgressMonitor monitor) {
			((org.eclipse.ui.ISaveablePart) detailsPart.getCurrentPage()).doSave(monitor);
		}

		public void doSaveAs() {
			throw new IllegalStateException("Not allowed to do SaveAs");
		}

		public boolean isDirty() {
			return detailsPart.getCurrentPage() == null ? false : detailsPart.getCurrentPage().isDirty();
		}

		public boolean isSaveAsAllowed() {
			return false;
		}

		public boolean isSaveOnCloseNeeded() {
			return isDirty();
		}

		protected void detailsDirtyStateChanged() {
			managedForm.dirtyStateChanged();
		}
	'''
}

def static String navigationMasterDetailOpenSaveQuestionDialog(GuiApplication it) {
	'''
		protected ANSWER openSaveQuestionDialog() {
			String[] buttons = new String[] { org.eclipse.jface.dialogs.IDialogConstants.YES_LABEL, org.eclipse.jface.dialogs.IDialogConstants.NO_LABEL,
				    org.eclipse.jface.dialogs.IDialogConstants.CANCEL_LABEL };
			org.eclipse.jface.dialogs.MessageDialog dialog = new org.eclipse.jface.dialogs.MessageDialog(org.eclipse.ui.PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(),
				    «getMessagesClass()».save_question_title, null, // accept the default window icon
				    «getMessagesClass()».save_question, org.eclipse.jface.dialogs.MessageDialog.QUESTION, buttons, 0);
			int result = dialog.open();
			if (result == -1) { // user pressed Esc
				result = ANSWER.CANCEL.ordinal(); // convert to cancel
			}
			return ANSWER.values()[result];
		}
	'''
}

def static String navigationMasterDetailUpdateTitle(GuiApplication it) {
	'''
		public void updateTitle(Object selection) {
			if (selection != null) {
				org.eclipse.jface.viewers.ILabelProvider provider = org.eclipse.ui.model.WorkbenchLabelProvider.getDecoratingWorkbenchLabelProvider();
				managedForm.getForm().getForm().setImage(provider.getImage(selection));
				managedForm.getForm().getForm().setText(provider.getText(selection));
			} else {
				managedForm.getForm().getForm().setImage(null);
				managedForm.getForm().getForm().setText("");
			}
		}
	'''
}

def static String navigationMasterDetailUpdate(GuiApplication it) {
	'''
		public void update(java.util.Observable repository, Object obj) {
			updateUtil.update(obj);
		}
	'''
}

def static String navigationMasterDetailSelect(GuiApplication it) {
	'''
		public void filter(org.eclipse.jface.viewers.IStructuredSelection selection) {
			treeExpander.expandSelect(selection);
		}
	'''
}

def static String navigationMasterDetailSelectionChangeListener(GuiApplication it) {
	'''
		class SelectionChangeListener implements org.eclipse.jface.viewers.ISelectionChangedListener {
			private org.eclipse.ui.forms.IManagedForm form;

			SelectionChangeListener(org.eclipse.ui.forms.IManagedForm managedForm) {
				this.form = managedForm;
			}

			public void selectionChanged(org.eclipse.jface.viewers.SelectionChangedEvent event) {
				Object selection = ((org.eclipse.jface.viewers.IStructuredSelection) event.getSelection()).getFirstElement();
				updateTitle(selection);
				if (currentSelection == selection) {
				    return;
				}

				// check if current selection is dirty before switching
				if (currentSelection != null && detailsPart.isDirty()) {
				    switch (openSaveQuestionDialog()) {
				    case YES:
				        // save and change selection
				        doSave(null);
				    case NO:
				        // discard and change selection
				        currentSelection = selection;
				        form.getMessageManager().removeAllMessages();
				        form.fireSelectionChanged(getFormPartWithSelectionProvider(), event.getSelection());
				        detailsDirtyStateChanged();
				        break;
				    case CANCEL:
				        // reset to previous selection
				        getSelectionProvider().setSelection(new org.eclipse.jface.viewers.StructuredSelection(currentSelection));
				        break;
				    default:
				        assert false : "We should never get here";

				    }
				} else {
				    form.getMessageManager().removeAllMessages();
				    currentSelection = selection;
				    form.fireSelectionChanged(getFormPartWithSelectionProvider(), event.getSelection());
				}
			}
		}
	'''
}

def static String navigationMasterDetailRefresh(GuiApplication it) {
	'''
		protected void refresh() {
			org.eclipse.jface.viewers.IStructuredSelection selection = (org.eclipse.jface.viewers.IStructuredSelection) treeViewer.getSelection();
			treeViewer.setInput(«getRichClientPackage("common")».data.RootNode.INSTANCE);
			filter(selection);
		}
		
		private class RefreshAction ^extends org.eclipse.jface.action.Action {
			public RefreshAction() {
				super("");
			}

			@Override
			public org.eclipse.jface.resource.ImageDescriptor getImageDescriptor() {
				return «getRichClientPackage()».«name.toFirstUpper()»Plugin.REFRESH_IMAGE;
			}

			@Override
			public String getToolTipText() {
				return "Refresh Tree";
			}

			@Override
			public void run() {
				refresh();
			}
		}
	'''
}
}
