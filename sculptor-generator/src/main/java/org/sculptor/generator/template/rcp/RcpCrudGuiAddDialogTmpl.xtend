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

class RcpCrudGuiAddDialogTmpl {



def static String addDialog(GuiApplication it) {
	'''
	«it.modules.forEach[addDialog(it)]»
	'''
}

def static String addDialog(GuiModule it) {
	'''
	«it.userTasks.typeSelect(AddTask).forEach[addDialog(it)]»
	«it.userTasks.typeSelect(AddTask) .filter(e | isGapClassToBeGenerated(e, "Add" + e.for.name + "Dialog")).forEach[gapAddDialog(it)]»
	«it.userTasks.typeSelect(AddTask).forEach[addPage(it)]»
	«it.userTasks.typeSelect(AddTask) .filter(e | isGapClassToBeGenerated(e, "Add" + e.for.name + "Page")).forEach[gapAddPage(it)]»
	'''
}

def static String gapAddDialog(AddTask it) {
	'''
	«val className = it."Add" + for.name + "Dialog"»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className), 'TO_SRC', '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	public class «className» ^extends «className»Base {
	public «className»(org.eclipse.swt.widgets.Shell parentShell) {
			super(parentShell);
		}
	}
	'''
	)
	'''
	'''
}

def static String addDialog(AddTask it) {
	'''
	«val className = it."Add" + for.name + "Dialog" + gapSubclassSuffix(this, "Add" + for.name + "Dialog")»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.jface.dialogs.TitleAreaDialog {
		«addDialogConstructor(it)»
		«addDialogInit(it)»
		«addDialogCreateContents(it)»
		«addDialogCreateDialogArea(it)»
		«addDialogOkPressed(it)»
		«addDialogCancelPressed(it)»
	}
	'''
	)
	'''
	'''
}

def static String addDialogConstructor(AddTask it) {
	'''
	«val className = it."Add" + for.name + "Dialog" + gapSubclassSuffix(this, "Add" + for.name + "Dialog")»
		public «className»(org.eclipse.swt.widgets.Shell parentShell) {
			super(parentShell);
		}
	'''
}

def static String addDialogInit(AddTask it) {
	'''
		private Add«for.name»Page page;
		private «fw("richclient.controller.ParentOfSubtask")»<«module.getRichClientPackage()».data.Rich«for.name»> subtaskParent;
		private String subtaskParentTitle;

		public void init(«fw("richclient.controller.ParentOfSubtask")»<«module.getRichClientPackage()».data.Rich«for.name»> subtaskParent, String parentTitle, boolean singleSelect) {
			page = «module.application.getRichClientPackage()».«module.application.name.toFirstUpper()»Plugin.getDefault().createPage(Add«for.name»Page.class);
			page.setSingleSelect(singleSelect);
			this.subtaskParent = subtaskParent;
			this.subtaskParentTitle = parentTitle;
		}
	'''
}

def static String addDialogCreateContents(AddTask it) {
	'''
		@Override
		protected org.eclipse.swt.widgets.Control createContents(org.eclipse.swt.widgets.Composite parent) {
			org.eclipse.swt.widgets.Control result = super.createContents(parent);

			getShell().setText(org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».breadCrumb_add, «getMessagesClass()».«for.getMessagesKey()»));
			if (subtaskParentTitle != null) {
				setTitle(subtaskParentTitle + " " +
				    «getMessagesClass()».breadCrumb_separator + " " +
				    org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».breadCrumb_add, «getMessagesClass()».«for.getMessagesKey()»));
			} else {
				setTitle(org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».breadCrumb_add, «getMessagesClass()».«for.getMessagesKey()»));
			}

			return result;
		}
	'''
}

def static String addDialogCreateDialogArea(AddTask it) {
	'''
		@Override
		protected org.eclipse.swt.widgets.Control createDialogArea(org.eclipse.swt.widgets.Composite parent) {
			return page.createControl(parent);
		}
	'''
}


def static String addDialogOkPressed(AddTask it) {
	'''
		@Override
		protected void okPressed() {
			«module.getRichClientPackage()».data.Rich«for.name»[] result = page.getCheckedElements();
			super.okPressed();
			subtaskParent.subtaskCompleted(result);
		}
	'''
}

def static String addDialogCancelPressed(AddTask it) {
	'''
		@Override
		protected void cancelPressed() {
			super.cancelPressed();
			subtaskParent.subtaskCancelled();
		}
	'''
}

def static String gapAddPage(AddTask it) {
	'''
	«val className = it."Add" + for.name + "Page"»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className), 'TO_SRC', '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	«addPageSpringAnnotation(it)»
	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String addPage(AddTask it) {
	'''
	«val className = it."Add" + for.name + "Page" + gapSubclassSuffix(this, "Add" + for.name + "Page")»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	«IF !className.endsWith("Base")»
	«addPageSpringAnnotation(it)»
	«ENDIF»
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» {
	«addPageConstructor(it)»
	«addPageSingleSelect(it)»
	«RcpCrudGuiMessageResources::messageSourceDependencyProperty(it)»
	«addPageRepository(it)»
	«addPageCreateControl(it)»
	«addPageInitParentLayout(it)»
	«addPageCreateContentComposite(it)»
	«addPageCreatePageContainer(it)»
	«addPageCreateSelectionTable(it)»
	«addPageDefineColumns(it)»
	«IF isPaging()»
		«addPageRetrievePagedInput(it)»
	«ELSE»
		«addPageRetrieveInput(it)»
	«ENDIF»
	«addPageGetCheckedElements(it)»

	}
	'''
	)
	'''
	'''
}

def static String addPageSpringAnnotation(AddTask it) {
	'''
	@org.springframework.stereotype.Component("add«for.name»Page")
	@org.springframework.context.annotation.Scope("prototype")
	'''
}

def static String addPageConstructor(AddTask it) {
	'''
	«val className = it."Add" + for.name + "Page" + gapSubclassSuffix(this, "Add" + for.name + "Page")»
		public «className»() {
		}
	'''
}

def static String addPageSingleSelect(AddTask it) {
	'''
		private boolean singleSelect;

		public boolean isSingleSelect() {
			return singleSelect;
		}

		public void setSingleSelect(boolean singleSelect) {
			this.singleSelect = singleSelect;
		}
	'''
}

def static String addPageRepository(AddTask it) {
	'''
	@org.springframework.beans.factory.annotation.Autowired
		private «module.getRichClientPackage()».data.Rich«for.name»Repository repository;
	'''
}

def static String addPageCreateControl(AddTask it) {
	'''
		protected org.eclipse.swt.widgets.Composite parent;
		protected org.eclipse.swt.widgets.Composite pageContainer;
		protected org.eclipse.swt.widgets.Composite contentComposite;
		protected «fw("richclient.table.CustomizableTableViewer")» tableViewer;

		protected org.eclipse.swt.widgets.Control createControl(org.eclipse.swt.widgets.Composite parent) {
			this.parent = parent;
			initParentLayout();

			contentComposite = createContentComposite();
			pageContainer = createPageContainer();

			tableViewer = createSelectionTable();

			retrieveInput();

			return contentComposite;
		}

		protected org.eclipse.swt.widgets.Composite getParent() {
			return parent;
		}
	'''
}

def static String addPageInitParentLayout(AddTask it) {
	'''
		protected void initParentLayout() {
			parent.setLayout(new org.eclipse.swt.layout.GridLayout(1, false));
		}
	'''
}

def static String addPageCreateContentComposite(AddTask it) {
	'''
		protected org.eclipse.swt.widgets.Composite createContentComposite() {
			org.eclipse.swt.widgets.Composite result = new org.eclipse.swt.widgets.Composite(parent, org.eclipse.swt.SWT.NONE);
			result.setLayoutData(new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false));

			org.eclipse.swt.layout.FillLayout layout = new org.eclipse.swt.layout.FillLayout(org.eclipse.swt.SWT.VERTICAL);
			layout.marginWidth = 5;
			layout.marginHeight = 5;
			result.setLayout(layout);
			return result;
		}

		protected org.eclipse.swt.widgets.Composite getContentComposite() {
			return contentComposite;
		}
	'''
}

def static String addPageCreatePageContainer(AddTask it) {
	'''
		protected org.eclipse.swt.widgets.Composite createPageContainer() {
			org.eclipse.swt.widgets.Composite result = new org.eclipse.swt.widgets.Composite(contentComposite, org.eclipse.swt.SWT.NULL);
			org.eclipse.swt.layout.GridLayout gridLayout = new org.eclipse.swt.layout.GridLayout();
			gridLayout.numColumns = 1;
			result.setLayout(gridLayout);
			return result;
		}

		protected org.eclipse.swt.widgets.Composite getPageContainer() {
			return pageContainer;
		}
	'''
}

def static String addPageCreateSelectionTable(AddTask it) {
	'''
		protected «fw("richclient.table.CustomizableTableViewer")» createSelectionTable() {
			int style = org.eclipse.swt.SWT.MULTI | org.eclipse.swt.SWT.BORDER | org.eclipse.swt.SWT.H_SCROLL | org.eclipse.swt.SWT.V_SCROLL | org.eclipse.swt.SWT.FULL_SELECTION;
			«fw("richclient.table.CustomizableTableViewer")» result;
			if (singleSelect) {
				result = «fw("richclient.table.CustomizableTableViewer")».newSingleCheckList(pageContainer, style);
			} else {
				result = «fw("richclient.table.CustomizableTableViewer")».newCheckList(pageContainer, style);
			}
			defineColumns(result);
			org.eclipse.swt.layout.GridData gridData = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.FILL, true, true, 3, 1);
			gridData.heightHint = 200;
			result.getViewer().getTable().setLayoutData(gridData);
			org.eclipse.swt.widgets.Table table = result.getViewer().getTable();
			table.setLinesVisible(true);
			table.setHeaderVisible(true);
			result.getViewer().setContentProvider(new org.eclipse.jface.viewers.ArrayContentProvider());

			return result;
		}

		protected «fw("richclient.table.CustomizableTableViewer")» getSelectionTableViewer() {
			return tableViewer;
		}
	'''
}

def static String addPageDefineColumns(AddTask it) {
	'''
	«RcpCrudGuiDefineColumns::defineColumns(it) FOR viewProperties»
	'''
}

def static String addPageRetrieveInput(AddTask it) {
	'''
		private void retrieveInput() {
			org.eclipse.core.runtime.jobs.Job job = new «fw("richclient.errorhandling.ExceptionAwareJob")»(
				org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».readJob, «getMessagesClass()».«for.getMessagesKey()»_plural), messages) {
				@Override
				protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor) {
				    monitor.beginTask(getName(), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				    final java.util.List<«module.getRichClientPackage()».data.Rich«for.name»> result = repository.«getPrimaryServiceOperation().name»();
				    org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
				        public void run() {
				            tableViewer.getViewer().setInput(result);
				        }
				    });
				    monitor.done();
				    return org.eclipse.core.runtime.Status.OK_STATUS;
				}
			};
			job.schedule();
		}
	'''
}

/*This solution should probably be changed. */
def static String addPageRetrievePagedInput(AddTask it) {
	'''
		private void retrieveInput() {
			org.eclipse.core.runtime.jobs.Job job = new «fw("richclient.errorhandling.ExceptionAwareJob")»(
				org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».readJob, «getMessagesClass()».«for.getMessagesKey()»_plural), messages) {
				@Override
				protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor) {
				    monitor.beginTask(getName(), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				    int maxPages = 20;
				    int pageSize = 500;
				    for (int i = 1; i <= maxPages; i++) {
				    	if (monitor.isCanceled() || i == 20) {
				            return Status.CANCEL_STATUS;
				        }
				        boolean countTotalPages = (i == 1);
				        «getJavaType("PagingParameter")» pagingParameter = «getJavaType("PagingParameter")».pageAccess(pageSize, i, countTotalPages);
	                final «getJavaType("PagedResult")»<«module.getRichClientPackage()».data.Rich«for.name»> result = repository.«getPrimaryServiceOperation().name»(pagingParameter);
				        if (result.isTotalCounted()) {
				            maxPages = result.getTotalPages();
				        }
	                
	                org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
	                    public void run() {
	                    	Object[] currentValues = (Object[]) tableViewer.getViewer().getInput();
				                if (currentValues == null) {
				                    currentValues = new Object[0];
				                }
				                java.util.Set<Object> allValues = new java.util.LinkedHashSet<Object>(java.util.Arrays.asList(currentValues));
				                allValues.addAll(result.getValues());
	                    
	                        tableViewer.getViewer().setInput(allValues.toArray());
	                    }
	                });
	            }
				    monitor.done();
				    return org.eclipse.core.runtime.Status.OK_STATUS;
				}
			};
			job.schedule();
		}
	'''
}

def static String addPageGetCheckedElements(AddTask it) {
	'''
		public «module.getRichClientPackage()».data.Rich«for.name»[] getCheckedElements() {
			org.eclipse.jface.viewers.CheckboxTableViewer viewer = (org.eclipse.jface.viewers.CheckboxTableViewer) tableViewer.getViewer();
			Object[] checkedElements = viewer.getCheckedElements();
			«module.getRichClientPackage()».data.Rich«for.name»[] result = new «module.getRichClientPackage()».data.Rich«for.name»[checkedElements.length];
			System.arraycopy(checkedElements, 0, result, 0, checkedElements.length);
			return result;
		}
	'''
}
}
