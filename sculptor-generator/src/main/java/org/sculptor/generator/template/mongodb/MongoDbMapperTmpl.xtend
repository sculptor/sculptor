/*
 * Copyright 2010 The Fornax Project Team, including the original
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

package org.sculptor.generator.template.mongodb

import sculptormetamodel.Attribute
import sculptormetamodel.BasicType
import sculptormetamodel.DomainObject
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference

import static org.sculptor.generator.ext.Properties.*
import static org.sculptor.generator.template.mongodb.MongoDbMapperTmpl.*
import static org.sculptor.generator.util.PropertiesBase.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*

class MongoDbMapperTmpl {

def static String mongoDbMapper(DomainObject it) {
	'''
	«IF it.hasHint("gapMapper")»
 	   «mongoDbMapperSubclass(it)»
		«ENDIF»
		«mongoDbMapperBase(it)»
	'''
}

def static String mongoDbMapperSubclass(DomainObject it) {
	fileOutput(javaFileName(getMapperPackage(module) + "." + name + "Mapper"), 'TO_SRC', '''
	«javaHeader()»
	package «getMapperPackage(module)»;

	public class «name»Mapper ^extends «name»MapperBase {
	«getInstance(it)»
	«constructor(it)»
	«gapToDomain(it)»
	«gapToData(it)»
	}
	'''
	)
}

def static String mongoDbMapperBase(DomainObject it) {
	fileOutput(javaFileName(getMapperPackage(module) + "." + name + "Mapper" + (if (it.hasHint("gapMapper")) "Base" else "")), '''
	«javaHeader()»
	package «getMapperPackage(module)»;

	public «IF it.hasHint("gapMapper")»abstract «ENDIF»class «name»Mapper«IF it.hasHint("gapMapper")»Base«ENDIF» implements «fw("accessimpl.mongodb.DataMapper")»<«getRootExtends(it).getDomainPackage()».«getRootExtends(it).name», com.mongodb.DBObject> {

	«IF ^extends != null»
		«discriminator(it)»
	«ENDIF»
		
		«IF !it.hasHint("gapMapper")»
			«getInstance(it)»
		«ENDIF»
		
		«constructorBase(it)»
		
		«canMapToData(it)»
		«getDBCollectionName(it)»
		
		«IF it.^abstract || hasSubClass(it)»
			«registerSubclassMappers(it)»
			«abstractToDomain(it)»
			«abstractToData(it)»
		«ELSE»
		«toDomain(it)»
		«toData(it)»
		«ENDIF»
		
		«indexes(it)»
		
	}
	'''
	)
}

def static String constructor(DomainObject it) {
	'''
	protected «name»Mapper() {
		}
	'''
}

def static String constructorBase(DomainObject it) {
	'''
	protected «name»Mapper«IF it.hasHint("gapMapper")»Base«ENDIF»() {
		«IF it.^abstract || it.hasSubClass()»
			registerSubclassMappers();
		«ENDIF»
		}
	'''
}

def static String getInstance(DomainObject it) {
	'''
		private static final «name»Mapper instance = new «name»Mapper();
		
		public static «name»Mapper getInstance() {
			return instance;
		}
		
	'''
}

def static String discriminator(DomainObject it) {
	'''
		public static final String «it.getRootExtends().inheritance.discriminatorColumnName()» = «IF discriminatorColumnValue == null»«getDomainPackage()».«name».class.getSimpleName()«ELSE»"«discriminatorColumnValue»"«ENDIF»;
	'''
}

def static String registerSubclassMappers(DomainObject it) {
	'''
		private final java.util.Map<Class<?>, «fw("accessimpl.mongodb.DataMapper")»<«getDomainPackage()».«name», com.mongodb.DBObject>> subclassMapperByClass = new java.util.concurrent.ConcurrentHashMap<Class<?>, «fw("accessimpl.mongodb.DataMapper")»<«getDomainPackage()».«name», com.mongodb.DBObject>>();
		private final java.util.Map<String, «fw("accessimpl.mongodb.DataMapper")»<«getDomainPackage()».«name», com.mongodb.DBObject>> subclassMapperByDtype = new java.util.concurrent.ConcurrentHashMap<String, «fw("accessimpl.mongodb.DataMapper")»<«getDomainPackage()».«name», com.mongodb.DBObject>>();
		
		protected void registerSubclassMappers() {
			«FOR sub : it.getAllSubclasses()»
			registerSubclassMapper(
				«sub.getDomainPackage()».«sub.name».class,
				«sub.module.getMapperPackage()».«sub.name»Mapper.«it.getRootExtends().inheritance.discriminatorColumnName()»,
				«sub.module.getMapperPackage()».«sub.name»Mapper.getInstance());
			«ENDFOR»
		}
		
		protected void registerSubclassMapper(Class<?> domainType, String dtype, «fw("accessimpl.mongodb.DataMapper")»<«getDomainPackage()».«name», com.mongodb.DBObject> mapper) {
			subclassMapperByClass.put(domainType, mapper);
			subclassMapperByDtype.put(dtype, mapper);
		}
	'''
}

def static String delegateToDomainToSubclassMapper(DomainObject it) {
	'''
	String dtype;
	if (from.containsField("«it.getRootExtends().inheritance.discriminatorColumnName()»")) {
			dtype = (String) from.get("«it.getRootExtends().inheritance.discriminatorColumnName()»");
		} else {
			dtype = "unknown";
		}
		
		«fw("accessimpl.mongodb.DataMapper")»<? ^extends «getDomainPackage()».«name», DBObject> subclassMapper = subclassMapperByDtype.get(dtype);
		if (subclassMapper == null) {
			throw new IllegalArgumentException("Unsupported domain object («it.getRootExtends().inheritance.discriminatorColumnName()»): " + dtype);
		}
		return subclassMapper.toDomain(from);
	'''
}

def static String delegateToDataToSubclassMapper(DomainObject it) {
	'''
			«fw("accessimpl.mongodb.DataMapper")»<«getDomainPackage()».«name», com.mongodb.DBObject> subclassMapper = subclassMapperByClass.get(from.getClass());
			if (subclassMapper == null) {
				throw new IllegalArgumentException("Unsupported domain object: " + from.getClass().getName());
			}

			return subclassMapper.toData(from);
	'''
}

def static String fromNullCheck(DomainObject it) {
	'''
		if (from == null) {
			return null;
		}
	'''
}

def static String abstractToDomain(DomainObject it) {
	'''
		@Override
	public «it.getRootExtends().getDomainPackage()».«it.getRootExtends().name» toDomain(com.mongodb.DBObject from) {
		«fromNullCheck(it)»
		«delegateToDomainToSubclassMapper(it)»
	}
	'''
}

def static String gapToDomain(DomainObject it) {
	'''
		@Override
	public «it.getRootExtends().getDomainPackage()».«it.getRootExtends().name» toDomain(com.mongodb.DBObject from) {
	    return super.toDomain(from);
	}
	'''
}
def static String toDomain(DomainObject it) {
	val constructorParameters = it.getConstructorParameters()
	val nonEnumReferenceConstructorParameters = it.getConstructorParameters().filter[e | e.^class == typeof(Reference) && !(e.isEnumReference())].map[e | (e as Reference)]
	val allNonEnumNonConstructorReferences = it.getAllReferences().filter[e | !(e.isEnumReference() || constructorParameters.contains(e))]

	'''
	@Override
	public «it.getRootExtends().getDomainPackage()».«it.getRootExtends().name» toDomain(com.mongodb.DBObject from) {
		«fromNullCheck(it)»
	
		«FOR p : it.constructorParameters.filter[e | e.^class == typeof(Attribute)].map[e | (e as Attribute)]»
			«IF p.isJodaTemporal() »
				«p.getTypeName()» «p.name» = «fw("accessimpl.mongodb." + (if (p.type == "Date") "JodaLocalDate" else "JodaDateTime")  + "Mapper")».getInstance().toDomain(from.get("«p.getDatabaseName()»"));
			«ELSE »
				«p.getTypeName()» «p.name» = («p.getTypeName().getObjectTypeName()») from.get("«p.getDatabaseName()»");
			«ENDIF»
		«ENDFOR»
		«FOR p  : constructorParameters.filter(e | e.isEnumReference()).map[e | (e as Reference)]»
			«p.getTypeName()» «p.name» = (from.get("«p.getDatabaseName()»") == null ? null : «p.getTypeName()».valueOf((String) from.get("«p.getDatabaseName()»")));
		«ENDFOR»

		// Single reference in constructor param, persistent, and should be included in aggregate
		«FOR p : nonEnumReferenceConstructorParameters .filter(e | !e.many && e.to.isPersistent() && e.opposite == null && (e.isBasicTypeReference() || !e.isUnownedReference()))»
			«p.getTypeName()» «p.name» = null;
			if (from.containsField("«p.getDatabaseName()»")) {
				«p.name» = 
				«p.to.module.getMapperPackage()».«p.to.name»Mapper.getInstance().toDomain(
					(com.mongodb.DBObject) from.get("«p.getDatabaseName()»"));
			}
		«ENDFOR»
		
		// Single reference in constructor param, not in same aggregate root (unowned reference)
		«FOR p : nonEnumReferenceConstructorParameters.filter(e | !e.many && e.isUnownedReference())»
			«getJavaType("IDTYPE")» «p.name» = null;
			if (from.containsField("«p.getDatabaseName()»")) {
				«p.name» = («getJavaType("IDTYPE")») from.get("«p.getDatabaseName()»");
			}
		«ENDFOR»
		// TODO many references in constructor
		
		«getDomainPackage()».«name» result = new «getDomainPackage()».«name»(
			«FOR p : constructorParameters SEPARATOR ", "»«p.name»«ENDFOR»);
		«IF it.metaType != typeof(BasicType)»
			if (from.containsField("_id")) {
				org.bson.types.ObjectId objectId = (org.bson.types.ObjectId) from.get("_id");
				String idString = objectId.toStringMongod();
				«fw("accessimpl.mongodb.IdReflectionUtil")».internalSetId(result, idString);
			}
		«ENDIF»
		«val uuid = it.getAllAttributes().findFirst(e|e.isUuid())»
		«IF uuid != null»
			if (from.containsField("«uuid.getDatabaseName()»")) {
				«fw("accessimpl.mongodb.IdReflectionUtil")».internalSetUuid(result, (String) from.get("«uuid.getDatabaseName()»"));
			}
		«ENDIF»
		«FOR att : it.getAllAttributes().filter[e | !(e.isUuid() || e.name == "id" || constructorParameters.contains(e))]»
			if (from.containsField("«att.getDatabaseName()»")) {
				«IF att.collectionType != null »
					result.set«att.name.toFirstUpper()»(new «att.getImplTypeName()»((java.util.Collection) from.get("«att.getDatabaseName()»")));
				«ELSEIF att.isJodaTemporal() »
					result.set«att.name.toFirstUpper()»(«fw("accessimpl.mongodb." + (if (att.type == "Date") "JodaLocalDate" else "JodaDateTime")  + "Mapper")».getInstance().toDomain(from.get("«att.getDatabaseName()»")));
				«ELSE »
					result.set«att.name.toFirstUpper()»((«att.getTypeName().getObjectTypeName()») from.get("«att.getDatabaseName()»"));
				«ENDIF»
			}
		«ENDFOR»

		«FOR enumRef : it.getAllEnumReferences().filter[e | !(constructorParameters.contains(e))]»
			if (from.containsField("«enumRef.getDatabaseName()»")) {
				result.set«enumRef.name.toFirstUpper()»((from.get("«enumRef.getDatabaseName()»") == null ? null : «enumRef.getTypeName()».valueOf((String) from.get("«enumRef.getDatabaseName()»"))));
			}
		«ENDFOR»

		// Single reference not in constructor param, persistent, and should be included in aggregate
		«FOR ref : allNonEnumNonConstructorReferences .filter(e | !e.many && e.to.isPersistent() && e.opposite == null && (e.isBasicTypeReference() || !e.isUnownedReference()))»
			if (from.containsField("«ref.getDatabaseName()»")) {
				result.set«ref.name.toFirstUpper()»(
				«ref.to.module.getMapperPackage()».«ref.to.name»Mapper.getInstance().toDomain(
					(com.mongodb.DBObject) from.get("«ref.getDatabaseName()»")));
			}
		«ENDFOR»

		// Multiple reference not in constructor param, persistent, and should be included in aggregate
		«FOR ref : allNonEnumNonConstructorReferences .filter(e | e.many && e.to.isPersistent() && (e.isBasicTypeReference() || !e.isUnownedReference()))»
			if (from.containsField("«ref.getDatabaseName()»")) {
				@SuppressWarnings("unchecked")
				java.util.Collection<com.mongodb.DBObject> «ref.name»Data = (java.util.Collection<com.mongodb.DBObject>) from.get("«ref.getDatabaseName()»");
				for (com.mongodb.DBObject each : «ref.name»Data) {
					result.add«ref.name.toFirstUpper().singular()»(«ref.to.module.getMapperPackage()».«ref.to.name»Mapper.getInstance().toDomain(each));
				}
			}
		«ENDFOR»

		// Single reference not in constructor param, not in same aggregate root (unowned reference)
		«FOR ref : allNonEnumNonConstructorReferences .filter(e | !e.many && e.isUnownedReference())»
			if (from.containsField("«ref.getDatabaseName()»")) {
				result.set«ref.name.toFirstUpper()»Id((«getJavaType("IDTYPE")») from.get("«ref.getDatabaseName()»"));
			}
		«ENDFOR»

		// Multiple reference not in constructor param, not in same aggregate root (unowned reference)
		«FOR ref : allNonEnumNonConstructorReferences .filter(e | e.many && e.isUnownedReference())»
			if (from.containsField("«ref.getDatabaseName()»")) {
				@SuppressWarnings("unchecked")
				java.util.Collection<«getJavaType("IDTYPE")»> «ref.name»Data = (java.util.Collection<«getJavaType("IDTYPE")»>) from.get("«ref.getDatabaseName()»");
				for («getJavaType("IDTYPE")» each : «ref.name»Data) {
					result.get«ref.name.toFirstUpper()»Ids().add(each);
				}
			}
		«ENDFOR»

		return result;
	}
	'''
}

def static String getDBCollectionName(DomainObject it) {
	'''
		@Override
		public String getDBCollectionName() {
			return "«it.getRootExtends().getDatabaseName()»";
		}
	'''
}

def static String getDBCollectionName(BasicType it) {
	'''
		@Override
		public String getDBCollectionName() {
			throw new IllegalStateException("BasicType «name» is not stored in own DBCollection");
		}
	'''
}

def static String canMapToData(DomainObject it) {
	'''
		@Override
	public boolean canMapToData(Class<?> domainObjectClass) {
	    if (domainObjectClass == null) {
	    	return true;
	    }
		return «getDomainPackage()».«name».class.isAssignableFrom(domainObjectClass);
	}
	'''
}


def static String abstractToData(DomainObject it) {
	'''
		@Override
	public com.mongodb.DBObject toData(«it.getRootExtends().getDomainPackage()».«it.getRootExtends().name» from) {
		«fromNullCheck(it)»
		«delegateToDataToSubclassMapper(it)»
	}
	'''
}	

def static String gapToData(DomainObject it) {
	'''
		@Override
	public com.mongodb.DBObject toData(«it.getRootExtends().getDomainPackage()».«it.getRootExtends().name» from) {
		return super.toData(from);
	}
	'''
}

def static String toData(DomainObject it) {
	val allNonEnumNonTransientReferences = it.getAllReferences().filter[e | !(e.isEnumReference() || e.transient)]

	'''
	@Override
	public com.mongodb.DBObject toData(«it.getRootExtends().getDomainPackage()».«it.getRootExtends().name» «IF it.^extends == null»from«ELSE»inFrom«ENDIF») {
		«IF ^extends != null»
			«getDomainPackage()».«name» from = («getDomainPackage()».«name») inFrom;
		«ENDIF»
		«fromNullCheck(it)»

		com.mongodb.DBObject result = new com.mongodb.BasicDBObject();
		«IF it.metaType != typeof(BasicType)»
			if (from.getId() != null) {
				org.bson.types.ObjectId objectId = org.bson.types.ObjectId.massageToObjectId(from.getId());
				result.put("_id", objectId);
			}
		«ENDIF»

		«IF it.^extends != null»
			result.put("«it.getRootExtends().inheritance.discriminatorColumnName()»", «it.getRootExtends().inheritance.discriminatorColumnName()»);
		«ENDIF»

		«FOR att : it.getAllAttributes().filter[e | !(e.name == "id" || e.transient)]»
			«IF att.collectionType != null»
				result.put("«att.getDatabaseName()»", new java.util.ArrayList<Object>(from.«att.getGetAccessor()»()));
			«ELSEIF att.isJodaTemporal()»
				result.put("«att.getDatabaseName()»", «fw("accessimpl.mongodb." + (if (att.type == "Date") "JodaLocalDate" else "JodaDateTime")  + "Mapper")».getInstance().toData(from.«att.getGetAccessor()»()));
			«ELSE»
				result.put("«att.getDatabaseName()»", from.«att.getGetAccessor()»());
			«ENDIF»
		«ENDFOR»

		«FOR enumRef : it.getAllEnumReferences().filter[e | !e.transient]»
			result.put("«enumRef.getDatabaseName()»", from.«enumRef.getGetAccessor()»() == null ? null : from.«enumRef.getGetAccessor()»().name());
		«ENDFOR»

		«FOR ref : allNonEnumNonTransientReferences .filter(e | e.isBasicTypeReference() || (!e.many && e.bothEndsInSameAggregateRoot() && e.opposite == null))»
			result.put("«ref.getDatabaseName()»", 
				«ref.to.module.getMapperPackage()».«ref.to.name»Mapper.getInstance().toData(
					from.get«ref.name.toFirstUpper()»()));
		«ENDFOR»

		«FOR ref : allNonEnumNonTransientReferences .filter(e | !e.isBasicTypeReference() && e.many && e.bothEndsInSameAggregateRoot())»
			java.util.List<com.mongodb.DBObject> «ref.name»Data = new java.util.ArrayList<com.mongodb.DBObject>();
			for («ref.getTypeName()» each : from.get«ref.name.toFirstUpper()»()) {
				«ref.name»Data.add(«ref.to.module.getMapperPackage()».«ref.to.name»Mapper.getInstance().toData(each));
			}
			result.put("«ref.name»", «ref.name»Data);
		«ENDFOR»

		«FOR ref : allNonEnumNonTransientReferences .filter(e | !e.many && e.isUnownedReference())»
			result.put("«ref.getDatabaseName()»", from.get«ref.name.toFirstUpper()»Id()); 
		«ENDFOR»

		«FOR ref : allNonEnumNonTransientReferences .filter(e | e.many && e.isUnownedReference())»
			java.util.List<«getJavaType("IDTYPE")»> «ref.name»Data = new java.util.ArrayList<«getJavaType("IDTYPE")»>();
			for («getJavaType("IDTYPE")» each : from.get«ref.name.toFirstUpper()»Ids()) {
				«ref.name»Data.add(each);
			}
			result.put("«ref.getDatabaseName()»", «ref.name»Data);
		«ENDFOR»
		return result;
	}
	'''
}

def static String indexes(DomainObject it) {
	'''
		@Override
	public java.util.List<«fw("accessimpl.mongodb.IndexSpecification")»> indexes() {
	«IF isAggregateRoot()»
		java.util.List<«fw("accessimpl.mongodb.IndexSpecification")»> indexes = new java.util.ArrayList<«fw("accessimpl.mongodb.IndexSpecification")»>();
		«IF it.hasNaturalKey()»
			com.mongodb.DBObject naturalKey = new com.mongodb.BasicDBObject();
			«populateNaturalKeyIndex(it, "") »
			indexes.add(new «fw("accessimpl.mongodb.IndexSpecification")»("naturalKey", naturalKey, true));
		«ENDIF»
		«FOR att : it.getAllAttributes().filter(e | e.index)»
			indexes.add(new «fw("accessimpl.mongodb.IndexSpecification")»("«att.name»", new com.mongodb.BasicDBObject("«att.name»", 1), false));
		«ENDFOR»
		return indexes;
	«ELSE»
		return java.util.Collections.emptyList();
	«ENDIF»
	}
	'''
}

def static String populateNaturalKeyIndex(DomainObject it, String parent) {
	'''
		«it.getAllNaturalKeyAttributes() .forEach[putNaturalKeyIndex(it, parent)]»
		«it.getAllNaturalKeyReferences().filter(e|e.isEnumReference()) .forEach[putNaturalKeyIndex(it, parent)]»
		«it.getAllNaturalKeyReferences().filter(e|e.isUnownedReference()) .forEach[putNaturalKeyIndex(it, parent)]»
		«FOR e : it.getAllNaturalKeyReferences().filter[e | !(e.isEnumReference() || e.isUnownedReference() || e.to.isAggregateRoot())]»
			«populateNaturalKeyIndex(e.to, parent + e.getDatabaseName() + ".")»
		«ENDFOR»
	'''
}

def static String putNaturalKeyIndex(NamedElement it, String parent) {
	'''
		    naturalKey.put("«parent»«it.getDatabaseName()»", 1);
	'''
}
}
