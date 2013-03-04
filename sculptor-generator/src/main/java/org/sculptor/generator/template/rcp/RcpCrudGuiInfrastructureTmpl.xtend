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

class RcpCrudGuiInfrastructureTmpl {



def static String infrastructure(GuiApplication it) {
	'''
	«plugin(it)»
	«IF isGapClassToBeGenerated("", name.toFirstUpper() + "Plugin")»
		«gapPlugin(it)»
	«ENDIF»
	«application(it)»
	«IF isGapClassToBeGenerated("", "Application")»
		«gapApplication(it)»
	«ENDIF»
	«actionBarAdvisor(it)»
	«IF isGapClassToBeGenerated("", "ApplicationActionBarAdvisor")»
		«gapActionBarAdvisor(it)»
	«ENDIF»
	«workbenchAdvisor(it)»
	«IF isGapClassToBeGenerated("", "ApplicationWorkbenchAdvisor")»
		«gapWorkbenchAdvisor(it)»
	«ENDIF»
	«workbenchWindowAdvisor(it)»
	«IF isGapClassToBeGenerated("", "ApplicationWorkbenchWindowAdvisor")»
		«gapWorkbenchWindowAdvisor(it)»
	«ENDIF»
	«contextClassLoaderFactory(it)»
		
	'''
} 

def static String gapPlugin(GuiApplication it) {
	'''
	«val className = it.name.toFirstUpper() + "Plugin"»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage()»;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
		
		«IF !className.endsWith("Base")»
		public void start(org.osgi.framework.BundleContext context) throws Exception {
			super.start(context);
			
			plugin = this;
		}

		public void stop(org.osgi.framework.BundleContext context) throws Exception {
			«fw("richclient.util.SWTResourceManager")».dispose();
			plugin = null;
			super.stop(context);
		}

	«pluginGetDefault(it)»
	«ENDIF»
		
	}
	'''
	)
	'''
	'''
}

def static String plugin(GuiApplication it) {
	'''
	«val className = it.name.toFirstUpper() + "Plugin" + gapSubclassSuffix(name.toFirstUpper() + "Plugin")»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className) , '''
	«javaHeader()»
	package «getRichClientPackage()»;

/**
 * The activator class controls the plug-in life cycle.
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.ui.plugin.AbstractUIPlugin {

		// The plug-in ID
		public static final String PLUGIN_ID = "«getRichClientPackage()»";

		public static final String ICONS_PATH = "icons/";
		
		public static final org.eclipse.jface.resource.ImageDescriptor CLEAR_IMAGE = getImageDescriptor(ICONS_PATH + "clear.gif");
		public static final org.eclipse.jface.resource.ImageDescriptor DESC_COLLAPSE_ALL_IMAGE = getImageDescriptor(ICONS_PATH + "collapse_all.gif");
		public static final org.eclipse.jface.resource.ImageDescriptor REFRESH_IMAGE = getImageDescriptor(ICONS_PATH + "refresh.gif");
		
		private static final String SPRING_CONFIG = System.getProperty(PLUGIN_ID + ".SpringConfig", "/applicationContext«IF isStubService()»-stub«ENDIF».xml");
		
		public «className»() {
		}

		public void start(org.osgi.framework.BundleContext context) throws Exception {
			super.start(context);
			«IF !className.endsWith("Base")»
			plugin = this;
			«ENDIF»
			
		}

		public void stop(org.osgi.framework.BundleContext context) throws Exception {
			spring.stop();
			«IF !className.endsWith("Base")»
			plugin = null;
			«ENDIF»
			super.stop(context);
		}

	«IF !className.endsWith("Base")»
		«pluginGetDefault(it)»
	«ENDIF»


		/**
			* Returns an image descriptor for the image file at the given plug-in
			* relative path
			* 
			* @param path the path
			* @return the image descriptor
			*/
		public static org.eclipse.jface.resource.ImageDescriptor getImageDescriptor(String path) {
			return imageDescriptorFromPlugin(PLUGIN_ID, path);
		}

	«pluginHandleSpringInitializationException(it)»
	«pluginSpringAccessor(it)»

	}
	'''
	)
	'''
	'''
}

def static String pluginHandleSpringInitializationException(GuiApplication it) {
	'''
		private «fw("richclient.util.SpringInitializer")» spring = 
			new «fw("richclient.util.SpringInitializer")»(getClass().getClassLoader()) {
			protected String getSpringConfig() {
				return SPRING_CONFIG;
			}
		};

		protected void handleSpringInitializationException(RuntimeException e) {
			String systemExceptionMsg = «fw("richclient.errorhandling.ExceptionUtil")».resolveSystemExceptionMessage(e);
			org.eclipse.core.runtime.Status status = new org.eclipse.core.runtime.Status(org.eclipse.core.runtime.IStatus.ERROR, PLUGIN_ID, systemExceptionMsg, e);
			
			org.eclipse.jface.util.Policy.getLog().log(status);
			if (org.eclipse.ui.PlatformUI.isWorkbenchRunning()) {
				org.eclipse.swt.widgets.Display.getDefault().syncExec(new Runnable() {
				    public void run() {
				        org.eclipse.ui.IWorkbench workbench = getWorkbench();
				        if (workbench != null) {
				            org.eclipse.jface.dialogs.MessageDialog.openError(org.eclipse.swt.widgets.Display.getDefault().getActiveShell(), 
				                «getRichClientPackage()».Messages.initErrorTitle, «getRichClientPackage()».Messages.initErrorMessage);
				            workbench.close();
				        }
				    }
				});
			}
			
			throw e;
		}
	'''
}

def static String pluginSpringAccessor(GuiApplication it) {
	'''
		public org.springframework.context.ApplicationContext getSpringContext() {
			try {
				return spring.getSpringContext();
			} catch (RuntimeException e) {
				handleSpringInitializationException(e);
				return null;
			}
		}
		
		public<T> T createController(Class<T> controllerClass) {
			return getBeanFromSimpleClassName(controllerClass);
		}
		
		public<T> T createPage(Class<T> pageClass) {
			return getBeanFromSimpleClassName(pageClass);
		}
		
		public<T> T getRepository(Class<T> repositoryClass) {
			return getBeanFromSimpleClassName(repositoryClass);
		}
		
		protected<T> T getBeanFromSimpleClassName(Class<T> clazz) {
			try {
				return spring.getBeanFromSimpleClassName(clazz);
			} catch (RuntimeException e) {
				handleSpringInitializationException(e);
				return null;
			}
		}
		
		
	'''
}

def static String pluginGetDefault(GuiApplication it) {
	'''
		// The shared instance
		private static «name»Plugin plugin;
		
		/**
			* @return the shared instance
			*/
		public static «name»Plugin getDefault() {
			return plugin;
		}
	'''
}

def static String gapApplication(GuiApplication it) {
	'''
	«val className = it."Application"»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage()»;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String application(GuiApplication it) {
	'''
	«val className = it."Application" + gapSubclassSuffix("Application")»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className) , '''
	«javaHeader()»
	package «getRichClientPackage()»;

/**
 * This class controls all aspects of the application's execution
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» implements org.eclipse.equinox.app.IApplication {

	«applicationStart(it)»
	«applicationStop(it)»
	«applicationLogin(it)»
	«applicationAuthenticate(it)»
	«applicationBackgroundInitialization(it)»
		
	}
	'''
	)
	'''
	'''
}

def static String applicationStart(GuiApplication it) {
	'''
		public Object start(org.eclipse.equinox.app.IApplicationContext context) {
			org.eclipse.swt.widgets.Display display = org.eclipse.ui.PlatformUI.createDisplay();
			if (!login()) {
				return org.eclipse.equinox.app.IApplication.EXIT_OK;
			}
			try {
				int returnCode = org.eclipse.ui.PlatformUI.createAndRunWorkbench(display, new ApplicationWorkbenchAdvisor());
				if (returnCode == org.eclipse.ui.PlatformUI.RETURN_RESTART) {
				    return org.eclipse.equinox.app.IApplication.EXIT_RESTART;
				}
				return org.eclipse.equinox.app.IApplication.EXIT_OK;
			} finally {
				display.dispose();
			}
		}
	'''
}

def static String applicationStop(GuiApplication it) {
	'''
		public void stop() {
			final org.eclipse.ui.IWorkbench workbench = org.eclipse.ui.PlatformUI.getWorkbench();
			if (workbench == null)
				return;
			final org.eclipse.swt.widgets.Display display = workbench.getDisplay();
			display.syncExec(new Runnable() {
				public void run() {
				    if (!display.isDisposed())
				        workbench.close();
				}
			});
		}
	'''
}

def static String applicationLogin(GuiApplication it) {
	'''
		private static final int MAX_LOGIN_ATTEMPTS = 5;
		
		/**
			* Ask for user credentials and {@link #authenticate}. 
			* Override and return true if login is not needed. 
			* @return true if login was successful
			*/
		protected boolean login() {
			boolean firstTry = true;
			boolean authenticated = false;
			«fw("richclient.login.LoginDialog")» loginDialog = new «fw("richclient.login.LoginDialog")»(null, «getRichClientPackage()».«name.toFirstUpper()»Plugin.PLUGIN_ID);
			
			for (int i = 0; !authenticated && i < MAX_LOGIN_ATTEMPTS; i++) {
				org.eclipse.core.runtime.preferences.IPreferencesService service = org.eclipse.core.runtime.Platform.getPreferencesService();
				boolean autoLogin = service.getBoolean(«getRichClientPackage()».«name.toFirstUpper()»Plugin.PLUGIN_ID,
				        «fw("richclient.login.LoginDialog")».AUTO_LOGIN_PREFERENCE, false, null);
				«fw("richclient.login.UserDetails")» details = loginDialog.getUserDetails();
				if (!autoLogin || details == null || !firstTry) {
				    if (firstTry) {
				        // this is a great time to initialize Spring in the background
				        backgroundInitialization();
				    }
				    if (loginDialog.open() != org.eclipse.jface.window.Window.OK) {
				        return false;
				    }
				    details = loginDialog.getUserDetails();
				}
				authenticated = authenticate(details);
				firstTry = false;
			}
			return true;
		}
	'''
}

def static String applicationAuthenticate(GuiApplication it) {
	'''
		/**
			* This method should be overridden by subclass to implement real
			* authentication. This default implementation always accepts the user.
			*/
		protected boolean authenticate(«fw("richclient.login.UserDetails")» userDetails) {
			«IF isServiceContextToBeGenerated()»
			try { 
				«fw("richclient.errorhandling.RichServiceContextFactoryImpl")» serviceContextFactory = («fw("richclient.errorhandling.RichServiceContextFactoryImpl")») 
				    «getRichClientPackage()».«name.toFirstUpper()»Plugin.getDefault().getSpringContext().getBean("serviceContextFactory");
				serviceContextFactory.setUserId(userDetails.getUserId());
			} catch (RuntimeException e) {
				org.eclipse.core.runtime.Status status = new org.eclipse.core.runtime.Status(org.eclipse.core.runtime.IStatus.ERROR, «fw("richclient.SculptorFrameworkPlugin")».PLUGIN_ID, e.getMessage(), e);
				org.eclipse.jface.util.Policy.getLog().log(status);
			}
			«ENDIF»
			
			return true;
		}

	'''
}

def static String applicationBackgroundInitialization(GuiApplication it) {
	'''
		protected void backgroundInitialization() {
			org.eclipse.core.runtime.jobs.Job job =
				new «fw("richclient.errorhandling.ExceptionAwareJob")»("", null) {
				    @Override
				    protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor) throws Exception {
				        monitor.beginTask(getName(), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				        «getRichClientPackage()».«name.toFirstUpper()»Plugin.getDefault().getSpringContext();
				        monitor.done();
				        return org.eclipse.core.runtime.Status.OK_STATUS;
				    }
				};
			job.schedule();
		}
	'''
}

def static String gapActionBarAdvisor(GuiApplication it) {
	'''
	«val className = it."ApplicationActionBarAdvisor"»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage()»;

	public class «className» ^extends «className»Base {
	public «className»(org.eclipse.ui.application.IActionBarConfigurer configurer) {
			super(configurer);
		}
	}
	'''
	)
	'''
	'''
}


def static String actionBarAdvisor(GuiApplication it) {
	'''
	«val className = it."ApplicationActionBarAdvisor" + gapSubclassSuffix("ApplicationActionBarAdvisor")»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className) , '''
	«javaHeader()»
	package «getRichClientPackage()»;

/**
 * An action bar advisor is responsible for creating, adding, and disposing of
 * the actions added to a workbench window. Each window will be populated with
 * new actions.
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.ui.application.ActionBarAdvisor {

		public «className»(org.eclipse.ui.application.IActionBarConfigurer configurer) {
			super(configurer);
		}

		/**
			* This creates the actions and then turns them into handlers for the
			* appropriate commands.
			* <p>
			* <b>Note:</b> as 3.3 progresses, more of the actions in ActionFactory
			* will just be front ends for command+handlers, like the
			* ActionFactory.ABOUT action. Then it won't even be necessary to
			* instantiate and register them.
			* </p>
			*/
		protected void makeActions(final org.eclipse.ui.IWorkbenchWindow window) {
			register(org.eclipse.ui.actions.ActionFactory.QUIT.create(window));
			register(org.eclipse.ui.actions.ActionFactory.SAVE.create(window));
			register(org.eclipse.ui.actions.ActionFactory.SAVE_ALL.create(window));
			register(org.eclipse.ui.actions.ActionFactory.OPEN_NEW_WINDOW.create(window));
			register(org.eclipse.ui.actions.ActionFactory.RESET_PERSPECTIVE.create(window));
			register(org.eclipse.ui.actions.ActionFactory.PREFERENCES.create(window));
		}

		protected void fillMenuBar(org.eclipse.jface.action.IMenuManager menuBar) {
			// this can all be done declaratively
		}

		protected void fillCoolBar(org.eclipse.jface.action.ICoolBarManager coolBar) {
			// this can all be done declaratively
		}
	}
	'''
	)
	'''
	'''
}

def static String gapWorkbenchAdvisor(GuiApplication it) {
	'''
	«val className = it."ApplicationWorkbenchAdvisor"»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage()»;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String workbenchAdvisor(GuiApplication it) {
	'''
	«val className = it."ApplicationWorkbenchAdvisor" + gapSubclassSuffix("ApplicationWorkbenchAdvisor")»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className) , '''
	«javaHeader()»
	package «getRichClientPackage()»;

/**
 * This workbench advisor creates the window advisor, and specifies the
 * perspective id for the initial window.
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.ui.application.WorkbenchAdvisor {

		private static final String PERSPECTIVE_ID = "«getRichClientPackage("common")».ui.Perspective";

		public org.eclipse.ui.application.WorkbenchWindowAdvisor createWorkbenchWindowAdvisor(org.eclipse.ui.application.IWorkbenchWindowConfigurer configurer) {
			return new ApplicationWorkbenchWindowAdvisor(configurer);
		}

		@Override
		public String getInitialWindowPerspectiveId() {
			return PERSPECTIVE_ID;
		}
		
		@Override
		public void initialize(org.eclipse.ui.application.IWorkbenchConfigurer configurer) {
			// enable save of memento settings
			configurer.setSaveAndRestore(true);
			super.initialize(configurer);
		}

	}
	'''
	)
	'''
	'''
}

def static String gapWorkbenchWindowAdvisor(GuiApplication it) {
	'''
	«val className = it."ApplicationWorkbenchWindowAdvisor"»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage()»;

	public class «className» ^extends «className»Base {
	public «className»(org.eclipse.ui.application.IWorkbenchWindowConfigurer configurer) {
			super(configurer);
		}
	}
	'''
	)
	'''
	'''
}

def static String workbenchWindowAdvisor(GuiApplication it) {
	'''
	«val className = it."ApplicationWorkbenchWindowAdvisor" + gapSubclassSuffix("ApplicationWorkbenchWindowAdvisor")»
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + className) , '''
	«javaHeader()»
	package «getRichClientPackage()»;

	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.ui.application.WorkbenchWindowAdvisor {

		public «className»(org.eclipse.ui.application.IWorkbenchWindowConfigurer configurer) {
			super(configurer);
		}

		public org.eclipse.ui.application.ActionBarAdvisor createActionBarAdvisor(org.eclipse.ui.application.IActionBarConfigurer configurer) {
			return new ApplicationActionBarAdvisor(configurer);
		}

		public void preWindowOpen() {
			org.eclipse.ui.application.IWorkbenchWindowConfigurer configurer = getWindowConfigurer();
			configurer.setInitialSize(new org.eclipse.swt.graphics.Point(800, 600));
			configurer.setShowCoolBar(true);
			configurer.setShowStatusLine(true);
			configurer.setShowProgressIndicator(true);
		}

	}
	'''
	)
	'''
	'''
}

def static String contextClassLoaderFactory(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage() + "." + "ContextClassLoaderFactory") , '''
	«javaHeader()»
	package «getRichClientPackage()»;

/**
 * Need a factory method that can be used by spring to grab the 
 * ClassLoader.
 */
	public class ContextClassLoaderFactory {
		public static ClassLoader getClassLoader() {
			return ContextClassLoaderFactory.class.getClassLoader();
		}
	}
	'''
	)
	'''
	'''
}
}
