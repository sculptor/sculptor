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

class RcpCrudGuiPluginTmpl {



def static String plugin(GuiApplication it) {
	'''
	'''
	fileOutput("plugin.xml", 'TO_GEN_ROOT', '''
	«pluginContent(it)»
	'''
	)
	'''
	'''
}

def static String pluginContent(GuiApplication it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<?eclipse version="3.2"?>
	<plugin>
	«product(it)»
	«application(it)»
	«perspective(it)»
	«view(it)»
	«handler(it)»
	«command(it)»
	«menu(it)»
	«wizard(it)»
	«adapter(it)»
	«preferences(it)»
	«morePluginContent(it)»
	</plugin>
	'''
}

def static String product(GuiApplication it) {
	'''
		<extension id="product" point="org.eclipse.core.runtime.products">
			<product application="«getRichClientPackage()».application"
				   name="%productName">
				<property name="aboutText" value="%aboutText">
				</property>
				<property name="windowImages" value="icons/window_icon.png">
				</property>
				<property name="aboutImage" value="icons/product.gif">
				</property>
			</product>
		</extension>
	'''
}

def static String application(GuiApplication it) {
	'''
		<extension id="application" point="org.eclipse.core.runtime.applications">
			<application>
				<run class="«getRichClientPackage()».Application">
				</run>
			</application>
		</extension>
	'''
} 

def static String perspective(GuiApplication it) {
	'''
		<extension point="org.eclipse.ui.perspectives">
			<perspective name="Library Perspective"
				       class="«getRichClientPackage("common")».ui.Perspective"
				       id="«getRichClientPackage("common")».ui.Perspective">
			</perspective>
		</extension>
		<extension
				point="org.eclipse.ui.perspectiveExtensions">
			<perspectiveExtension
				targetID="«getRichClientPackage("common")».ui.Perspective">
				<view
				   id="«getRichClientPackage("common")».ui.MainView"
				   closeable="false"
				   minimized="false"
				   moveable="true"
				   relationship="left"
				   relative="org.eclipse.ui.editors"
				   showTitle="false"
				   standalone="false"
				   visible="true">
				</view>
				«val allListTasks = it.modules.userTasks.typeSelect(ListTask)»
				«IF !allListTasks.isEmpty»
				<view
				   id="«allListTasks.first().module.getRichClientPackage()».ui.List«allListTasks.first().for.name»View"
				   closeable="true"
				   minimized="false"
				   moveable="true"
				   relationship="bottom"
				   relative="«getRichClientPackage("common")».ui.MainView"
				   ratio="0.6"
				   showTitle="true"
				   standalone="false"
				   visible="false">
				</view>
				«FOR listTask : allListTasks.reject(e|e == allListTasks.first())»
				<view
				   id="«listTask.module.getRichClientPackage()».ui.List«listTask.for.name»View"
				   closeable="true"
				   minimized="false"
				   moveable="true"
				   relationship="stack"
				   relative="«allListTasks.first().module.getRichClientPackage()».ui.List«allListTasks.first().for.name»View"
				   showTitle="true"
				   standalone="false"
				   visible="false">
				</view>
				«ENDFOR»
				«ENDIF»
			</perspectiveExtension>
		</extension>
	'''
}

def static String view(GuiApplication it) {
	'''
		<extension point="org.eclipse.ui.views">
			«mainView(it)»
			«it.modules.userTasks.typeSelect(ListTask).forEach[listView(it)]»
		</extension>
	'''
}

def static String mainView(GuiApplication it) {
	'''
			<view name="%mainViewName"
				icon="icons/main_view.png"
				class="«getRichClientPackage("common")».ui.MainView"
				id="«getRichClientPackage("common")».ui.MainView">
			</view>
	'''
}

def static String listView(ListTask it) {
	'''
			<view
				class="«module.getRichClientPackage()».ui.List«for.name»View"
				id="«module.getRichClientPackage()».ui.List«for.name»View"
				icon="icons/list_view.png"
				name="%list«for.name»ViewName">
			</view>
	'''
}

def static String handler(GuiApplication it) {
	'''
 
		<extension
				point="org.eclipse.ui.handlers">
			<handler class="«getRichClientPackage("common")».handler.SelectInMainViewHandler" commandId="«getRichClientPackage("common")».command.selectInMainView"></handler>
			«it.modules.userTasks.filter(e | e.getPrimaryServiceOperation() != null).forEach[handler(it)]»
		</extension>
	'''
}

def static String handler(UserTask it) {
	'''
	'''
}

def static String handler(CreateTask it) {
	'''
			<handler
				class="«module.getRichClientPackage()».handler.New«for.name»Handler"
				commandId="«module.getRichClientPackage()».command.new«for.name»">
			</handler>
	'''
}

def static String handler(DeleteTask it) {
	'''
			<handler
				class="«module.getRichClientPackage()».handler.Delete«for.name»Handler"
				commandId="org.eclipse.ui.edit.delete">
				<activeWhen>
				<with variable="selection">
				<iterate
				      ifEmpty="false"
				      operator="and">
				      <instanceof
				            value="«module.getRichClientPackage()».data.Rich«for.name»">
				      </instanceof>
				</iterate>
				</with>
				</activeWhen>
			</handler>
	'''
}

def static String handler(ListTask it) {
	'''
			<handler
				class="«module.getRichClientPackage()».handler.ShowList«for.name»ViewHandler"
				commandId="«module.getRichClientPackage()».command.showList«for.name»View">
			</handler>
	'''
}

def static String command(GuiApplication it) {
	'''
		<extension point="org.eclipse.ui.commands">
			<category name="«name.toPresentation()»" id="«getRichClientPackage()».category">
			</category>
			<command
				id="«getRichClientPackage()».collapseAll"
				categoryId="«getRichClientPackage()».category"
				name="%collapseAllCommandName">
			</command>
			<command
				id="«getRichClientPackage()».showprogress"
				name="%showprogressCommandName"
				defaultHandler="«fw('richclient.handler.ShowProgressViewHandler')»">
			</command>
			<command
				id="«getRichClientPackage("common")».command.selectInMainView"
				name="%selectInMainViewCommandName">
			</command>
			
			«it.modules.userTasks.filter(e | e.getPrimaryServiceOperation() != null).forEach[command(it)]»
		</extension>
	'''
}

def static String command(UserTask it) {
	'''
	'''
}

def static String command(CreateTask it) {
	'''
			<command
				id="«module.getRichClientPackage()».command.new«for.name»"
				name="%new«for.name»CommandName">
			</command>
	'''
}

def static String command(ListTask it) {
	'''
			<command
				id="«module.getRichClientPackage()».command.showList«for.name»View"
				name="%showList«for.name»ViewCommandName">
			</command>
	'''
}

def static String menu(GuiApplication it) {
	'''
		<extension point="org.eclipse.ui.menus">
			<menuContribution locationURI="menu:org.eclipse.ui.main.menu">
				<menu id="file" label="%fileMenuLabel" mnemonic="%fileMenuMnemonic">
				<command
				      commandId="org.eclipse.ui.file.save">
				</command>
				<separator name="additions" visible="false"/>
				<separator name="file.exit" visible="true"/>
				<command commandId="org.eclipse.ui.file.exit"
				         label="%exitMenuItemLabel"
				         mnemonic="%exitMenuItemMnemonic"/>
				</menu>
				<menu
				   id="list"
				   label="%listMenuLabel">
				«FOR listTask : modules.userTasks.typeSelect(ListTask)»
				<command
				      commandId="«listTask.module.getRichClientPackage()».command.showList«listTask.for.name»View">
				</command>
				«ENDFOR»
				</menu>
				<separator name="additions" visible="false"/>
				<menu
				   id="window"
				   label="&amp;Window">
				<command commandId="org.eclipse.ui.window.newWindow"
				         label="%openInNewMenuItemLabel"
				         mnemonic="%openInNewMenuItemMnemonic"/>
				<command
				      commandId="«getRichClientPackage()».showprogress"
				      label="%progressMenuItemLabel">
				</command>
				<separator
				      name="additions">
				</separator>
				<command
				      commandId="org.eclipse.ui.window.resetPerspective"
				      label="%resetPerspectiveMenuItemLabel">
				</command>
				<command
				      commandId="org.eclipse.ui.window.preferences"
				      label="%preferencesMenuItemLabel">
				</command>
				<command commandId="org.eclipse.ui.help.aboutAction"
				     label="%aboutMenuItemLabel"
				     mnemonic="%aboutMenuItemMnemonic"/>
				</menu>
			</menuContribution>
			<menuContribution locationURI="toolbar:org.eclipse.ui.main.toolbar?after=additions">
				<toolbar id="main">
				<command
				      commandId="org.eclipse.ui.file.save"
				      style="push">
				</command>
				</toolbar>
			</menuContribution>
			
			<menuContribution
				locationURI="popup:«getRichClientPackage()».NavigationTreeMenu">
				<menu
				   id="«getRichClientPackage()».menu.new"
				   label="%newMenuItemLabel">
				«FOR task : modules.userTasks.typeSelect(CreateTask).filter(e | e.getPrimaryServiceOperation() != null)»
				<command
				      commandId="«task.module.getRichClientPackage()».command.new«task.for.name»">
				</command>
				«ENDFOR»
				</menu>
				<separator
				   name="org.fornax.cartridges.sculptor.examples.library.richclient.separator.new"
				   visible="false">
				</separator>
				<command
				   commandId="org.eclipse.ui.edit.delete">
				</command>
				<separator
				   name="extensions">
				</separator>
			</menuContribution>
			«FOR listTask : modules.userTasks.typeSelect(ListTask)»
			<menuContribution
				locationURI="popup:«listTask.module.getRichClientPackage()».ui.List«listTask.for.name»ViewMenu">
				<command commandId="«listTask.module.application.getRichClientPackage("common")».command.selectInMainView" label="%selectInMainViewCommandName">
				<visibleWhen> 
				   <iterate> 
				      <or> 
				         <instanceof
				               value="«listTask.module.getRichClientPackage()».data.Rich«listTask.for.name»">
				         </instanceof> 
				      </or> 
				   </iterate> 
				</visibleWhen> 
				</command>
				<command
				   commandId="«listTask.module.getRichClientPackage()».command.new«listTask.for.name»"
				   label="New «listTask.for.name»">
				</command>
				<command
				   commandId="org.eclipse.ui.edit.delete" label="%deleteMenuItemLabel">
				<visibleWhen>
				   <iterate>
				      <or>
				         <instanceof
				               value="«listTask.module.getRichClientPackage()».data.Rich«listTask.for.name»">
				         </instanceof>
				      </or>
				   </iterate>
				</visibleWhen>
				</command>
				<separator
				   name="extensions">
				</separator>
			</menuContribution>
			«ENDFOR»

		</extension>
	'''
}

def static String wizard(GuiApplication it) {
	'''
		<extension
				point="org.eclipse.ui.newWizards">
			«it.modules.userTasks.typeSelect(CreateTask).forEach[wizard(it)]»
		</extension>
	'''
}

def static String wizard(CreateTask it) {
	'''
			<wizard
				category="«module.application.getRichClientPackage()».wizards"
				class="«module.getRichClientPackage()».ui.New«for.name»Wizard"
				id="«module.getRichClientPackage()».ui.New«for.name»Wizard"
				name="%new«for.name»WizardName">
			</wizard>
	'''
}

def static String adapter(GuiApplication it) {
	'''
		<extension
				point="org.eclipse.core.runtime.adapters">
			<factory
				adaptableType="«getRichClientPackage("common")».data.RootNode"
				class="«getRichClientPackage("common")».adapter.CommonAdapterFactory">
				<adapter
				   type="org.eclipse.ui.progress.IDeferredWorkbenchAdapter">
				</adapter>
				<adapter
				   type="org.eclipse.ui.model.IWorkbenchAdapter">
				</adapter>      
			</factory>
			<factory
				adaptableType="«getRichClientPackage("common")».data.ModuleFolder"
				class="«getRichClientPackage("common")».adapter.CommonAdapterFactory">
				<adapter
				   type="org.eclipse.ui.progress.IDeferredWorkbenchAdapter">
				</adapter>
				<adapter
				   type="org.eclipse.ui.model.IWorkbenchAdapter">
				</adapter>      
			</factory>
			<factory
				adaptableType="«getRichClientPackage("common")».data.DomainObjectFolder"
				class="«getRichClientPackage("common")».adapter.CommonAdapterFactory">
				<adapter
				   type="org.eclipse.ui.progress.IDeferredWorkbenchAdapter">
				</adapter>
				<adapter
				   type="org.eclipse.ui.model.IWorkbenchAdapter">
				</adapter>      
			</factory>
			<factory
				adaptableType="«getRichClientPackage("common")».data.ErrorNode"
				class="«getRichClientPackage("common")».adapter.CommonAdapterFactory">
				<adapter
				   type="org.eclipse.ui.progress.IDeferredWorkbenchAdapter">
				</adapter>
				<adapter
				   type="org.eclipse.ui.model.IWorkbenchAdapter">
				</adapter>      
			</factory>
			<factory
				adaptableType="«getRichClientPackage("common")».data.MoreNode"
				class="«getRichClientPackage("common")».adapter.CommonAdapterFactory">
				<adapter
				   type="org.eclipse.ui.progress.IDeferredWorkbenchAdapter">
				</adapter>
				<adapter
				   type="org.eclipse.ui.model.IWorkbenchAdapter">
				</adapter>      
			</factory>
			«it.modules.userTasks.typeSelect(ListTask).forEach[adapter(it)]»
		</extension>
	'''
}

def static String adapter(ListTask it) {
	'''
			<factory
				adaptableType="«module.getRichClientPackage()».data.Rich«for.name»"
				class="«module.getRichClientPackage()».adapter.«module.name.toFirstUpper()»AdapterFactory">
				<adapter
				   type="org.eclipse.ui.progress.IDeferredWorkbenchAdapter">
				</adapter>
				<adapter
				   type="org.eclipse.ui.model.IWorkbenchAdapter">
				</adapter>      
			</factory>
	'''
}

def static String preferences(GuiApplication it) {
	'''
	<extension
				point="org.eclipse.ui.preferencePages">
			<page
				class="«getRichClientPackage()».GeneralPreferencePage"
				id="«getRichClientPackage()».preferences.general"
				name="%preferencesGeneral"/>
		</extension>
		<extension
				point="org.eclipse.core.runtime.preferences">
			<initializer class="«getRichClientPackage()».PreferenceInitializer"/>
		</extension>
	'''
}

/*Hook intented to be redefined by AOP to be able to add more stuff */
def static String morePluginContent(GuiApplication it) {
	'''
	'''
}
}
