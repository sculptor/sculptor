/*
 * Copyright 2007 The Fornax Project Team, including the original
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

package org.sculptor.generator.template.domain

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Reference

class DomainObjectReferenceTmpl {

	@Inject private var DomainObjectReferenceAnnotationTmpl domainObjectReferenceAnnotationTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def String oneReferenceAttribute(Reference it) {
	'''
		«IF it.isUnownedReference()»
			«oneReferenceIdAttribute(it)»
			«IF mongoDb()»
				«oneReferenceLazyAttribute(it)»
			«ENDIF»
		«ELSE»
			«oneReferenceAttribute(it, true)»
		«ENDIF»
	'''
}

def String oneReferenceAttribute(Reference it, boolean annotations) {
	'''
		«IF annotations»
			«domainObjectReferenceAnnotationTmpl.oneReferenceAttributeAnnotations(it)»
		«ENDIF»
		private «IF transient»transient «ENDIF»«it.getTypeName()» «name»«oneReferenceAttributeDefaultValue(it)»;
	'''
}

/*Possibility to overwrite and set custom default initialization for some attributes,
	e.g. using hint. Note that you must include =.
 */
def String oneReferenceAttributeDefaultValue(Reference it) {
	'''
	'''
}

def String oneReferenceIdAttribute(Reference it) {
	'''
		«IF isJpaProviderAppEngine() && isJpaAnnotationOnFieldToBeGenerated()»
		«domainObjectReferenceAnnotationTmpl.oneReferenceAppEngineKeyAnnotation(it)»
		«ENDIF»
		private «getJavaType("IDTYPE")» «name»«it.unownedReferenceSuffix()»;
	'''
}

def String oneReferenceLazyAttribute(Reference it) {
	'''
	private boolean «name»IsLoaded = false;
		private «it.getTypeName()» «name»;
	'''
}

def String oneReferenceAccessors(Reference it) {
	'''
		«IF it.isUnownedReference()»
			«oneReferenceIdGetter(it)»
			«IF mongoDb()»
				«oneReferenceMongoDbLazyGetter(it)»
			«ENDIF»
			«IF changeable»
				«oneReferenceIdSetter(it)»
				«IF mongoDb()»
					«oneReferenceMongoDbLazySetter(it)»
				«ENDIF»
			«ENDIF»
		«ELSE»
			«oneReferenceGetter(it)»
			«IF !changeable»
				«notChangeableOneReferenceSetter(it)»
			«ELSE»
				«oneReferenceSetter(it)»
			«ENDIF»
		«ENDIF»

	'''
}

def String oneReferenceGetter(Reference it) {
	'''
		«oneReferenceGetter(it, true)»
	'''
}

def String oneReferenceGetter(Reference it, boolean annotations) {
	'''
		«it.formatJavaDoc()»
		«IF annotations»
			«domainObjectReferenceAnnotationTmpl.oneReferenceGetterAnnotations(it)»
		«ENDIF»
		«it.getVisibilityLitteralGetter()»«it.getTypeName()» get«name.toFirstUpper()»() {
			return «name»;
		};
	'''
}

def String oneReferenceIdGetter(Reference it) {
	'''
		«it.formatJavaDoc()»
		«IF isJpaProviderAppEngine() && !isJpaAnnotationOnFieldToBeGenerated()»
		«domainObjectReferenceAnnotationTmpl.oneReferenceAppEngineKeyAnnotation(it)»
		«ENDIF»
		«it.getVisibilityLitteralGetter()»«getJavaType("IDTYPE")» get«name.toFirstUpper()»«it.unownedReferenceSuffix()»() {
			«IF mongoDb()»
			if (!«name»IsLoaded) {
				return «name»«it.unownedReferenceSuffix()»;
			} else {
				// associated instance has been loaded, or set, id was maybe not assigned when associated instance was set
				if («name» == null) {
					return null;
				} else if («name».getId() == null) {
					throw new IllegalStateException("Reference «from.name».«name» is unsaved instance. Cascade not supported. Save «to.name» before saving «from.name».");
				} else {
					return «name».getId();
				}
			}
			«ELSE»
			return «name»«it.unownedReferenceSuffix()»;
			«ENDIF»
		};
	'''
}

def String oneReferenceMongoDbLazyGetter(Reference it) {
	'''
		«it.formatJavaDoc()»
		«it.getVisibilityLitteralGetter()»«it.getTypeName()» get«name.toFirstUpper()»() {
			if («name»IsLoaded) {
				return «name»;
			}
			if («name»«it.unownedReferenceSuffix()» == null) {
				«name»IsLoaded = true;
				return null;
			}
			«fw("accessimpl.mongodb.DbManager")» dbManager = «fw("accessimpl.mongodb.DbManager")».getThreadInstance();
			if (dbManager == null) {
				throw new IllegalStateException("Lazy loading of «from.name».«name» failed due to missing DbManager.getThreadInstance()");
			}
			String dbCollectionName = «to.module.getMapperPackage()».«to.name»Mapper.getInstance().getDBCollectionName();
			com.mongodb.DBRef dbRef = new com.mongodb.DBRef(dbManager.getDB(), dbCollectionName,
				org.bson.types.ObjectId.massageToObjectId(«name»«it.unownedReferenceSuffix()»));
			«name» = («it.getTypeName()»)«to.module.getMapperPackage()».«to.name»Mapper.getInstance().toDomain(dbRef.fetch());
			«name»IsLoaded = true;
			return «name»;
		};

		«it.getVisibilityLitteralGetter()» boolean is«name.toFirstUpper()»Loaded() {
			return «name»IsLoaded;
		}
	'''
}

def String oneReferenceIdSetter(Reference it) {
	'''
	«IF it.isSetterNeeded()»
		«it.formatJavaDoc()»
		«it.getVisibilityLitteralSetter()»void set«name.toFirstUpper()»«it.unownedReferenceSuffix()»(«getJavaType("IDTYPE")» «name»«it.unownedReferenceSuffix()») {
			this.«name»«it.unownedReferenceSuffix()» = «name»«it.unownedReferenceSuffix()»;
			«IF mongoDb() »
				«name»IsLoaded = false;
				«name» = null;
			«ENDIF »
		};
		«ENDIF»
	'''
}

def String oneReferenceMongoDbLazySetter(Reference it) {
	'''
	«IF it.isSetterNeeded()»
		«it.formatJavaDoc()»
		«it.getVisibilityLitteralSetter()»void set«name.toFirstUpper()»(«it.getTypeName()» «name») {
			this.«name» = «name»;
			«name»IsLoaded = true;
				this.«name»«it.unownedReferenceSuffix()» = («name» == null ? null : «name».getId());
		};
		«ENDIF»
	'''
}

def String oneReferenceSetter(Reference it) {
	'''
	«IF it.isSetterNeeded()»
		«it.formatJavaDoc()»
		«domainObjectReferenceAnnotationTmpl.oneReferenceSetterAnnotations(it)»
		«it.getVisibilityLitteralSetter()»void set«name.toFirstUpper()»(«it.getTypeName()» «name») {
			«IF isFullyAuditable() && !transient»
			receiveInternalAuditHandler().recordChange(«it.getDomainObject().name»Properties.«name»(), this.«name», «name»);
			«ENDIF»
			this.«name» = «name»;
		};
		«ENDIF»
	'''
}

def String notChangeableOneReferenceSetter(Reference it) {
	'''
		«IF it.isSetterNeeded()»
		«IF notChangeableReferenceSetterVisibility() == "private"»
		@SuppressWarnings("unused")
		«ELSE »
		/**
			* This reference can't be changed. Use constructor to assign value.
			* However, some tools need setter methods and sometimes the
			* referred object is not available at construction time. Therefore
			* this method is visible, but the actual reference can't be changed
			* once it is assigned.
			*/
		«ENDIF »
		«domainObjectReferenceAnnotationTmpl.oneReferenceSetterAnnotations(it)»
		«notChangeableReferenceSetterVisibility()» void set«name.toFirstUpper()»(«it.getTypeName()» «name») {
			// it must be possible to set null when deleting objects
			if ((«name» != null) && (this.«name» != null) && !this.«name».equals(«name»)) {
				throw new IllegalArgumentException("Not allowed to change the «name» reference.");
			}
			this.«name» = «name»;
		};
		«ENDIF»
	'''
}

def String manyReferenceAttribute(Reference it) {
	'''
	«IF it.isUnownedReference()»
		«manyReferenceIdsAttribute(it)»
		«IF mongoDb()»
			«manyReferenceLazyAttribute(it)»
		«ENDIF»
	«ELSE»
		«manyReferenceAttribute(it, true)»		
		«ENDIF»
	'''
}

def String manyReferenceAttribute(Reference it, boolean annotations) {
	'''
	«IF annotations»
		«domainObjectReferenceAnnotationTmpl.manyReferenceAttributeAnnotations(it)»
	«ENDIF»
	
	private «IF transient»transient «ENDIF»«it.getCollectionInterfaceType()»<«it.getTypeName()»> «name» = new «it.getCollectionImplType()»<«it.getTypeName()»>();

	'''
}


def String manyReferenceIdsAttribute(Reference it) {
	'''
	«IF isJpaProviderAppEngine() && isJpaAnnotationOnFieldToBeGenerated()»
	    «domainObjectReferenceAnnotationTmpl.manyReferenceAppEngineKeyAnnotation(it)»
	«ENDIF»
		private «it.getCollectionInterfaceType()»<«getJavaType("IDTYPE")»> «name»«it.unownedReferenceSuffix()» = new «it.getCollectionImplType()»<«getJavaType("IDTYPE")»>();
	'''
}

def String manyReferenceLazyAttribute(Reference it) {
	'''
		private «it.getCollectionInterfaceType()»<«it.getTypeName()»> «name»;
	'''
}

def String manyReferenceIdsGetter(Reference it) {
	'''
		«it.formatJavaDoc()»
		«IF isJpaProviderAppEngine() && !isJpaAnnotationOnFieldToBeGenerated()»
			«domainObjectReferenceAnnotationTmpl.manyReferenceAppEngineKeyAnnotation(it)»
		«ENDIF»
		«it.getVisibilityLitteralGetter()»«it.getCollectionInterfaceType()»<«getJavaType("IDTYPE")»> get«name.toFirstUpper()»«it.unownedReferenceSuffix()»() {
			// appengine sometimes stores the collection as null
			if («name»«it.unownedReferenceSuffix()» == null) {
			    «name»«it.unownedReferenceSuffix()» = new «it.getCollectionImplType()»<«getJavaType("IDTYPE")»>();
			}
			«IF mongoDb()»
				if («name» == null) {
					return «name»«it.unownedReferenceSuffix()»;
				} else {
					// associated instances have been loaded, and possibly changed
					«it.getCollectionInterfaceType()»<«getJavaType("IDTYPE")»> result = new «it.getCollectionImplType()»<«getJavaType("IDTYPE")»>();
					for («it.getTypeName()» each : «name») {
						if (each.getId() == null) {
							throw new IllegalStateException("Reference «from.name».«name» contains unsaved instance. Cascade not supported. Save «to.name» before saving «from.name».");
						}
						result.add(each.getId());
					}
					«name»«it.unownedReferenceSuffix()» = result;
					return java.util.Collections.unmodifiable«getCollectionType().toFirstUpper()»(result);
				}
			«ELSE»
				return «name»«it.unownedReferenceSuffix()»;
			«ENDIF»

		};
	'''
}

def String manyReferenceAccessors(Reference it) {
	'''
	«IF it.isUnownedReference()»
		«manyReferenceIdsGetter(it)»
		«IF mongoDb()»
			«manyReferenceMongoDbLazyGetter(it)»
			«additionalManyReferenceAccessors(it)»
		«ENDIF»
	«ELSE»
	    «manyReferenceGetter(it, true)»
	    «manyReferenceSetter(it)»
	    «additionalManyReferenceAccessors(it)»
		«ENDIF»
	'''
}


def String additionalManyReferenceAccessors(Reference it) {
	'''
	«IF opposite != null && !opposite.many && (opposite.changeable || (notChangeableReferenceSetterVisibility() != "private"))»«bidirectionalReferenceAccessors(it)»«ENDIF »
	«IF opposite != null && opposite.many »«many2manyBidirectionalReferenceAccessors(it)»«ENDIF »
	«IF opposite == null»«unidirectionalReferenceAccessors(it)»«ENDIF»
	'''
}

def String manyReferenceGetter(Reference it) {
	'''
	«manyReferenceGetter(it, true)»
	'''
}

def String manyReferenceGetter(Reference it, boolean annotations) {
	'''
		«it.formatJavaDoc()»
		«IF annotations»
		«domainObjectReferenceAnnotationTmpl.manyReferenceGetterAnnotations(it)»
		«ENDIF»
		«it.getVisibilityLitteralGetter()»«it.getCollectionInterfaceType()»<«it.getTypeName()»> get«name.toFirstUpper()»() {
			return «name»;
		};
	'''
}

def String manyReferenceSetter(Reference it) {
	'''
	«IF !isJpaAnnotationToBeGenerated()»
		@SuppressWarnings("unused")
		private void set«name.toFirstUpper()»(«it.getCollectionInterfaceType()»<«it.getTypeName()»> «name») {
			this.«name» = «name»;
		}
		«ENDIF»
	'''
}

def String manyReferenceMongoDbLazyGetter(Reference it) {
	'''
		«it.formatJavaDoc()»
		«it.getVisibilityLitteralGetter()»«it.getCollectionInterfaceType()»<«it.getTypeName()»> get«name.toFirstUpper()»() {
			if («name» != null) {
				return «name»;
			}
			«it.getCollectionInterfaceType()»<«it.getTypeName()»> result = new «it.getCollectionImplType()»<«it.getTypeName()»>();
			java.util.List<org.bson.types.ObjectId> ids = new java.util.ArrayList<org.bson.types.ObjectId>();
			for («getJavaType("IDTYPE")» each : «name»«it.unownedReferenceSuffix()») {
				ids.add(org.bson.types.ObjectId.massageToObjectId(each));
			}
			String dbCollectionName = «to.module.getMapperPackage()».«to.name»Mapper.getInstance().getDBCollectionName();
			«fw("accessimpl.mongodb.DbManager")» dbManager = «fw("accessimpl.mongodb.DbManager")».getThreadInstance();
			if (dbManager == null) {
				throw new IllegalStateException("Lazy loading of «from.name».«name» failed due to missing DbManager.getThreadInstance()");
			}
			com.mongodb.DBCollection dbCollection = dbManager.getDBCollection(dbCollectionName);
			com.mongodb.DBCursor cur = dbCollection.find(new com.mongodb.BasicDBObject("_id", new com.mongodb.BasicDBObject("$in", ids)));
			while (cur.hasNext()) {
				com.mongodb.DBObject each = cur.next();
				result.add(«to.module.getMapperPackage()».«to.name»Mapper.getInstance().toDomain(each));
			}

			«name» = result;
			return result;
		};

		«it.getVisibilityLitteralGetter()» boolean is«name.toFirstUpper()»Loaded() {
			return «name» != null;
		}
	'''
}

def String bidirectionalReferenceAccessors(Reference it) {
	'''
		«bidirectionalReferenceAdd(it)»
		«bidirectionalReferenceRemove(it)»
	«bidirectionalReferenceRemoveAll(it)»
	'''
}

def String bidirectionalReferenceAdd(Reference it) {
	'''
	«IF !it.isSetterPrivate()»
		/**
			* Adds an object to the bidirectional many-to-one
			* association in both ends.
			* It is added the collection {@link #get«name.toFirstUpper()»}
			* at this side and the association
			* {@link «it.getTypeName()»#set«opposite.name.toFirstUpper()»}
			* at the opposite side is set.
			*/
		«it.getVisibilityLitteralSetter()»void add«name.toFirstUpper().singular()»(«it.getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().add(«name.singular()»Element);
			«name.singular()»Element.set«opposite.name.toFirstUpper()»((«opposite.getTypeName()») this);
		};
		«ENDIF»
	'''
}

def String bidirectionalReferenceRemove(Reference it) {
	'''
	«IF !it.isSetterPrivate()»
		/*
		 * EclipseLink/DataNucleus are trying to update the related entities.
		 * This fails on non nullable references
		 */
		«val clearOpposite = (opposite.nullable || !(isJpaProviderOpenJpa() || isJpaProviderEclipseLink() || isJpaProviderDataNucleus()))»
		/**
			* Removes an object from the bidirectional many-to-one
			* association«IF clearOpposite» in both ends.
			* It is removed from the collection {@link #get«name.toFirstUpper()»}
			* at this side and the association
			* {@link «it.getTypeName()»#set«opposite.name.toFirstUpper()»}
			* at the opposite side is cleared (nulled).«ENDIF»
			*/
		«it.getVisibilityLitteralSetter()»void remove«name.toFirstUpper().singular()»(«it.getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().remove(«name.singular()»Element);

			«IF clearOpposite»
			«name.singular()»Element.set«opposite.name.toFirstUpper()»(null);
		«ENDIF»
		};
	«ENDIF»
	'''
}

def String bidirectionalReferenceRemoveAll(Reference it) {
	'''
	«IF !it.isSetterPrivate()»
		/*
		 * EclipseLink/DataNucleus are trying to update the related entities.
		 * This fails on non nullable references
		 */
		«val clearOpposite = (opposite.nullable || !(isJpaProviderOpenJpa() || isJpaProviderEclipseLink() || isJpaProviderDataNucleus()))»
		/**
			* Removes all object from the bidirectional
			* many-to-one association«IF clearOpposite» in both ends.
			* All elements are removed from the collection {@link #get«name.toFirstUpper()»}
			* at this side and the association
			* {@link «it.getTypeName()»#set«opposite.name.toFirstUpper()»}
			* at the opposite side is cleared (nulled).«ENDIF»
			*/
		«it.getVisibilityLitteralSetter()»void removeAll«name.toFirstUpper()»() {
			«IF clearOpposite»
				for («it.getTypeName()» d : get«name.toFirstUpper()»()) {
					d.set«opposite.name.toFirstUpper()»(null);
				}
			«ENDIF»
			get«name.toFirstUpper()»().clear();
		};
	«ENDIF»
	'''
}

def String unidirectionalReferenceAccessors(Reference it) {
	'''
		«unidirectionalReferenceAdd(it)»
		«unidirectionalReferenceRemove(it)»
	«unidirectionalReferenceRemoveAll(it)»
	'''
}

def String unidirectionalReferenceAdd(Reference it) {
	'''
	«IF !it.isSetterPrivate()»
		/**
			* Adds an object to the unidirectional to-many
			* association.
			* It is added the collection {@link #get«name.toFirstUpper()»}.
			*/
		«it.getVisibilityLitteralSetter()»void add«name.toFirstUpper().singular()»(«it.getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().add(«name.singular()»Element);
		};
		«ENDIF»
	'''
}

def String unidirectionalReferenceRemove(Reference it) {
	'''
	«IF !it.isSetterPrivate()»
		/**
			* Removes an object from the unidirectional to-many
			* association.
			* It is removed from the collection {@link #get«name.toFirstUpper()»}.
			*/
		«it.getVisibilityLitteralSetter()»void remove«name.toFirstUpper().singular()»(«it.getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().remove(«name.singular()»Element);
		};
		«ENDIF»
	'''
}

def String unidirectionalReferenceRemoveAll(Reference it) {
	'''
	«IF !it.isSetterPrivate()»
		/**
			* Removes all object from the unidirectional
			* to-many association.
			* All elements are removed from the collection {@link #get«name.toFirstUpper()»}.
			*/
		«it.getVisibilityLitteralSetter()»void removeAll«name.toFirstUpper()»() {
			get«name.toFirstUpper()»().clear();
		};
		«ENDIF»
	'''
}


def String many2manyBidirectionalReferenceAccessors(Reference it) {
	'''
		«many2manyBidirectionalReferenceAdd(it)»
		«many2manyBidirectionalReferenceRemove(it)»
		«many2manyBidirectionalReferenceRemoveAll(it)»
	'''
}

def String many2manyBidirectionalReferenceAdd(Reference it) {
	'''
	«IF !it.isSetterPrivate()»
		/**
		 * Adds an object to the bidirectional many-to-many
		 * association in both ends.
		 * It is added the collection {@link #get«name.toFirstUpper()»}
		 * at this side and to the collection
		 * {@link «it.getTypeName()»#get«opposite.name.toFirstUpper()»}
		 * at the opposite side.
		 */
		«it.getVisibilityLitteralSetter()»void add«name.toFirstUpper().singular()»(«it.getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().add(«name.singular()»Element);
			«name.singular()»Element.get«opposite.name.toFirstUpper()»().add((«opposite.getTypeName()») this);
		};
		«ENDIF»
	'''
}

def String many2manyBidirectionalReferenceRemove(Reference it) {
	'''
	«IF !it.isSetterPrivate()»
		/**
			* Removes an object from the bidirectional many-to-many
			* association in both ends.
			* It is removed from the collection {@link #get«name.toFirstUpper()»}
			* at this side and from the collection
			* {@link «it.getTypeName()»#get«opposite.name.toFirstUpper()»}
			* at the opposite side.
			*/
		«it.getVisibilityLitteralSetter()»void remove«name.toFirstUpper().singular()»(«it.getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().remove(«name.singular()»Element);
			«name.singular()»Element.get«opposite.name.toFirstUpper()»().remove((«opposite.getTypeName()») this);
		};
		«ENDIF»
	'''
}

def String many2manyBidirectionalReferenceRemoveAll(Reference it) {
	'''
	«IF !it.isSetterPrivate()»
		/**
			* Removes all object from the bidirectional
			* many-to-many association in both ends.
			* All elements are removed from the collection {@link #get«name.toFirstUpper()»}
			* at this side and from the collection
			* {@link «it.getTypeName()»#get«opposite.name.toFirstUpper()»}
			* at the opposite side.
			*/
		«it.getVisibilityLitteralSetter()»void removeAll«name.toFirstUpper()»() {
			for («it.getTypeName()» d : get«name.toFirstUpper()»()) {
				d.get«opposite.name.toFirstUpper()»().remove((«opposite.getTypeName()») this);
			}
			get«name.toFirstUpper()»().clear();

		};
		«ENDIF»
	'''
}


}
