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

class RcpCrudGuiDetailsPageTmpl {



def static String detailsPage(GuiApplication it) {
	'''
	«it.modules.forEach[detailsPage(it)]»
	'''
}

def static String detailsPage(GuiModule it) {
	'''
	«it.userTasks.typeSelect(UpdateTask).forEach[detailsPage(it)]»
	«it.userTasks.typeSelect(UpdateTask) .filter(e | isGapClassToBeGenerated(e, e.for.name + "DetailsPage")).forEach[gapDetailsPage(it)]»
	'''
}

def static String gapDetailsPage(UpdateTask it) {
	'''
	«val className = it.for.name + "DetailsPage"»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className), 'TO_SRC', '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	«detailsPageSpringAnnotation(it)»
	public class «className» ^extends «className»Base {
	public «className»() {
		}
	}
	'''
	)
	'''
	'''
}

def static String detailsPage(UpdateTask it) {
	'''
	«val className = it.for.name + "DetailsPage" + gapSubclassSuffix(this, for.name + "DetailsPage")»
	'''
	fileOutput(javaFileName(module.getRichClientPackage() + ".ui." + className ) , '''
	«javaHeader()»
	package «module.getRichClientPackage()».ui;

	«IF !className.endsWith("Base")»
	«detailsPageSpringAnnotation(it)»
	«ENDIF»
	public «IF className.endsWith("Base")»abstract«ENDIF» class «className» ^extends «fw("richclient.ui.AbstractDetailsPage")»<«module.getRichClientPackage()».data.Rich«for.name»>
		implements «module.getRichClientPackage()».controller.«for.name»DetailsPresentation {
	«detailsPageConstructor(it)»
	«RcpCrudGuiMessageResources::messageSourceDependencyProperty(it)»
	«detailsPageController(it)»
	«detailsPageSetFocus(it)»
	«detailsPageResetForm(it)»
	«it.viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.base).forEach[detailsPageRetrieveReferenceInput(it)]»
	«detailsPageCreateContents(it)»
	«IF !viewProperties.typeSelect(ReferenceViewProperty).isEmpty»
		«detailsPageCreateMainComposite(it)»
		«detailsPageShowMainTask(it)»
	«ENDIF»
	«detailsPageInitParentLayout(it)»
	«detailsPageCreateSection(it)»
	«detailsPageCreatePageContainer(it)»
	«it.viewProperties.reject(e|e.isSystemAttribute()).forEach[RcpCrudGuiPage::pageCreateWidget(it)]»
	«IF isPossibleSubtask()»
		«RcpCrudGuiPage::pageCreateSubtaskButtonBar(it)»
		«RcpCrudGuiPage::pageCreateSubtaskOkButton(it)»
		«RcpCrudGuiPage::pageCreateSubtaskCancelButton(it)»
		«RcpCrudGuiPage::pageCreateSubtaskButton(it)»
		«RcpCrudGuiPage::pageSubtaskParent(it)»
	«ENDIF»
	}
	'''
	)
	'''
	'''
}

def static String detailsPageSpringAnnotation(UpdateTask it) {
	'''
	@org.springframework.stereotype.Component("«for.name.toFirstLower()»DetailsPage")
	@org.springframework.context.annotation.Scope("prototype")
	'''
}

def static String detailsPageConstructor(UpdateTask it) {
	'''
		public «for.name»DetailsPage«gapSubclassSuffix(this, for.name + "DetailsPage")»() {
			«IF getPrimaryServiceOperation() == null»
			setReadOnly(true);
			«ENDIF»
		}
	'''
}

def static String detailsPageController(UpdateTask it) {
	'''

		/**
			* Dependency injection
			*/
		@org.springframework.beans.factory.annotation.Autowired
		public void setController(«module.getRichClientPackage()».controller.«for.name»DetailsController controller) {
			super.setController(controller);
		}

		protected «module.getRichClientPackage()».controller.«for.name»DetailsController getController() {
			return («module.getRichClientPackage()».controller.«for.name»DetailsController) super.getController();
		}
	'''
}

def static String detailsPageSetFocus(UpdateTask it) {
	'''
		public void setFocus() {
			«viewProperties.reject(e|e.isSystemAttribute()).first().name».setFocus();
		}
	'''
}

def static String detailsPageResetForm(UpdateTask it) {
	'''
		@Override
		public void resetForm() {
			super.resetForm();
			«detailsPageCallEvaluateEnabled(it)»
			«FOR refProp : viewProperties.typeSelect(ReferenceViewProperty).reject(e|e.base)»
			retrieve«refProp.resolveReferenceName().toFirstUpper()»Input();
			«ENDFOR»
		}
	'''
}

def static String detailsPageRetrieveReferenceInput(ReferenceViewProperty it) {
	'''
	«IF isSingleSelectAddSubTask() »
	«detailsPageRetrieveReferenceInputForSingleSelect(it)»
	«ELSE»
		protected void retrieve«resolveReferenceName().toFirstUpper()»Input() {
			if («resolveReferenceName().toFirstLower()»TableViewer == null) {
				return;
			}
			«resolveReferenceName().toFirstLower()»TableViewer.getViewer().setInput(null);
			«resolveReferenceName().toFirstLower()»Section.setEnabled(false);
			final Object currentModel = getController().getModel();
			org.eclipse.core.runtime.jobs.Job job = new «fw("richclient.errorhandling.ExceptionAwareJob")»(
				org.eclipse.osgi.util.NLS.bind(«relatedTransitions.first().to.getMessagesClass()».readJob, «relatedTransitions.first().to.getMessagesClass()».«relatedTransitions.first().to.for.getMessagesKey()»_plural), messages) {
				@Override
				protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor) {
				    monitor.beginTask(getName(), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				    final java.util.List<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»> result = getController().get«resolveReferenceName().toFirstUpper()»Input();
				    org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
				        public void run() {
				            if (!currentModel.equals(getController().getModel())) {
				                // not same model any more, skip
				                return;
				            }
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

def static String detailsPageRetrieveReferenceInputForSingleSelect(ReferenceViewProperty it) {
	'''
		protected void retrieve«resolveReferenceName().toFirstUpper()»Input() {
			if («resolveReferenceName().toFirstLower()» == null) {
				return;
			}
			«resolveReferenceName().toFirstLower()».setInput(null);
			final Object currentModel = getController().getModel();
			org.eclipse.core.runtime.jobs.Job job = new «fw("richclient.errorhandling.ExceptionAwareJob")»(
				org.eclipse.osgi.util.NLS.bind(«relatedTransitions.first().to.getMessagesClass()».readJob, «relatedTransitions.first().to.getMessagesClass()».«relatedTransitions.first().to.for.getMessagesKey()»_plural), messages) {
				@Override
				protected org.eclipse.core.runtime.IStatus doRun(org.eclipse.core.runtime.IProgressMonitor monitor) {
				    monitor.beginTask(getName(), org.eclipse.core.runtime.IProgressMonitor.UNKNOWN);
				    final java.util.List<«IF isNullable()»Object«ELSE»«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name»«ENDIF»> input = getController().get«resolveReferenceName().toFirstUpper()»Input();
				    final «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» selection = getController().get«resolveReferenceName().toFirstUpper()»Selection();
				    org.eclipse.swt.widgets.Display.getDefault().asyncExec(new Runnable() {
				        public void run() {
				            if (!currentModel.equals(getController().getModel())) {
				                // not same model any more, skip
				                return;
				            }
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

def static String detailsPageCallEvaluateEnabled(UpdateTask it) {
	'''
			«FOR prop : viewProperties.typeSelect(AttributeViewProperty).filter(e|e.getAttributeType() == "Date" && e.isNullable())»
			evaluate«prop.name.toFirstUpper()»Enabled();
			«ENDFOR»
	'''
}

def static String detailsPageCreateContents(UpdateTask it) {
	'''
		protected org.eclipse.swt.widgets.Composite parent;

		public void createContents(org.eclipse.swt.widgets.Composite parent) {
			this.parent = parent;
			«IF !viewProperties.typeSelect(ReferenceViewProperty).isEmpty»
			main = createMainComposite();
			«ENDIF»
			initParentLayout();
			section = createSection();
			pageContainer = createPageContainer();

		«it.viewProperties.reject(e|e.isSystemAttribute()).forEach[detailsPageCreateContentsCreateWidget(it)]»

			«IF isPossibleSubtask()»
			if (getController().isSubtask()) {
				subtaskButtonComposite = createSubtaskButtonBar();
				okButton = createOkButton();
				cancelButton = createCancelButton();
			}
			«ENDIF»

			«detailsPageCallEvaluateEnabled(it)»

			getController().presentationCreated(this);
		}

		protected org.eclipse.swt.widgets.Composite getParent() {
			return parent;
		}
	'''
}

def static String detailsPageCreateContentsCreateWidget(ViewDataProperty it) {
	'''
			«name» = create«name.toFirstUpper()»();
	'''
}

def static String detailsPageCreateContentsCreateWidget(ReferenceViewProperty it) {
	'''
	«IF !base »
	«IF userTask.isPossibleSubtask()»
			if (getController().getSubtaskParent() == null ||
				!«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«relatedTransitions.first().to.for.name».class.isAssignableFrom(getController().getSubtaskParent().getParentType())) {
		«ENDIF»
	«IF isSingleSelectAddSubTask()»
		«name» = create«name.toFirstUpper()»();
	«ELSE»
			«resolveReferenceName().toFirstLower()»Section = create«resolveReferenceName().toFirstUpper()»Section();
			«resolveReferenceName().toFirstLower()»Composite = create«resolveReferenceName().toFirstUpper()»Composite();
			«resolveReferenceName().toFirstLower()»TableViewer = create«resolveReferenceName().toFirstUpper()»Viewer();
		«IF isCreateSubTaskAvailable() && (userTask.metaType == CreateTask || isChangeable())»
		    «resolveReferenceName().toFirstLower()»NewButton = create«resolveReferenceName()»NewButton();
		«ENDIF»
		«IF isAddSubTaskAvailable() && (userTask.metaType == CreateTask || isChangeable())»
		    «resolveReferenceName().toFirstLower()»AddButton = create«resolveReferenceName()»AddButton();
		«ENDIF»
		«IF isUpdateSubTaskAvailable()»
		    «resolveReferenceName().toFirstLower()»EditButton = create«resolveReferenceName()»EditButton();
			«ENDIF»
			«IF userTask.metaType == CreateTask || isChangeable()»
	        «resolveReferenceName().toFirstLower()»RemoveButton = create«resolveReferenceName()»RemoveButton();
		«ENDIF»
			evaluate«resolveReferenceName()»ButtonsEnabled();
	«ENDIF »
	«IF userTask.isPossibleSubtask()»
			}
		«ENDIF»
	«ENDIF »
	'''
}

def static String detailsPageCreateMainComposite(UpdateTask it) {
	'''
		protected org.eclipse.swt.widgets.Composite main;

		protected org.eclipse.swt.widgets.Composite createMainComposite() {
			org.eclipse.swt.widgets.Composite result = getToolkit().createComposite(parent, org.eclipse.swt.SWT.NONE);
			getToolkit().paintBordersFor(result);
			org.eclipse.swt.layout.GridLayout gridLayout = new org.eclipse.swt.layout.GridLayout();
			gridLayout.verticalSpacing = 20;
			gridLayout.marginWidth = 5;
			gridLayout.marginHeight = 5;
			result.setLayout(gridLayout);
			return result;
		}
	'''
}

def static String detailsPageShowMainTask(UpdateTask it) {
	'''
		public void showMainTask() {
			if (stackLayout.topControl != main) {
				stackLayout.topControl = main;
				parent.layout();
			}
		}
	'''
}

def static String detailsPageInitParentLayout(UpdateTask it) {
	'''
	«IF viewProperties.typeSelect(ReferenceViewProperty).isEmpty»
		protected void initParentLayout() {
			org.eclipse.swt.layout.GridLayout gridLayout = new org.eclipse.swt.layout.GridLayout();
			gridLayout.verticalSpacing = 20;
			gridLayout.marginWidth = 5;
			gridLayout.marginHeight = 5;
			parent.setLayout(gridLayout);
		}
		«ELSE»
		protected org.eclipse.swt.custom.StackLayout stackLayout;
		protected void initParentLayout() {
			stackLayout = new org.eclipse.swt.custom.StackLayout();
			parent.setLayout(stackLayout);
			stackLayout.topControl = main;
		}
		«ENDIF»
	'''
}

def static String detailsPageCreateSection(UpdateTask it) {
	'''
		protected org.eclipse.ui.forms.widgets.Section section;

		protected org.eclipse.ui.forms.widgets.Section createSection() {
			org.eclipse.ui.forms.widgets.Section result = getToolkit().createSection(«IF viewProperties.typeSelect(ReferenceViewProperty).isEmpty»parent«ELSE»main«ENDIF», org.eclipse.ui.forms.widgets.ExpandableComposite.ED(it) | org.eclipse.ui.forms.widgets.ExpandableComposite.TITLE_BAR);
			org.eclipse.swt.layout.GridData sectionGd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false);
			result.setLayoutData(sectionGd);
			«IF isPossibleSubtask()»
			if (subtaskParentTitle != null) {
				result.setText(subtaskParentTitle + «getMessagesClass()».breadCrumb_separator +
				        «getMessagesClass()».breadCrumb_update + " " + «getMessagesClass()».«for.getMessagesKey()»); //$NON-NLS-1$
			} else {
				result.setText(«getMessagesClass()».breadCrumb_update + " " + «getMessagesClass()».«for.getMessagesKey()»); //$NON-NLS-1$
			}
			«ELSE»
				result.setText(«getMessagesClass()».breadCrumb_update + " " + «getMessagesClass()».«for.getMessagesKey()»); //$NON-NLS-1$
			«ENDIF»
			return result;
		}

		protected org.eclipse.ui.forms.widgets.Section getSection() {
			return section;
		}

		protected String getTitle() {
			return section.getText();
		}
	'''
}

def static String detailsPageCreatePageContainer(UpdateTask it) {
	'''
		protected org.eclipse.swt.widgets.Composite pageContainer;

		protected org.eclipse.swt.widgets.Composite createPageContainer() {
			org.eclipse.swt.widgets.Composite result = getToolkit().createComposite(section, org.eclipse.swt.SWT.NONE);
			org.eclipse.swt.layout.GridLayout compositeGridLayout = new org.eclipse.swt.layout.GridLayout();
			compositeGridLayout.numColumns = 2;
			result.setLayout(compositeGridLayout);
			getToolkit().paintBordersFor(result);
			section.setClient(result);
			return result;
		}

		protected org.eclipse.swt.widgets.Composite getPageContainer() {
			return pageContainer;
		}
	'''
}


}
