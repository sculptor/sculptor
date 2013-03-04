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

class RcpCrudGuiCommonDataTmpl {



def static String commonData(GuiApplication it) {
	'''
	«domainObjectFolder(it)»
	«errorNode(it)»
	«moreNode(it)»
	«moduleFolder(it)»
	«rootNode(it)»
	«treeFolder(it)»
	'''
}

def static String domainObjectFolder(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".data.DomainObjectFolder") , '''
	«javaHeader()»
	package «getRichClientPackage("common")».data;

/**
 * Tree node object for grouping DomainObjects.
 */
	public enum DomainObjectFolder implements TreeFolder {

	«it.modules.userTasks.typeSelect(ListTask) SEPARATOR ", ".forEach[domainObjectFolderEnumItem(it)]»;

		private String name;
		private ModuleFolder parent;

		private DomainObjectFolder(String name, ModuleFolder parent) {
			this.name = name;
			this.parent = parent;
		}

		public String getName() {
			return name;
		}

		public ModuleFolder getParent() {
			return parent;
		}

	}
	'''
	)
	'''
	'''
}

def static String domainObjectFolderEnumItem(ListTask it) {
	'''
	«for.name.toUpperCase()»(«getMessagesClass()».«for.getMessagesKey()»_plural, ModuleFolder.«module.name.toUpperCase()»)
	'''
}

def static String errorNode(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".data.ErrorNode") , '''
	«javaHeader()»
	package «getRichClientPackage("common")».data;

/**
 * Tree node object for displaying errors.
 */
	public class ErrorNode {

		private String message;
		private DomainObjectFolder parent;

		public ErrorNode(String message, DomainObjectFolder parent) {
			this.message = message;
			this.parent = parent;
		}

		public String getMessage() {
			return message;
		}

		public DomainObjectFolder getParent() {
			return parent;
		}

	}
	'''
	)
	'''
	'''
}

def static String moreClass(ListTask it) {
	'''
		class More«for.name» ^extends «fw("richclient.data.AbstractRichObject")» implements «fw("richclient.data.RichObject")» {
			@Override
			public String toString() {
				return "...";
			}
			
			public void update(«fw("richclient.data.RichObject")» other) {
			}
		};
	'''
}

def static String moreNode(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".data.MoreNode") , '''
	«javaHeader()»
	package «getRichClientPackage("common")».data;

/**
 * Tree node object for that more elements are available.
 */
	public class MoreNode ^extends «fw("richclient.data.AbstractRichObject")» implements «fw("richclient.data.RichObject")» {
		@Override
		public String toString() {
			return "...";
		}
		
		public void update(«fw("richclient.data.RichObject")» other) {
		}
	};
	'''
	)
	'''
	'''
}

def static String moduleFolder(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".data.ModuleFolder") , '''
	«javaHeader()»
	package «getRichClientPackage("common")».data;

/**
 * Tree node object for grouping of modules.
 */
	public enum ModuleFolder implements TreeFolder {

	«it.modules.reject(m | m.userTasks.typeSelect(ListTask).isEmpty) SEPARATOR ", ".forEach[moduleFolderEnumItem(it)]»;

		private String name;

		private ModuleFolder(String name) {
			this.name = name;
		}

		public String getName() {
			return name;
		}

	}
	'''
	)
	'''
	'''
}

def static String moduleFolderEnumItem(GuiModule it) {
	'''
	«name.toUpperCase()»("«name.toFirstUpper()» Module")
	'''
}

def static String rootNode(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".data.RootNode") , '''
	«javaHeader()»
	package «getRichClientPackage("common")».data;

/**
 * Placeholder object servings as the root node in tree.
 * 
 */
	public final class RootNode {
		public static final RootNode INSTANCE = new RootNode();

		private RootNode() {
		}
	}
	'''
	)
	'''
	'''
}

def static String treeFolder(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(getRichClientPackage("common") + ".data.TreeFolder") , '''
	«javaHeader()»
	package «getRichClientPackage("common")».data;

/**
 * Marker interface used to indicate that a type is a folder node in a tree.
 * 
 */
	public interface TreeFolder {

	}
	'''
	)
	'''
	'''
}

}
