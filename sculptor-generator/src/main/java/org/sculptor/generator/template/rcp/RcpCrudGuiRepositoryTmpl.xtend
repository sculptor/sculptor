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

class RcpCrudGuiRepositoryTmpl {



def static String repository(GuiApplication it) {
	'''
	«it.groupByTarget().forEach[repository(it)]»
	'''
}

def static String repository(UserTaskGroup it) {
	'''
	«repositoryInterface(it)»
	«repositoryImpl(it)»
	«IF isGapClassToBeGenerated(this, "Rich" + for.name + "RepositoryImpl")»
		«gapRepositoryImpl(it)»
	«ENDIF»
	'''
}

def static String repositoryInterface(UserTaskGroup it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".data.Rich" + for.name + "Repository") , '''
	«javaHeader()»
	package «module.getRichClientPackage()».data;

	«IF pureEjb3()»
	@javax.ejb.Local
	«ENDIF»
	public interface Rich«for.name»Repository ^extends «fw("richclient.data.RichObjectFactory")»<Rich«for.name»>«IF hasReferenceViewProperties()»,
		«fw("richclient.data.AssociationLoader")»<«for.getDomainPackage()».«for.name»>«ENDIF» {

	«IF getListTaskPrimaryServiceOperation() != null»
		«IF getListTaskPrimaryServiceOperation().hasPagingParameter()» «getJavaType("PagedResult")»«ELSE»java.util.List«ENDIF»<«module.getRichClientPackage()».data.Rich«for.name»> «getListTaskPrimaryServiceOperation().name»(«IF getListTaskPrimaryServiceOperation().hasPagingParameter()» «getJavaType("PagingParameter")» pagingParameter«ENDIF»);
	«ELSEIF for.getFindAllMethod() != null»
		«IF for.getFindAllMethod().hasPagingParameter()» «getJavaType("PagedResult")»«ELSE»java.util.List«ENDIF» «for.getFindAllMethod().name»(«IF for.getFindAllMethod().hasPagingParameter()» «getJavaType("PagingParameter")» pagingParameter«ENDIF»);
	«ENDIF»

	«IF getUpdateTaskPrimaryServiceOperation() != null»
		«module.getRichClientPackage()».data.Rich«for.name» «getUpdateTaskPrimaryServiceOperation().name»(«module.getRichClientPackage()».data.Rich«for.name» rich«for.name»);
	«ENDIF»
	«IF getCreateTaskPrimaryServiceOperation() != null && (getCreateTaskPrimaryServiceOperation() != getUpdateTaskPrimaryServiceOperation())»
		«module.getRichClientPackage()».data.Rich«for.name» «getCreateTaskPrimaryServiceOperation().name»(«module.getRichClientPackage()».data.Rich«for.name» rich«for.name»);
	«ENDIF»

	«IF getUpdateTaskFindWithServiceOperation() != null»
	«module.getRichClientPackage()».data.Rich«for.name» «getUpdateTaskFindWithServiceOperation().name»(Long id) « ExceptionTmpl::throws(it) FOR getUpdateTaskFindWithServiceOperation()»;
	«ENDIF»

	«IF getDeleteTaskPrimaryServiceOperation() != null»
		void «getDeleteTaskPrimaryServiceOperation().name»(«module.getRichClientPackage()».data.Rich«for.name» rich«for.name»);
	«ENDIF»

		void addObserver(java.util.Observer o);

		void deleteObserver(java.util.Observer o);
		
		/**
			* Turn notification on/off for current thread.
			*/
		void setNotifyObservers(boolean notify);

	}
	'''
	)
	'''
	'''
}

def static String gapRepositoryImpl(UserTaskGroup it) {
	'''
	«val className = it."Rich" + for.name + "RepositoryImpl"»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".data." + className), 'TO_SRC', '''
	«javaHeader()»
	package «module.getRichClientPackage()».data;

	«repositorySpringAnnotation(it)»
	public class «className» ^extends «className»Base {
		public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String repositoryImpl(UserTaskGroup it) {
	'''
	«val className = it."Rich" + for.name + "RepositoryImpl" + gapSubclassSuffix(this, "Rich" + for.name + "RepositoryImpl")»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".data." + className) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».data;

	«IF !className.endsWith("Base")»
	«repositorySpringAnnotation(it)»
	«ENDIF»
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends java.util.Observable implements Rich«for.name»Repository {

		«repositoryService(it)»
		«repositoryRichObjectFactory(it)»
		«IF isServiceContextToBeGenerated()»
	    «repositoryServiceContrextFactory(it)»
		«ENDIF»

		«IF getListTaskPrimaryServiceOperation() != null || for.getFindAllMethod() != null»
			«repositoryGetAll(it)»
		«ENDIF»

	«IF getUpdateTaskPrimaryServiceOperation() != null»
	    «repositorySave(it)(getUpdateTaskPrimaryServiceOperation())»
	«ENDIF»
	«IF getCreateTaskPrimaryServiceOperation() != null && (getCreateTaskPrimaryServiceOperation() != getUpdateTaskPrimaryServiceOperation())»
		«repositorySave(it)(getCreateTaskPrimaryServiceOperation())»
		«ENDIF»

		«IF getUpdateTaskFindWithServiceOperation() != null»
			«repositoryFindById(it)»
	«ENDIF»

	«IF getDeleteTaskPrimaryServiceOperation() != null»
		«repositoryDelete(it) FOR userTasks.typeSelect(DeleteTask).first()»
	«ENDIF»

	«IF hasReferenceViewProperties()»
		«repositoryAssociationLoaderImpl(it)»
	«ENDIF»

	«repositoryNotifyView(it)»
	«repositorySetNotifyObservers(it)»

	}
	'''
	)
	'''
	'''
}

def static String repositorySpringAnnotation(UserTaskGroup it) {
	'''
	@org.springframework.stereotype.Repository("rich«for.name»Repository")
	'''
}

def static String repositoryService(UserTaskGroup it) {
	'''
	«FOR s : getUsedServices()»
	@org.springframework.beans.factory.annotation.Autowired
		private «s.getServiceapiPackage()».«s.name» «s.name.toFirstLower()»;

		protected «s.getServiceapiPackage()».«s.name» get«s.name»() {
			return «s.name.toFirstLower()»;
		}
		«ENDFOR»
	'''
}

def static String repositoryRichObjectFactory(UserTaskGroup it) {
	'''
	@org.springframework.beans.factory.annotation.Autowired
		private «module.getRichClientPackage()».data.Rich«for.name»«gapSubclassSuffix(this, "Rich" + for.name)».Factory rich«for.name»Factory;

		protected «module.getRichClientPackage()».data.Rich«for.name»«gapSubclassSuffix(this, "Rich" + for.name)».Factory getRich«for.name»Factory() {
			return rich«for.name»Factory;
		}

		public «module.getRichClientPackage()».data.Rich«for.name» create() {
			return rich«for.name»Factory.create();
		}
	'''
}

def static String repositoryServiceContrextFactory(Object it) {
	'''
	@org.springframework.beans.factory.annotation.Autowired
		private «fw("richclient.errorhandling.RichServiceContextFactory")» serviceContextFactory;

		protected «fw("errorhandling.ServiceContext")» createServiceContext() {
			return serviceContextFactory.createServiceContext();
		}
	'''
}

def static String repositoryGetAll(UserTaskGroup it) {
	'''
	«val operation = it.getListTaskPrimaryServiceOperation() != null ? getListTaskPrimaryServiceOperation() : for.getFindAllMethod()»
		public «IF operation.hasPagingParameter()» «getJavaType("PagedResult")»«ELSE»java.util.List«ENDIF»<«module.getRichClientPackage()».data.Rich«for.name»> «operation.name»(«IF operation.hasPagingParameter()» «getJavaType("PagingParameter")» pagingParameter«ENDIF») {
			«IF operation.hasPagingParameter()»
				«getJavaType("PagedResult")»<«operation.domainObjectType.getDomainPackage()».«operation.domainObjectType.name»> foundPagedResult = «operation.service.name.toFirstLower()».«operation.name»(«IF isServiceContextToBeGenerated()»createServiceContext()«ENDIF», pagingParameter);
				java.util.List<«operation.domainObjectType.getDomainPackage()».«operation.domainObjectType.name»> all = 
					new java.util.ArrayList<«operation.domainObjectType.getDomainPackage()».«operation.domainObjectType.name»>(foundPagedResult.getValues());
			«ELSE»
			java.util.List<«operation.domainObjectType.getDomainPackage()».«operation.domainObjectType.name»> all = «operation.service.name.toFirstLower()».«operation.name»(«IF isServiceContextToBeGenerated()»createServiceContext()«ENDIF»);
			«ENDIF»
			java.util.List<«module.getRichClientPackage()».data.Rich«for.name»> result = new java.util.ArrayList<«module.getRichClientPackage()».data.Rich«for.name»>();
			for («operation.domainObjectType.getDomainPackage()».«operation.domainObjectType.name» each : all) {
				«IF for != operation.domainObjectType»
				if (!(each instanceof «for.getDomainPackage()».«for.name»)) {
				    continue;
				}
				«for.getDomainPackage()».«for.name» each«for.name» = («for.getDomainPackage()».«for.name») each;
				«ENDIF»
				«module.getRichClientPackage()».data.Rich«for.name» rich«for.name» = rich«for.name»Factory.create();
				rich«for.name».fromDomainObject(each«IF for != operation.domainObjectType»«for.name»«ENDIF»);
				result.add(rich«for.name»);

				if (isNotifyObservers()) {
				    «fw("richclient.data.DataEvent")» event = new «fw("richclient.data.DataEvent")»(rich«for.name», «fw("richclient.data.DataEvent")».Action.UPDATE);
				    notifyView(event);
				}
			}
			
			«IF operation.hasPagingParameter()»
	        «getJavaType("PagedResult")»<«module.getRichClientPackage()».data.Rich«for.name»> pagedResult = 
	        	new «getJavaType("PagedResult")»<«module.getRichClientPackage()».data.Rich«for.name»>(result, foundPagedResult.getStartRow(), foundPagedResult.getRowCount(),
				    	foundPagedResult.getPageSize(), foundPagedResult.getTotalRows(), foundPagedResult.getAdditionalResultRows());
				return pagedResult;
			«ELSE»
				return result;
			«ENDIF»
		}
	'''
}

def static String repositorySave(UserTaskGroup it, ServiceOperation operation) {
	'''
		/**
			* Saves a new or existing object. When saving a new object it is important that you
			* Use the returned instance, or the one published to the repository listeners, because
			* the previous instance has not the same key (UUID) as the saved instance.
			*/
		public «module.getRichClientPackage()».data.Rich«for.name» «operation.name»(«module.getRichClientPackage()».data.Rich«for.name» rich«for.name») {
			boolean isNew = (rich«for.name».isNew());

			«module.getRichClientPackage()».data.Rich«for.name» result;
			if (isNew && rich«for.name».isStale()) {
				throw new IllegalArgumentException("Stale objects should not be saved. Use the returned instance, " +
				    "or the one published to the repository listeners.");
			} else if (isNew) {
				// need to publish a new instance, since the key (UUID) of the RichObject might be changed
				result = rich«for.name»Factory.create();
			} else {
				result = rich«for.name»;
			}

			«for.getDomainPackage()».«for.name» updated«for.name» = rich«for.name».toDomainObject(true);
			/*Handle in different ways depending on if the operation returns the saved object or not */
			«IF operation.domainObjectType != null && (operation.domainObjectType == for || operation.domainObjectType.getAllSubclasses().contains(for))
				&& operation.collectionType == null»
				«for.getDomainPackage()».«for.name» saved«for.name» = «IF operation.domainObjectType != for»(«for.getDomainPackage()».«for.name») «ENDIF»«operation.service.name.toFirstLower()».«operation.name»(«IF isServiceContextToBeGenerated()»createServiceContext(), «ENDIF»updated«for.name»);
				result.fromDomainObject(saved«for.name»);

	        «fw("richclient.data.DataEvent")» event = new «fw("richclient.data.DataEvent")»(result,
	            (isNew ? «fw("richclient.data.DataEvent")».Action.INSERT : «fw("richclient.data.DataEvent")».Action.UPDATE));
				notifyView(event);

				if (isNew) {
				    // The previous instance is stale and should not be saved again.
				    // Use the returned instance, or the one published to the repository listeners.
				    rich«for.name».setStale(true);
				}
			«ELSE»
			«operation.service.name.toFirstLower()».«operation.name»(«IF isServiceContextToBeGenerated()»createServiceContext(), «ENDIF»updated«for.name»);

			if (isNew) {
				// new object, INSERT, but we don't have an id, so we need to refresh
				«fw("richclient.data.DataEvent")» event = new DataEvent(result, «fw("richclient.data.DataEvent")».Action.REFRESH);
				notifyView(event);
				// The previous instance is stale and should not be saved again.
				// Use the returned instance, or the one published to the repository listeners.
				rich«for.name».setStale(true);
			} else {
				«IF getUpdateTaskFindWithServiceOperation() == null»
					// there is no findById method and we must do a refresh
					«fw("richclient.data.DataEvent")» event = new DataEvent(result, «fw("richclient.data.DataEvent")».Action.REFRESH);
					notifyView(event);
				«ELSE»
		        try {
		            «for.getDomainPackage()».«for.name» saved«for.name» = «getUpdateTaskFindWithServiceOperation().service.name.toFirstLower()».«getUpdateTaskFindWithServiceOperation().name»(«IF isServiceContextToBeGenerated()»createServiceContext(), «ENDIF»updated«for.name».getId());
		            result.fromDomainObject(saved«for.name»);
		        } catch (RuntimeException e) {
		            throw e;
		        }
		        «IF getUpdateTaskFindWithServiceOperation().throws != null»
		        catch (Exception e) {
		            throw new RuntimeException(e.getMessage(), e);
		        }
		        «ENDIF»
		        «fw("richclient.data.DataEvent")» event = new «fw("richclient.data.DataEvent")»(result, «fw("richclient.data.DataEvent")».Action.UPDATE);
	            notifyView(event);
	        «ENDIF»
			}
			«ENDIF»
			return result;
		}
	'''
}

def static String repositoryFindById(UserTaskGroup it) {
	'''
		public «module.getRichClientPackage()».data.Rich«for.name» «getUpdateTaskFindWithServiceOperation().name»(Long id) « ExceptionTmpl::throws(it) FOR getUpdateTaskFindWithServiceOperation()» {
			«getUpdateTaskFindWithServiceOperation().domainObjectType.getDomainPackage()».«getUpdateTaskFindWithServiceOperation().domainObjectType.name» found = «getUpdateTaskFindWithServiceOperation().service.name.toFirstLower()».«getUpdateTaskFindWithServiceOperation().name»(«IF isServiceContextToBeGenerated()»createServiceContext(), «ENDIF»id);
			«IF !getUpdateTaskFindWithServiceOperation().hasNotFoundException()»
	        if (found == null) {
				throw new IllegalArgumentException("Didn't find «for.name» with id: " + id);
			}
			«ENDIF»
			«module.getRichClientPackage()».data.Rich«for.name» result = rich«for.name»Factory.create();
			result.fromDomainObject(found);

			«fw("richclient.data.DataEvent")» event = new «fw("richclient.data.DataEvent")»(result, «fw("richclient.data.DataEvent")».Action.UPDATE);
			notifyView(event);

			return result;
		}
	'''
}

def static String repositoryDelete(DeleteTask it) {
	'''
		public void «getPrimaryServiceOperation().name»(«module.getRichClientPackage()».data.Rich«for.name» rich«for.name») {
			«for.getDomainPackage()».«for.name» deleted«for.name» = rich«for.name».toDomainObject(false);
			«getPrimaryServiceOperation().service.name.toFirstLower()».«getPrimaryServiceOperation().name»(«IF isServiceContextToBeGenerated()»createServiceContext(), «ENDIF»deleted«for.name»);

			«fw("richclient.data.DataEvent")» event = new «fw("richclient.data.DataEvent")»(rich«for.name», «fw("richclient.data.DataEvent")».Action.REMOVE);
			notifyView(event);
		}
	'''
}

def static String repositoryAssociationLoaderImpl(UserTaskGroup it) {
	'''
	«val operation = it.getUpdateTaskPopulateWithServiceOperation() != null ? getUpdateTaskPopulateWithServiceOperation() : getCreateTaskPopulateWithServiceOperation()»
		«IF operation == null»
		public «for.getDomainPackage()».«for.name» populateAssociations(«for.getDomainPackage()».«for.name» original) {
			return original;
		}
		«ELSE»
		public «for.getDomainPackage()».«for.name» populateAssociations(«for.getDomainPackage()».«for.name» original) {
			«fw("domain.AssociationSpecification")» spec = new «fw("domain.AssociationSpecification")»();
			«repositoryAssociationLoaderSpecNames(it)»
			«IF !operation.getExceptions().isEmpty »try {«ENDIF»
				return «IF operation.domainObjectType != for»(«for.getDomainPackage()».«for.name») «ENDIF»«operation.service.name.toFirstLower()».«operation.name»(«IF isServiceContextToBeGenerated()»createServiceContext(), «ENDIF»original, spec);
		«IF !operation.getExceptions().isEmpty »
			«FOR exc : operation.getExceptions()»
			} catch («exc» e) {
			    return original;
			«ENDFOR»
			}
			«ENDIF»
		}
	«ENDIF»
	'''
}

def static String repositoryAssociationLoaderSpecNames(UserTaskGroup it) {
	'''
	«FOR ref : userTasks.first().for.getAllReferencesForSubTasks()»
				spec.addAssociationName("«ref.name»");
	«ENDFOR»
	'''
}

def static String repositoryNotifyView(Object it) {
	'''
		protected void notifyView(final Object event) {
			if (!isNotifyObservers()) {
				return;
			}
			if (org.eclipse.swt.widgets.Display.getCurrent() == null) {
				org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
				    public void run() {
				        setChanged();
				        notifyObservers(event);
				    }
				});
			} else {
				setChanged();
				notifyObservers(event);
			}
		}
	'''
}

def static String repositorySetNotifyObservers(Object it) {
	'''
		private ThreadLocal<Boolean> notifyObservers = new ThreadLocal<Boolean>();
		
		public void setNotifyObservers(boolean notify) {
			notifyObservers.set(notify);
		}
		
		protected boolean isNotifyObservers() {
			return notifyObservers.get() == null || notifyObservers.get();
		}
	'''
}
}
