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

class RcpCrudGuiDefineColumnsTmpl {



	«DEFINE defineColumns FOR List[ViewDataProperty]»
		protected void defineColumns(«fw("richclient.table.CustomizableTableViewer")» tableViewer) {
			new «fw("richclient.table.TableDefinition")»(tableViewer) {{
				«it.this.forEach[column(it)]»
			}}.build();
		}
	'''
}

def static String column(ViewDataProperty it) {
	'''
	'''
}

def static String column(AttributeViewProperty it) {
	'''
	«attributeColumn(it)(userTask.for.getMessagesKey() + "_" + attribute.name, getAttributeType())»
	'''
}

def static String column(BasicTypeViewProperty it) {
	'''
	«attributeColumn(it)(userTask.for.getMessagesKey() + "_" + reference.name + "_" + attribute.name, getAttributeType())»
	'''
}

def static String attributeColumn(ViewDataProperty it, String labelKey, String attributeType) {
	'''
	«IF attributeType == "Date"»
		«dateColumn(it)(labelKey)»
	«ELSE»
		«standardColumn(it)(labelKey)»;
	«ENDIF»
	'''
}

def static String dateColumn(ViewDataProperty it, String labelKey) {
	'''
		«standardColumn(it)(labelKey)»
	«IF getDateTimeLibrary() == "joda"»
			.convertWith(new «fw("propertyeditor.LocalDateEditor")»(«userTask.getMessagesClass()».format_datePattern, true));
	«ELSE»
			.convertWith(new org.springframework.beans.propertyeditors.CustomDateEditor(new java.text.SimpleDateFormat(«userTask.getMessagesClass()».format_datePattern), true));
	«ENDIF»
	'''
}

def static String standardColumn(ViewDataProperty it, String labelKey) {
	'''
		column(«userTask.getMessagesClass()».«labelKey»).property("«name»")
	'''
}

/*TODO: EnumViewProperty not added by transformation */
def static String column(EnumViewProperty it) {
	'''
		«enumColumn(it)(userTask.for.getMessagesKey() + "_" + reference.name)»
	'''
}

/*TODO: BasicTypeEnumViewProperty not added by transformation */
def static String column(BasicTypeEnumViewProperty it) {
	'''
		«enumColumn(it)(userTask.for.getMessagesKey() + "_" + basicTypeReference.name + "_" + reference.name)»
	'''
}

def static String enumColumn(EnumViewProperty it, String labelKey) {
	'''
		«standardColumn(it)(labelKey)»
			.convertWith(new org.eclipse.core.databinding.conversion.Converter(«reference.to.getDomainPackage()».«reference.to.name».class, String.class) {
				public Object convert(Object element) {
				    return «userTask.getMessagesClass()».getString("«reference.to.getMessagesKey()»_" + ((«reference.to.getDomainPackage()».«reference.to.name») element).getName());
				}
			});
	'''
}

}
