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

class RcpCrudGuiCommonAdapterTmpl {



def static String commonAdapter(GuiApplication it) {
	'''
	«commonAdapterFactory(it)»
	«IF isGapClassToBeGenerated("", "CommonAdapterFactory")»
		«gapCommonAdapterFactory(it)»
	«ENDIF»
	
	«domainObjectFolderAdapter(it)»
	«IF isGapClassToBeGenerated("", "DomainObjectFolderAdapter")»
		«gapDomainObjectFolderAdapter(it)»
	«ENDIF»
	
	«errorNodeAdapter(it)»
	«IF isGapClassToBeGenerated("", "ErrorNodeAdapter")»
		«gapErrorNodeAdapter(it)»
	«ENDIF»
	
	«moreNodeAdapter(it)»
	«IF isGapClassToBeGenerated("", "MoreNodeAdapter")»
		«gapMoreNodeAdapter(it)»
	«ENDIF»
	
	«moduleFolderAdapter(it)»
	«IF isGapClassToBeGenerated("", "ModuleFolderAdapter")»
		«gapModuleFolderAdapter(it)»
	«ENDIF»
	
	«rootNodeAdapter(it)»
	«IF isGapClassToBeGenerated("", "RootNodeAdapter")»
		«gapRootNodeAdapter(it)»
	«ENDIF»
	
	'''
}

def static String gapCommonAdapterFactory(GuiApplication it) {
	'''
	«val className = it."CommonAdapterFactory"»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String commonAdapterFactory(GuiApplication it) {
	'''
	«val className = it."CommonAdapterFactory" + gapSubclassSuffix("CommonAdapterFactory")»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className) , '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

/**
 * Factory for common adapters used in the navigation tree. 
 * 
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends «fw("richclient.adapter.AbstractAdapterFactory")» {
		
		public «className»() {
			addAdapterForObject(«getRichClientPackage("common")».data.RootNode.class, RootNodeAdapter.class);
			addAdapterForObject(«getRichClientPackage("common")».data.ModuleFolder.class, ModuleFolderAdapter.class);
			addAdapterForObject(«getRichClientPackage("common")».data.DomainObjectFolder.class, DomainObjectFolderAdapter.class);
			addAdapterForObject(«getRichClientPackage("common")».data.ErrorNode.class, ErrorNodeAdapter.class);
			addAdapterForObject(«getRichClientPackage("common")».data.MoreNode.class, MoreNodeAdapter.class);
		}

	}
	'''
	)
	'''
	'''
}

def static String gapDomainObjectFolderAdapter(GuiApplication it) {
	'''
	«val className = it."DomainObjectFolderAdapter"»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String domainObjectFolderAdapter(GuiApplication it) {
	'''
	«val className = it."DomainObjectFolderAdapter" + gapSubclassSuffix("DomainObjectFolderAdapter")»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className) , '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

/**
 * Adapter for the DomainObject folder node.
 * 
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» implements org.eclipse.ui.progress.IDeferredWorkbenchAdapter {
		private org.eclipse.jface.resource.ImageDescriptor imageDescriptor = 
			«getRichClientPackage()».«name.toFirstUpper()»Plugin.getImageDescriptor(«getRichClientPackage()».«name.toFirstUpper()»Plugin.ICONS_PATH + "domain_object_folder.png");

	«FOR task : modules.userTasks.typeSelect(ListTask)»
	private «task.module.getRichClientPackage()».data.Rich«task.for.name»Repository «task.for.name.toFirstLower()»Repository;
	«ENDFOR»
		
		public «className»() {
			messages = (org.springframework.context.MessageSource) «getRichClientPackage()».«name.toFirstUpper()»Plugin.getDefault()
				.getSpringContext().getBean("messageSource");
				
		«FOR task : modules.userTasks.typeSelect(ListTask)»
		«task.for.name.toFirstLower()»Repository = «getRichClientPackage()».«name.toFirstUpper()»Plugin.getDefault().getRepository(«task.module.getRichClientPackage()».data.Rich«task.for.name»Repository.class);
	«ENDFOR»
	
	«FOR task : modules.userTasks.typeSelect(ListTask)»
	    fetchers.put(«getRichClientPackage("common")».data.DomainObjectFolder.«task.for.name.toUpperCase()», new «task.for.name»Fetcher());
	«ENDFOR»
		}
		
		«RcpCrudGuiMessageResources::messageSourceDependencyProperty(it)»
		
	«domainObjectFolderAdapterFetchDeferredChildren(it)»

		public org.eclipse.core.runtime.jobs.ISchedulingRule getRule(Object object) {
			return null;
		}

		public boolean isContainer() {
			return true;
		}

		public Object[] getChildren(Object object) {
			return null;
		}

		public org.eclipse.jface.resource.ImageDescriptor getImageDescriptor(Object object) {
			return imageDescriptor;
		}

		public String getLabel(Object object) {
			return ((«getRichClientPackage("common")».data.DomainObjectFolder) object).getName();
		}

		public Object getParent(Object object) {
			return ((«getRichClientPackage("common")».data.DomainObjectFolder) object).getParent();
		}
		
		«domainObjectFolderAdapterFetchers(it)»

	}
	'''
	)
	'''
	'''
}

def static String domainObjectFolderAdapterFetchDeferredChildren(GuiApplication it) {
	'''
		public void fetchDeferredChildren(final Object object, final org.eclipse.ui.progress.IElementCollector collector, final org.eclipse.core.runtime.IProgressMonitor monitor) {
			java.util.concurrent.Callable<Object> callable = new java.util.concurrent.Callable<Object>() {
				public Object call() throws Exception {
		        «getRichClientPackage("common")».data.DomainObjectFolder current = («getRichClientPackage("common")».data.DomainObjectFolder) object;
		        try {
		            monitor.beginTask(org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».fetchChildrenJob, current.getName()), 1);
		
		            Fetcher fetcher = fetchers.get(current);
		            if (fetcher == null) {
		                throw new IllegalArgumentException("Unsupported DomainObjectFolder " + current);
		            }
		            
		            for («fw("richclient.data.RichObject")» each : fetcher.getAll()) {
		                collector.add(each, monitor);
		            }
		            monitor.worked(1);
		            return null;
		
		        } catch (Exception e) {
		            collector.add(new «getRichClientPackage("common")».data.ErrorNode(«getMessagesClass()».errorNode, current), monitor);
		            throw e;
		        } finally {
		            monitor.done();
		        }
		    }
			};
			
			«fw("richclient.errorhandling.ExceptionAware")»<Object> runner = new «fw("richclient.errorhandling.ExceptionAware")»<Object>(messages);
			runner.run(callable);
		}
	'''
}

def static String domainObjectFolderAdapterFetchers(GuiApplication it) {
	'''
		private java.util.Map<«getRichClientPackage("common")».data.DomainObjectFolder, Fetcher> fetchers = new java.util.HashMap<«getRichClientPackage("common")».data.DomainObjectFolder, Fetcher>();
		
		static interface Fetcher {
			java.util.List<? ^extends «fw("richclient.data.RichObject")»> getAll();
		}
		
		«FOR task : modules.userTasks.typeSelect(ListTask)»
		«val operation = it.task.getPrimaryServiceOperation() != null ? task.getPrimaryServiceOperation() : task.for.getFindAllMethod()»
		class «task.for.name»Fetcher implements Fetcher {
			public java.util.List<? ^extends «fw("richclient.data.RichObject")»> getAll() {
				«IF task.isPaging()»
					int pageSize = 20;
					«getJavaType("PagedResult")»<«task.module.getRichClientPackage()».data.Rich«task.for.name»> pagedResult = «task.for.name.toFirstLower()»Repository.«operation.name»(
						«getJavaType("PagingParameter")».pageAccess(pageSize, 1, true));
					java.util.List<«fw("richclient.data.RichObject")»> result = new java.util.ArrayList<«fw("richclient.data.RichObject")»>(pagedResult.getValues());
	            if (pagedResult.isTotalCounted() && pagedResult.getTotalPages() > 1) {
	                result.add(new «getRichClientPackage("common")».data.MoreNode());
	            }
	            return result;
				«ELSE»
					return «task.for.name.toFirstLower()»Repository.«operation.name»();
				«ENDIF»
			}
		}
	«ENDFOR»
	'''
}

def static String gapErrorNodeAdapter(GuiApplication it) {
	'''
	«val className = it."ErrorNodeAdapter"»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String errorNodeAdapter(GuiApplication it) {
	'''
	«val className = it."ErrorNodeAdapter" + gapSubclassSuffix("ErrorNodeAdapter")»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className) , '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

/**
 * Adapter for error objects
 * 
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» implements org.eclipse.ui.progress.IDeferredWorkbenchAdapter {
		private org.eclipse.jface.resource.ImageDescriptor imageDescriptor = 
			«getRichClientPackage()».«name.toFirstUpper()»Plugin.getImageDescriptor(«getRichClientPackage()».«name.toFirstUpper()»Plugin.ICONS_PATH + "error_node.png");

		public void fetchDeferredChildren(Object object, org.eclipse.ui.progress.IElementCollector collector, final org.eclipse.core.runtime.IProgressMonitor monitor) {
			// This type has no children
		}

		public org.eclipse.core.runtime.jobs.ISchedulingRule getRule(Object object) {
			return null;
		}

		public boolean isContainer() {
			return false;
		}

		public Object[] getChildren(Object object) {
			return null;
		}

		public org.eclipse.jface.resource.ImageDescriptor getImageDescriptor(Object object) {
			return imageDescriptor;
		}

		public String getLabel(Object object) {
			return ((«getRichClientPackage("common")».data.ErrorNode) object).getMessage();
		}

		public Object getParent(Object object) {
			return ((«getRichClientPackage("common")».data.ErrorNode) object).getParent();
		}
		
	}
	'''
	)
	'''
	'''
}

def static String gapMoreNodeAdapter(GuiApplication it) {
	'''
	«val className = it."MoreNodeAdapter"»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String moreNodeAdapter(GuiApplication it) {
	'''
	«val className = it."MoreNodeAdapter" + gapSubclassSuffix("MoreNodeAdapter")»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className) , '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

/**
 * Adapter for MoreNode objects
 * 
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» implements org.eclipse.ui.progress.IDeferredWorkbenchAdapter {
		public void fetchDeferredChildren(Object object, org.eclipse.ui.progress.IElementCollector collector, final org.eclipse.core.runtime.IProgressMonitor monitor) {
			// This type has no children
		}

		public org.eclipse.core.runtime.jobs.ISchedulingRule getRule(Object object) {
			return null;
		}

		public boolean isContainer() {
			return false;
		}

		public Object[] getChildren(Object object) {
			return null;
		}

		public org.eclipse.jface.resource.ImageDescriptor getImageDescriptor(Object object) {
			return null;
		}

		public String getLabel(Object object) {
			// Nodes are ordered by label.
			// Is there a better way to make sure that this is placed last?
			return "_ ...";
		}

		public Object getParent(Object object) {
			return null;
		}
		
	}
	'''
	)
	'''
	'''
}

def static String gapModuleFolderAdapter(GuiApplication it) {
	'''
	«val className = it."ModuleFolderAdapter"»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String moduleFolderAdapter(GuiApplication it) {
	'''
	«val className = it."ModuleFolderAdapter" + gapSubclassSuffix("ErrorNodeAdapter")»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className) , '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

/**
 * Adapter for the Module folder node
 * 
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» implements org.eclipse.ui.progress.IDeferredWorkbenchAdapter {
		private org.eclipse.jface.resource.ImageDescriptor imageDescriptor = 
			«getRichClientPackage()».«name.toFirstUpper()»Plugin.getImageDescriptor(«getRichClientPackage()».«name.toFirstUpper()»Plugin.ICONS_PATH + "module_folder.png");
		
		public «className»() {
		«FOR module : modules.reject(m | m.userTasks.typeSelect(ListTask).isEmpty)»
	fetchers.put(«getRichClientPackage("common")».data.ModuleFolder.«module.name.toUpperCase()», new «module.name.toFirstUpper()»Fetcher());
	«ENDFOR»
		}
		
		«moduleFolderAdapterFetchDeferredChildren(it)»

		public org.eclipse.core.runtime.jobs.ISchedulingRule getRule(Object object) {
			return null;
		}

		public boolean isContainer() {
			return true;
		}

		public Object[] getChildren(Object pO) {
			return null;
		}

		public org.eclipse.jface.resource.ImageDescriptor getImageDescriptor(Object object) {
			return imageDescriptor;
		}

		public String getLabel(Object object) {
			return ((«getRichClientPackage("common")».data.ModuleFolder) object).getName();
		}

		public Object getParent(Object object) {
			return «getRichClientPackage("common")».data.RootNode.INSTANCE;
		}
		
		«moduleFolderAdapterFetchers(it)»

	}
	'''
	)
	'''
	'''
}

def static String moduleFolderAdapterFetchDeferredChildren(GuiApplication it) {
	'''
		public void fetchDeferredChildren(Object object, org.eclipse.ui.progress.IElementCollector collector, org.eclipse.core.runtime.IProgressMonitor monitor) {

			«getRichClientPackage("common")».data.ModuleFolder current = («getRichClientPackage("common")».data.ModuleFolder) object;

			monitor.beginTask("Fetching domain object types", 1);
			
			Fetcher fetcher = fetchers.get(current);
			if (fetcher == null) {
				throw new IllegalArgumentException("Unsupported ModuleFolder " + current);
			}
			
			for («getRichClientPackage("common")».data.DomainObjectFolder each : fetcher.getAll()) {
				collector.add(each, monitor);
			}
			monitor.worked(1);
			monitor.done();
		}
	'''
}

def static String moduleFolderAdapterFetchers(GuiApplication it) {
	'''
		private java.util.Map<«getRichClientPackage("common")».data.ModuleFolder, Fetcher> fetchers = new java.util.HashMap<«getRichClientPackage("common")».data.ModuleFolder, Fetcher>();
		
		static interface Fetcher {
			java.util.List<«getRichClientPackage("common")».data.DomainObjectFolder> getAll();
		}
		
		«FOR module : modules.reject(m | m.userTasks.typeSelect(ListTask).isEmpty)»
		class «module.name.toFirstUpper()»Fetcher implements Fetcher {
			public java.util.List<«getRichClientPackage("common")».data.DomainObjectFolder> getAll() {
				java.util.List<«getRichClientPackage("common")».data.DomainObjectFolder> result = new java.util.ArrayList<«getRichClientPackage("common")».data.DomainObjectFolder>();
				«FOR task : module.userTasks.typeSelect(ListTask)»
				result.add(«getRichClientPackage("common")».data.DomainObjectFolder.«task.for.name.toUpperCase()»);
				«ENDFOR»
				return result;
			}
		}
	«ENDFOR»
	'''
}

def static String gapRootNodeAdapter(GuiApplication it) {
	'''
	«val className = it."RootNodeAdapter"»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String rootNodeAdapter(GuiApplication it) {
	'''
	«val className = it."RootNodeAdapter" + gapSubclassSuffix("RootNodeAdapter")»
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".adapter." + className) , '''
	«javaHeader()»
	package «getRichClientPackage("common")».adapter;

/**
 * Adapter for the root node. This class is responsible for loading
 * all modules.
 * 
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» implements org.eclipse.ui.progress.IDeferredWorkbenchAdapter {
		private volatile java.util.concurrent.atomic.AtomicBoolean initialized = new java.util.concurrent.atomic.AtomicBoolean(false);

		public «className»() {
		}

		public void fetchDeferredChildren(Object object, org.eclipse.ui.progress.IElementCollector collector, final org.eclipse.core.runtime.IProgressMonitor monitor) {

			synchronized (initialized) {
				if (initialized.get()) {
				    return;
				}
				initialized.set(true);

				monitor.beginTask("Fetching modules", 1);
				«FOR module : modules.reject(m | m.userTasks.typeSelect(ListTask).isEmpty)»
				collector.add(«getRichClientPackage("common")».data.ModuleFolder.«module.name.toUpperCase()», monitor);
				«ENDFOR»
				monitor.worked(1);
				monitor.done();
			}
		}

		public org.eclipse.core.runtime.jobs.ISchedulingRule getRule(Object object) {
			return null;
		}

		public boolean isContainer() {
			return true;
		}

		public Object[] getChildren(Object object) {
			return null;
		}

		public org.eclipse.jface.resource.ImageDescriptor getImageDescriptor(Object object) {
			return null;
		}

		public String getLabel(Object object) {
			return "Root";
		}

		public Object getParent(Object object) {
			return null;
		}

	}
	'''
	)
	'''
	'''
}

}
