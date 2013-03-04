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

class RcpCrudGuiDataBindingTmpl {



def static String initDataBindings(UserTask it) {
	'''
	«val bindViewProperties = it.viewProperties.reject(e | e.isSystemAttribute()).reject(e | e.metaType == ReferenceViewProperty && ((ReferenceViewProperty) e).base)»
		protected void initDataBindings(org.eclipse.core.databinding.DataBindingContext bindingContext) {
			«it.bindViewProperties.forEach[bindInvocation(it)]»
			«IF metaType == UpdateTask && isPossibleSubtask()»
				bindOk(bindingContext);
			«ENDIF»
		}

	«FOR prop  : bindViewProperties»
		«bind(it) FOR prop»
		«IF prop.isDateOrDateTime() && prop.isNullable()»
			«bindDateDefined(it) FOR prop»
		«ENDIF»
	«ENDFOR»
	«IF metaType == UpdateTask && isPossibleSubtask()»
			«bindOk(it)»
		«ENDIF»
	'''
}

def static String bindInvocation(ViewDataProperty it) {
	'''
			bind«name.toFirstUpper()»(bindingContext);
			«IF isDateOrDateTime() && isNullable()»
			bind«name.toFirstUpper()»Defined(bindingContext);
			«ENDIF»
	'''
}

def static String bindInvocation(ReferenceViewProperty it) {
	'''
			bind«resolveReferenceName()»(bindingContext);
	'''
}

def static String bind(ViewDataProperty it) {
	''' 
	«val optionalBoolean = it.getTypeName().toLowerCase() == "boolean" && isNullable()»
	«val requiredBoolean = it.getTypeName().toLowerCase() == "boolean" && !isNullable()»
		protected void bind«name.toFirstUpper()»(org.eclipse.core.databinding.DataBindingContext bindingContext) {
			String attributeName = "«name»";
			if (getTargetObservable(attributeName) == null) {
				return;
			}
			«IF requiredBoolean»
		org.eclipse.core.databinding.UpdateValueStrategy targetToModelUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			org.eclipse.core.databinding.UpdateValueStrategy modelToTargetUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
		«ELSEIF optionalBoolean»        
			org.eclipse.core.databinding.UpdateValueStrategy targetToModelUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			org.eclipse.core.databinding.UpdateValueStrategy modelToTargetUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			targetToModelUpdateStrategy.setConverter(new «fw("richclient.databinding.EmptyStringConverter")»(true));
			modelToTargetUpdateStrategy.setConverter(new «fw("richclient.databinding.EmptyStringConverter")»(false));
			«ELSEIF !isNullable() && getTypeName() == "String" && !isSystemAttribute() && getDatabaseLength() != null»
			String requiredMessage = org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».validation_required, «userTask.getMessagesClass()».«getMessagesKey()»);
			String maxLengthMessage = org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».validation_too_long, «userTask.getMessagesClass()».«getMessagesKey()», «getDatabaseLength()»);
			org.eclipse.core.databinding.UpdateValueStrategy targetToModelUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			org.eclipse.core.databinding.UpdateValueStrategy modelToTargetUpdateStrategy = createRequiredUpdateStrategy(requiredMessage);
		targetToModelUpdateStrategy.setBeforeSetValidator(new «fw("richclient.databinding.CompositeValidator")»(
				new «fw("richclient.databinding.RequiredValidator")»(requiredMessage),
				new «fw("richclient.databinding.StringMaxLengthValidator")»(«getDatabaseLength()», maxLengthMessage)
				));
			«ELSEIF !isNullable()»
			String requiredMessage = org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».validation_required, «userTask.getMessagesClass()».«getMessagesKey()»);
			org.eclipse.core.databinding.UpdateValueStrategy targetToModelUpdateStrategy = createRequiredUpdateStrategy(requiredMessage);
			org.eclipse.core.databinding.UpdateValueStrategy modelToTargetUpdateStrategy = createRequiredUpdateStrategy(requiredMessage);
			«ELSEIF getTypeName() == "String" && !isSystemAttribute() && getDatabaseLength() != null»
			org.eclipse.core.databinding.UpdateValueStrategy targetToModelUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			org.eclipse.core.databinding.UpdateValueStrategy modelToTargetUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			String maxLengthMessage = org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».validation_too_long, «userTask.getMessagesClass()».«getMessagesKey()», «getDatabaseLength()»); 
			targetToModelUpdateStrategy.setBeforeSetValidator(new «fw("richclient.databinding.StringMaxLengthValidator")»(«getDatabaseLength()», maxLengthMessage));
			«ELSE»
			org.eclipse.core.databinding.UpdateValueStrategy targetToModelUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			org.eclipse.core.databinding.UpdateValueStrategy modelToTargetUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			«ENDIF»
			«IF getTypeName() != "String" && !isDateOrDateTime() && metaType != EnumViewProperty && metaType != BasicTypeEnumViewProperty && !optionalBoolean»
			java.beans.PropertyEditor propEditor = java.beans.PropertyEditorManager.findEditor(«getTypeName().getObjectTypeName()».class);
			if (propEditor != null) {
				String formatMessage = org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».validation_invalidFormat, «userTask.getMessagesClass()».«getMessagesKey()»);
				targetToModelUpdateStrategy.setConverter(
				    new «fw("richclient.databinding.SetAsTextPropertyEditorConverter")»(
				        propEditor, formatMessage));
				modelToTargetUpdateStrategy.setConverter(
				    new «fw("richclient.databinding.GetAsTextPropertyEditorConverter")»(
				        propEditor));
			}
			«ENDIF»
			bindingContext.bindValue(getTargetObservable(attributeName), getModelObservable(attributeName), 
				    targetToModelUpdateStrategy, modelToTargetUpdateStrategy);
		}

	'''
}

def static String bind(EnumViewProperty it) {
	'''
		protected void bind«name.toFirstUpper()»(org.eclipse.core.databinding.DataBindingContext bindingContext) {
			String attributeName = "«name»";
			if (getTargetObservable(attributeName) == null) {
				return;
			}
			«IF isNullable()»
			org.eclipse.core.databinding.UpdateValueStrategy targetToModelUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			org.eclipse.core.databinding.UpdateValueStrategy modelToTargetUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			targetToModelUpdateStrategy.setConverter(new «fw("richclient.databinding.EmptyStringConverter")»(true));
			modelToTargetUpdateStrategy.setConverter(new «fw("richclient.databinding.EmptyStringConverter")»(false));
			«ELSE»
			String requiredMessage = org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».validation_required, «userTask.getMessagesClass()».«getMessagesKey()»);
			org.eclipse.core.databinding.UpdateValueStrategy targetToModelUpdateStrategy = createRequiredUpdateStrategy(requiredMessage);
			org.eclipse.core.databinding.UpdateValueStrategy modelToTargetUpdateStrategy = createRequiredUpdateStrategy(requiredMessage);
			«ENDIF»
			bindingContext.bindValue(getTargetObservable(attributeName), getModelObservable(attributeName), 
				    targetToModelUpdateStrategy, modelToTargetUpdateStrategy);
		}
	'''
}



def static String bind(ReferenceViewProperty it) {
	'''
		protected void bind«resolveReferenceName().toFirstUpper()»(org.eclipse.core.databinding.DataBindingContext bindingContext) {
		«IF (isMany() && reference.required) || (!isMany() && !isNullable())»
			«val relatedUserTask = it.relatedUserTaskGroupsIncludingSubclassSiblings()»
			String refName = "«resolveReferenceName().toFirstLower()»";
			if (getTargetObservable(refName) == null) {
				return;
			}
			String requiredMessage = org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».validation_required, «userTask.getMessagesClass()».«getMessagesKey()»);
			«IF isSingleSelectAddSubTask()»
				org.eclipse.core.databinding.UpdateValueStrategy targetToModelUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			«ELSE»
				org.eclipse.core.databinding.UpdateValueStrategy targetToModelUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy(org.eclipse.core.databinding.UpdateValueStrategy.POLICY_NEVER);
			«ENDIF»
			org.eclipse.core.databinding.UpdateValueStrategy modelToTargetUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			«IF userTask.isPossibleSubtask()»
			«fw("richclient.databinding.RequiredValidator")» refRequiredValidator = new «fw("richclient.databinding.RequiredValidator")»(requiredMessage) {
				@Override
				public org.eclipse.core.runtime.IStatus validate(Object value) {
				    if (getSubtaskParent() != null && 
					    («FOR group SEPARATOR " || "  : relatedUserTask»
					    «group.module.getRichClientPackage()».data.Rich«group.for.name».class.isAssignableFrom(getSubtaskParent().getParentType())
					    «ENDFOR»)) {
				        // reference to parent will be assigned by parent
				        return org.eclipse.core.runtime.Status.OK_STATUS;
				    } else {
				    	«IF relatedUserTask.size > 1 »
				    		// TODO mandatory validation of reference to subclasses to are not 
				    		// supported yet. Implement manually by overriding bind method in gap class.
				    		return org.eclipse.core.runtime.Status.OK_STATUS;
				    	«ELSE»
				    	return super.validate(value); 
				    	«ENDIF»
				    }
				    
				}
			};
			«ELSE»
			«fw("richclient.databinding.RequiredValidator")» refRequiredValidator = new «fw("richclient.databinding.RequiredValidator")»(requiredMessage);
			«ENDIF»
			modelToTargetUpdateStrategy.setBeforeSetValidator(refRequiredValidator);
			
			bindingContext.bindValue(getTargetObservable(refName), getModelObservable(refName), 
				    targetToModelUpdateStrategy, modelToTargetUpdateStrategy);
		«ELSEIF !isMany()»
			String refName = "«resolveReferenceName().toFirstLower()»";
			if (getTargetObservable(refName) == null) {
				return;
			}
			org.eclipse.core.databinding.UpdateValueStrategy targetToModelUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			org.eclipse.core.databinding.UpdateValueStrategy modelToTargetUpdateStrategy = new org.eclipse.core.databinding.UpdateValueStrategy();
			«IF isNullable()»
			targetToModelUpdateStrategy.setConverter(new «fw("richclient.databinding.EmptyStringConverter")»(true));
			modelToTargetUpdateStrategy.setConverter(new «fw("richclient.databinding.EmptyStringConverter")»(false));
			«ENDIF»
			bindingContext.bindValue(getTargetObservable(refName), getModelObservable(refName), 
				    targetToModelUpdateStrategy, modelToTargetUpdateStrategy);
		«ENDIF»
		}
	'''
}


def static String bindDateDefined(ViewDataProperty it) {
	'''
		protected void bind«name.toFirstUpper()»Defined(org.eclipse.core.databinding.DataBindingContext bindingContext) {
			String attributeName = "«name»Defined";
			if (getTargetObservable(attributeName) == null) {
				return;
			}
			org.eclipse.core.databinding.UpdateValueStrategy updateStrategy = null;
			bindingContext.bindValue(getTargetObservable(attributeName), getModelObservable(attributeName), 
				    updateStrategy, updateStrategy);
		}
	'''
}

def static String getInput(EnumViewProperty it) {
	'''
	«IF isNullable()»
		public java.util.List<Object> get«reference.name.toFirstUpper()»Input() {
			java.util.List<Object> result = new java.util.ArrayList<Object>();
			result.add("");
			result.addAll(java.util.Arrays.asList(«reference.to.getDomainPackage()».«reference.to.name».values()));
			return result;
		}
		«ELSE»
		public java.util.List<«reference.to.getDomainPackage()».«reference.to.name»> get«reference.name.toFirstUpper()»Input() {
			return java.util.Arrays.asList(«reference.to.getDomainPackage()».«reference.to.name».values());
		}
		«ENDIF»
	'''
}

def static String getInput(BasicTypeEnumViewProperty it) {
	'''
		public java.util.List<«reference.to.getDomainPackage()».«reference.to.name»> get«basicTypeReference.name.toFirstUpper()»«reference.name.toFirstUpper()»Input() {
			return java.util.Arrays.asList(«reference.to.getDomainPackage()».«reference.to.name».values());
		}
	'''
}

def static String getInput(ReferenceViewProperty it) {
	'''
	«IF !isMany()»
	private java.util.List<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> «resolveReferenceName().toFirstLower()»Input;
	«ENDIF»
	@SuppressWarnings("unchecked")
		public java.util.List<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> get«resolveReferenceName()»Input() {
			«IF userTask.metaType == UpdateTask && ((UpdateTask) userTask).findDOWith != null »
			java.util.concurrent.CountDownLatch latch = retrievingLatestFormInputLatch.get();
			if (latch != null) {
				try {
				    latch.await(2, java.util.concurrent.TimeUnit.SECONDS);
				} catch (InterruptedException e) {
				}
			}
			«ENDIF»
			«IF isMany()»
			java.util.List<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> result = getModel().getObservable«resolveReferenceName()»();
			return result;
			«ELSE»
			if («resolveReferenceName().toFirstLower()»Input == null) {
				«resolveReferenceName().toFirstLower()»Input =
	            «fw("richclient.databinding.ObservableUtil")».createWritableList(
	                new java.util.ArrayList<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»>());
			}
			final «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» result = getModel().get«resolveReferenceName()»();
			org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
	        public void run() {
	            «resolveReferenceName().toFirstLower()»Input.clear();
	            if (result != null) {
	                «resolveReferenceName().toFirstLower()»Input.add(result);
	            }
	        }
	    });
			return «resolveReferenceName().toFirstLower()»Input;
			«ENDIF»
		}
	'''
}

def static String getInputValuesSingleSelectAddTask(ReferenceViewProperty it) {
	'''
	«val addTask = it.getRelatedAddTask()»
	«val listType = it.isNullable() ? "Object" : relatedTransitions.first().to.module.getRichClientPackage() + ".data.Rich" + target.name»
	@org.springframework.beans.factory.annotation.Autowired
	private «addTask.module.getRichClientPackage()».data.Rich«addTask.for.name»Repository «resolveReferenceName().toFirstLower()»Repository;
	
		public java.util.List<«listType»> get«resolveReferenceName()»Input() {
			try {
				«resolveReferenceName().toFirstLower()»Repository.setNotifyObservers(false);
			«IF addTask.isPaging()»
				java.util.List<«listType»> allValues = new java.util.ArrayList<«listType»>();
				«IF isNullable()»
					allValues.add("");
				«ENDIF» 
				int maxPages = 20;
				int pageSize = 500;
				for (int i = 1; i <= maxPages; i++) {
				    boolean countTotalPages = (i == 1);
				    «getJavaType("PagingParameter")» pagingParameter = «getJavaType("PagingParameter")».pageAccess(pageSize, i, countTotalPages);
				    final «getJavaType("PagedResult")»<«addTask.module.getRichClientPackage()».data.Rich«addTask.for.name»> result = «resolveReferenceName().toFirstLower()»Repository.«addTask.getPrimaryServiceOperation().name»(pagingParameter);
				    if (result.isTotalCounted()) {
				        maxPages = result.getTotalPages();
				    }
				    allValues.addAll(result.getValues());
				}
				return allValues;
			«ELSE»
				«IF isNullable()»
					java.util.List<«listType»> allValues = new java.util.ArrayList<«listType»>();
					allValues.add("");
					allValues.addAll(«resolveReferenceName().toFirstLower()»Repository.«addTask.getPrimaryServiceOperation().name»());
					return allValues;
				«ELSE»
					return «resolveReferenceName().toFirstLower()»Repository.«addTask.getPrimaryServiceOperation().name»();
				«ENDIF»
			«ENDIF»
			} finally {
				«resolveReferenceName().toFirstLower()»Repository.setNotifyObservers(true);
			}
		}
		
		public «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» get«resolveReferenceName()»Selection() {
			return getModel().get«resolveReferenceName()»();
		}
	'''
}

def static String bindOk(UserTask it) {
	'''
		protected void bindOk(final org.eclipse.core.databinding.DataBindingContext bindingContext) {
			String targetName = "ok";
			if (getTargetObservable(targetName) == null) {
				return;
			}
			
			org.eclipse.core.databinding.UpdateValueStrategy modelToTargetUpdateStrategy =
				new org.eclipse.core.databinding.UpdateValueStrategy();
			modelToTargetUpdateStrategy.setConverter(new org.eclipse.core.databinding.conversion.Converter(org.eclipse.core.runtime.IStatus.class, Boolean.class) {
				public Object convert(Object fromObject) {
				    return ((org.eclipse.core.runtime.IStatus) fromObject).getSeverity() == org.eclipse.core.runtime.IStatus.OK;
				}
				
			});
				    
			org.eclipse.core.databinding.AggregateValidationStatus aggregatedStatus = new org.eclipse.core.databinding.AggregateValidationStatus(bindingContext, org.eclipse.core.databinding.AggregateValidationStatus.MAX_SEVERITY);

			bindingContext.bindValue(getTargetObservable(targetName),
				    aggregatedStatus, null, modelToTargetUpdateStrategy);

		}
	'''
}
}
