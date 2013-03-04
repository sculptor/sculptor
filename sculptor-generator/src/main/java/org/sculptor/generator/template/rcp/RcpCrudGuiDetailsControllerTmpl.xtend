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

class RcpCrudGuiDetailsControllerTmpl {



def static String detailsController(GuiApplication it) {
	'''
	«it.modules.forEach[detailsController(it)]»
	'''
}

def static String detailsController(GuiModule it) {
	'''
	«it.userTasks.typeSelect(UpdateTask).forEach[detailsPresentation(it)]»
	«it.userTasks.typeSelect(UpdateTask).forEach[detailsController(it)]»
	«it.userTasks.typeSelect(UpdateTask) .filter(e | isGapClassToBeGenerated(e, e.for.name + "DetailsController")).forEach[gapDetailsController(it)]»
	'''
}

def static String gapDetailsController(UpdateTask it) {
	'''
	«val className = it.for.name + "DetailsController"»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".controller." + className), 'TO_SRC', '''
	«javaHeader()»
	package «module.getRichClientPackage()».controller;

	«detailsControllerSpringAnnotation(it)»
	public class «className» ^extends «className»Base {
		public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String detailsController(UpdateTask it) {
	'''
	«val className = it.for.name + "DetailsController" + gapSubclassSuffix(this, for.name + "DetailsController")»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".controller." + className) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».controller;

	«IF !className.endsWith("Base")»
	«detailsControllerSpringAnnotation(it)»
	«ENDIF»
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className»
		^extends «fw("richclient.controller.AbstractDetailsController")»<«module.getRichClientPackage()».data.Rich«for.name»> {

	«detailsControllerRepository(it)»

		«detailsControllerConstructor(it)»

		«RcpCrudGuiMessageResources::messageSourceDependencyProperty(it)»

		«detailsControllerSetFormInput(it)»

		«IF findDOWith != null »
			«detailsControllerRetrieveLatestFormInput(it)»
		«ENDIF»

		«IF isPossibleSubtask()»
			«detailsControllerSubtask(it)»
		«ENDIF»

		«detailsControllerDoSave(it)»

		«detailsControllerMiscMethods(it)»

		«RcpCrudGuiDataBinding::initDataBindings(it)»

		«it.viewProperties.typeSelect(EnumViewProperty).forEach[RcpCrudGuiDataBinding::getInput(it)]»
		
		«it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).filter(e | e.isSingleSelectAddSubTask()).forEach[RcpCrudGuiDataBinding::getInputValuesSingleSelectAddTask(it)]»

	«it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).reject(e | e.isSingleSelectAddSubTask()).forEach[RcpCrudGuiDataBinding::getInput(it)]»
		«IF !viewProperties.typeSelect(ReferenceViewProperty).reject(e | e.isSingleSelectAddSubTask()).isEmpty»
		«detailsControllerSubtaskAttributes(it)»
		«detailsControllerResetSubtask(it)»
	«ENDIF»

		«it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).reject(e | e.isSingleSelectAddSubTask()).forEach[detailsControllerSubtasks(it)]»

	«controllerHook(it)»
	// TODO remove this when fw is updated
		@Override
		public void propertyChange(final java.beans.PropertyChangeEvent event) {
			if (org.fornax.cartridges.sculptor.framework.util.EqualsHelper.equals(event.getOldValue(), event.getNewValue())) {
				return;
			}
			if (org.eclipse.swt.widgets.Display.getCurrent() == null) {
				org.eclipse.swt.widgets.Display.getDefault().syncExec(new Runnable() {
				    public void run() {
				        «className».super.propertyChange(event);
				    }
				});
			} else {
				super.propertyChange(event);
			}
		}
			
	}
	'''
	)
	'''
	'''
}

def static String detailsControllerSpringAnnotation(UpdateTask it) {
	'''
	@org.springframework.stereotype.Controller("«for.name.toFirstLower()»DetailsController")
	@org.springframework.context.annotation.Scope("prototype")
	'''
}

def static String detailsControllerRepository(UpdateTask it) {
	'''
		private «module.getRichClientPackage()».data.Rich«for.name»Repository repository;

		/**
			* Dependency injection
			*/
		@org.springframework.beans.factory.annotation.Autowired
		public void setRepository(«module.getRichClientPackage()».data.Rich«for.name»Repository repository) {
			if (this.repository != null) {
				this.repository.deleteObserver(this);
			}
			this.repository = repository;
			repository.addObserver(this);
			setObjectFactory(repository);
		}
	'''
}

def static String detailsControllerConstructor(UpdateTask it) {
	'''
		public «for.name»DetailsController«gapSubclassSuffix(this, for.name + "DetailsController")»() {
		}
	'''
}

def static String detailsControllerSetFormInput(UpdateTask it) {
	'''
		@Override
		public boolean setFormInput(«module.getRichClientPackage()».data.Rich«for.name» input) {
			boolean result = super.setFormInput(input);
			«IF !viewProperties.typeSelect(ReferenceViewProperty).reject(e | e.isSingleSelectAddSubTask()).isEmpty»
			resetSubtask();
			«ENDIF»
			«IF findDOWith != null »
			retrieveLatestFormInput();
			«ENDIF»
			return result;
		}
	'''
}

def static String detailsControllerRetrieveLatestFormInput(UpdateTask it) {
	'''
		private java.util.concurrent.atomic.AtomicReference<java.util.concurrent.CountDownLatch> retrievingLatestFormInputLatch = new java.util.concurrent.atomic.AtomicReference<java.util.concurrent.CountDownLatch>();

		protected void retrieveLatestFormInput() {
			if (retrievingLatestFormInputLatch.get() != null) {
				// already in progress
				return;
			}
			retrievingLatestFormInputLatch.set(new java.util.concurrent.CountDownLatch(1));
			org.eclipse.core.runtime.jobs.Job job =
				new «fw("richclient.errorhandling.ExceptionAwareJob")»(
				    org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».readJob, «getMessagesClass()».«for.getMessagesKey()»), messages) {
				    @Override
				    protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor) throws Exception {
				        try {
				            monitor.beginTask(getName(), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				            repository.«findDOWith.name»(getModel().getId());
				            monitor.done();
				            return org.eclipse.core.runtime.Status.OK_STATUS;
				        } finally {
				            org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
				                public void run() {
				                    retrievingLatestFormInputLatch.get().countDown();
				                    retrievingLatestFormInputLatch.set(null);
				                }
				            });

				        }
				    }
				};
			job.schedule();
		}
	'''
}


def static String detailsControllerDoSave(UpdateTask it) {
	'''
		@Override
		public void doSave(final org.eclipse.core.runtime.IProgressMonitor monitor) {
		«IF getPrimaryServiceOperation() != null»
			org.eclipse.core.runtime.jobs.Job job = new «fw("richclient.errorhandling.ExceptionAwareJob")»(
				org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».updateJob, «getMessagesClass()».«for.getMessagesKey()»), messages) {
				@Override
				protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor2) {
				    monitor2.beginTask(getName(), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				    repository.«getPrimaryServiceOperation().name»(getModel());

				    org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
	                public void run() {
	                    superDoSave(monitor);
	                }
	            });

				    monitor2.done();
				    return org.eclipse.core.runtime.Status.OK_STATUS;
				}
			};
			job.setUser(true);
			job.schedule();


		«ENDIF»
		}

		private void superDoSave(org.eclipse.core.runtime.IProgressMonitor monitor) {

			super.doSave(monitor);
		}
	'''
}

def static String detailsControllerMiscMethods(UpdateTask it) {
	'''
		@Override
		public void dispose() {
			if (repository != null) {
				repository.deleteObserver(this);
			}
			super.dispose();
		}

		protected «for.name»DetailsPresentation get«for.name»DetailsPresentation() {
			return («for.name»DetailsPresentation) getPresentation();
		}
	'''
}

def static String detailsControllerSubtask(UpdateTask it) {
	'''
		private «fw("richclient.controller.ParentOfSubtask")»<«module.getRichClientPackage()».data.Rich«for.name»> subtaskParent;

		public «fw("richclient.controller.ParentOfSubtask")»<«module.getRichClientPackage()».data.Rich«for.name»> getSubtaskParent() {
			return subtaskParent;
		}

		public void setSubtaskParent(«fw("richclient.controller.ParentOfSubtask")»<«module.getRichClientPackage()».data.Rich«for.name»> subtaskParent) {
			this.subtaskParent = subtaskParent;
		}

		public void subtaskOk() {
			subtaskParent.subtaskCompleted(getModel());
		}

		public void subtaskCancel() {
			subtaskParent.subtaskCancelled();
		}

		public boolean isSubtask() {
			return subtaskParent != null;
		}
	'''
}

def static String detailsControllerSubtaskAttributes(UpdateTask it) {
	'''
		private «fw("richclient.controller.SubtaskLife")»<? ^extends «fw("richclient.data.RichObject")»> currentSubtask;

		protected «fw("richclient.controller.SubtaskLife")»<? ^extends «fw("richclient.data.RichObject")»> getCurrentSubtask() {
			return currentSubtask;
		}
	'''
}

def static String detailsControllerResetSubtask(UpdateTask it) {
	'''
		private void resetSubtask() {
			currentSubtask = null;
			get«for.name»DetailsPresentation().showMainTask();
		}
	'''
}

def static String detailsControllerSubtasks(ReferenceViewProperty it) {
	'''
		«IF isCreateSubTaskAvailable() && isChangeable()»
		public void new«resolveReferenceName()»Subtask() {
			currentSubtask = new New«resolveReferenceName()»Strategy();
			currentSubtask.start();
		}
		«ENDIF»

		«IF isUpdateSubTaskAvailable()»
		public void edit«resolveReferenceName()»Subtask() {
			currentSubtask = new Edit«resolveReferenceName()»Strategy();
			currentSubtask.start();
		}
		«ENDIF»

		«IF isAddSubTaskAvailable() && isChangeable()»
		public void add«resolveReferenceName()»Subtask() {
			currentSubtask = new Add«resolveReferenceName()»Strategy();
			currentSubtask.start();
		}
		«ENDIF»

		«IF isChangeable()»
		public void remove«resolveReferenceName()»Subtask() {
			currentSubtask = new Remove«resolveReferenceName()»Strategy();
			currentSubtask.start();
		}
		«ENDIF»

		«IF isCreateSubTaskAvailable() && isChangeable()»
			«detailsControllerCreateSubtaskStrategy(it)»
		«ENDIF»
		«IF isUpdateSubTaskAvailable()»
			«detailsControllerUpdateSubtaskStrategy(it)»
		«ENDIF»
		«IF isAddSubTaskAvailable() && isChangeable()»
			«detailsControllerAddSubtaskStrategy(it)»
		«ENDIF»
		«IF isChangeable()»
			«detailsControllerRemoveSubtaskStrategy(it)»
		«ENDIF»
	'''
}

def static String detailsControllerCreateSubtaskStrategy(ReferenceViewProperty it) {
	'''
		class New«resolveReferenceName()»Strategy implements «fw("richclient.controller.SubtaskLife")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> {

			public void start() {
				get«userTask.for.name»DetailsPresentation().showNew«resolveReferenceName()»Subtask(this);
			}

			public Class<?> getParentType() {
				return getModel().getClass();
			}

			public void subtaskCompleted(«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»... items) {
				getModel().add«resolveReferenceName()»(items[0]);
				get«userTask.for.name»DetailsPresentation().set«resolveReferenceName()»Selection(new org.eclipse.jface.viewers.StructuredSelection(items[0]));
				setDirty(true); // TODO not necessary, we are listening on changes on model object
				resetSubtask();
			}

			public void subtaskCancelled() {
				resetSubtask();
			}
		}
	'''
}

def static String detailsControllerUpdateSubtaskStrategy(ReferenceViewProperty it) {
	'''
		class Edit«resolveReferenceName()»Strategy implements «fw("richclient.controller.SubtaskLife")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> {

			public void start() {
				org.eclipse.jface.viewers.IStructuredSelection selection = (org.eclipse.jface.viewers.IStructuredSelection) get«userTask.for.name»DetailsPresentation().get«resolveReferenceName()»Selection();
				if (selection.isEmpty()) {
				    resetSubtask();
				    return;
				}
				«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» item = («relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name») selection.getFirstElement();

				get«userTask.for.name»DetailsPresentation().showEdit«resolveReferenceName()»Subtask(this, item);
			}

			public Class<?> getParentType() {
				return getModel().getClass();
			}

			public void subtaskCompleted(«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»... items) {
				getModel().add«resolveReferenceName()»(items[0]);
				setDirty(true); // TODO not necessary, we are listening on changes on model object
				resetSubtask();
			}

			public void subtaskCancelled() {
				resetSubtask();
			}
		}
	'''
}

def static String detailsControllerAddSubtaskStrategy(ReferenceViewProperty it) {
	'''
		class Add«resolveReferenceName()»Strategy implements «fw("richclient.controller.SubtaskLife")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> {

			public void start() {
				get«userTask.for.name»DetailsPresentation().showAdd«resolveReferenceName()»Subtask(this);
			}

			public Class<?> getParentType() {
				return getModel().getClass();
			}

			public void subtaskCompleted(«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»... items) {
				«IF isMany()»
				for («relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» each : items) {
				    getModel().add«resolveReferenceName().singular()»(each);
				}
				«ELSE»
				if («resolveReferenceName().toFirstLower()»Input != null) {
				    «resolveReferenceName().toFirstLower()»Input.clear();
				}
				for («relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» each : items) {
				    getModel().set«resolveReferenceName()»(each);
				    if («resolveReferenceName().toFirstLower()»Input != null) {
				        «resolveReferenceName().toFirstLower()»Input.add(each);
				    }
				}
				«ENDIF»
				get«userTask.for.name»DetailsPresentation().set«resolveReferenceName()»Selection(new org.eclipse.jface.viewers.StructuredSelection(items));
				setDirty(true); // TODO not necessary, we are listening on changes on model object
				resetSubtask();
			}

			public void subtaskCancelled() {
				resetSubtask();
			}
		}
	'''
}

def static String detailsControllerRemoveSubtaskStrategy(ReferenceViewProperty it) {
	'''
		class Remove«resolveReferenceName()»Strategy implements «fw("richclient.controller.SubtaskLife")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> {

			public void start() {
				org.eclipse.jface.viewers.IStructuredSelection selection = get«userTask.for.name»DetailsPresentation().get«resolveReferenceName()»Selection();
				if (selection.isEmpty()) {
				    resetSubtask();
				    return;
				}
				«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» item = («relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name») selection.getFirstElement();
				get«userTask.for.name»DetailsPresentation().showRemove«resolveReferenceName()»Subtask(this, item);
			}

			public Class<?> getParentType() {
				return getModel().getClass();
			}

			public void subtaskCompleted(«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»... items) {
				«IF isMany()»
				getModel().remove«resolveReferenceName().singular()»(items[0]);
				«ELSE»
				getModel().set«resolveReferenceName()»(null);
				if («resolveReferenceName().toFirstLower()»Input != null) {
				    «resolveReferenceName().toFirstLower()»Input.clear();
				}
				«ENDIF»

				setDirty(true); // TODO not necessary, we are listening on changes on model object
				resetSubtask();
			}

			public void subtaskCancelled() {
				resetSubtask();
			}
		}
	'''
}

def static String detailsPresentation(UpdateTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".controller." + for.name + "DetailsPresentation") , '''
	«javaHeader()»
	package «module.getRichClientPackage()».controller;

	public interface «for.name»DetailsPresentation ^extends «fw("richclient.controller.DetailsPresentation")» {

		«IF !viewProperties.typeSelect(ReferenceViewProperty).isEmpty»
		void showMainTask();

	«it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).forEach[detailsPresentationSubtasks(it)]»
	«ENDIF»

	}
	'''
	)
	'''
	'''
}

def static String detailsPresentationSubtasks(ReferenceViewProperty it) {
	'''
	«val subtaskModule = it.relatedTransitions.first().to.module»
		org.eclipse.jface.viewers.IStructuredSelection get«resolveReferenceName()»Selection();

		void set«resolveReferenceName()»Selection(org.eclipse.jface.viewers.IStructuredSelection selection);

	«IF isCreateSubTaskAvailable() && isChangeable()»
		void showNew«resolveReferenceName()»Subtask(«fw("richclient.controller.ParentOfSubtask")»<«subtaskModule.getRichClientPackage()».data.Rich«target.name»> subtaskParent);
		«ENDIF»

		«IF isUpdateSubTaskAvailable()»
		void showEdit«resolveReferenceName()»Subtask(«fw("richclient.controller.ParentOfSubtask")»<«subtaskModule.getRichClientPackage()».data.Rich«target.name»> subtaskParent, «subtaskModule.getRichClientPackage()».data.Rich«target.name» item);
		«ENDIF»

		«IF isAddSubTaskAvailable() && isChangeable()»
		void showAdd«resolveReferenceName()»Subtask(«fw("richclient.controller.ParentOfSubtask")»<«subtaskModule.getRichClientPackage()».data.Rich«target.name»> subtaskParent);
		«ENDIF»

	«IF isChangeable()»
	void showRemove«resolveReferenceName()»Subtask(«fw("richclient.controller.ParentOfSubtask")»<«subtaskModule.getRichClientPackage()».data.Rich«target.name»> subtaskParent, «subtaskModule.getRichClientPackage()».data.Rich«target.name» item);
	«ENDIF»

	'''
}

/*Extension point to generate more stuff in Controller classes.
	Use AROUND RcpCrudGuiDetailsControllerTmpl::controllerHook FOR UpdateTask
	in SpecialCases.xpt */
def static String controllerHook(UpdateTask it) {
	'''
	'''
}
}
