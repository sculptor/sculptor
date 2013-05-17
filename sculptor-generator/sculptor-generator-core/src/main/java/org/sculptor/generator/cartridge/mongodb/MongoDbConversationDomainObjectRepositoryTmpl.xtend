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

package org.sculptor.generator.cartridge.mongodb

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptorguimetamodel.GuiApplication
import sculptormetamodel.Application
import sculptormetamodel.BasicType

class MongoDbConversationDomainObjectRepositoryTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def String conversationDomainObectRepository(GuiApplication it) {
	var it = it.guiForApplication

	fileOutput(javaFileName(it.basePackage + ".util." + subPackage("web") + "." + "ConversationDomainObjectMongoDbRepositoryImpl"), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «basePackage».util.«subPackage("web")»;

	public class ConversationDomainObjectMongoDbRepositoryImpl implements «fw("web.hibernate.ConversationDomainObjectRepository")» {
		
		«dbManager(it)»
		«mappers(it)»
		«get(it)»
		«revert(it)»
		«clear(it)»

	}
	'''
	)
}

def String dbManager(Application it) {
	'''
	private «fw("accessimpl.mongodb.DbManager")» dbManager;
	public «fw("accessimpl.mongodb.DbManager")» getDbManager() {
		return dbManager;
	}
	public void setDbManager(«fw("accessimpl.mongodb.DbManager")» dbManager) {
		this.dbManager = dbManager;
	} 
	'''
}

def String mappers(Application it) {
	'''
	private java.util.Map<Class<?>, «fw("accessimpl.mongodb.DataMapper")»<?, com.mongodb.DBObject>> mappers = new java.util.HashMap<Class<?>, «fw("accessimpl.mongodb.DataMapper")»<?, com.mongodb.DBObject>>();
	{
	«FOR each  : it.getAllDomainObjects(false).filter[e | e.isPersistent() || e instanceof BasicType]»
		mappers.put(«each.getDomainPackage()».«each.name».class, «each.module.getMapperPackage()».«each.name»Mapper.getInstance());
	«ENDFOR»
	}
	'''
}

def String get(Application it) {
	'''
	@SuppressWarnings("unchecked")
		public <T> T get(Class<T> domainObjectClass, java.io.Serializable id) {
			«fw("accessimpl.mongodb.DataMapper")»<T, com.mongodb.DBObject> mapper = («fw("accessimpl.mongodb.DataMapper")»<T, com.mongodb.DBObject>) mappers.get(domainObjectClass);
			if (mapper == null) {
				throw new IllegalArgumentException("Unsupported domain object: " + domainObjectClass.getName());
			}
			com.mongodb.DBRef dbRef = new com.mongodb.DBRef(dbManager.getDB(), mapper.getDBCollectionName(), 
				org.bson.types.ObjectId.massageToObjectId(id));
			T result = mapper.toDomain(dbRef.fetch());
			return result;
		}
	'''
}

def String revert(Application it) {
	'''
		public void revert(Object domainObject) {
			// TODO revert
			throw new UnsupportedOperationException("Revert not implemented yet");
		}
	'''
}

def String clear(Application it) {
	'''
	public void clear() {
	}
	'''
}

}
