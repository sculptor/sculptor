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

class RcpCrudGuiManifestTmpl {



def static String manifest(GuiApplication it) {
	'''
	'''
	fileOutput("META-INF/MANIFEST.MF", 'TO_GEN_ROOT', '''
	«manifestContent(it)»
	'''
	)
	'''		
	'''
}

def static String manifestContent(GuiApplication it) {
	'''
	Manifest-Version: 1.0
	Bundle-ManifestVersion: 2
	Bundle-Name: «name.toPresentation()» Rich Client Plug-in
	Bundle-SymbolicName: «getRichClientPackage()»;singleton:=true
	Bundle-Version: 1.0.0
	Bundle-Activator: «getRichClientPackage()».«name.toFirstUpper()»Plugin
	Bundle-ActivationPolicy: lazy
	Bundle-Localization: plugin
	«requireBundle(it)»
	«bundleClassPath(it)»
	'''
}

def static String requireBundle(GuiApplication it) {
	'''
	Eclipse-RegisterBuddy: org.fornax.cartridges.sculptor.richclient.lib, 
 org.fornax.cartridges.sculptor.framework.richclient
	Require-Bundle: org.eclipse.ui,
 org.eclipse.core.runtime,
 org.eclipse.ui.forms,
 org.eclipse.core.databinding,
 org.eclipse.jface.databinding,
 org.eclipse.core.databinding.beans,
 org.eclipse.core.databinding.property,
 org.fornax.cartridges.sculptor.richclient.lib,
 org.fornax.cartridges.sculptor.framework.richclient
	'''
}

def static String bundleClassPath(GuiApplication it) {
	'''
	Bundle-ClassPath: «IF hasProperty("businessClientJar")»«getProperty("businessClientJar")»«ELSE»lib/«name»-client.jar«ENDIF»,
 .
	'''
}
}
