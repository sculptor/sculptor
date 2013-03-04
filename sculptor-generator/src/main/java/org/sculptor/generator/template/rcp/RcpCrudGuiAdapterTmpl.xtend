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

class RcpCrudGuiAdapterTmpl {



def static String adapter(GuiApplication it) {
	'''
	«it.modules.forEach[adapter(it)]»
	'''
} 

def static String adapter(GuiModule it) {
	'''
	«it.userTasks.typeSelect(ListTask).forEach[adapter(it)]»
	«it.userTasks.typeSelect(ListTask) .filter(e | isGapClassToBeGenerated(e, e.for.name + "Adapter")).forEach[gapAdapter(it)]»
	«adapterFactory(it)»
	«IF isGapClassToBeGenerated(this.name, this.name.toFirstUpper() + "AdapterFactory")»
		«gapAdapterFactory(it)»
	«ENDIF»
	
	
	'''
}

def static String gapAdapter(ListTask it) {
	'''
	«val className = it.for.name + "Adapter"»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".adapter." + className), 'TO_SRC', '''
	«javaHeader()»
	package «module.getRichClientPackage()».adapter;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String adapter(ListTask it) {
	'''
	«val className = it.for.name + "Adapter" + gapSubclassSuffix(this, for.name + "Adapter")»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".adapter." + className) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».adapter;

/**
 * Adapter for Rich«for.name» objects
 * 
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» implements org.eclipse.ui.progress.IDeferredWorkbenchAdapter {
		private org.eclipse.jface.resource.ImageDescriptor imageDescriptor = 
			«module.application.getRichClientPackage()».«module.application.name.toFirstUpper()»Plugin.getImageDescriptor(«module.application.getRichClientPackage()».«module.application.name.toFirstUpper()»Plugin.ICONS_PATH + "domain_object.png");

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

		«adapterGetLabel(it)»

		public Object getParent(Object object) {
			return «module.application.getRichClientPackage("common")».data.DomainObjectFolder.«for.name.toUpperCase()»;
		}

	}
	'''
	)
	'''
	'''
}

/*TODO we need something in gui meta model to define the short label */
def static String adapterGetLabel(ListTask it) {
	'''
		public String getLabel(Object object) {
			«module.getRichClientPackage()».data.Rich«for.name» rich«for.name» = ((«module.getRichClientPackage()».data.Rich«for.name») object);
			StringBuilder result = new StringBuilder();
	«IF for.hasNaturalKey()»
	«val naturalKeyRef  = it.for.getAllNaturalKeyReferences().first()»
	«IF naturalKeyRef == null »
		«val naturalKeys = it.for.getNaturalKeyAttributes()»
			«FOR keyProp SEPARATOR '.append(", "); ' - : viewProperties.typeSelect(AttributeViewProperty).filter(e|naturalKeys.contains(e.attribute))»
			result.append(rich«for.name».get«keyProp.name.toFirstUpper()»())
			«ENDFOR»;
	«ELSE »
		«FOR keyProp SEPARATOR '.append(", "); '- : viewProperties.typeSelect(BasicTypeViewProperty).filter(e|e.reference == naturalKeyRef)»
		result.append(rich«for.name».get«keyProp.name.toFirstUpper()»())
		«ENDFOR»;
	«ENDIF»
	«ELSEIF for.getConstructorParameters().filter(p | p.metaType == Attribute).size > 0 »
	/*TODO should we support basic types and enum when getting from contructor parameters? */
	«val params = it.for.getConstructorParameters().filter(p | p.metaType == Attribute)»
		«FOR paramProp SEPARATOR '.append(", "); '- : viewProperties.typeSelect(AttributeViewProperty).filter(e|params.contains(e.attribute))»
		result.append(rich«for.name».get«paramProp.name.toFirstUpper()»())
		«ENDFOR»;
	«ELSE»
	«val atts = it.for.getAllNonSystemAttributes()»
		«FOR attProp SEPARATOR '.append(", "); '- : viewProperties.typeSelect(AttributeViewProperty).filter(e|atts.contains(e.attribute))»
		result.append(rich«for.name».get«attProp.name.toFirstUpper()»())
		«ENDFOR»;
	«ENDIF»
			return result.toString();
		}
	'''
}

def static String gapAdapterFactory(GuiModule it) {
	'''
	«val className = it.name.toFirstUpper() + "AdapterFactory"»
	'''
	fileOutput(javaFileName(getRichClientPackage() + ".adapter." + className), 'TO_SRC', '''
	«javaHeader()»
	package «getRichClientPackage()».adapter;

	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String adapterFactory(GuiModule it) {
	'''
	«val className = it.name.toFirstUpper() + "AdapterFactory" + gapSubclassSuffix(this, name.toFirstUpper() + "AdapterFactory")»
	'''
	fileOutput(javaFileName(getRichClientPackage() + ".adapter." + className) , '''
	«javaHeader()»
	package «getRichClientPackage()».adapter;

/**
 * Factory for adapters in the «name» module.
 * 
 */
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends «fw("richclient.adapter.AbstractAdapterFactory")» {
		
		public «className»() {
			«FOR task : userTasks.typeSelect(ListTask)»
			addAdapterForObject(«task.module.getRichClientPackage()».data.Rich«task.for.name».class, «task.for.name»Adapter.class);
			«ENDFOR»
		}

	}
	'''
	)
	'''
	'''
}

}
