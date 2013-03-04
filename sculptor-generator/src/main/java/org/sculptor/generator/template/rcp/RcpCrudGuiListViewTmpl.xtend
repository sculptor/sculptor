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

class RcpCrudGuiListViewTmpl {



def static String listView(GuiApplication it) {
	'''
	«it.modules.forEach[listView(it)]»
	'''
} 

def static String listView(GuiModule it) {
	'''
	«it.userTasks.typeSelect(ListTask).forEach[listView(it)]»
	«it.userTasks.typeSelect(ListTask) .filter(e | isGapClassToBeGenerated(e, "List" + e.for.name + "View")).forEach[gapListView(it)]»
	«it.userTasks.typeSelect(ListTask).forEach[listViewTextFilter(it)]»
	«it.userTasks.typeSelect(ListTask) .filter(e | isGapClassToBeGenerated(e, "List" + e.for.name + "TextFilter")).forEach[gapListViewTextFilter(it)]»
	'''
}

def static String gapListView(ListTask it) {
	'''
	«val className = it."List" + for.name + "View"»
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

def static String listView(ListTask it) {
	'''
	«val className = it."List" + for.name + "View" + gapSubclassSuffix(this, "List" + for.name + "View")»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.ui.part.ViewPart implements java.util.Observer {
		
		// TODO feels like a lot of stuff can be extracted to a base ListView base class, maybe not generated
		
		«listViewID(it)»
		«listViewImageDescriptor(it)»
	«listViewConstructor(it)»
	«RcpCrudGuiMessageResources::messageSourceDependencyProperty(it)»
	«listViewInit(it)»
	«listViewDispose(it)»
	«listViewSaveState(it)»
	«listViewSetFocus(it)»
	«listViewUpdate(it)»
	«listViewRetrieveInput(it)»
	«IF isPaging()»
		«listViewRetrievePage(it)»
	«ENDIF»
	«listViewCreatePartControl(it)»
	«listViewDefineColumns(it)»
	«listViewSetFilterText(it)»
	«listViewInitFilters(it)»
	«listViewInitializePopupMenu(it)»
	«listViewInitializeMenu(it)»
	«listViewSetupViewMenu(it)»
	«listViewCreateAdjustColumnsAction(it)»
	«listViewCreateChooseColumnsAction(it)»
	«listViewCreateRefreshAction(it)»
	}
	'''
	)
	'''
	'''
}

def static String listViewID(ListTask it) {
	'''
		public static final String ID = «module.getRichClientPackage()».ui.List«for.name»View.class.getName();
		public static final String MENU_ID = «module.getRichClientPackage()».ui.List«for.name»View.class.getName() + "Menu";
	'''
}

def static String listViewImageDescriptor(ListTask it) {
	'''
		private static org.eclipse.jface.resource.ImageDescriptor chooseColImageDescriptor = «fw("richclient.SculptorFrameworkPlugin")».TABLE_CHOOSE_COL_IMAGE;
		private static org.eclipse.jface.resource.ImageDescriptor adjustImageDescriptor = «fw("richclient.SculptorFrameworkPlugin")».TABLE_ADJUST_IMAGE;
	'''
}

def static String listViewConstructor(ListTask it) {
	'''
	«val className = it."List" + for.name + "View" + gapSubclassSuffix(this, "List" + for.name + "View")»
		private «module.getRichClientPackage()».data.Rich«for.name»Repository repository;
		
		public «className»() {
			repository = «module.application.getRichClientPackage()».«module.application.name.toFirstUpper()»Plugin.getDefault().getRepository(«module.getRichClientPackage()».data.Rich«for.name»Repository.class);
			messages = (org.springframework.context.MessageSource) «module.application.getRichClientPackage()».«module.application.name.toFirstUpper()»Plugin.getDefault()
				.getSpringContext().getBean("messageSource");
		}
	'''
}

def static String listViewInit(ListTask it) {
	'''
		private org.eclipse.ui.IMemento memento;
		
		@Override
		public void init(org.eclipse.ui.IViewSite site, org.eclipse.ui.IMemento memento) throws org.eclipse.ui.PartInitException {
			super.init(site, memento);
			this.memento = memento;
		}
	'''
}

def static String listViewDispose(ListTask it) {
	'''
		@Override
		public void dispose() {
			if (repository != null) {
				repository.deleteObserver(this);
			}
			super.dispose();
		}
	'''
}

def static String listViewSaveState(ListTask it) {
	'''
		@Override
		public void saveState(org.eclipse.ui.IMemento pMemento) {
			super.saveState(pMemento);
			tableViewer.saveState(pMemento, ID + ".Table");
		}
	'''
}

def static String listViewSetFocus(ListTask it) {
	'''
		public void setFocus() {
		}
	'''
}

def static String listViewUpdate(ListTask it) {
	'''
		public void update(java.util.Observable o, final Object object) {
			org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
				public void run() {
				    «fw("richclient.data.DataEvent")» event = («fw("richclient.data.DataEvent")») object;
				    
				    switch (event.getAction()) {
	                case INSERT:
	                    tableViewer.getViewer().add(event.getSourceObject());
	                    break;
	                case REMOVE:
	                    tableViewer.getViewer().remove(event.getSourceObject());
	                    break;
	                case UPDATE:
	                    tableViewer.getViewer().update(event.getSourceObject(), null);
	                    break;
	                case REFRESH:
	                    retrieveInput();
	                    break;
	                default:
	                    // Unknown type, not handled anyway
				    }
				}
			});
		}
	'''
}

def static String listViewRetrievePage(ListTask it) {
	'''
		private void retrievePage(final int page) {
			if (page < 1) {
				return;
			}    
			org.eclipse.core.runtime.jobs.Job job = new «fw("richclient.errorhandling.ExceptionAwareJob")»(
				org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».readJob, «getMessagesClass()».«for.getMessagesKey()»_plural), messages) {
				@Override
				protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor) {
				    monitor.beginTask(getName(), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				    «getJavaType("PagingParameter")» pagingParameter = «getJavaType("PagingParameter")».pageAccess(«getJavaType("PagingParameter")».DEFAULT_PAGE_SIZE, page);
				    final «getJavaType("PagedResult")»<«module.getRichClientPackage()».data.Rich«for.name»> result = repository.«getPrimaryServiceOperation().name»(pagingParameter);
				    org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
				        public void run() {
				            tableViewer.getViewer().setInput(result.getValues().toArray());
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

def static String listViewRetrieveInput(ListTask it) {
	'''
		private void retrieveInput() {
			org.eclipse.core.runtime.jobs.Job job = new «fw("richclient.errorhandling.ExceptionAwareJob")»(
				org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».readJob, «getMessagesClass()».«for.getMessagesKey()»_plural), messages) {
				@Override
				protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor) {
				    monitor.beginTask(getName(), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				    «IF isPaging()»
				    «getJavaType("PagingParameter")» pagingParameter = «getJavaType("PagingParameter")».pageAccess(«getJavaType("PagingParameter")».DEFAULT_PAGE_SIZE, 1, true);
				    final «getJavaType("PagedResult")»<«module.getRichClientPackage()».data.Rich«for.name»> result = repository.«getPrimaryServiceOperation().name»(pagingParameter);
				    «ELSE»
				    final java.util.List<«module.getRichClientPackage()».data.Rich«for.name»> result = repository.«getPrimaryServiceOperation().name»();
				    «ENDIF»
				    org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
				        public void run() {
				        	«IF isPaging()»
				        		page.setText(String.valueOf(result.getPage()));
				        		if (result.isTotalCounted()) {
				                    maxPagesLabel.setText("of " + result.getTotalPages());
				                }
				                tableViewer.getViewer().setInput(result.getValues().toArray());
				            «ELSE»
				            	tableViewer.getViewer().setInput(result);
				            «ENDIF»
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

def static String listViewCreatePartControl(ListTask it) {
	'''
	«val gridColumns = it.isPaging() ? "6" : "3"»
		protected «fw("richclient.table.CustomizableTableViewer")» tableViewer;
		protected org.eclipse.swt.widgets.Text filterText;
		protected org.eclipse.swt.widgets.ToolItem clearToolItem;
		«IF isPaging()»
		protected org.eclipse.swt.widgets.Text page;
		protected org.eclipse.swt.widgets.Label maxPagesLabel;
		«ENDIF»
		
		@Override
		public void createPartControl(org.eclipse.swt.widgets.Composite parent) {
			org.eclipse.swt.widgets.Composite container = new org.eclipse.swt.widgets.Composite(parent, org.eclipse.swt.SWT.NONE);
			org.eclipse.swt.layout.GridLayout gridLayout = new org.eclipse.swt.layout.GridLayout(«gridColumns», false);
			gridLayout.verticalSpacing = 0;
			gridLayout.marginWidth = 0;
			gridLayout.marginHeight = 0;
			gridLayout.horizontalSpacing = 0;
			container.setLayout(gridLayout);

			org.eclipse.swt.widgets.Label filterLabel = new org.eclipse.swt.widgets.Label(container, org.eclipse.swt.SWT.NONE);
			filterLabel.setText(«getMessagesClass()».listView_filter_label);

			filterText = new org.eclipse.swt.widgets.Text(container, org.eclipse.swt.SWT.BORDER);
			filterText.addModifyListener(new org.eclipse.swt.events.ModifyListener() {
				public void modifyText(org.eclipse.swt.events.ModifyEvent event) {
				    setFilterText(filterText.getText());
				    if ("".equals(filterText.getText())) {
				        clearToolItem.setEnabled(false);
				    } else {
				        clearToolItem.setEnabled(true);
				    }
				}
			});
			org.eclipse.swt.layout.GridData filterTextGd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, false, false);
			filterTextGd.widthHint = 200;
			filterTextGd.minimumWidth = 200;
			filterText.setLayoutData(filterTextGd);

			org.eclipse.swt.widgets.ToolBar toolBar = new org.eclipse.swt.widgets.ToolBar(container, org.eclipse.swt.SWT.NONE);

			clearToolItem = new org.eclipse.swt.widgets.ToolItem(toolBar, org.eclipse.swt.SWT.NONE);
			clearToolItem.setImage(«module.application.getRichClientPackage()».«module.application.name»Plugin.CLEAR_IMAGE.createImage());
			clearToolItem.setToolTipText(«getMessagesClass()».listView_clear_filter);
			clearToolItem.setEnabled(false);
			clearToolItem.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
				@Override
				public void widgetSelected(org.eclipse.swt.events.SelectionEvent event) {
				    filterText.setText("");
				}
			});
			
		«IF isPaging()»
			org.eclipse.swt.widgets.Label pageLabel = new org.eclipse.swt.widgets.Label(container, org.eclipse.swt.SWT.RIGHT);
			pageLabel.setText("Page:");
			org.eclipse.swt.layout.GridData pageLabelGd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.RIGHT, org.eclipse.swt.SWT.CENTER, true, false);
			pageLabel.setLayoutData(pageLabelGd);

			page = new org.eclipse.swt.widgets.Text(container, org.eclipse.swt.SWT.BORDER);
			page.setText("1");
			page.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
				public void widgetDefaultSelected(org.eclipse.swt.events.SelectionEvent event) {
				    try {
				        int pageNumber = Integer.valueOf(page.getText());
				        retrievePage(pageNumber);
				    } catch (NumberFormatException skip) {
				    }
				}
			});

			org.eclipse.swt.layout.GridData pageGd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.RIGHT, org.eclipse.swt.SWT.CENTER, false, false);
			pageGd.widthHint = 50;
			pageGd.minimumWidth = 50;
			page.setLayoutData(pageGd);

			maxPagesLabel = new org.eclipse.swt.widgets.Label(container, org.eclipse.swt.SWT.NONE);
			maxPagesLabel.setText("");
			org.eclipse.swt.layout.GridData maxPagesLabelGd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.RIGHT, org.eclipse.swt.SWT.CENTER, false, false);
			maxPagesLabelGd.widthHint = 50;
			maxPagesLabelGd.minimumWidth = 50;
			maxPagesLabel.setLayoutData(maxPagesLabelGd);
		«ENDIF»

			tableViewer = «fw("richclient.table.CustomizableTableViewer")».newTable(container, 
				    org.eclipse.swt.SWT.MULTI | org.eclipse.swt.SWT.BORDER | org.eclipse.swt.SWT.H_SCROLL | org.eclipse.swt.SWT.V_SCROLL | org.eclipse.swt.SWT.FULL_SELECTION);
			defineColumns(tableViewer);
			initFilters();
			tableViewer.getViewer().getTable().setLayoutData(new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.FILL, true, true, «gridColumns», 1));
			org.eclipse.swt.widgets.Table table = tableViewer.getViewer().getTable();
			table.setLinesVisible(true);
			table.setHeaderVisible(true);
			tableViewer.getViewer().setContentProvider(new org.eclipse.jface.viewers.ArrayContentProvider());
			tableViewer.init(memento, ID + ".Table");

			repository.addObserver(this);

			initializeMenu();
			initializePopupMenu();

			getSite().setSelectionProvider(tableViewer.getViewer());
			
			retrieveInput();

		}
	'''
}

def static String listViewDefineColumns(ListTask it) {
	'''
	«RcpCrudGuiDefineColumns::defineColumns(it) FOR viewProperties.reject(p | p.isSystemAttribute()) »
	'''
}

def static String listViewSetFilterText(ListTask it) {
	'''
		private void setFilterText(String text) {
			textFilter.setText("*" + text);
			tableViewer.refresh();
		}
	'''
}

def static String listViewInitFilters(ListTask it) {
	'''
		private List«for.name»TextFilter textFilter = new List«for.name»TextFilter();
		
		private void initFilters() {
			java.util.List<org.eclipse.jface.viewers.ViewerFilter> filters = new java.util.ArrayList<org.eclipse.jface.viewers.ViewerFilter>();
			filters.add(textFilter);

			tableViewer.getViewer().setFilters(filters.toArray(new org.eclipse.jface.viewers.ViewerFilter[filters.size()]));
		}
	'''
}

def static String listViewInitializePopupMenu(ListTask it) {
	'''
		protected void initializePopupMenu() {
			org.eclipse.jface.action.MenuManager menuMgr = new org.eclipse.jface.action.MenuManager();
			menuMgr.setRemoveAllWhenShown(true);
			menuMgr.addMenuListener(new org.eclipse.jface.action.IMenuListener() {
				public void menuAboutToShow(org.eclipse.jface.action.IMenuManager manager) {
				    manager.add(new org.eclipse.jface.action.Separator(org.eclipse.ui.IWorkbenchActionConstants.MB_ADDITIONS));
				}

			});
			org.eclipse.swt.widgets.Menu menu = menuMgr.createContextMenu(tableViewer.getViewer().getTable());
			tableViewer.getViewer().getTable().setMenu(menu);
			getSite().registerContextMenu(MENU_ID, menuMgr, tableViewer.getViewer());
		}
	'''
}

def static String listViewInitializeMenu(ListTask it) {
	'''
		protected void initializeMenu() {
			org.eclipse.jface.action.IMenuManager menuManager = getViewSite().getActionBars().getMenuManager();
			setupViewMenu(tableViewer, menuManager);
		}
	'''
}

def static String listViewSetupViewMenu(ListTask it) {
	'''
		protected void setupViewMenu(«fw("richclient.table.CustomizableTableViewer")» columnViewer, org.eclipse.jface.action.IMenuManager menuManager) {
			menuManager.add(createAdjustColumnsAction(columnViewer));
			menuManager.add(createChooseColumnsAction(columnViewer));
			menuManager.add(createRefreshAction());
		}
	'''
}

def static String listViewCreateAdjustColumnsAction(ListTask it) {
	'''
		protected org.eclipse.jface.action.Action createAdjustColumnsAction(final «fw("richclient.table.CustomizableTableViewer")» columnViewer) {
			org.eclipse.jface.action.Action adjustColumnsAction = new org.eclipse.jface.action.Action() {

				@Override
				public org.eclipse.jface.resource.ImageDescriptor getImageDescriptor() {
				    return adjustImageDescriptor;
				}

				@Override
				public String getText() {
				    return «getMessagesClass()».listView_columns_adjust;
				}

				@Override
				public void run() {
				    columnViewer.adjustTableWidth(true);
				}
			};
			return adjustColumnsAction;
		}
	'''
}

def static String listViewCreateChooseColumnsAction(ListTask it) {
	'''
		protected org.eclipse.jface.action.Action createChooseColumnsAction(final «fw("richclient.table.CustomizableTableViewer")» columnViewer) {
			org.eclipse.jface.action.Action chooseColumnsAction = new org.eclipse.jface.action.Action() {

				@Override
				public org.eclipse.jface.resource.ImageDescriptor getImageDescriptor() {
				    return chooseColImageDescriptor;
				}

				@Override
				public String getText() {
				    return «getMessagesClass()».listView_columns_choose;
				}

				@Override
				public void run() {
				    «fw("richclient.table.ColumnChooserDlg")» dialog = new «fw("richclient.table.ColumnChooserDlg")»(org.eclipse.swt.widgets.Display.getCurrent().getActiveShell(), («fw("richclient.table.CustomizableTableViewer")») columnViewer);
				    dialog.open();
				}
			};
			return chooseColumnsAction;
		}
	'''
}

def static String listViewCreateRefreshAction(ListTask it) {
	'''
		protected org.eclipse.jface.action.Action createRefreshAction() {
			org.eclipse.jface.action.Action refreshAction = new org.eclipse.jface.action.Action() {

				@Override
				public org.eclipse.jface.resource.ImageDescriptor getImageDescriptor() {
				    return «module.application.getRichClientPackage()».«module.application.name.toFirstUpper()»Plugin.REFRESH_IMAGE;
				}

				@Override
				public String getText() {
				    return «getMessagesClass()».listView_columns_refresh;
				}

				@Override
				public void run() {
				    retrieveInput();
				}
			};
			return refreshAction;
		}
	'''
}


def static String gapListViewTextFilter(ListTask it) {
	'''
	«val className = it."List" + for.name + "TextFilter"»
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

def static String listViewTextFilter(ListTask it) {
	'''
	«val className = it."List" + for.name + "TextFilter" + gapSubclassSuffix(this, "List" + for.name + "TextFilter")»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.jface.viewers.ViewerFilter {
		«listViewTextFilterConstructor(it)»
		«listViewTextFilterTextProperty(it)»
		«listViewTextFilterSelect(it)»
	}
	'''
	)
	'''
	'''
}

def static String listViewTextFilterConstructor(ListTask it) {
	'''
	«val className = it."List" + for.name + "TextFilter" + gapSubclassSuffix(this, "List" + for.name + "TextFilter")»
		private org.eclipse.ui.dialogs.SearchPattern searchPattern;
		
		public «className»() {
			searchPattern = new org.eclipse.ui.dialogs.SearchPattern(org.eclipse.ui.dialogs.SearchPattern.RULE_PATTERN_MATCH | org.eclipse.ui.dialogs.SearchPattern.RULE_CAMELCASE_MATCH);
		}
	'''
}

def static String listViewTextFilterTextProperty(ListTask it) {
	'''
		private String text;

		public String getText() {
			return text;
		}

		public void setText(String text) {
			this.text = text;
		}
	'''
}

def static String listViewTextFilterSelect(ListTask it) {
	'''
		@Override
		public boolean filter(org.eclipse.jface.viewers.Viewer viewer, Object parentElement, Object element) {
			if (text == null || text.trim().length() == 0) {
				return true;
			}
			if (!(element instanceof «module.getRichClientPackage()».data.Rich«for.name»)) {
				return true;
			}
			searchPattern.setPattern(text.trim());
			// TODO handle enum, dates and other converted values
			«module.getRichClientPackage()».data.Rich«for.name» obj = («module.getRichClientPackage()».data.Rich«for.name») element;
			«LET viewProperties .reject(p | p.isSystemAttribute())
				.reject(e|e.metaType == ReferenceViewProperty || e.metaType == DerivedReferenceViewProperty) AS searchableProperties»
			return («it.searchableProperties SEPARATOR " || ".forEach[searchPatternMatch(it)]»);
		}
	'''
}

def static String searchPatternMatch(ViewDataProperty it) {
	'''
	searchPattern.matches(String.valueOf(obj.get«name.toFirstUpper()»()))
	'''
}

}
