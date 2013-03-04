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

class RcpCrudGuiCreateControllerTmpl {



def static String createController(GuiApplication it) {
	'''
	«it.modules.forEach[createController(it)]»
	'''
}

def static String createController(GuiModule it) {
	'''
	«it.userTasks.typeSelect(CreateTask).forEach[createPresentation(it)]»
	«it.userTasks.typeSelect(CreateTask).forEach[createController(it)]»
	«it.userTasks.typeSelect(CreateTask) .filter(e | isGapClassToBeGenerated(e, "New" + e.for.name + "Controller")).forEach[gapCreateController(it)]»
	'''
}

def static String gapCreateController(CreateTask it) {
	'''
	«val className = it."New" + for.name + "Controller"»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".controller." + className), 'TO_SRC', '''
	«javaHeader()»
	package «module.getRichClientPackage()».controller;

	«createControllerSpringAnnotation(it)»
	public class «className» ^extends «className»Base {
		public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String createController(CreateTask it) {
	'''
	«val className = it."New"+ for.name + "Controller" + gapSubclassSuffix(this, "New" + for.name + "Controller")»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".controller." + className) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».controller;

	«IF !className.endsWith("Base")»
	«createControllerSpringAnnotation(it)»
	«ENDIF»
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className»
		^extends «fw("richclient.controller.AbstractWizardController")»<«module.getRichClientPackage()».data.Rich«for.name»> {

	«createControllerRepository(it)»
	
		«createControllerConstructor(it)»

		«RcpCrudGuiMessageResources::messageSourceDependencyProperty(it)»

		«IF isPossibleSubtask()»
			«createControllerSubtask(it)»
		«ENDIF»

		«createControllerPerformFinish(it)»
		«createControllerPerformCancel(it)»

		«createControllerMiscMethods(it)»

		«RcpCrudGuiDataBinding::initDataBindings(it)»

		«it.viewProperties.typeSelect(EnumViewProperty).forEach[RcpCrudGuiDataBinding::getInput(it)]»

	«it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).filter(e | e.isSingleSelectAddSubTask()).forEach[RcpCrudGuiDataBinding::getInputValuesSingleSelectAddTask(it)]»

	«it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).reject(e | e.isSingleSelectAddSubTask()).forEach[RcpCrudGuiDataBinding::getInput(it)]»

		«IF !viewProperties.typeSelect(ReferenceViewProperty).reject(e | e.isSingleSelectAddSubTask()).isEmpty»
		«createControllerSubtaskAttributes(it)»
		«createControllerResetSubtask(it)»
	«ENDIF»

		«it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).reject(e | e.isSingleSelectAddSubTask()).forEach[createControllerSubtasks(it)]»

	«controllerHook(it)»

	// TODO remove this when fw is updated
	@Override
	protected org.eclipse.core.databinding.observable.value.IObservableValue getTargetObservable(String name) {
		try {
				return super.getTargetObservable(name);
			} catch (IllegalArgumentException e) {
				return null;
			} 
		}
	}
	'''
	)
	'''
	'''
}

def static String createControllerSpringAnnotation(CreateTask it) {
	'''
	@org.springframework.stereotype.Controller("new«for.name»Controller")
	@org.springframework.context.annotation.Scope("prototype")
	'''
}

def static String createControllerRepository(CreateTask it) {
	'''
		private «module.getRichClientPackage()».data.Rich«for.name»Repository repository;

		/**
			* Dependency injection
			*/
		@org.springframework.beans.factory.annotation.Autowired
		public void setRepository(«module.getRichClientPackage()».data.Rich«for.name»Repository repository) {
			this.repository = repository;
			setObjectFactory(repository);
		}
	'''
}

def static String createControllerConstructor(CreateTask it) {
	'''
		public New«for.name»Controller«gapSubclassSuffix(this, "New" + for.name + "Controller")»() {
		}
	'''
}

def static String createControllerPerformFinish(CreateTask it) {
	'''
		public boolean performFinish() {
		«IF isPossibleSubtask()»
			if (isSubtask()) {
				// don't save
				org.eclipse.swt.widgets.Display.getDefault().syncExec(new Runnable() {
				    public void run() {
				        getSubtaskParent().subtaskCompleted(getModel());
				    }
				});

				return true;
			}
		«ENDIF»

		«IF getPrimaryServiceOperation() != null»
			java.util.concurrent.Callable<Boolean> callable = new java.util.concurrent.Callable<Boolean>() {
				public Boolean call() throws Exception {
				    repository.«getPrimaryServiceOperation().name»(getModel());
				    return Boolean.TRUE;
				}
			};
			«fw("richclient.errorhandling.ExceptionAware")»<Boolean> runner = new «fw("richclient.errorhandling.ExceptionAware")»<Boolean>(messages, Boolean.FALSE);
			return runner.run(callable);
		«ELSE»
			return true;
		«ENDIF»
		}
	'''
}

def static String createControllerPerformCancel(CreateTask it) {
	'''
		public boolean performCancel() {
		«IF isPossibleSubtask()»
			if (isSubtask()) {
				getSubtaskParent().subtaskCancelled();
				return true;
			}
		«ENDIF»

			return true;
		}
	'''
}

def static String createControllerMiscMethods(CreateTask it) {
	'''
		protected New«for.name»Presentation getNew«for.name»Presentation() {
			return (New«for.name»Presentation) getPresentation();
		}
	'''
}

def static String createControllerSubtaskAttributes(CreateTask it) {
	'''
		private «fw("richclient.controller.SubtaskLife")»<? ^extends «fw("richclient.data.RichObject")»> currentSubtask;
	'''
}

def static String createControllerResetSubtask(CreateTask it) {
	'''
		private void resetSubtask() {
			currentSubtask = null;
			getNew«for.name»Presentation().showMainTask();
		}
	'''
}

/*TODO: subtask templates are very similar for Create and Update - extract */

def static String createControllerSubtask(CreateTask it) {
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

def static String createControllerSubtasks(ReferenceViewProperty it) {
	'''
		«IF isCreateSubTaskAvailable()»
		public void new«resolveReferenceName()»Subtask() {
			currentSubtask = new New«resolveReferenceName()»Strategy();
			currentSubtask.start();
		}
		«ENDIF»

		«IF isAddSubTaskAvailable()»
		public void add«resolveReferenceName()»Subtask() {
			currentSubtask = new Add«resolveReferenceName()»Strategy();
			currentSubtask.start();
		}
		«ENDIF»

		public void remove«resolveReferenceName()»Subtask() {
			currentSubtask = new Remove«resolveReferenceName()»Strategy();
			currentSubtask.start();
		}

		«IF isCreateSubTaskAvailable()»
			«createControllerCreateSubtaskStrategy(it)»
		«ENDIF»
		«IF isAddSubTaskAvailable()»
			«createControllerAddSubtaskStrategy(it)»
		«ENDIF»
		«createControllerRemoveSubtaskStrategy(it)»
	'''
}

def static String createControllerCreateSubtaskStrategy(ReferenceViewProperty it) {
	'''
		class New«resolveReferenceName()»Strategy implements «fw("richclient.controller.SubtaskLife")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> {

			public void start() {
				getNew«userTask.for.name»Presentation().showNew«resolveReferenceName()»Subtask(this);
			}

			public Class<?> getParentType() {
				return getModel().getClass();
			}

			public void subtaskCompleted(«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»... items) {
				getModel().add«resolveReferenceName()»(items[0]);
				getNew«userTask.for.name»Presentation().set«resolveReferenceName()»Selection(new org.eclipse.jface.viewers.StructuredSelection(items[0]));
				resetSubtask();
			}

			public void subtaskCancelled() {
				resetSubtask();
			}
		}
	'''
}


def static String createControllerAddSubtaskStrategy(ReferenceViewProperty it) {
	'''
		class Add«resolveReferenceName()»Strategy implements «fw("richclient.controller.SubtaskLife")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> {

			public void start() {
				getNew«userTask.for.name»Presentation().showAdd«resolveReferenceName()»Subtask(this);
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
				getNew«userTask.for.name»Presentation().set«resolveReferenceName()»Selection(new org.eclipse.jface.viewers.StructuredSelection(items));
				resetSubtask();
			}

			public void subtaskCancelled() {
				resetSubtask();
			}
		}
	'''
}

def static String createControllerRemoveSubtaskStrategy(ReferenceViewProperty it) {
	'''
		class Remove«resolveReferenceName()»Strategy implements «fw("richclient.controller.SubtaskLife")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> {

			public void start() {
				org.eclipse.jface.viewers.IStructuredSelection selection = getNew«userTask.for.name»Presentation().get«resolveReferenceName()»Selection();
				if (selection.isEmpty()) {
				    resetSubtask();
				    return;
				}
				«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» item = («relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name») selection.getFirstElement();
				getNew«userTask.for.name»Presentation().showRemove«resolveReferenceName()»Subtask(this, item);
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

				resetSubtask();
			}

			public void subtaskCancelled() {
				resetSubtask();
			}
		}
	'''
}

def static String createPresentation(CreateTask it) {
	'''
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".controller.New" + for.name + "Presentation") , '''
	«javaHeader()»
	package «module.getRichClientPackage()».controller;

	public interface New«for.name»Presentation ^extends «fw("richclient.controller.WizardPresentation")» {

		«IF !viewProperties.typeSelect(ReferenceViewProperty).isEmpty»
		void showMainTask();

	«it.viewProperties.typeSelect(ReferenceViewProperty).reject(p | p.base).forEach[createPresentationSubtasks(it)]»
	«ENDIF»

	}
	'''
	)
	'''
	'''
}

def static String createPresentationSubtasks(ReferenceViewProperty it) {
	'''
	«val subtaskModule = it.relatedTransitions.first().to.module»
		org.eclipse.jface.viewers.IStructuredSelection get«resolveReferenceName()»Selection();

		void set«resolveReferenceName()»Selection(org.eclipse.jface.viewers.IStructuredSelection selection);

	«IF isCreateSubTaskAvailable()»
		void showNew«resolveReferenceName()»Subtask(«fw("richclient.controller.ParentOfSubtask")»<«subtaskModule.getRichClientPackage()».data.Rich«target.name»> subtaskParent);
		«ENDIF»

		«IF isAddSubTaskAvailable()»
		void showAdd«resolveReferenceName()»Subtask(«fw("richclient.controller.ParentOfSubtask")»<«subtaskModule.getRichClientPackage()».data.Rich«target.name»> subtaskParent);
		«ENDIF»

		void showRemove«resolveReferenceName()»Subtask(«fw("richclient.controller.ParentOfSubtask")»<«subtaskModule.getRichClientPackage()».data.Rich«target.name»> subtaskParent, «subtaskModule.getRichClientPackage()».data.Rich«target.name» item);
	'''
}

/*Extension point to generate more stuff in Controller classes.
	Use AROUND RcpCrudGuiCreateControllerTmpl::controllerHook FOR CreateTask
	in SpecialCases.xpt */
def static String controllerHook(CreateTask it) {
	'''
	'''
}
}
