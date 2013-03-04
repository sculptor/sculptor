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

package org.sculptor.generator.template.web

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class JSFCrudGuiJavaFormTmpl {


def static String flowJavaForm(UserTask it) {
	'''	'''
}

def static String flowJavaForm(CreateTask it) {
	'''
	«flowJavaFormBase(it)»
	«IF gapClass»
		«flowJavaFormImpl(it)»
	«ENDIF»
	'''
}
def static String flowJavaForm(UpdateTask it) {
	'''
	«flowJavaFormBase(it)»
	«IF gapClass»
		«flowJavaFormImpl(it)»
	«ENDIF»
	'''
}
def static String flowJavaForm(ViewTask it) {
	'''
	«flowJavaFormBase(it)»
	«IF gapClass»
		«flowJavaFormImpl(it)»
	«ENDIF»
	'''
}

def static String flowJavaForm(ListTask it) {
	'''
	«IF searchDOWith.isPagedResult()»
		«flowJavaPagedFormBase(it)»
	«ELSE»
		«flowJavaFormBase(it)»
	«ENDIF»
	«IF gapClass»
		«flowJavaFormImpl(it)»
	«ENDIF»
	'''
}



def static String flowJavaFormImpl(UserTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Form"), 'TO_SRC', '''
	«javaHeader()»
	package «this.module.getWebPackage()»;

	public class «name.toFirstUpper()»Form ^extends «name.toFirstUpper()»FormBase {
	}
	'''
	)
	'''
	'''
}


def static String flowJavaFormBase(CreateTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Form" + (gapClass ? "Base" : "")) , '''
	«javaHeader()»
	package «this.module.getWebPackage()»;

	public «IF gapClass»abstract «ENDIF»class «name.toFirstUpper()»Form«IF gapClass»Base«ENDIF» implements java.io.Serializable {
	«serialVersionUID(it)»
	«it.this.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == DerivedReferenceViewProperty).forEach[viewDataProperty(it)(false)]»
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.base).forEach[addSelectedProperty(it)]»
	/*add required property for required references  */
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.metaType == DerivedReferenceViewProperty).forEach[addRequiredProperty(it)]»

	/*
	«it.getReferencesPropertiesToSelect().collect(prop | prop.reference).forEach[referenceItemsProperty(it)]»
	 */
	«it.getReferencesPropertiesChildrenToSelect().forEach[referenceItemsProperty(it)]»
	«confirmDraftProperty(it) FOR for»
	«publicFormToModel(it)»
	«privateFormToModel(it)»
	«publicFormToConfirmModel(it)»
	«privateFormToConfirmModel(it)»
	«createModel(it)»
	«it.this.viewProperties.typeSelect(BasicTypeViewProperty).collect(e|e.reference).toSet().forEach[formCreateBasicTypeModel(it)(this)]»
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.metaType == DerivedReferenceViewProperty).forEach[removeChildMethodForm(it)]»
	«IF !viewProperties.typeSelect(ReferenceViewProperty).isEmpty»
		«shallowClone(it)»
	«ENDIF»
	«validateInputState(it)»
	}
	'''
	)
	'''
	'''
}

def static String flowJavaFormBase(UpdateTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Form" + (gapClass ? "Base" : "")) , '''
	«javaHeader()»
	package «this.module.getWebPackage()»;

	public «IF gapClass»abstract «ENDIF»class «name.toFirstUpper()»Form«IF gapClass»Base«ENDIF» implements java.io.Serializable {
	«serialVersionUID(it)»
	«original(it) FOR this.for»
	«it.this.viewProperties.reject(p | p.isSystemAttribute()).reject(e|e.metaType == DerivedReferenceViewProperty).forEach[viewDataProperty(it)(false)]»
	
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.base).forEach[addSelectedProperty(it)]»
	/*add required property for references that is required */
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.metaType == DerivedReferenceViewProperty).forEach[addRequiredProperty(it)]»

	«it.getReferencesPropertiesChildrenToSelect().forEach[referenceItemsProperty(it)]»
	/*
	«it.getReferencesPropertiesToSelect().collect(prop | prop.reference).forEach[referenceItemsProperty(it)]»
	 */
	«confirmDraftProperty(it) FOR for»
	«nextEnabledProperty(it) FOR for»
	«formFromModel(it)»
	«publicFormToModel(it)»
	«privateFormToModel(it)»
	«publicFormToConfirmModel(it)»
	«privateFormToConfirmModel(it)»
	
	«it.this.viewProperties.typeSelect(BasicTypeViewProperty).collect(e|e.reference).toSet().forEach[formCreateBasicTypeModel(it)(this)]»
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.metaType == DerivedReferenceViewProperty).forEach[removeChildMethodForm(it)]»
	«shallowClone(it)»
	«validateInputState(it)»
	}
	'''
	)
	'''
	'''
}

def static String flowJavaFormBase(ViewTask it) {
	'''
	'''
	fileOutput(javaFileName(this.module.getWebPackage() + "." + name.toFirstUpper() + "Form" + (gapClass ? "Base" : "")) , '''
	«javaHeader()»
	package «this.module.getWebPackage()»;

	public «IF gapClass»abstract «ENDIF»class «name.toFirstUpper()»Form«IF gapClass»Base«ENDIF» implements java.io.Serializable {
	«serialVersionUID(it)»
	«domainObjectProperty(it) FOR for»
	«it.this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.metaType == DerivedReferenceViewProperty).forEach[viewDataProperty(it)(true)]»
		/*TODO - use gui meta model??? */
	«viewFlowFormFromModel(it)»
	}
	'''
	)
	'''
	'''
}


def static String flowJavaFormBase(ListTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getWebPackage() + "." + name.toFirstUpper() + "Form" + (gapClass ? "Base" : "")) , '''
	«javaHeader()»
	package «module.getWebPackage()»;

	public «IF gapClass»abstract «ENDIF»class «name.toFirstUpper()»Form«IF gapClass»Base«ENDIF» implements java.io.Serializable {
	«serialVersionUID(it)»
	private java.util.List<«for.getDomainPackage()».«for.name»> all«for.name.plural()»;

	public java.util.List<«for.getDomainPackage()».«for.name»> getAll«for.name.plural()»() {
			return all«for.name.plural()»;
		}

		public void setAll«for.name.plural()»(java.util.List<«for.getDomainPackage()».«for.name»> all«for.name.plural()») {
			this.all«for.name.plural()» = all«for.name.plural()»;
		}
	}
	'''
	)
	'''
	'''
}

def static String flowJavaPagedFormBase(ListTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getWebPackage() + "." + name.toFirstUpper() + "Form" + (gapClass ? "Base" : "")) , '''
	«javaHeader()»
	package «module.getWebPackage()»;

	public «IF gapClass»abstract «ENDIF»class «name.toFirstUpper()»Form«IF gapClass»Base«ENDIF» implements java.io.Serializable {
	«serialVersionUID(it)»
	
		private «searchDOWith.getTypeName()» pagedResult;
		private int pageNumber = 1;
		private int totalPages = -1;

		public java.util.List<«for.getDomainPackage()».«for.name»> getAll«for.name.plural()»() {
			if (pagedResult == null) {
				return new java.util.ArrayList<«for.getDomainPackage()».«for.name»>();
			}
			return pagedResult.getValues();
		}

		public «searchDOWith.getTypeName()» getPagedResult() {
			return pagedResult;
		}

		public void setPagedResult(«searchDOWith.getTypeName()» pagedResult) {
			this.pagedResult = pagedResult;
			pageNumber = pagedResult.getPage();
			if (pagedResult.isTotalCounted()) {
				totalPages = pagedResult.getTotalPages();
			}
		}

		public int getPageNumber() {
			return pageNumber;
		}

		public void setPageNumber(int pageNumber) {
			if (pageNumber < 1) {
				pageNumber = 1;
			}
			this.pageNumber = pageNumber;
		}
		
		public boolean isTotalPagesCounted() {
			return totalPages > -1;
		}
		
		public int getTotalPages() {
			return totalPages;
		}
		
		public boolean isEmptyResult() {
			if (isTotalPagesCounted()) {
			    return totalPages == 0;
			} else {
			    return getAll«for.name.plural()»().isEmpty();
			}
		}
	
	}
	'''
	)
	'''
	'''
}



def static String viewFlowFormFromModel(ViewTask it) {
	'''
	public void fromModel(«this.for.getDomainPackage()».«this.for.name» model) {
	this.domainObject = model;
	«FOR prop : this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.metaType == DerivedReferenceViewProperty)»
		«IF prop.isMany() »
		this.«prop.name» = new java.util.ArrayList<«prop.reference.to.getDomainPackage()».«prop.reference.to.name»>(model.get«prop.name.toFirstUpper()»());
		«ELSE»
		this.«prop.name» = model.get«prop.name.toFirstUpper()»();
		«ENDIF »
	«ENDFOR»
	}
	'''
}

def static String formCreateBasicTypeModel(Reference it, UserTask task) {
	'''
	«LET task.viewProperties.typeSelect(BasicTypeViewProperty).filter(e|e.reference == this) .addAll(task.viewProperties.typeSelect(BasicTypeEnumViewProperty).select(e|e.basicTypeReference == this))
	AS basicTypeProperties»
	protected «to.getDomainPackage()».«to.name» create«name.toFirstUpper()»() {
		«to.getDomainPackage()».«to.name» result =
			new «to.getDomainPackage()».«to.name»(
		«FOR p SEPARATOR ", "  : to.getConstructorParameters()»
			«LET basicTypeProperties.typeSelect(BasicTypeViewProperty).filter(e|e.attribute == p) .addAll(basicTypeProperties.typeSelect(BasicTypeEnumViewProperty).select(e|e.reference == p))
				.selectFirst(e|true).name.toFirstUpper() AS name»
				«IF name != null»
				get«name»()
				«ELSE»
				null
				«ENDIF»
				
			
		«ENDFOR»);
		«FOREACH basicTypeProperties.typeSelect(BasicTypeViewProperty).reject(e|to.getConstructorParameters().contains(e.attribute)) 	AS prop»
		result.set«prop.attribute.name.toFirstUpper()»(get«prop.name.toFirstUpper()»());
		«ENDFOR»
		«FOR prop : basicTypeProperties.typeSelect(BasicTypeEnumViewProperty).reject(e|to.getConstructorParameters().contains(e.reference))»
		result.set«prop.reference.name.toFirstUpper()»(get«prop.name.toFirstUpper()»());
		«ENDFOR»
		return result;
	}
	'''
}




def static String original(DomainObject it) {
	'''
		private «getDomainPackage()».«name» original;
		«getDomainPackage()».«name» getOriginalModel() {
			return original;
		}
	'''
}




def static String viewDataProperty(ViewDataProperty it, boolean readOnly) {
	'''
	'''
}
def static String viewDataProperty(AttributeViewProperty it, boolean readOnly) {
	'''
	«propertyField(it)(this.name) FOR this.attribute»
	«propertyGetter(it)(this.name) FOR this.attribute»
	«propertySetter(it)(this.name) FOR this.attribute»
	'''
}
def static String viewDataProperty(BasicTypeViewProperty it, boolean readOnly) {
	'''
	«propertyField(it)(this.name) FOR this.attribute»
	«propertyGetter(it)(this.name) FOR this.attribute»
	«propertySetter(it)(this.name) FOR this.attribute»
	'''
}

def static String viewDataProperty(ReferenceViewProperty it, boolean readOnly) {
	'''
	«IF isMany() »
	private java.util.List<«getDomainPackage(this.reference.to)».«this.reference.to.name»> «this.name» = new java.util.ArrayList<«getDomainPackage(this.reference.to)».«this.reference.to.name»>();
	public java.util.List<«getDomainPackage(this.reference.to)».«this.reference.to.name»> get«this.name.toFirstUpper()»() {
		return this.«this.name»;
	}
	«ELSE»
	private «getDomainPackage(this.reference.to)».«this.reference.to.name» «this.name»;
	void set«this.name.toFirstUpper()»(«getDomainPackage(this.reference.to)».«this.reference.to.name» «this.name») {
		this.«this.name» = «this.name»;
		«IF !readOnly »
		if («this.name».getId() != null) {
			this.«resolveRequiredIdAttributeName()» = this.«this.name».getId();
		} else {
			this.«resolveRequiredIdAttributeName()» = new «reference.to.getIdAttributeType()»("" + Long.MIN_VALUE);
		}
		«ENDIF»
	}
	public «getDomainPackage(this.reference.to)».«this.reference.to.name» get«this.name.toFirstUpper()»() {
		return this.«this.name»;
	}
	«ENDIF »
	«IF isAddMethodApplicable()»
	void add«this.name.toFirstUpper().singular()»(«getDomainPackage(this.reference.to)».«this.reference.to.name» «this.name.singular()») {
		int i = this.«this.name».indexOf(«this.name.singular()»);
			if (i == -1) {
				this.«this.name».add(«this.name.singular()»);
			} else {
				this.«this.name».set(i, «this.name.singular()»);
			}
		/*if reference is required, adjust the size property to enable gui resolving required lists/sets */
		«IF reference.required»
			if (this.«this.name».size() > 0) {
			this.«resolveRequiredIdAttributeName()» = new «reference.to.getIdAttributeType()»("" + this.«this.name».size());
			} else {
			this.«resolveRequiredIdAttributeName()» = null;
			}
			«ENDIF»

	}
	«ENDIF»

	'''
}
def static String viewDataProperty(EnumViewProperty it, boolean readOnly) {
	'''
	private «reference.to.getDomainPackage()».«reference.to.name» «name»;
	public void set«name.toFirstUpper()»(«reference.to.getDomainPackage()».«reference.to.name» «name») {
		this.«name» = «name»;
	}
	public «reference.to.getDomainPackage()».«reference.to.name» get«name.toFirstUpper()»() {
		return this.«name»;
	}
		public java.util.List<javax.faces.model.SelectItem> get«name.toFirstUpper()»Items() {
			java.util.List<javax.faces.model.SelectItem> items = new java.util.ArrayList<javax.faces.model.SelectItem>();
			for («reference.to.getDomainPackage()».«reference.to.name» «reference.to.name.toFirstLower()» : «reference.to.getDomainPackage()».«reference.to.name».values()) {
				items.add(new javax.faces.model.SelectItem(«reference.to.name.toFirstLower()», "model.DomainObject.«reference.to.name»."+«reference.to.name.toFirstLower()».getName()));
			}
			return items;
		}

	'''
}

def static String propertyField(Attribute it, String propertyName) {
	'''
	private «getTypeName(this)» «propertyName»;
	'''
}

def static String propertyGetter(Attribute it, String propertyName) {
	'''
		«formatJavaDoc()»
		public «getTypeName(this)» get«propertyName.toFirstUpper()»() {
			return «propertyName»;
		};

	'''
}

def static String propertySetter(Attribute it, String propertyName) {
	'''
		«formatJavaDoc()»
		public void set«propertyName.toFirstUpper()»(«getTypeName(this)» «propertyName») {
			this.«propertyName» = «propertyName»;
		};
	'''
}

def static String referenceItemsProperty(ReferenceViewProperty it) {
	'''
	private java.util.List<javax.faces.model.SelectItem/*«optionClass()» */> «target.name.toFirstLower()»Items;
	public java.util.List<javax.faces.model.SelectItem/*«optionClass()» */> get«target.name.toFirstUpper()»Items() {
			return «target.name.toFirstLower()»Items;
		}

		void set«target.name.toFirstUpper()»Items(java.util.List<javax.faces.model.SelectItem/*«optionClass()» */> items) {
			this.«target.name.toFirstLower()»Items = items;
		}
	'''
}

def static String addSelectedProperty(ReferenceViewProperty it) {
	'''
	«IF isAddSubTaskAvailable()»
	«val selectedId = it.resolveSelectedExistingChildIdAttributeName(this)»
	private «this.reference.to.getIdAttributeType()» «selectedId»;
	public void set«selectedId.toFirstUpper()»(«this.reference.to.getIdAttributeType()» id) {
		this.«selectedId» = id;
	}
	public «this.reference.to.getIdAttributeType()» get«selectedId.toFirstUpper()»() {
		return this.«selectedId»;
	}
	«ENDIF»
	'''
}

def static String addRequiredProperty(ReferenceViewProperty it) {
	'''
	«val reqPropName = it.resolveRequiredIdAttributeName()»
	private «this.reference.to.getIdAttributeType()» «reqPropName»;
	public void set«reqPropName.toFirstUpper()»(«this.reference.to.getIdAttributeType()» idOrSize) {
	this.«reqPropName» = idOrSize;
	}
	public «this.reference.to.getIdAttributeType()» get«reqPropName.toFirstUpper()»() {
	return this.«reqPropName»;
	}
	'''
}

def static String formFromModel(UserTask it) {
	'''
	public void fromModel(«this.for.getDomainPackage()».«this.for.name» model) {
	this.original = model;

	«FOR prop : this.viewProperties.typeSelect(AttributeViewProperty).reject(p | p.attribute.isSystemAttribute())»
		this.set«prop.name.toFirstUpper()»(model.«prop.attribute.getGetAccessor()»());
	«ENDFOR»
	«FOR prop : this.viewProperties.typeSelect(BasicTypeViewProperty)»
		«IF prop.reference.isNullable()»
		    this.set«prop.name.toFirstUpper()»(model.get«prop.reference.name.toFirstUpper()»() == null ? null : model.get«prop.reference.name.toFirstUpper()»().«prop.attribute.getGetAccessor()»());
		«ELSE»
		this.set«prop.name.toFirstUpper()»(model.get«prop.reference.name.toFirstUpper()»().«prop.attribute.getGetAccessor()»());
		«ENDIF»
	«ENDFOR»
	«FOR prop : this.viewProperties.typeSelect(EnumViewProperty).reject(e|e.metaType == BasicTypeEnumViewProperty)»
		this.set«prop.name.toFirstUpper()»(model.get«prop.name.toFirstUpper()»());
	«ENDFOR»
	«FOR prop : this.viewProperties.typeSelect(BasicTypeEnumViewProperty)»
		«IF prop.basicTypeReference.isNullable()»
			this.set«prop.name.toFirstUpper()»(model.get«prop.basicTypeReference.name.toFirstUpper()»() == null ? null : model.get«prop.basicTypeReference.name.toFirstUpper()»().get«prop.reference.name.toFirstUpper()»());
		«ELSE»
			this.set«prop.name.toFirstUpper()»(model.get«prop.basicTypeReference.name.toFirstUpper()»().get«prop.reference.name.toFirstUpper()»());
		«ENDIF»
	«ENDFOR»

	«FOR prop : this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.metaType == DerivedReferenceViewProperty)»
		«IF prop.isMany()»
		this.«prop.name» = new java.util.ArrayList<«prop.reference.to.getDomainPackage()».«prop.reference.to.name»>(model.get«prop.name.toFirstUpper()»());
			/*if the reference is required, adjust the size property  */
			«IF prop.reference.required»
			if (this.«prop.name».size() > 0) {
				this.«resolveRequiredIdAttributeName(prop)» = «for.getIdAttributeType()».valueOf("" + this.«prop.name».size());
			} else {
				this.«resolveRequiredIdAttributeName(prop)» = null;
			}
			«ENDIF»
		«ELSE»
		this.«prop.name» = model.get«prop.name.toFirstUpper()»();

		if (model.get«prop.name.toFirstUpper()»() != null) {
			this.«resolveRequiredIdAttributeName(prop)» = model.get«prop.name.toFirstUpper()»().getId();
		}


		«ENDIF»
	«ENDFOR»
	}
	'''
}

def static String publicFormToConfirmModel(CreateTask it) {
	'''
	public «for.getDomainPackage()».«for.name» toConfirmModel() {
	return toConfirmModel(createModel());
	}
	'''
}

def static String privateFormToConfirmModel(CreateTask it) {
	'''
	public «for.getDomainPackage()».«for.name» toConfirmModel(«for.getDomainPackage()».«for.name» model) {
	«toModelNonReferences(it)»
	«toModelReferences(it)(true)»
	return model;
	}
	'''
}

def static String publicFormToModel(CreateTask it) {
	'''
	public «for.getDomainPackage()».«for.name» toModel() {
	return toModel(createModel());
	}
	'''
}
def static String privateFormToModel(CreateTask it) {
	'''
	private «for.getDomainPackage()».«for.name» toModel(«for.getDomainPackage()».«for.name» model) {
	
	«toModelNonReferences(it)»
	«toModelReferences(it)(false)»
	return model;
	}
	'''
}



def static String publicFormToConfirmModel(UpdateTask it) {
	'''
	public «for.getDomainPackage()».«for.name» toConfirmModel() {
	return toConfirmModel(shallowClone(original));
	}
	'''
}

def static String privateFormToConfirmModel(UpdateTask it) {
	'''
	public «for.getDomainPackage()».«for.name» toConfirmModel(«for.getDomainPackage()».«for.name» model) {
	«toModelNonReferences(it)»
	«FOR prop : this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.metaType == DerivedReferenceViewProperty)»
		«val ref = it.prop.reference»
		
			«IF ref.isOneToMany() || ref.isManyToMany() »
				«IF ref.opposite == null »
				model.get«ref.name.toFirstUpper()»().addAll(this.«ref.name»);
				«ELSE»
				
				// find «ref.to.name» that has been removed by user
				java.util.Set<«ref.to.getDomainPackage()».«ref.to.name»> removed«ref.name.singular().toFirstUpper()» = new java.util.HashSet<«ref.to.getDomainPackage()».«ref.to.name»>();
				for («ref.to.getDomainPackage()».«ref.to.name» «ref.name.singular()» : model.get«ref.name.toFirstUpper()»()) {
					if (!this.«ref.name».contains(«ref.name.singular()»)) {
						removed«ref.name.singular().toFirstUpper()».add(«ref.name.singular()»);
					}
				}
				
				// add all from original that hasn't been marked for removal
				for («ref.to.getDomainPackage()».«ref.to.name» «ref.name.singular()» : original.get«ref.name.toFirstUpper()»()) {
	                if (!removed«ref.name.singular().toFirstUpper()».contains(«ref.name.singular()»)) {
						model.add«ref.name.toFirstUpper().singular()»(shallowClone(«ref.name.singular()»));
	                }
	            }
				// add «ref.to.name» to model that has been added by user
	            for («ref.to.getDomainPackage()».«ref.to.name» «ref.name.singular()» : this.«ref.name») {
	                if (!model.get«ref.name.toFirstUpper()»().contains(«ref.name.singular()»)) {
						model.add«ref.name.toFirstUpper().singular()»(shallowClone(«ref.name.singular()»));
	                }
	            }
	            «ENDIF»
			«ELSEIF !for.getConstructorParameters().contains(ref)»
			model.set«ref.name.toFirstUpper()»(this.«ref.name»);
			«ENDIF »
	«ENDFOR»
	return model;
	}
	'''
}


def static String publicFormToModel(UpdateTask it) {
	'''
	public «for.getDomainPackage()».«for.name» toModel() {
	return toModel(original);
	}
	'''
}

def static String privateFormToModel(UpdateTask it) {
	'''
	private «for.getDomainPackage()».«for.name» toModel(«for.getDomainPackage()».«for.name» model) {
	«toModelNonReferences(it)»
	«FOR prop : this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.metaType == DerivedReferenceViewProperty)»
		«val ref = it.prop.reference»
		
			«IF ref.isOneToMany() || ref.isManyToMany() »
				«IF ref.opposite == null »
				model.get«ref.name.toFirstUpper()»().clear();
				model.get«ref.name.toFirstUpper()»().addAll(this.«ref.name»);
				«ELSE»
				// find «ref.to.name» that has been removed by user
				java.util.Set<«ref.to.getDomainPackage()».«ref.to.name»> removed«ref.name.singular().toFirstUpper()» = new java.util.HashSet<«ref.to.getDomainPackage()».«ref.to.name»>();
				for («ref.to.getDomainPackage()».«ref.to.name» «ref.name.singular()» : model.get«ref.name.toFirstUpper()»()) {
					if (!this.«ref.name».contains(«ref.name.singular()»)) {
						removed«ref.name.singular().toFirstUpper()».add(«ref.name.singular()»);
					}
				}
				// remove them from model
				for («ref.to.getDomainPackage()».«ref.to.name» «ref.name.singular()» : removed«ref.name.singular().toFirstUpper()») {
					model.remove«ref.name.toFirstUpper().singular()»(«ref.name.singular()»);
				}
				// add «ref.to.name» to model that has been added by user
				// copy original set to working copy to by pass persistent set implementation
				java.util.Set<«ref.to.getDomainPackage()».«ref.to.name»> copyOf«ref.name.toFirstUpper()» = new java.util.HashSet<«ref.to.getDomainPackage()».«ref.to.name»>(model.get«ref.name.toFirstUpper()»());
	            for («ref.to.getDomainPackage()».«ref.to.name» «ref.name.singular()» : this.«ref.name») {
	                if (!copyOf«ref.name.toFirstUpper()».contains(«ref.name.singular()»)) {
						model.add«ref.name.toFirstUpper().singular()»((«ref.to.getDomainPackage()».«ref.to.name») «ref.name.singular()»);
	                }
	            }
	            «ENDIF»
			«ELSEIF !for.getConstructorParameters().contains(ref)»
			model.set«ref.name.toFirstUpper()»(this.«ref.name»);
			«ENDIF »
	«ENDFOR»
	return model;
	}
	'''
}


def static String createModel(UserTask it) {
	'''
	protected «for.getDomainPackage()».«for.name» createModel() {
	«for.getDomainPackage()».«for.name» model = new «for.getDomainPackage()».«for.name»(«FOR p SEPARATOR "," : for.getConstructorParameters()»
		«IF (p.metaType == Reference) && (((Reference) p).to.metaType == BasicType)»
		create«p.name.toFirstUpper()»()
		«ELSEIF p.metaType == Reference»
		this.«p.name»
		«ELSE»
		this.get«p.name.toFirstUpper()»()
		«ENDIF»
	«ENDFOR»);
	return model;
	}
	'''
}


def static String toModelNonReferences(UserTask it) {
	'''
	«FOR prop : this.viewProperties.typeSelect(AttributeViewProperty).reject(p | p.attribute.isSystemAttribute())»
		«toModelAttribute(it)(for) FOR prop.attribute»
	«ENDFOR»
	«FOR prop : this.viewProperties.typeSelect(BasicTypeViewProperty)»
		«toModelBasicType(it)(for) FOR prop.reference»
	«ENDFOR»
	«FOR prop : this.viewProperties.typeSelect(EnumViewProperty).reject(e|e.metaType == BasicTypeEnumViewProperty)»
		«toModelEnum(it)(for) FOR prop.reference»
	«ENDFOR»	
	'''
}

def static String toModelReferences(CreateTask it, boolean forConfirm) {
	'''
	«FOR prop : this.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.metaType == DerivedReferenceViewProperty)»
		«val ref = it.prop.reference»
			«IF ref.isOneToMany() || ref.isManyToMany() »
			for («ref.to.getDomainPackage()».«ref.to.name» «ref.name.singular()» : this.«ref.name») {
				«IF ref.opposite == null »
				model.get«ref.name.toFirstUpper()»().add(«IF forConfirm»shallowClone(«ref.name.singular()»)«ELSE»«ref.name.singular()»«ENDIF»);
				«ELSE»
				model.add«ref.name.toFirstUpper().singular()»(«IF forConfirm»shallowClone(«ref.name.singular()»)«ELSE»(«ref.to.getDomainPackage()».«ref.to.name») «ref.name.singular()»«ENDIF»);
				«ENDIF»
				}
			«ELSEIF !for.getConstructorParameters().contains(ref)»
			model.set«ref.name.toFirstUpper()»(«IF forConfirm»shallowClone(«ref.name.singular()»)«ELSE»this.«ref.name»«ENDIF»);
			«ENDIF »
	«ENDFOR»
	'''
}


def static String toModelAttribute(Attribute it, DomainObject domainObject) {
	'''
	«IF !domainObject.getConstructorParameters().contains(this)»
	model.set«this.name.toFirstUpper()»(this.get«this.name.toFirstUpper()»());
	«ENDIF»
	'''
}

def static String toModelBasicType(Reference it, DomainObject domainObject) {
	'''
	«IF !domainObject.getConstructorParameters().contains(this)»
	model.set«this.name.toFirstUpper()»(create«this.name.toFirstUpper()»());
	«ENDIF»
	'''
}

def static String toModelEnum(Reference it, DomainObject domainObject) {
	'''
	«IF !domainObject.getConstructorParameters().contains(this)»
	model.set«this.name.toFirstUpper()»(get«this.name.toFirstUpper()»());
	«ENDIF»
	'''
}

	

def static String removeChildMethodForm(ReferenceViewProperty it) {
	'''
	«IF isMany() »
	void remove«name.toFirstUpper().singular()»(Integer index) {
	«reference.to.getDomainPackage()».«reference.to.name» «name.singular()» = this.«name».get(index);
	this.«name».remove(«name.singular()»);
	/*if reference is required, adjust the size property to enable gui resolving required lists/sets */
	«IF reference.required»
	if (this.«this.name».size() > 0) {
		this.«resolveRequiredIdAttributeName()» = new «reference.to.getIdAttributeType()»("" + this.«this.name».size());
		} else {
		this.«resolveRequiredIdAttributeName()» = null;
		}
	«ENDIF»
	}
	«ELSE »
	void remove«name.toFirstUpper().singular()»() {
	this.«name.singular()» = null;
	this.«resolveRequiredIdAttributeName(this)» = null;
	}
	«ENDIF »
	'''
}

def static String nextEnabledProperty(DomainObject it) {
	'''
		private boolean nextEnabled;

		public boolean isNextEnabled() {
			return nextEnabled;
		}

		public void setNextEnabled(boolean nextEnabled) {
			this.nextEnabled = nextEnabled;
		}
	'''
}

def static String confirmDraftProperty(DomainObject it) {
	'''
	private «getDomainPackage()».«name» confirmDraft;
	public «getDomainPackage()».«name» getConfirmDraft() {
		return confirmDraft;
	}
	void setConfirmDraft(«getDomainPackage()».«name» draft) {
		this.confirmDraft = draft;
	}
	'''
}

def static String domainObjectProperty(DomainObject it) {
	'''
	private «getDomainPackage()».«name» domainObject;
	public «getDomainPackage()».«name» getDomainObject() {
		return domainObject;
	}
	void setDomainObject(«getDomainPackage()».«name» domainObject) {
		this.domainObject = domainObject;
	}
	'''
}

def static String shallowClone(CreateTask it) {
	'''
	«val domainObjects = it.viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.metaType == DerivedReferenceViewProperty).reference.to.getAllSubclasses().addAll(viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.metaType == DerivedReferenceViewProperty).reference.to).toSet()»
		«it.domainObjects.forEach[shallowClone(it)]»
	'''
}

def static String shallowClone(UpdateTask it) {
	'''
	«val domainObjects = it.viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.metaType == DerivedReferenceViewProperty).reference.to.getAllSubclasses().addAll(viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.metaType == DerivedReferenceViewProperty).reference.to).add(for).toSet()»
		«it.domainObjects.forEach[shallowClone(it)]»
	'''
}

def static String shallowClone(DomainObject it) {
	'''
	private «getDomainPackage()».«name» shallowClone(«getDomainPackage()».«name» original) {
	if (original != null) {
	«IF getAllSubclasses().size > 0»
		«FOR sub : getAllSubclasses()»
		if (original instanceof «sub.getDomainPackage()».«sub.name») {
			return shallowClone((«sub.getDomainPackage()».«sub.name») original);
		}
		«ENDFOR»
		throw new RuntimeException("Unsupported type");
	«ELSE»
		«getDomainPackage()».«name» shallowClone = new «getDomainPackage()».«name»(«FOR p SEPARATOR "," : getConstructorParameters()»original.«p.getGetAccessor()»()«ENDFOR»);
		«FOR att : getAllAttributes()»
			«IF att.changeable && att.name != "uuid"»
			shallowClone.set«att.name.toFirstUpper()»(original.«att.getGetAccessor()»());
			«ENDIF»
		
		«ENDFOR»
		return shallowClone;
	«ENDIF»
	}
	return null;
	}
	'''
}

def static String serialVersionUID(Object it) {
	'''
		private static final long serialVersionUID = 1L;
	'''
}

def static String validateInputState(UserTask it) {
	'''
	«IF !this.for.getRequiredReferences().isEmpty»
	public void validateInput(org.springframework.binding.validation.ValidationContext context) {
	org.springframework.binding.message.MessageContext messages = context.getMessageContext();
	«FOR requiredReference  : this.for.getRequiredReferences().reject(ref | !ref.to.isPersistent())»
	if («module.application.basePackage».util.«subPackage("web")».RequiredHelper.isReferenceRequired(new String[] 
		«IF requiredReference.to.getSubclasses() == null || requiredReference.to.getSubclasses().size == 0 »
				{"«requiredReference.to.name»"}
		«ELSE »
				{
			«FOR sub SEPARATOR "," : requiredReference.to.getSubclasses()»
			"«sub.name»"
			«ENDFOR»
			}
		«ENDIF »)) {
		if (required«requiredReference.name.toFirstUpper()» == null || required«requiredReference.name.toFirstUpper()».equals(new «for.getIdAttributeType()»(""+ 0))) { 
				messages.addMessage(new org.springframework.binding.message.MessageBuilder().error().code("required.reference").resolvableArg("model.DomainObject.«requiredReference.to.name»").defaultText("«requiredReference.to.name» is required").build());
		}
	}
	«ENDFOR»
	}
	«ENDIF»
	'''
}
}
