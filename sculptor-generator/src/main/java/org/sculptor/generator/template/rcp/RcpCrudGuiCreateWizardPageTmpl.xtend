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

class RcpCrudGuiCreateWizardPageTmpl {



def static String createWizardPage(GuiApplication it) {
	'''
	«it.modules.forEach[createWizardPage(it)]»
	'''
}

def static String createWizardPage(GuiModule it) {
	'''
	«it.userTasks.typeSelect(CreateTask).forEach[createWizardPage(it)]»
	«it.userTasks.typeSelect(CreateTask) .filter(e | isGapClassToBeGenerated(e, "New" + e.for.name + "WizardPage")).forEach[gapCreateWizardPage(it)]»
	'''
}

def static String gapCreateWizardPage(CreateTask it) {
	'''
	«val className = it."New" + for.name + "WizardPage"»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className), 'TO_SRC', '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	«createWizardPageSpringAnnotation(it)»
	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String createWizardPage(CreateTask it) {
	'''
	«val className = it."New" + for.name + "WizardPage" + gapSubclassSuffix(this, "New" + for.name + "WizardPage")»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	«IF !className.endsWith("Base")»
	«createWizardPageSpringAnnotation(it)»
	«ENDIF»
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends org.eclipse.jface.wizard.WizardPage implements «module.getRichClientPackage()».controller.New«for.name»Presentation {
	«createWizardPageConstructor(it)»
	«RcpCrudGuiMessageResources::messageSourceDependencyProperty(it)»
	«createWizardPageController(it)»
	«createWizardPageResetForm(it)»
	«it.viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.base).forEach[createWizardPageRetrieveReferenceInput(it)]»
	«createWizardPageCreateControl(it)»
	«createWizardPageInitParentLayout(it)»
	«createWizardPageCreateInitFromSelection(it)»
	«createWizardPageCreateContentComposite(it)»
	«createWizardPageCreatePage(it)»
	«createWizardPageCreatePageContainer(it)»
	«createWizardPageTargetObservables(it)»
	«createWizardPageErrorMessage(it)»
	«createWizardPageOpenQuestion(it)»
	«IF !viewProperties.typeSelect(ReferenceViewProperty).isEmpty»
		«createWizardPageShowMainTask(it)»
	«ENDIF»
	«it.viewProperties.reject(e|e.isSystemAttribute()).forEach[RcpCrudGuiPage::pageCreateWidget(it)]»
	«IF isPossibleSubtask()»
		«RcpCrudGuiPage::pageSubtaskParent(it)»
	«ENDIF»

	}
	'''
	)
	'''
	'''
}

def static String createWizardPageSpringAnnotation(CreateTask it) {
	'''
	@org.springframework.stereotype.Component("new«for.name»WizardPage")
	@org.springframework.context.annotation.Scope("prototype")
	'''
}

def static String createWizardPageConstructor(CreateTask it) {
	'''
	«val className = it."New" + for.name + "WizardPage" + gapSubclassSuffix(this, "New" + for.name + "WizardPage")»
		public «className»() {
			super("wizardPage"); //$NON-NLS-1$
			setTitle(org.eclipse.osgi.util.NLS.bind(«getMessagesClass()».newWizardPage_title, «getMessagesClass()».«for.getMessagesKey()»));
			setDescription(«getMessagesClass()».new«for.name»WizardPage_description);
		}
	'''
}

def static String createWizardPageController(CreateTask it) {
	'''
	@org.springframework.beans.factory.annotation.Autowired
		private «module.getRichClientPackage()».controller.New«for.name»Controller controller;

		protected «module.getRichClientPackage()».controller.New«for.name»Controller getController() {
			return controller;
		}
	'''
}

def static String createWizardPageResetForm(CreateTask it) {
	'''
		public void resetForm() {
			«createWizardPageCallEvaluateEnabled(it)»
			«FOR refProp : viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.base)»
			retrieve«refProp.resolveReferenceName().toFirstUpper()»Input();
			«ENDFOR»
		}
	'''
}

def static String createWizardPageRetrieveReferenceInput(ReferenceViewProperty it) {
	'''
	«IF isSingleSelectAddSubTask() »
	«createWizardPageRetrieveReferenceInputForSingleSelect(it)»
	«ELSE»    
		private void retrieve«resolveReferenceName().toFirstUpper()»Input() {
			if («resolveReferenceName().toFirstLower()»TableViewer == null) {
				return;
			}
			«resolveReferenceName().toFirstLower()»TableViewer.getViewer().setInput(null);
			«resolveReferenceName().toFirstLower()»Section.setEnabled(false);
			org.eclipse.core.runtime.jobs.Job job = new «fw("richclient.errorhandling.ExceptionAwareJob")»(
				org.eclipse.osgi.util.NLS.bind(«relatedTransitions.first().to.getMessagesClass()».readJob, «relatedTransitions.first().to.getMessagesClass()».«relatedTransitions.first().to.for.getMessagesKey()»_plural), messages) {
				@Override
				protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor) {
				    monitor.beginTask(getName(), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				    final java.util.List<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> result = getController().get«resolveReferenceName().toFirstUpper()»Input();
				    org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
				        public void run() {
				            «resolveReferenceName().toFirstLower()»TableViewer.getViewer().setInput(result);
				            «resolveReferenceName().toFirstLower()»Section.setEnabled(true);
				        }
				    });
				    monitor.done();
				    return org.eclipse.core.runtime.Status.OK_STATUS;
				}
			};
			job.schedule();
		}
	«ENDIF»
	'''
}

def static String createWizardPageRetrieveReferenceInputForSingleSelect(ReferenceViewProperty it) {
	'''
		private void retrieve«resolveReferenceName().toFirstUpper()»Input() {
			if («resolveReferenceName().toFirstLower()» == null) {
				return;
			}
			«resolveReferenceName().toFirstLower()».setInput(null);
			org.eclipse.core.runtime.jobs.Job job = new «fw("richclient.errorhandling.ExceptionAwareJob")»(
				org.eclipse.osgi.util.NLS.bind(«relatedTransitions.first().to.getMessagesClass()».readJob, «relatedTransitions.first().to.getMessagesClass()».«relatedTransitions.first().to.for.getMessagesKey()»_plural), messages) {
				@Override
				protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor) {
				    monitor.beginTask(getName(), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				    final java.util.List<«IF isNullable()»Object«ELSE»«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»«ENDIF»> input = getController().get«resolveReferenceName().toFirstUpper()»Input();
				    final «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» selection = getController().get«resolveReferenceName().toFirstUpper()»Selection();
				    org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
				        public void run() {
				            «resolveReferenceName().toFirstLower()».setInput(input);
				            if (selection == null) {
				                «resolveReferenceName().toFirstLower()».setSelection(new org.eclipse.jface.viewers.StructuredSelection());
				            } else {
				                «resolveReferenceName().toFirstLower()».setSelection(new org.eclipse.jface.viewers.StructuredSelection(selection), true);
				            }
				        }
				    });
				    monitor.done();
				    return org.eclipse.core.runtime.Status.OK_STATUS;
				}
			};
			job.schedule();
		}
	'''
}

def static String createWizardPageCallEvaluateEnabled(CreateTask it) {
	'''
			«FOR prop : viewProperties.typeSelect(AttributeViewProperty).filter(e|e.getAttributeType() == "Date" && e.isNullable())»
			evaluate«prop.name.toFirstUpper()»Enabled();
			«ENDFOR»
	'''
}

def static String createWizardPageCreateControl(CreateTask it) {
	'''
		protected org.eclipse.swt.widgets.Composite parent;

		public void createControl(org.eclipse.swt.widgets.Composite parent) {
			this.parent = parent;
			initParentLayout();

			createInitFromSelection();
			contentComposite = createContentComposite();

			createPage();

			setControl(parent);

			«createWizardPageCallEvaluateEnabled(it)»

			getController().pageCreated(this);

			resetForm();
		}

		protected org.eclipse.swt.widgets.Composite getParent() {
			return parent;
		}
	'''
}

def static String createWizardPageCreateInitFromSelection(CreateTask it) {
	'''
		protected void createInitFromSelection() {
			if (getController().isSelectedObjectValid()) {
				org.eclipse.swt.widgets.Composite fromComposite = new org.eclipse.swt.widgets.Composite(parent, org.eclipse.swt.SWT.FILL);
				fromComposite.setLayoutData(new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.TOP, true, false));

				fromComposite.setLayout(new org.eclipse.swt.layout.GridLayout(1, false));
				org.eclipse.swt.widgets.Button fromSelectionButton = new org.eclipse.swt.widgets.Button(fromComposite, org.eclipse.swt.SWT.PUSH | org.eclipse.swt.SWT.RIGHT);
				fromSelectionButton.setText(«getMessagesClass()».newWizardPage_initFromSelected);
				fromSelectionButton.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
				    @SuppressWarnings("unchecked")
				    @Override
				    public void widgetSelected(org.eclipse.swt.events.SelectionEvent event) {
				        getController().copyFromSelection();
				    }
				});
				fromSelectionButton.setLayoutData(new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.RIGHT, org.eclipse.swt.SWT.CENTER, true, false));
				org.eclipse.swt.widgets.Label separator = new org.eclipse.swt.widgets.Label(parent, org.eclipse.swt.SWT.HORIZONTAL | org.eclipse.swt.SWT.SEPARATOR);
				separator.setLayoutData(new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, false, false));
			}
		}
	'''
}

def static String createWizardPageCreateContentComposite(CreateTask it) {
	'''
		protected org.eclipse.swt.widgets.Composite contentComposite;

		protected org.eclipse.swt.widgets.Composite createContentComposite() {
			org.eclipse.swt.widgets.Composite result = new org.eclipse.swt.widgets.Composite(parent, org.eclipse.swt.SWT.NONE);
			result.setLayoutData(new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false));

			org.eclipse.swt.layout.FillLayout layout = new org.eclipse.swt.layout.FillLayout(org.eclipse.swt.SWT.VERTICAL);
			layout.marginWidth = 5;
			layout.marginHeight = 5;
			result.setLayout(layout);
			return result;
		}

		protected org.eclipse.swt.widgets.Composite getContentComposite() {
			return contentComposite;
		}
	'''
}

def static String createWizardPageCreatePage(CreateTask it) {
	'''
		public void createPage() {
			pageContainer = createPageContainer();

			«it.viewProperties.reject(e|e.isSystemAttribute()).forEach[createWizardPageCreatePageCreateWidget(it)]»
		}
	'''
}

def static String createWizardPageCreatePageCreateWidget(ViewDataProperty it) {
	'''
			«name» = create«name.toFirstUpper()»();
	'''
}

def static String createWizardPageCreatePageCreateWidget(ReferenceViewProperty it) {
	'''
	«IF !base »
	«IF userTask.isPossibleSubtask()»
			if (getController().getSubtaskParent() == null ||
					(«FOR group SEPARATOR " && "  : relatedUserTaskGroupsIncludingSubclassSiblings()»
					!«group.module.getRichClientPackage()».data.Rich«group.for.name».class.isAssignableFrom(getController().getSubtaskParent().getParentType())
					«ENDFOR»)) {

		«ENDIF»
	«IF isSingleSelectAddSubTask()»
		«name» = create«name.toFirstUpper()»();
	«ELSE»
			«resolveReferenceName().toFirstLower()»Section = create«resolveReferenceName().toFirstUpper()»Section();
			«resolveReferenceName().toFirstLower()»Composite = create«resolveReferenceName().toFirstUpper()»Composite();
			«resolveReferenceName().toFirstLower()»TableViewer = create«resolveReferenceName().toFirstUpper()»Viewer();
		«IF isCreateSubTaskAvailable()»
		    «resolveReferenceName().toFirstLower()»NewButton = create«resolveReferenceName()»NewButton();
		«ENDIF»
		«IF isAddSubTaskAvailable()»
		    «resolveReferenceName().toFirstLower()»AddButton = create«resolveReferenceName()»AddButton();
		«ENDIF»
	    «resolveReferenceName().toFirstLower()»RemoveButton = create«resolveReferenceName()»RemoveButton();

			evaluate«resolveReferenceName()»ButtonsEnabled();
	«ENDIF »
	«IF userTask.isPossibleSubtask()»
			}
		«ENDIF»
	«ENDIF »
	'''
}

def static String createWizardPageInitParentLayout(CreateTask it) {
	'''
		protected void initParentLayout() {
			parent.setLayout(new org.eclipse.swt.layout.GridLayout(1, false));
		}
	'''
}

def static String createWizardPageCreatePageContainer(CreateTask it) {
	'''
		protected org.eclipse.swt.widgets.Composite pageContainer;

		protected org.eclipse.swt.widgets.Composite createPageContainer() {
			org.eclipse.swt.widgets.Composite result = new org.eclipse.swt.widgets.Composite(contentComposite, org.eclipse.swt.SWT.NULL);
			org.eclipse.swt.layout.GridLayout gridLayout = new org.eclipse.swt.layout.GridLayout();
			gridLayout.numColumns = 2;
			result.setLayout(gridLayout);
			return result;
		}

		protected org.eclipse.swt.widgets.Composite getPageContainer() {
			return pageContainer;
		}
	'''
}

def static String createWizardPageTargetObservables(CreateTask it) {
	'''
		private java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> targetObservables = new java.util.HashMap<String, org.eclipse.core.databinding.observable.value.IObservableValue>();

		public java.util.Map<String, org.eclipse.core.databinding.observable.value.IObservableValue> getTargetObservables() {
			return targetObservables;
		}
	'''
}

def static String createWizardPageErrorMessage(CreateTask it) {
	'''
		public void clearErrorMessage() {
			setErrorMessage(null);
		}

		public boolean hasErrorMessage() {
			return (getErrorMessage() != null);
		}
	'''
}

def static String createWizardPageOpenQuestion(CreateTask it) {
	'''
		protected boolean openQuestion(String title, String message) {
			return org.eclipse.jface.dialogs.MessageDialog.openQuestion(org.eclipse.ui.PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(),
				title, message);
		}
	'''
}

def static String createWizardPageShowMainTask(CreateTask it) {
	'''
		public void showMainTask() {
		}
	'''
}



}
