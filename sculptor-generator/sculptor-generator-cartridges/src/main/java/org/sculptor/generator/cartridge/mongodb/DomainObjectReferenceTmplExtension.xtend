/*
 * Copyright 2014 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.cartridge.mongodb

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.domain.DomainObjectReferenceTmpl
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Reference

@ChainOverride
class DomainObjectReferenceTmplExtension extends DomainObjectReferenceTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension MongoDbProperties mongoDbProperties
	@Inject extension Properties properties

	override String oneReferenceAttributeUnownedReference(Reference it) {
		'''
			«next.oneReferenceAttributeUnownedReference(it)»
			«IF mongoDb»
				«oneReferenceLazyAttribute(it)»
			«ENDIF»
		'''
	}

	override String oneUnownedReferenceGetter(Reference it) {
		'''
			«next.oneUnownedReferenceGetter(it)»
			«IF mongoDb»
				«oneReferenceMongoDbLazyGetter(it)»
			«ENDIF»
		'''
	}

	private def String oneReferenceMongoDbLazyGetter(Reference it) {
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

	override String oneUnownedReferenceSetter(Reference it) {
		'''
			«next.oneUnownedReferenceSetter(it)»
			«IF mongoDb()»
				«oneReferenceMongoDbLazySetter(it)»
			«ENDIF»
		'''
	}

	private def String oneReferenceMongoDbLazySetter(Reference it) {
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

	override String oneReferenceIdGetterBody(Reference it) {
		'''
			«IF mongoDb»
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
				«next.oneReferenceIdGetterBody(it)»
			«ENDIF»
		'''
	}

	override String oneReferenceIdSetterBody(Reference it) {
		'''
			«next.oneReferenceIdSetterBody(it)»
			«IF mongoDb »
				«name»IsLoaded = false;
				«name» = null;
			«ENDIF »
		'''
	}

	override String manyUnownedReferenceAttribute(Reference it) {
		'''
			«next.manyUnownedReferenceAttribute(it)»
			«IF mongoDb»
				«manyReferenceLazyAttribute(it)»
			«ENDIF»
		'''
	}

	override String manyReferenceIdsGetterBody(Reference it) {
		'''
			«IF mongoDb»
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
				«next.manyReferenceIdsGetterBody(it)»
			«ENDIF»
		'''
	}

	override String manyReferenceAccessorsUnownedReference(Reference it) {
		'''
			«next.manyReferenceAccessorsUnownedReference(it)»
			«IF mongoDb»
				«manyReferenceMongoDbLazyGetter(it)»
				«additionalManyReferenceAccessors(it)»
			«ENDIF»
		'''
	}

	private def String manyReferenceMongoDbLazyGetter(Reference it) {
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

}
