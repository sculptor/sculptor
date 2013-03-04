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

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class DomainObjectReferenceTmpl {

def static String oneReferenceAttribute(Reference it) {
	'''
	«IF isUnownedReference()»
		«oneReferenceIdAttribute(it)»
		«IF mongoDb()»
			«oneReferenceLazyAttribute(it)»
		«ENDIF»
	«ELSE»
		«oneReferenceAttribute(it)(true)»
	«ENDIF»
	'''
}

def static String oneReferenceAttribute(Reference it, boolean annotations) {
	'''
		«IF annotations»
			«DomainObjectReferenceAnnotationTmpl::oneReferenceAttributeAnnotations(it)»
		«ENDIF»
		private «IF transient»transient «ENDIF»«getTypeName()» «name»«oneReferenceAttributeDefaultValue(it)»;
	'''
}

/*Possibility to overwrite and set custom default initialization for some attributes,
	e.g. using hint. Note that you must include =.
 */
def static String oneReferenceAttributeDefaultValue(Reference it) {
	'''
	'''
}

def static String oneReferenceIdAttribute(Reference it) {
	'''
		«IF isJpaProviderAppEngine() && isJpaAnnotationOnFieldToBeGenerated()»
		«DomainObjectReferenceAnnotationTmpl::oneReferenceAppEngineKeyAnnotation(it)»
		«ENDIF»
		private «getJavaType("IDTYPE")» «name»«unownedReferenceSuffix()»;
	'''
}

def static String oneReferenceLazyAttribute(Reference it) {
	'''
	private boolean «name»IsLoaded = false;
		private «getTypeName()» «name»;
	'''
}

def static String oneReferenceAccessors(Reference it) {
	'''
	«IF isUnownedReference()»
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

def static String oneReferenceGetter(Reference it) {
	'''
	«oneReferenceGetter(it)(true)»
	'''
}

def static String oneReferenceGetter(Reference it, boolean annotations) {
	'''
		«formatJavaDoc()»
		«IF annotations»
			«DomainObjectReferenceAnnotationTmpl::oneReferenceGetterAnnotations(it)»
		«ENDIF»
		«getVisibilityLitteralGetter()»«getTypeName()» get«name.toFirstUpper()»() {
			return «name»;
		};
	'''
}

def static String oneReferenceIdGetter(Reference it) {
	'''
		«formatJavaDoc()»
		«IF isJpaProviderAppEngine() && !isJpaAnnotationOnFieldToBeGenerated()»
		«DomainObjectReferenceAnnotationTmpl::oneReferenceAppEngineKeyAnnotation(it)»
		«ENDIF»
		«getVisibilityLitteralGetter()»«getJavaType("IDTYPE")» get«name.toFirstUpper()»«unownedReferenceSuffix()»() {
			«IF mongoDb()»
			if (!«name»IsLoaded) {
				return «name»«unownedReferenceSuffix()»;
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
			return «name»«unownedReferenceSuffix()»;
			«ENDIF»
		};
	'''
}

def static String oneReferenceMongoDbLazyGetter(Reference it) {
	'''
		«formatJavaDoc()»
		«getVisibilityLitteralGetter()»«getTypeName()» get«name.toFirstUpper()»() {
			if («name»IsLoaded) {
				return «name»;
			}
			if («name»«unownedReferenceSuffix()» == null) {
				«name»IsLoaded = true;
				return null;
			}
			«fw("accessimpl.mongodb.DbManager")» dbManager = «fw("accessimpl.mongodb.DbManager")».getThreadInstance();
			if (dbManager == null) {
				throw new IllegalStateException("Lazy loading of «from.name».«name» failed due to missing DbManager.getThreadInstance()");
			}
			String dbCollectionName = «to.module.getMapperPackage()».«to.name»Mapper.getInstance().getDBCollectionName();
			com.mongodb.DBRef dbRef = new com.mongodb.DBRef(dbManager.getDB(), dbCollectionName,
				org.bson.types.ObjectId.massageToObjectId(«name»«unownedReferenceSuffix()»));
			«name» = («getTypeName()»)«to.module.getMapperPackage()».«to.name»Mapper.getInstance().toDomain(dbRef.fetch());
			«name»IsLoaded = true;
			return «name»;
		};

		«getVisibilityLitteralGetter()» boolean is«name.toFirstUpper()»Loaded() {
			return «name»IsLoaded;
		}
	'''
}

def static String oneReferenceIdSetter(Reference it) {
	'''
	«IF isSetterNeeded()»
		«formatJavaDoc()»
		«getVisibilityLitteralSetter()»void set«name.toFirstUpper()»«unownedReferenceSuffix()»(«getJavaType("IDTYPE")» «name»«unownedReferenceSuffix()») {
			this.«name»«unownedReferenceSuffix()» = «name»«unownedReferenceSuffix()»;
			«IF mongoDb() »
				«name»IsLoaded = false;
				«name» = null;
			«ENDIF »
		};
		«ENDIF»
	'''
}

def static String oneReferenceMongoDbLazySetter(Reference it) {
	'''
	«IF isSetterNeeded()»
		«formatJavaDoc()»
		«getVisibilityLitteralSetter()»void set«name.toFirstUpper()»(«getTypeName()» «name») {
			this.«name» = «name»;
			«name»IsLoaded = true;
				this.«name»«unownedReferenceSuffix()» = («name» == null ? null : «name».getId());
		};
		«ENDIF»
	'''
}

def static String oneReferenceSetter(Reference it) {
	'''
	«IF isSetterNeeded()»
		«formatJavaDoc()»
		«DomainObjectReferenceAnnotationTmpl::oneReferenceSetterAnnotations(it)»
		«getVisibilityLitteralSetter()»void set«name.toFirstUpper()»(«getTypeName()» «name») {
			«IF isFullyAuditable() && !transient»
			receiveInternalAuditHandler().recordChange(«getDomainObject().name»Properties.«name»(), this.«name», «name»);
			«ENDIF»
			this.«name» = «name»;
		};
		«ENDIF»
	'''
}

def static String notChangeableOneReferenceSetter(Reference it) {
	'''
		«IF isSetterNeeded()»
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
		«DomainObjectReferenceAnnotationTmpl::oneReferenceSetterAnnotations(it)»
		«notChangeableReferenceSetterVisibility()» void set«name.toFirstUpper()»(«getTypeName()» «name») {
			// it must be possible to set null when deleting objects
			if ((«name» != null) && (this.«name» != null) && !this.«name».equals(«name»)) {
				throw new IllegalArgumentException("Not allowed to change the «name» reference.");
			}
			this.«name» = «name»;
		};
		«ENDIF»
	'''
}

def static String manyReferenceAttribute(Reference it) {
	'''
	«IF isUnownedReference()»
		«manyReferenceIdsAttribute(it)»
		«IF mongoDb()»
			«manyReferenceLazyAttribute(it)»
		«ENDIF»
	«ELSE»
		«manyReferenceAttribute(it)(true)»		
		«ENDIF»
	'''
}

def static String manyReferenceAttribute(Reference it, boolean annotations) {
	'''
	«IF annotations»
		«DomainObjectReferenceAnnotationTmpl::manyReferenceAttributeAnnotations(it)»
	«ENDIF»
	
	private «IF transient»transient «ENDIF»«getCollectionInterfaceType()»<«getTypeName()»> «name» = new «getCollectionImplType()»<«getTypeName()»>();

	'''
}


def static String manyReferenceIdsAttribute(Reference it) {
	'''
	«IF isJpaProviderAppEngine() && isJpaAnnotationOnFieldToBeGenerated()»
	    «DomainObjectReferenceAnnotationTmpl::manyReferenceAppEngineKeyAnnotation(it)»
	«ENDIF»
		private «getCollectionInterfaceType()»<«getJavaType("IDTYPE")»> «name»«unownedReferenceSuffix()» = new «getCollectionImplType()»<«getJavaType("IDTYPE")»>();
	'''
}

def static String manyReferenceLazyAttribute(Reference it) {
	'''
		private «getCollectionInterfaceType()»<«getTypeName()»> «name»;
	'''
}

def static String manyReferenceIdsGetter(Reference it) {
	'''
		«formatJavaDoc()»
	«IF isJpaProviderAppEngine() && !isJpaAnnotationOnFieldToBeGenerated()»
		    «DomainObjectReferenceAnnotationTmpl::manyReferenceAppEngineKeyAnnotation(it)»
	«ENDIF»
		«getVisibilityLitteralGetter()»«getCollectionInterfaceType()»<«getJavaType("IDTYPE")»> get«name.toFirstUpper()»«unownedReferenceSuffix()»() {
			// appengine sometimes stores the collection as null
			if («name»«unownedReferenceSuffix()» == null) {
			    «name»«unownedReferenceSuffix()» = new «getCollectionImplType()»<«getJavaType("IDTYPE")»>();
			}
			«IF mongoDb()»
				if («name» == null) {
					return «name»«unownedReferenceSuffix()»;
				} else {
					// associated instances have been loaded, and possibly changed
					«getCollectionInterfaceType()»<«getJavaType("IDTYPE")»> result = new «getCollectionImplType()»<«getJavaType("IDTYPE")»>();
					for («getTypeName()» each : «name») {
						if (each.getId() == null) {
		        		throw new IllegalStateException("Reference «from.name».«name» contains unsaved instance. Cascade not supported. Save «to.name» before saving «from.name».");
		        	}
						result.add(each.getId());
					}
					«name»«unownedReferenceSuffix()» = result;
					return java.util.Collections.unmodifiable«getCollectionType().toFirstUpper()»(result);
				}
			«ELSE»
				return «name»«unownedReferenceSuffix()»;
			«ENDIF»

		};
	'''
}

def static String manyReferenceAccessors(Reference it) {
	'''
	«IF isUnownedReference()»
		«manyReferenceIdsGetter(it)»
		«IF mongoDb()»
			«manyReferenceMongoDbLazyGetter(it)»
			«additionalManyReferenceAccessors(it)»
		«ENDIF»
	«ELSE»
	    «manyReferenceGetter(it)(true)»
	    «manyReferenceSetter(it)»
	    «additionalManyReferenceAccessors(it)»
		«ENDIF»
	'''
}


def static String additionalManyReferenceAccessors(Reference it) {
	'''
	«IF opposite != null && !opposite.many && (opposite.changeable || (notChangeableReferenceSetterVisibility() != "private"))»«bidirectionalReferenceAccessors(it)»«ENDIF »
	«IF opposite != null && opposite.many »«many2manyBidirectionalReferenceAccessors(it)»«ENDIF »
	«IF opposite == null»«unidirectionalReferenceAccessors(it)»«ENDIF»
	'''
}

def static String manyReferenceGetter(Reference it) {
	'''
	«manyReferenceGetter(it)(true)»
	'''
}

def static String manyReferenceGetter(Reference it, boolean annotations) {
	'''
		«formatJavaDoc()»
		«IF annotations»
		«DomainObjectReferenceAnnotationTmpl::manyReferenceGetterAnnotations(it)»
		«ENDIF»
		«getVisibilityLitteralGetter()»«getCollectionInterfaceType()»<«getTypeName()»> get«name.toFirstUpper()»() {
			return «name»;
		};
	'''
}

def static String manyReferenceSetter(Reference it) {
	'''
	«IF !isJpaAnnotationToBeGenerated()»
		@SuppressWarnings("unused")
		private void set«name.toFirstUpper()»(«getCollectionInterfaceType()»<«getTypeName()»> «name») {
			this.«name» = «name»;
		}
		«ENDIF»
	'''
}

def static String manyReferenceMongoDbLazyGetter(Reference it) {
	'''
		«formatJavaDoc()»
		«getVisibilityLitteralGetter()»«getCollectionInterfaceType()»<«getTypeName()»> get«name.toFirstUpper()»() {
			if («name» != null) {
				return «name»;
			}
			«getCollectionInterfaceType()»<«getTypeName()»> result = new «getCollectionImplType()»<«getTypeName()»>();
			java.util.List<org.bson.types.ObjectId> ids = new java.util.ArrayList<org.bson.types.ObjectId>();
			for («getJavaType("IDTYPE")» each : «name»«unownedReferenceSuffix()») {
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

		«getVisibilityLitteralGetter()» boolean is«name.toFirstUpper()»Loaded() {
			return «name» != null;
		}
	'''
}

def static String bidirectionalReferenceAccessors(Reference it) {
	'''
		«bidirectionalReferenceAdd(it)»
		«bidirectionalReferenceRemove(it)»
	«bidirectionalReferenceRemoveAll(it)»
	'''
}

def static String bidirectionalReferenceAdd(Reference it) {
	'''
	«IF !isSetterPrivate()»
		/**
			* Adds an object to the bidirectional many-to-one
			* association in both ends.
			* It is added the collection {@link #get«name.toFirstUpper()»}
			* at this side and the association
			* {@link «getTypeName()»#set«opposite.name.toFirstUpper()»}
			* at the opposite side is set.
			*/
		«getVisibilityLitteralSetter()»void add«name.toFirstUpper().singular()»(«getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().add(«name.singular()»Element);
			«name.singular()»Element.set«opposite.name.toFirstUpper()»((«opposite.getTypeName()») this);
		};
		«ENDIF»
	'''
}

def static String bidirectionalReferenceRemove(Reference it) {
	'''
	«IF !isSetterPrivate()»
	/*
	EclipseLink/DataNucleus are trying to update the related entities.
	This fails on non nullable references
	 */
	«val clearOpposite = it.(opposite.nullable || !(isJpaProviderOpenJpa() || isJpaProviderEclipseLink() || isJpaProviderDataNucleus()))»
		/**
			* Removes an object from the bidirectional many-to-one
			* association«IF clearOpposite» in both ends.
			* It is removed from the collection {@link #get«name.toFirstUpper()»}
			* at this side and the association
			* {@link «getTypeName()»#set«opposite.name.toFirstUpper()»}
			* at the opposite side is cleared (nulled).«ENDIF»
			*/
		«getVisibilityLitteralSetter()»void remove«name.toFirstUpper().singular()»(«getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().remove(«name.singular()»Element);

			«IF clearOpposite»
			«name.singular()»Element.set«opposite.name.toFirstUpper()»(null);
		«ENDIF»
		};
		«ENDIF»
	'''
}

def static String bidirectionalReferenceRemoveAll(Reference it) {
	'''
	«IF !isSetterPrivate()»
	/*
	EclipseLink/DataNucleus are trying to update the related entities.
	This fails on non nullable references
	 */
	«val clearOpposite = it.(opposite.nullable || !(isJpaProviderOpenJpa() || isJpaProviderEclipseLink() || isJpaProviderDataNucleus()))»
		/**
			* Removes all object from the bidirectional
			* many-to-one association«IF clearOpposite» in both ends.
			* All elements are removed from the collection {@link #get«name.toFirstUpper()»}
			* at this side and the association
			* {@link «getTypeName()»#set«opposite.name.toFirstUpper()»}
			* at the opposite side is cleared (nulled).«ENDIF»
			*/
		«getVisibilityLitteralSetter()»void removeAll«name.toFirstUpper()»() {
			«IF clearOpposite»
			for («getTypeName()» d : get«name.toFirstUpper()»()) {
				d.set«opposite.name.toFirstUpper()»(null);
			}
		«ENDIF»
			get«name.toFirstUpper()»().clear();

		};
		«ENDIF»
	'''
}

def static String unidirectionalReferenceAccessors(Reference it) {
	'''
		«unidirectionalReferenceAdd(it)»
		«unidirectionalReferenceRemove(it)»
	«unidirectionalReferenceRemoveAll(it)»
	'''
}

def static String unidirectionalReferenceAdd(Reference it) {
	'''
	«IF !isSetterPrivate()»
		/**
			* Adds an object to the unidirectional to-many
			* association.
			* It is added the collection {@link #get«name.toFirstUpper()»}.
			*/
		«getVisibilityLitteralSetter()»void add«name.toFirstUpper().singular()»(«getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().add(«name.singular()»Element);
		};
		«ENDIF»
	'''
}

def static String unidirectionalReferenceRemove(Reference it) {
	'''
	«IF !isSetterPrivate()»
		/**
			* Removes an object from the unidirectional to-many
			* association.
			* It is removed from the collection {@link #get«name.toFirstUpper()»}.
			*/
		«getVisibilityLitteralSetter()»void remove«name.toFirstUpper().singular()»(«getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().remove(«name.singular()»Element);
		};
		«ENDIF»
	'''
}

def static String unidirectionalReferenceRemoveAll(Reference it) {
	'''
	«IF !isSetterPrivate()»
		/**
			* Removes all object from the unidirectional
			* to-many association.
			* All elements are removed from the collection {@link #get«name.toFirstUpper()»}.
			*/
		«getVisibilityLitteralSetter()»void removeAll«name.toFirstUpper()»() {
			get«name.toFirstUpper()»().clear();
		};
		«ENDIF»
	'''
}


def static String many2manyBidirectionalReferenceAccessors(Reference it) {
	'''
		«many2manyBidirectionalReferenceAdd(it)»
		«many2manyBidirectionalReferenceRemove(it)»
		«many2manyBidirectionalReferenceRemoveAll(it)»
	'''
}

def static String many2manyBidirectionalReferenceAdd(Reference it) {
	'''
	«IF !isSetterPrivate()»
		/**
			* Adds an object to the bidirectional many-to-many
			* association in both ends.
			* It is added the collection {@link #get«name.toFirstUpper()»}
			* at this side and to the collection
			* {@link «getTypeName()»#get«opposite.name.toFirstUpper()»}
			* at the opposite side.
			*/
		«getVisibilityLitteralSetter()»void add«name.toFirstUpper().singular()»(«getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().add(«name.singular()»Element);
			«name.singular()»Element.get«opposite.name.toFirstUpper()»().add((«opposite.getTypeName()») this);
		};
		«ENDIF»
	'''
}

def static String many2manyBidirectionalReferenceRemove(Reference it) {
	'''
	«IF !isSetterPrivate()»
		/**
			* Removes an object from the bidirectional many-to-many
			* association in both ends.
			* It is removed from the collection {@link #get«name.toFirstUpper()»}
			* at this side and from the collection
			* {@link «getTypeName()»#get«opposite.name.toFirstUpper()»}
			* at the opposite side.
			*/
		«getVisibilityLitteralSetter()»void remove«name.toFirstUpper().singular()»(«getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().remove(«name.singular()»Element);
			«name.singular()»Element.get«opposite.name.toFirstUpper()»().remove((«opposite.getTypeName()») this);
		};
		«ENDIF»
	'''
}

def static String many2manyBidirectionalReferenceRemoveAll(Reference it) {
	'''
	«IF !isSetterPrivate()»
		/**
			* Removes all object from the bidirectional
			* many-to-many association in both ends.
			* All elements are removed from the collection {@link #get«name.toFirstUpper()»}
			* at this side and from the collection
			* {@link «getTypeName()»#get«opposite.name.toFirstUpper()»}
			* at the opposite side.
			*/
		«getVisibilityLitteralSetter()»void removeAll«name.toFirstUpper()»() {
			for («getTypeName()» d : get«name.toFirstUpper()»()) {
				d.get«opposite.name.toFirstUpper()»().remove((«opposite.getTypeName()») this);
			}
			get«name.toFirstUpper()»().clear();

		};
		«ENDIF»
	'''
}


}
