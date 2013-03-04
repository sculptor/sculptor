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

class RcpCrudGuiRichObjectTmpl {



def static String richObject(GuiApplication it) {
	'''
	«it.modules.forEach[richObject(it)]»
	'''
} 

def static String richObject(GuiModule it) {
	'''
	«it.groupByTarget().forEach[richObject(it)]»
	«it.groupByTarget() .filter(e | isGapClassToBeGenerated(e, "Rich" + e.for.name)).forEach[gapRichObject(it)]»
	'''
}

def static String gapRichObject(UserTaskGroup it) {
	'''
	«val className = it."Rich" + for.name»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".data." + className), 'TO_SRC', '''
	«javaHeader()»
	package «module.getRichClientPackage()».data;

	«richObjectSpringAnnotation(it)»
	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String richObject(UserTaskGroup it) {
	'''
	«val className = it."Rich" + for.name + gapSubclassSuffix(this, "Rich" + for.name)»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".data." + className) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».data;

	«IF !className.endsWith("Base")»
	«richObjectSpringAnnotation(it)»
	«ENDIF»
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends «fw("richclient.data.AbstractRichObject")» implements java.io.Serializable {
		«richObjectSerialVersionUID(it)»
		
		«richObjectOriginal(it) FOR for»
		«richObjectIsNew(it) FOR for»
		«richObjectStale(it) FOR for»
		«richObjectGetId(it) FOR for»
		
		«IF hasReferenceViewProperties()»
			«richObjectPopulated(it) FOR for»
			«richObjectAssociationLoader(it)»
		«ENDIF»
		
		«it.getAggregatedViewProperties().reject(p | p.isSystemAttribute()).forEach[richObjectViewDataProperty(it)]»

	«richObjectUuidKey(it) FOR for»    
		
	«richObjectConstructor(it)»
		
		«richObjectUpdate(it)»

	«richObjectFromDomainObject(it)»
	«richObjectToDomainObject(it)»
	«richObjectToCloneDomainObject(it)»
	«richObjectToDomainObjectImpl(it)»
	«it. getAggregatedViewProperties().typeSelect(ReferenceViewProperty).filter(e|e.isMany()).collect(e|e.reference).toSet().forEach[richObjectToDomainObjectManyReferenceMethod(it)(this)]»
	
	«it. getAggregatedViewProperties().typeSelect(BasicTypeViewProperty).collect(e|e.reference).toSet().forEach[richObjectCreateBasicType(it)(this)]»
	
	«it. getAggregatedViewProperties().typeSelect(ReferenceViewProperty).reject(e|e.isMany()).collect(e|e.reference).toSet().forEach[richObjectCreateOneReference(it)(this)]»
	
	«richObjectFactory(it)»
	}
	'''
	)
	'''
	'''
}

def static String richObjectSpringAnnotation(UserTaskGroup it) {
	'''
	@org.springframework.stereotype.Component("rich«for.name»")
	@org.springframework.context.annotation.Scope("prototype")
	'''
}

def static String richObjectSerialVersionUID(Object it) {
	'''
		private static final long serialVersionUID = 1L;
	'''
}

def static String richObjectOriginal(DomainObject it) {
	'''
		private «getDomainPackage()».«name» original;
		
		protected synchronized «getDomainPackage()».«name» getOriginalDomainObject() {
			return original;
		}
	'''
}

def static String richObjectIsNew(DomainObject it) {
	'''
		public synchronized boolean isNew() {
			return (original == null || original.getId() == null);
		}
	'''
}

def static String richObjectGetId(DomainObject it) {
	'''
		public synchronized Long getId() {
			return (original == null ? null : original.getId());
		}
	'''
}

def static String richObjectStale(DomainObject it) {
	'''
		private boolean staleState;
		protected synchronized boolean isStale() {
			return staleState;
		}
		protected synchronized void setStale(boolean stale) {
			this.staleState = stale;
		}
	'''
}

def static String richObjectPopulated(DomainObject it) {
	'''
		private «getDomainPackage()».«name» populated;
		
		protected synchronized «getDomainPackage()».«name» getPopulated() {
			return populated;
		}
		
		protected synchronized void populate() {
			if (!isNew() && populated == null && associationLoader != null) {
				populated = associationLoader.populateAssociations(original);
			}
		}
	'''
}


def static String richObjectViewDataProperty(ViewDataProperty it) {
	'''
	'''
}
def static String richObjectViewDataProperty(AttributeViewProperty it) {
	'''
	«richObjectPropertyField(it)»
	«richObjectPropertyGetter(it)»
	«richObjectPropertySetter(it)»
	«IF isDateOrDateTime() && isNullable()»
		«richObjectDefinedFlag(it)»
	«ENDIF»
	'''
}
def static String richObjectViewDataProperty(BasicTypeViewProperty it) {
	'''
	«richObjectPropertyField(it)»
	«richObjectPropertyGetter(it)»
	«richObjectPropertySetter(it)»
	«IF isDateOrDateTime() && isNullable()»
		«richObjectDefinedFlag(it)»
	«ENDIF»
	'''
}

def static String richObjectViewDataProperty(ReferenceViewProperty it) {
	'''
	«IF !base»
		«richObjectReferenceTargetFactory(it)»
	«IF isMany() »
		private java.util.List<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> «resolveReferenceName().toFirstLower()»;
		private volatile org.eclipse.core.databinding.observable.list.IObservableList observable«resolveReferenceName()»;
		«richObjectGetManyReference(it)»
		«richObjectAddReference(it)»
		«richObjectRemoveReference(it)»
	«ELSE»
		private java.util.concurrent.atomic.AtomicReference<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> «resolveReferenceName().toFirstLower()»Holder;
		«richObjectGetOneReference(it)»
		«richObjectSetReference(it)»
	«ENDIF »
	«ENDIF»
	'''
}

def static String richObjectReferenceTargetFactory(ReferenceViewProperty it) {
	'''
		private «fw("richclient.data.RichObjectFactory")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> rich«resolveReferenceName()»Factory;
		/**
			* Dependency injection
			*/
		@javax.annotation.Resource(name="rich«target.name»Repository")
		@org.springframework.beans.factory.annotation.Required
		public void setRich«resolveReferenceName()»Factory(«fw("richclient.data.RichObjectFactory")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> factory) {
			rich«resolveReferenceName()»Factory = factory;
		}
		protected «fw("richclient.data.RichObjectFactory")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> getRich«resolveReferenceName()»Factory() {
			return rich«resolveReferenceName()»Factory;
		}
	'''
}

def static String richObjectGetManyReference(ReferenceViewProperty it) {
	'''
		@SuppressWarnings("unchecked")
		public synchronized java.util.List<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> get«resolveReferenceName()»() {
			if («resolveReferenceName().toFirstLower()» != null) {
				return «resolveReferenceName().toFirstLower()»;
			}
			populate();
			if (populated == null) {
				«resolveReferenceName().toFirstLower()» = new java.util.ArrayList();
			} else {
				java.util.List<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> items = new java.util.ArrayList<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»>();
				for («reference.to.getDomainPackage()».«reference.to.name» each : populated.get«reference.name.toFirstUpper()»()) {
					«IF reference.to != target»
				    if (!(each instanceof «target.getDomainPackage()».«target.name»)) {
				        continue;
				    }
				    «ENDIF» 
				    «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» rich«target.name» = rich«resolveReferenceName()»Factory.create();
				    rich«target.name».fromDomainObject(«IF reference.to != target»(«target.getDomainPackage()».«target.name») «ENDIF»each);
				    items.add(rich«target.name»);
				}
				«resolveReferenceName().toFirstLower()» = items;
			}
			return «resolveReferenceName().toFirstLower()»;
		}
		
		public org.eclipse.core.databinding.observable.list.IObservableList getObservable«resolveReferenceName()»() {
			if (observable«resolveReferenceName()» == null) {
				observable«resolveReferenceName()» = «fw("richclient.databinding.ObservableUtil")».createWritableList(get«resolveReferenceName()»());
			}
			return observable«resolveReferenceName()»;
		}
	'''
}

def static String richObjectGetOneReference(ReferenceViewProperty it) {
	'''
		@SuppressWarnings("unchecked")
		public synchronized «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» get«resolveReferenceName()»() {
			if («resolveReferenceName().toFirstLower()»Holder != null) {
				return «resolveReferenceName().toFirstLower()»Holder.get();
			}
		
			populate();
			«resolveReferenceName().toFirstLower()»Holder = new java.util.concurrent.atomic.AtomicReference<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»>(); 
			if (populated != null) {
				«IF reference.to != target»
				if (populated.get«reference.name.toFirstUpper()»() instanceof «target.getDomainPackage()».«target.name») {
				«ELSE»
				if (populated.get«reference.name.toFirstUpper()»() != null) {
				«ENDIF»
				«resolveReferenceName().toFirstLower()»Holder.set(rich«resolveReferenceName()»Factory.create());
				«resolveReferenceName().toFirstLower()»Holder.get().fromDomainObject(«IF reference.to != target»(«target.getDomainPackage()».«target.name») «ENDIF»populated.get«reference.name.toFirstUpper()»());
				}
			}
			return «resolveReferenceName().toFirstLower()»Holder.get();
		}
	'''
}

def static String richObjectAddReference(ReferenceViewProperty it) {
	'''
	public synchronized void add«resolveReferenceName().singular()»(«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» «name.singular()») {
	    Object oldValue;
		int i = getObservable«resolveReferenceName()»().indexOf(«name.singular()»);
			if (i == -1) {
				oldValue = new Object(); // not used, but can't be null
				getObservable«resolveReferenceName()»().add(«name.singular()»);
			} else {
				oldValue = getObservable«resolveReferenceName()»().get(i);
				getObservable«resolveReferenceName()»().set(i, «name.singular()»);
			}
			
			«IF reference.opposite != null»
				«val group = it.userTask.module.application.groupByTarget().selectFirst(g | g.userTasks.exists(t | t == userTask))»
			if (oldValue != «name.singular()») {
			    «name.singular()».«reference.opposite.many ? "add" : "set"»«resolveReferenceName("", reference.opposite, userTask.for, "") »(«IF isGapClassToBeGenerated(group, "Rich" + userTask.for.name)»(Rich«userTask.for.name») «ENDIF»this);
	    }
	    «ENDIF»
			
			firePropertyChange("«resolveReferenceName().toFirstLower()»", oldValue, getObservable«resolveReferenceName()»());
	}
	'''
}

def static String richObjectRemoveReference(ReferenceViewProperty it) {
	'''
	public synchronized void remove«resolveReferenceName().singular()»(«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» «name») {
	    int i = getObservable«resolveReferenceName()»().indexOf(«name»);
			if (i == -1) {
				return;
			}
			Object oldValue = getObservable«resolveReferenceName()»().get(i);
			getObservable«resolveReferenceName()»().remove(«name»);
			
			«IF reference.opposite != null»
	    	«IF reference.opposite.many»
	    		«val group = it.userTask.module.application.groupByTarget().selectFirst(g | g.userTasks.exists(t | t == userTask))»
	    		«name».remove«resolveReferenceName("", reference.opposite, userTask.for, "") »(«IF isGapClassToBeGenerated(group, "Rich" + userTask.for.name)»(Rich«userTask.for.name») «ENDIF»this);
	    	«ELSE»
	    		«name».set«resolveReferenceName("", reference.opposite, userTask.for, "")»(null);
	    	«ENDIF»
	    «ENDIF»
			
			firePropertyChange("«resolveReferenceName().toFirstLower()»", oldValue, getObservable«resolveReferenceName()»());
		}
	'''
}

def static String richObjectSetReference(ReferenceViewProperty it) {
	'''
	public synchronized void set«resolveReferenceName()»(«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» «name») {
	    if (this.«resolveReferenceName().toFirstLower()»Holder == null) {
	        this.«resolveReferenceName().toFirstLower()»Holder = new java.util.concurrent.atomic.AtomicReference<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»>();
	    }
	    Object oldValue = this.«resolveReferenceName().toFirstLower()»Holder.get();
		this.«resolveReferenceName().toFirstLower()»Holder.set(«name»);
		
		«IF reference.opposite != null»
			«val group = it.userTask.module.application.groupByTarget().selectFirst(g | g.userTasks.exists(t | t == userTask))»
		    if (oldValue != «name») {
		        if («name.singular()» == null) {
					«IF reference.opposite.many»
					    ((«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name») oldValue).remove«resolveReferenceName("", reference.opposite, userTask.for, "") »(«IF isGapClassToBeGenerated(group, "Rich" + userTask.for.name)»(Rich«userTask.for.name») «ENDIF»this);
					«ELSE»
					    ((«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name») oldValue).set«resolveReferenceName("", reference.opposite, userTask.for, "") »(null);
					«ENDIF»
	    	    } else {
	                «name».«reference.opposite.many ? "add" : "set"»«resolveReferenceName("", reference.opposite, userTask.for, "") »(«IF isGapClassToBeGenerated(group, "Rich" + userTask.for.name)»(Rich«userTask.for.name») «ENDIF»this);
	    	    }
	    	}
	    «ENDIF»
		
		firePropertyChange("«resolveReferenceName().toFirstLower()»", oldValue, this.«resolveReferenceName().toFirstLower()»Holder.get());
	}
	'''
}

def static String richObjectViewDataProperty(EnumViewProperty it) {
	'''
	private «reference.to.getDomainPackage()».«reference.to.name» «name»;
	public «reference.to.getDomainPackage()».«reference.to.name» get«name.toFirstUpper()»() {
		return «name»;
	}
	public void set«name.toFirstUpper()»(«reference.to.getDomainPackage()».«reference.to.name» «name») {
	    Object oldValue = this.«name»;
		this.«name» = «name»;
		firePropertyChange("«name»", oldValue, «name»);
	}
	public java.util.List<«reference.to.getDomainPackage()».«reference.to.name»> get«name.toFirstUpper()»Options() {
			return java.util.Arrays.asList(«reference.to.getDomainPackage()».«reference.to.name».values());
		}
	'''
}

def static String richObjectDefinedFlag(ViewDataProperty it) {
	'''
		private boolean «name»Defined;
		
		public boolean is«name.toFirstUpper()»Defined() {
			return «name»Defined;
		}
		
		public void set«name.toFirstUpper()»Defined(boolean «name»Defined) {
			Object oldValue = this.«name»Defined;
			this.«name»Defined = «name»Defined;
			firePropertyChange("«name»Defined", oldValue, «name»Defined);
			if (!«name»Defined && («name» != null)) {
				set«name.toFirstUpper()»(null);
			}
		}
	'''
}

def static String richObjectPropertyField(ViewDataProperty it) {
	'''
	private «getTypeName()» «name»;
	'''
}

def static String richObjectPropertyGetter(ViewDataProperty it) {
	'''
		«formatJavaDoc()»
		public «getTypeName()» get«name.toFirstUpper()»() {
			return «name»;
		};

	'''
}

def static String richObjectPropertySetter(ViewDataProperty it) {
	'''
		«formatJavaDoc()»
		public void set«name.toFirstUpper()»(«getTypeName()» «name») {
			Object oldValue = this.«name»;
			this.«name» = «name»;
			firePropertyChange("«name»", oldValue, «name»);
			«IF isDateOrDateTime() && isNullable() »
			set«name.toFirstUpper()»Defined(this.«name» != null);
			«ENDIF»
		};
	'''
}

def static String richObjectAssociationLoader(UserTaskGroup it) {
	'''
		private «fw("richclient.data.AssociationLoader")»<«for.getDomainPackage()».«for.name»> associationLoader;
		
		private «fw("richclient.data.AssociationLoader")»<«for.getDomainPackage()».«for.name»> getAssociationLoader() {
			return associationLoader;
		}

		/**
			* Dependency injection
			*/
		@javax.annotation.Resource(name="rich«for.name»Repository")
		@org.springframework.beans.factory.annotation.Required
		public void setAssociationLoader(«fw("richclient.data.AssociationLoader")»<«for.getDomainPackage()».«for.name»> associationLoader) {
			this.associationLoader = associationLoader;
		}

	'''
}

def static String richObjectUuidKey(DomainObject it) {
	'''
		private String uuidKey;
		
		public synchronized Object getKey() {
			if (uuidKey != null) {
				return uuidKey;
			} else if (isNew()) {
				uuidKey = java.util.UUID.randomUUID().toString();
				return uuidKey;
			} else {
				return «originalKey(it)»;
			}
		}
	'''
}

def static String originalKey(DomainObject it) {
	'''
	original.getKey()
	'''
}

def static String originalKey(DataTransferObject it) {
	'''
	original.getId()
	'''
}

def static String richObjectConstructor(UserTaskGroup it) {
	'''
		/**
			* Instances are to be created with the 
			* {@link «module.getRichClientPackage()».data.Rich«for.name»«gapSubclassSuffix(this, "Rich" + for.name)».Factory factory}
			*/
		protected Rich«for.name»«gapSubclassSuffix(this, "Rich" + for.name)»() {
		}
	'''
}

def static String richObjectUpdate(UserTaskGroup it) {
	'''
		public synchronized void update(«fw("richclient.data.RichObject")» other) {
			updateFrom((Rich«for.name»«gapSubclassSuffix(this, "Rich" + for.name)») other);
		}
		
		private void updateFrom(Rich«for.name»«gapSubclassSuffix(this, "Rich" + for.name)» other) {
		«IF hasReferenceViewProperties()»
			this.associationLoader = other.associationLoader;
		«ENDIF»
		«richObjectUpdateSetGet(it) FOREACH getAggregatedViewProperties() .reject(p | p.metaType == ReferenceViewProperty || p.metaType == DerivedReferenceViewProperty)
			.reject(p | p.isSystemAttribute()) »
		}
	'''
}

def static String richObjectUpdateSetGet(ViewDataProperty it) {
	'''
		set«name.toFirstUpper()»(other.get«name.toFirstUpper()»());
	'''
}

def static String richObjectFromDomainObject(UserTaskGroup it) {
	'''
	public synchronized void fromDomainObject(«for.getDomainPackage()».«for.name» domainObject) {
		original = domainObject;
		«IF hasReferenceViewProperties()»
		populated = null;
		«ENDIF»
	
		«it.getAggregatedViewProperties().reject(p | p.isSystemAttribute()).forEach[richObjectFromDomainObjectProperty(it)]»
			
			clearModifications();
	}
	'''
}

def static String richObjectFromDomainObjectProperty(ViewDataProperty it) {
	'''
	'''
}

def static String richObjectFromDomainObjectProperty(AttributeViewProperty it) {
	'''
		set«name.toFirstUpper()»(domainObject.«attribute.getGetAccessor()»());
	'''
}

def static String richObjectFromDomainObjectProperty(BasicTypeViewProperty it) {
	'''
		set«name.toFirstUpper()»(domainObject.get«reference.name.toFirstUpper()»() == null ? null : domainObject.get«reference.name.toFirstUpper()»().«attribute.getGetAccessor()»());
	'''
}

def static String richObjectFromDomainObjectProperty(EnumViewProperty it) {
	'''
		set«name.toFirstUpper()»(domainObject.get«reference.name.toFirstUpper()»());
	'''
}

def static String richObjectFromDomainObjectProperty(BasicTypeEnumViewProperty it) {
	'''
		set«name.toFirstUpper()»(domainObject.get«basicTypeReference.name.toFirstUpper()»().get«reference.name.toFirstUpper()»());
	'''
}

def static String richObjectFromDomainObjectProperty(ReferenceViewProperty it) {
	'''
	«IF !base»
		// will be lazy loaded by getter
		«resolveReferenceName().toFirstLower()»«IF !isMany()»Holder«ENDIF» = null;
		«IF isMany()»observable«resolveReferenceName()» = null;«ENDIF»
		«ENDIF»
	'''
}

def static String richObjectToDomainObject(UserTaskGroup it) {
	'''
		public synchronized «for.getDomainPackage()».«for.name» toDomainObject(boolean includeAssociations) {
			if (isNew()) {
			«for.getDomainPackage()».«for.name» domainObject = new «for.getDomainPackage()».«for.name»(«FOR p SEPARATOR "," : for.getConstructorParameters()»
				«IF (p.metaType == Reference) && (((Reference) p).to.metaType != Enum)»
				create«p.name.toFirstUpper()»() 
				«ELSE»
				get«p.name.toFirstUpper()»()
				«ENDIF»
			«ENDFOR»);
				original =  toDomainObject(domainObject, includeAssociations);
				return original;
			} else if (!isModified()) {
				return original;
			} else {
				«IF hasReferenceViewProperties()»        
				populate();
				«for.getDomainPackage()».«for.name» domainObject = (populated == null ? original : populated);
					«IF !for.getAllAttributes().filter(e|e.name == "version").isEmpty »
						domainObject.setVersion(original.getVersion());
					«ENDIF »
				original = toDomainObject(domainObject, includeAssociations);
				
				«ELSE»
				original = toDomainObject(original, includeAssociations);
				«ENDIF»
				return original;
			}
		}
	'''
}

def static String richObjectToCloneDomainObject(UserTaskGroup it) {
	'''
		synchronized «for.getDomainPackage()».«for.name» toCloneDomainObject() {
			return toDomainObject((«for.getDomainPackage()».«for.name») original.clone(), false);
		}
	'''
}

def static String richObjectToDomainObjectImpl(UserTaskGroup it) {
	'''
		protected «for.getDomainPackage()».«for.name» toDomainObject(«for.getDomainPackage()».«for.name» domainObject, boolean includeAssociations) {
	«it. getAggregatedViewProperties().reject(p | p.isSystemAttribute()).forEach[richObjectToDomainObjectProperty(it)]»
	
	«it. getAggregatedViewProperties().typeSelect(BasicTypeViewProperty).collect(e|e.reference).toSet().forEach[richObjectToDomainObjectBasicTypeProperty(it)(this)]»
	
	«IF hasReferenceViewProperties()»
	if (includeAssociations) {
		«it.getAggregatedViewProperties().typeSelect(ReferenceViewProperty).collect(e|e.reference).toSet().forEach[richObjectToDomainObjectReferenceProperty(it)(this) ]»
	}
	«ENDIF»
	
	return domainObject;
	}
	'''
}

def static String richObjectToDomainObjectProperty(ViewDataProperty it) {
	'''
	'''
}

def static String richObjectToDomainObjectProperty(AttributeViewProperty it) {
	'''
	«IF !userTask.for.getConstructorParameters().contains(attribute)»
	if (isModified("«attribute.name»")) {
	    domainObject.set«attribute.name.toFirstUpper()»(get«name.toFirstUpper()»());
	}
	«ENDIF»
	'''
}

def static String richObjectToDomainObjectProperty(EnumViewProperty it) {
	'''
	«IF !userTask.for.getConstructorParameters().contains(reference)»
	if (isModified("«reference.name»")) {
	    domainObject.set«reference.name.toFirstUpper()»(get«name.toFirstUpper()»());
	}
	«ENDIF»
	'''
}

def static String richObjectToDomainObjectProperty(BasicTypeEnumViewProperty it) {
	'''
/*TODO ? */
	'''
}

def static String richObjectToDomainObjectReferenceProperty(Reference it, UserTaskGroup group) {
	'''
	«IF !group.for.getConstructorParameters().contains(this)»
		«IF isMany()»
			«richObjectToDomainObjectManyReferenceProperty(it)(group)»
		«ELSE »
			«richObjectToDomainObjectOneReferenceProperty(it)(group)»
		«ENDIF»
	«ENDIF»
	'''
}

def static String richObjectToDomainObjectManyReferenceProperty(Reference it, UserTaskGroup group) {
	'''
		toDomainObject«name.toFirstUpper()»(domainObject);
	'''
}

def static String richObjectToDomainObjectManyReferenceMethod(Reference it, UserTaskGroup group) {
	'''
	«IF !group.for.getConstructorParameters().contains(this)»
	«val referenceProperties = it.group.getAggregatedViewProperties().typeSelect(ReferenceViewProperty).filter(e|e.reference == this).reject(e|e.base)»
		protected void toDomainObject«name.toFirstUpper()»(«group.for.getDomainPackage()».«group.for.name» domainObject) {
		if («FOR prop SEPARATOR " && " : referenceProperties»!isModified("«prop.resolveReferenceName().toFirstLower()»")«ENDFOR») {
		    return;
		}
		«IF opposite == null »
		    domainObject.get«name.toFirstUpper()»().clear();
		    «FOR prop : referenceProperties»
		    for («prop.relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«prop.relatedTransitions.first().to.for.name» each : get«prop.resolveReferenceName()»()) {
		        domainObject.get«name.toFirstUpper()»().add(each.toDomainObject(«hasUpdatingSubtask(group)»));
		    }
		    «ENDFOR»
		«ELSE»
		java.util.Set<«to.getDomainPackage()».«to.name»> current = new java.util.HashSet<«to.getDomainPackage()».«to.name»>();
		java.util.Set<«to.getDomainPackage()».«to.name»> modified = new java.util.HashSet<«to.getDomainPackage()».«to.name»>();
		«FOR prop : referenceProperties»
		for («prop.relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«prop.relatedTransitions.first().to.for.name» each : get«prop.resolveReferenceName()»()) {
	        «to.getDomainPackage()».«to.name» currentElement = each.toDomainObject(«hasUpdatingSubtask(group)»); 
	        current.add(currentElement);
	        if (each.isModified()) {
				    modified.add(currentElement);
				}
	    }
	    «ENDFOR»
		
		// replace modified
		for («to.getDomainPackage()».«to.name» each : modified) {
		    try {
			    domainObject.remove«name.toFirstUpper().singular()»(each);
			    domainObject.add«name.toFirstUpper().singular()»(each);
			} catch (RuntimeException e) {
			    // might be LazyInitializationException, try this best effort...
			    domainObject.get«name.toFirstUpper()»().remove(each);
			    domainObject.get«name.toFirstUpper()»().add(each);
			}
			}
		
		// find «to.name» that has been removed by user
		java.util.Set<«to.getDomainPackage()».«to.name»> removed«name.singular().toFirstUpper()» = new java.util.HashSet<«to.getDomainPackage()».«to.name»>();
		for («to.getDomainPackage()».«to.name» each : domainObject.get«name.toFirstUpper()»()) {
			if (!current.contains(each)) {
				removed«name.singular().toFirstUpper()».add(each);
			}
		}
		// remove them from domainObject
		for («to.getDomainPackage()».«to.name» each : removed«name.singular().toFirstUpper()») {
		    try {
			    domainObject.remove«name.toFirstUpper().singular()»(each);
			} catch (RuntimeException e) {
			    // might be LazyInitializationException, try this best effort...
			    domainObject.get«name.toFirstUpper()»().remove(each);
			}
		}
		
		// add «to.name» to domainObject that has been added by user
			for («to.getDomainPackage()».«to.name» each : current) {
				if (!domainObject.get«name.toFirstUpper()»().contains(each)) {
				    try {
				    domainObject.add«name.toFirstUpper().singular()»(each);
				} catch (RuntimeException e) {
			        // might be LazyInitializationException, try this best effort...
				    domainObject.get«name.toFirstUpper()»().add(each);
				}
				}
			}
			«ENDIF»
		}
	«ENDIF»
	'''
}

def static String richObjectToDomainObjectOneReferenceProperty(Reference it, UserTaskGroup group) {
	'''
			if (isModified("«name»")) {
				domainObject.set«name.toFirstUpper()»(create«name.toFirstUpper()»());
			}
	'''
}

def static String richObjectToDomainObjectBasicTypeProperty(Reference it, UserTaskGroup group) {
	'''
	«IF !group.for.getConstructorParameters().contains(this)»
	«val basicTypeProperties = it.group.getAggregatedViewProperties().typeSelect(BasicTypeViewProperty).filter(e|e.reference == this)»
	
	if («FOR prop SEPARATOR " || " : basicTypeProperties»isModified("«name»«prop.attribute.name.toFirstUpper()»")«ENDFOR») {
	    domainObject.set«name.toFirstUpper()»(create«name.toFirstUpper()»());
	}
	«ENDIF»
	'''
}

def static String richObjectCreateBasicType(Reference it, UserTaskGroup group) {
	'''
	«LET group.getAggregatedViewProperties().typeSelect(BasicTypeViewProperty).filter(e|e.reference == this) .addAll(group.getAggregatedViewProperties().typeSelect(BasicTypeEnumViewProperty).select(e|e.basicTypeReference == this))
	AS basicTypeProperties»
	protected «to.getDomainPackage()».«to.name» create«name.toFirstUpper()»() {
		«to.getDomainPackage()».«to.name» result =
			new «to.getDomainPackage()».«to.name»(
		«FOR p SEPARATOR ", "  : to.getConstructorParameters()»
			get«basicTypeProperties.typeSelect(BasicTypeViewProperty).filter(e|e.attribute == p) .addAll(basicTypeProperties.typeSelect(BasicTypeEnumViewProperty).select(e|e.reference == p))
				.selectFirst(e|true).name.toFirstUpper()»()
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

def static String richObjectCreateOneReference(Reference it, UserTaskGroup group) {
	'''
	«val referenceProperties = it.group.getAggregatedViewProperties().typeSelect(ReferenceViewProperty).filter(e|e.reference == this).reject(e|e.base)»
	protected «to.getDomainPackage()».«to.name» create«name.toFirstUpper()»() {
	«IF referenceProperties.first().metaType == DerivedReferenceViewProperty»
	    if «FOR prop SEPARATOR "} else if " : referenceProperties»(get«prop.resolveReferenceName()»() != null) {
				return get«prop.resolveReferenceName()»().toDomainObject(«hasUpdatingSubtask(group)»);
			«ENDFOR»} else {
				return null;
			}
	«ELSE»
	    if (get«referenceProperties.first().resolveReferenceName()»() == null) {
	        return null;
	    } else {
	        return get«referenceProperties.first().resolveReferenceName()»().toDomainObject(«hasUpdatingSubtask(group)»);
	    }
	«ENDIF»
	}
	'''
}

def static String richObjectFactory(UserTaskGroup it) {
	'''
		/**
			* Rich«for.name» objects are created with Spring as 'prototype'
			* scoped beans. This factory is used by Spring's factory method injection, as 
			* described here:
			* http://static.springframework.org/spring/docs/2.5.x/reference/beans.html#beans-factory-method-injection
			*/
		public abstract static class Factory implements «fw("richclient.data.RichObjectFactory")»<Rich«for.name»> {
			public abstract Rich«for.name» create();
		}
	'''
}
}
