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

class RcpCrudGuiPageTmpl {



def static String pageCreateWidget(ViewDataProperty it) {
	'''
	'''
}

def static String pageCreateWidget(AttributeViewProperty it) {
	'''
	«pageCreateAttributeWidget(it)(getAttributeType())»
	'''
}

def static String pageCreateWidget(BasicTypeViewProperty it) {
	'''
	«pageCreateAttributeWidget(it)(getAttributeType())»
	'''
}

def static String pageCreateAttributeWidget(ViewDataProperty it, String attributeType) {
	'''
	«IF attributeType == "Date"»
		«IF isNullable()»
			«pageCreateDateField(it)»
		«ELSE»
			«pageCreateRequiredDateField(it)»
		«ENDIF»
	«ELSEIF attributeType.toLowerCase() == "boolean"»
		«IF isNullable()»
			«pageCreateOptionalBooleanWidget(it)»
		«ELSE»
			«pageCreateRequiredBooleanWidget(it)»
		«ENDIF»
	«ELSE»
		«pageCreateTextField(it)»
	«ENDIF»
	'''
}

def static String pageCreateTextField(ViewDataProperty it) {
	'''
		protected org.eclipse.swt.widgets.Text «name»;

		protected org.eclipse.swt.widgets.Text create«name.toFirstUpper()»() {
			«pageLabel(it)»
		«IF userTask.metaType == UpdateTask»
		org.eclipse.swt.widgets.Text result = getToolkit().createText(pageContainer, null, org.eclipse.swt.SWT.«IF isChangeable()»NONE«ELSE»READ_ONLY«ENDIF»);
			result.setEditable(«IF isChangeable()»!isReadOnly()«ELSE»false«ENDIF»);
		«ELSE»
			org.eclipse.swt.widgets.Text result = new org.eclipse.swt.widgets.Text(pageContainer, org.eclipse.swt.SWT.BORDER);
			«ENDIF»
			org.eclipse.swt.layout.GridData gd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false);
			result.setLayoutData(gd);

			getTargetObservables().put("«name»", org.eclipse.jface.databinding.swt.SWTObservables.observeText(result, org.eclipse.swt.SWT.Modify)); //$NON-NLS-1$
			return result;
		}

		protected org.eclipse.swt.widgets.Text get«name.toFirstUpper()»Widget() {
			return «name»;
		}
	'''
}

def static String pageCreateRequiredBooleanWidget(ViewDataProperty it) {
	'''
		protected org.eclipse.swt.widgets.Button «name»;

		protected org.eclipse.swt.widgets.Button create«name.toFirstUpper()»() {
			«pageLabel(it)»
		«IF userTask.metaType == UpdateTask»
			org.eclipse.swt.widgets.Button result = getToolkit().createButton(pageContainer, "", org.eclipse.swt.SWT.CHECK); //$NON-NLS-1$
	        «IF isChangeable()»
			result.setEnabled(!isReadOnly());
			    «ELSE»
			result.setEnabled(false);
	        «ENDIF»
		«ELSE»
			org.eclipse.swt.widgets.Button result = new org.eclipse.swt.widgets.Button(pageContainer, org.eclipse.swt.SWT.CHECK); //$NON-NLS-1$
			«ENDIF»
			org.eclipse.swt.layout.GridData gd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false);
			result.setLayoutData(gd);

			getTargetObservables().put("«name»", org.eclipse.jface.databinding.swt.SWTObservables.observeSelection(result)); //$NON-NLS-1$
			return result;
		}

		protected org.eclipse.swt.widgets.Button get«name.toFirstUpper()»Widget() {
			return «name»;
		}
	'''
}

def static String pageCreateOptionalBooleanWidget(ViewDataProperty it) {
	'''
	protected org.eclipse.jface.viewers.ComboViewer «name»;

		protected org.eclipse.jface.viewers.ComboViewer create«name.toFirstUpper()»() {
			«pageLabel(it)»

			org.eclipse.jface.viewers.ComboViewer result = new org.eclipse.jface.viewers.ComboViewer(pageContainer, org.eclipse.swt.SWT.READ_ONLY);
		«IF userTask.metaType == UpdateTask»
		result.getCombo().setEnabled(!isReadOnly());
			«ENDIF»
			result.setContentProvider(new org.eclipse.jface.viewers.ArrayContentProvider());
			java.util.List<Object> input = new java.util.ArrayList<Object>();
			input.add("");
			input.add(Boolean.FALSE);
			input.add(Boolean.TRUE);
			result.setInput(input);
			result.setLabelProvider(new org.eclipse.jface.viewers.LabelProvider() {
				@Override
				public String getText(Object element) {
					if (element == null || "".equals(element)) {
						return "";
					}
				    return «userTask.getMessagesClass()».getString("booleanSelect_" + String.valueOf(element)); //$NON-NLS-1$
				}
			});
			org.eclipse.swt.layout.GridData gd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false);
			result.getCombo().setLayoutData(gd);

			getTargetObservables().put("«name»", org.eclipse.jface.databinding.viewers.ViewersObservables.observeSingleSelection(result)); //$NON-NLS-1$
			return result;
		}
	'''
}

def static String pageLabel(ViewDataProperty it) {
	'''
		«IF userTask.metaType == UpdateTask»
		org.eclipse.swt.widgets.Label label = getToolkit().createLabel(pageContainer,
				«userTask.getMessagesClass()».«getMessagesKey()», org.eclipse.swt.SWT.NONE);
			label.setForeground(getToolkit().getColors().getColor(org.eclipse.ui.forms.IFormColors.TITLE));
		«ELSE»
		org.eclipse.swt.widgets.Label label = new org.eclipse.swt.widgets.Label(pageContainer, org.eclipse.swt.SWT.NONE);
			label.setText(«userTask.getMessagesClass()».«getMessagesKey()»);
			«ENDIF»
			label.setLayoutData(new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.RIGHT, org.eclipse.swt.SWT.CENTER, false, false));
			«IF !isChangeable() && !isNullable()»
			label.setFont(«fw("richclient.util.SWTResourceManager")».getBoldItalicFont(label.getFont()));
			«ELSEIF !isChangeable()»
			label.setFont(«fw("richclient.util.SWTResourceManager")».getItalicFont(label.getFont()));
			«ELSEIF !isNullable()»
			label.setFont(«fw("richclient.util.SWTResourceManager")».getBoldFont(label.getFont()));
			«ENDIF»
	'''
}

def static String pageCreateRequiredDateField(ViewDataProperty it) {
	'''
/*DateTime sample: http://dev.eclipse.org/viewcvs/index.cgi/org.eclipse.swt.snippets/src/org/eclipse/swt/snippets/Snippet250.java?view=co
	note that time is also possible, and calendar
	new org.eclipse.swt.widgets.DateTime(composite, org.eclipse.swt.SWT.CALENDAR | org.eclipse.swt.SWT.BORDER);
 */
		protected org.eclipse.swt.widgets.DateTime «name»;

		protected org.eclipse.swt.widgets.DateTime create«name.toFirstUpper()»() {
			«pageLabel(it)»
		org.eclipse.swt.widgets.DateTime result = new org.eclipse.swt.widgets.DateTime(pageContainer, org.eclipse.swt.SWT.NONE);
		«IF userTask.metaType == UpdateTask»
			«IF isChangeable()»
			result.setEnabled(!isReadOnly());
	        «ELSE»
			result.setEnabled(false);
			    «ENDIF»
			getToolkit().adapt(result, true, true);
			«ENDIF»
			org.eclipse.swt.layout.GridData gd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false);
			result.setLayoutData(gd);
			getTargetObservables().put("«name»",
			«IF getDateTimeLibrary() == "joda"»
				new «fw("richclient.databinding.JodaLocalDateObservableValue")»(result)); //$NON-NLS-1$
			«ELSE»
				new «fw("richclient.databinding.DateTimeObservableValue")»(result)); //$NON-NLS-1$
			«ENDIF»
			return result;
		}

		protected org.eclipse.swt.widgets.DateTime get«name.toFirstUpper()»() {
			return «name»;
		}
	'''
}

def static String pageCreateDateField(ViewDataProperty it) {
	'''
		protected org.eclipse.swt.widgets.DateTime «name»;
		protected org.eclipse.swt.widgets.Button «name»Defined;

		protected org.eclipse.swt.widgets.DateTime create«name.toFirstUpper()»() {
			«pageLabel(it)»
		«IF userTask.metaType == UpdateTask»
		org.eclipse.swt.widgets.Composite dateComposite = getToolkit().createComposite(pageContainer, org.eclipse.swt.SWT.NONE);
		getToolkit().paintBordersFor(dateComposite);
		«ELSE»
		org.eclipse.swt.widgets.Composite dateComposite = new org.eclipse.swt.widgets.Composite(pageContainer, org.eclipse.swt.SWT.NONE);
			«ENDIF»
			org.eclipse.swt.layout.GridLayout compositeGridLayout = new org.eclipse.swt.layout.GridLayout();
			compositeGridLayout.numColumns = 2;
			dateComposite.setLayout(compositeGridLayout);
			org.eclipse.swt.layout.GridData dateCompositeGd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false);
			dateComposite.setLayoutData(dateCompositeGd);

			«IF userTask.metaType == UpdateTask»
			«name»Defined = getToolkit().createButton(dateComposite, "", org.eclipse.swt.SWT.CHECK); //$NON-NLS-1$
	        «IF isChangeable()»
			«name»Defined.setEnabled(!isReadOnly());
			    «ELSE»
			«name»Defined.setEnabled(false);
	        «ENDIF»
		«ELSE»
			«name»Defined = new org.eclipse.swt.widgets.Button(dateComposite, org.eclipse.swt.SWT.CHECK); //$NON-NLS-1$
			«ENDIF»

			org.eclipse.swt.widgets.DateTime result = new org.eclipse.swt.widgets.DateTime(dateComposite, org.eclipse.swt.SWT.NONE);
			«IF userTask.metaType == UpdateTask»
				«IF isChangeable()»
			result.setEnabled(!isReadOnly());
			    «ELSE»
			result.setEnabled(false);
	        «ENDIF»
			getToolkit().adapt(result, true, true);
			«ENDIF»
			org.eclipse.swt.layout.GridData gd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false);
			result.setLayoutData(gd);

			«name»Defined.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
				public void widgetSelected(org.eclipse.swt.events.SelectionEvent e) {
				    evaluate«name.toFirstUpper()»Enabled();
				}
			});

			getTargetObservables().put("«name»",
			«IF getDateTimeLibrary() == "joda"»
				new «fw("richclient.databinding.JodaLocalDateObservableValue")»(result)); //$NON-NLS-1$
			«ELSE»
				new «fw("richclient.databinding.DateTimeObservableValue")»(result)); //$NON-NLS-1$
			«ENDIF»
			getTargetObservables().put("«name»Defined", org.eclipse.jface.databinding.swt.SWTObservables.observeSelection(«name»Defined)); //$NON-NLS-1$

			return result;
		}

		protected org.eclipse.swt.widgets.DateTime get«name.toFirstUpper()»() {
			return «name»;
		}

		protected void evaluate«name.toFirstUpper()»Enabled() {
			«name».setEnabled(«name»Defined.getSelection());
		}

	'''
}

def static String pageCreateWidget(EnumViewProperty it) {
	'''
		protected org.eclipse.jface.viewers.ComboViewer «name»;

		protected org.eclipse.jface.viewers.ComboViewer create«name.toFirstUpper()»() {
			«pageLabel(it)»

			org.eclipse.jface.viewers.ComboViewer result = new org.eclipse.jface.viewers.ComboViewer(pageContainer, org.eclipse.swt.SWT.READ_ONLY);
		«IF userTask.metaType == UpdateTask»
		result.getCombo().setEnabled(!isReadOnly());
			«ENDIF»
			result.setContentProvider(new org.eclipse.jface.viewers.ArrayContentProvider());
			result.setInput(getController().get«name.toFirstUpper()»Input());
			result.setLabelProvider(new org.eclipse.jface.viewers.LabelProvider() {
				@Override
				public String getText(Object element) {
					if (element == null || "".equals(element)) {
						return "";
					}
				    return «userTask.getMessagesClass()».getString("«reference.to.getMessagesKey()»_" + ((«reference.to.getDomainPackage()».«reference.to.name») element).getName()); //$NON-NLS-1$
				}
			});
			org.eclipse.swt.layout.GridData gd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false);
			result.getCombo().setLayoutData(gd);

			getTargetObservables().put("«name»", org.eclipse.jface.databinding.viewers.ViewersObservables.observeSingleSelection(result)); //$NON-NLS-1$
			return result;
		}
	'''
}

def static String pageCreateWidgetSingleSelect(ReferenceViewProperty it) {
	'''
		protected org.eclipse.jface.viewers.ComboViewer «name»;

		protected org.eclipse.jface.viewers.ComboViewer create«name.toFirstUpper()»() {
			«pageLabel(it)»

			org.eclipse.jface.viewers.ComboViewer result = new org.eclipse.jface.viewers.ComboViewer(pageContainer, org.eclipse.swt.SWT.READ_ONLY);
		«IF userTask.metaType == UpdateTask»
		result.getCombo().setEnabled(!isReadOnly());
			«ENDIF»
			result.setContentProvider(new org.eclipse.jface.viewers.ArrayContentProvider());
		«pageCreateWidgetSingleSelectLabelProvider(it)»
			org.eclipse.swt.layout.GridData gd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false);
			result.getCombo().setLayoutData(gd);

			getTargetObservables().put("«name»", org.eclipse.jface.databinding.viewers.ViewersObservables.observeSingleSelection(result)); //$NON-NLS-1$
			return result;
		}
	'''
}

def static String pageCreateWidgetSingleSelectLabelProvider(ReferenceViewProperty it) {
	'''
	«val addTask = it.getRelatedAddTask()»
		result.setLabelProvider(new org.eclipse.jface.viewers.LabelProvider() {
				@Override
				public String getText(Object element) {
					if (element == null || "".equals(element)) {
				    	return "";
				    }
					«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name» value = («relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«target.name») element; 
				    StringBuilder sb = new StringBuilder();
				    «FOR e SEPARATOR 'sb.append(" | ");' : addTask.viewProperties»
				    	sb.append(value.get«e.name.toFirstUpper()»());
				    «ENDFOR»
				    return sb.toString();
				}
			});
	'''
}

def static String pageSingleSelectSelection(ReferenceViewProperty it) {
	'''
		public org.eclipse.jface.viewers.IStructuredSelection get«resolveReferenceName()»Selection() {
			return (org.eclipse.jface.viewers.IStructuredSelection) «resolveReferenceName().toFirstLower()».getSelection();
		}

		public void set«resolveReferenceName()»Selection(org.eclipse.jface.viewers.IStructuredSelection selection) {
			«resolveReferenceName().toFirstLower()».setSelection(selection, true);

		}
	'''
}

def static String pageCreateWidget(ReferenceViewProperty it) {
	'''
	«IF !base »
	«IF isSingleSelectAddSubTask()»
	«pageCreateWidgetSingleSelect(it)»
	«pageSingleSelectSelection(it)»
	«IF isAddSubTaskAvailable() && (userTask.metaType == CreateTask || isChangeable())»
		«pageReferenceShowAddSubtask(it)»
	«ENDIF»
	«IF (userTask.metaType == CreateTask || isChangeable())»
		«pageReferenceShowRemoveSubtask(it)»
	«ENDIF»
	«ELSE»
	«pageReferenceCreateSection(it)»
	«pageReferenceCreateComposite(it)»
	«pageReferenceCreateViewer(it)»
	«pageReferenceDefineColumns(it)»
	«pageReferenceSelection(it)»
	«pageReferenceEvaluateButtonsEnabled(it)»
	«IF isCreateSubTaskAvailable() && (userTask.metaType == CreateTask || isChangeable())»
		«pageReferenceCreateNewButton(it)»
		«pageReferenceShowNewSubtask(it)»
	«ENDIF»
	«IF isAddSubTaskAvailable() && (userTask.metaType == CreateTask || isChangeable())»
	    «pageReferenceCreateAddButton(it)»
		«pageReferenceShowAddSubtask(it)»
	«ENDIF»
	«IF userTask.metaType == UpdateTask»
		«IF isUpdateSubTaskAvailable()»
	    	«pageReferenceCreateEditButton(it)»
			«pageReferenceShowEditSubtask(it)»
			«pageReferenceCreatePage(it)»
	    «ENDIF»
		«ENDIF»
		«IF (userTask.metaType == CreateTask || isChangeable())»
		«pageReferenceCreateRemoveButton(it)»
		«pageReferenceShowRemoveSubtask(it)»
	«ENDIF»
	«ENDIF »
	«ENDIF »
	'''
}

def static String pageReferenceCreateSection(ReferenceViewProperty it) {
	'''
		protected org.eclipse.ui.forms.widgets.Section «resolveReferenceName().toFirstLower()»Section;

		protected org.eclipse.ui.forms.widgets.Section create«resolveReferenceName()»Section() {
			«IF userTask.metaType == UpdateTask»
			org.eclipse.ui.forms.widgets.Section result = getToolkit().createSection(main,
				    org.eclipse.ui.forms.widgets.Section.TWISTIE | org.eclipse.ui.forms.widgets.Section.ED(it) | org.eclipse.ui.forms.widgets.Section.TITLE_BAR);
			org.eclipse.swt.layout.GridData sectionGd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false);
				«IF isMany()»
			result.setText(org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».detailsPage_reference_many,
				«ELSE»
			result.setText(org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».detailsPage_reference,
				«ENDIF»
				«userTask.getMessagesClass()».«getMessagesKey()»,
				«relatedTransitions.first().to.getMessagesClass()».«target.getMessagesKey()»));
		«ELSE»
			org.eclipse.ui.forms.widgets.Section result = new org.eclipse.ui.forms.widgets.Section(pageContainer,
				    org.eclipse.ui.forms.widgets.Section.TWISTIE | org.eclipse.ui.forms.widgets.Section.ED(it) | org.eclipse.ui.forms.widgets.Section.TITLE_BAR);
			org.eclipse.swt.layout.GridData sectionGd = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.CENTER, true, false, 2, 1);
				«IF isMany()»
			result.setText(org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».newWizardPage_reference_many,
				«ELSE»
			result.setText(org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».newWizardPage_reference,
				«ENDIF»
				«userTask.getMessagesClass()».«getMessagesKey()»,
				«relatedTransitions.first().to.getMessagesClass()».«target.getMessagesKey()»));
			«ENDIF»
			result.setLayoutData(sectionGd);
			«IF !isChangeable() && !isNullable()»
			result.setFont(«fw("richclient.util.SWTResourceManager")».getBoldItalicFont(result.getFont()));
			«ELSEIF !isChangeable()»
			result.setFont(«fw("richclient.util.SWTResourceManager")».getItalicFont(result.getFont()));
			«ELSEIF !isNullable()»
			result.setFont(«fw("richclient.util.SWTResourceManager")».getBoldFont(result.getFont()));
			«ENDIF»

			return result;
		}
	'''
}

def static String pageReferenceCreateComposite(ReferenceViewProperty it) {
	'''
		protected org.eclipse.swt.widgets.Composite «resolveReferenceName().toFirstLower()»Composite;

		protected org.eclipse.swt.widgets.Composite create«resolveReferenceName()»Composite() {
			«IF userTask.metaType == UpdateTask»
			org.eclipse.swt.widgets.Composite result = getToolkit().createComposite(«resolveReferenceName().toFirstLower()»Section, org.eclipse.swt.SWT.NONE);
			getToolkit().paintBordersFor(result);
		«ELSE»
			org.eclipse.swt.widgets.Composite result = new org.eclipse.swt.widgets.Composite(«resolveReferenceName().toFirstLower()»Section, org.eclipse.swt.SWT.NONE);
			«ENDIF»
			org.eclipse.swt.layout.GridLayout compositeGridLayout = new org.eclipse.swt.layout.GridLayout();
			compositeGridLayout.numColumns = 2;
			result.setLayout(compositeGridLayout);
			«resolveReferenceName().toFirstLower()»Section.setClient(result);

			return result;
		}
	'''
}

def static String pageReferenceCreateViewer(ReferenceViewProperty it) {
	'''
		protected «fw("richclient.table.CustomizableTableViewer")» «resolveReferenceName().toFirstLower()»TableViewer;

		protected «fw("richclient.table.CustomizableTableViewer")» create«resolveReferenceName()»Viewer() {
			«fw("richclient.table.CustomizableTableViewer")» result = «fw("richclient.table.CustomizableTableViewer")».newTable(«resolveReferenceName().toFirstLower()»Composite,
				    org.eclipse.swt.SWT.MULTI | org.eclipse.swt.SWT.BORDER | org.eclipse.swt.SWT.H_SCROLL | org.eclipse.swt.SWT.V_SCROLL | org.eclipse.swt.SWT.FULL_SELECTION);
			define«resolveReferenceName()»Columns(result);
			org.eclipse.swt.layout.GridData gridData = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.FILL, true, true, 1, 4);
			gridData.heightHint = 70;
			result.getViewer().getTable().setLayoutData(gridData);
			org.eclipse.swt.widgets.Table table = result.getViewer().getTable();
			table.setLinesVisible(true);
			table.setHeaderVisible(true);
			result.getViewer().setContentProvider(new org.eclipse.jface.databinding.viewers.ObservableListContentProvider());

			result.getViewer().addSelectionChangedListener(new org.eclipse.jface.viewers.ISelectionChangedListener() {
				public void selectionChanged(org.eclipse.jface.viewers.SelectionChangedEvent event) {
				    evaluate«resolveReferenceName()»ButtonsEnabled();
				}
			});

			return result;
		}
	'''
}

def static String pageReferenceDefineColumns(ReferenceViewProperty it) {
	'''
		protected void define«resolveReferenceName()»Columns(«fw("richclient.table.CustomizableTableViewer")» tableViewer) {
			new «fw("richclient.table.TableDefinition")»(tableViewer) {
				{
				«FOR prop : previewProperties»
				    column(«relatedTransitions.first().to.getMessagesClass()».«prop.getMessagesKey()»).property("«prop.name»");
				«ENDFOR»
				}
			}.build();
		}
	'''
}

def static String pageReferenceSelection(ReferenceViewProperty it) {
	'''
		public org.eclipse.jface.viewers.IStructuredSelection get«resolveReferenceName()»Selection() {
			return (org.eclipse.jface.viewers.IStructuredSelection) «resolveReferenceName().toFirstLower()»TableViewer.getViewer().getSelection();
		}

		public void set«resolveReferenceName()»Selection(org.eclipse.jface.viewers.IStructuredSelection selection) {
			«resolveReferenceName().toFirstLower()»TableViewer.getViewer().setSelection(selection, true);

		}
	'''
}

def static String pageReferenceEvaluateButtonsEnabled(ReferenceViewProperty it) {
	'''
		@SuppressWarnings("unchecked")
		protected void evaluate«resolveReferenceName()»ButtonsEnabled() {
			if («resolveReferenceName().toFirstLower()»TableViewer == null) {
				return;
			}
			«IF userTask.metaType == UpdateTask»
			if (isReadOnly()) {
				return;
			}
			«ENDIF»
			org.eclipse.jface.viewers.IStructuredSelection selection = (org.eclipse.jface.viewers.IStructuredSelection) «resolveReferenceName().toFirstLower()»TableViewer.getViewer().getSelection();
			java.util.List selectedElements = selection.toList();
			«IF userTask.metaType == UpdateTask»
		    «IF isUpdateSubTaskAvailable()»
			boolean singleSelected = selectedElements.size() == 1;
			«resolveReferenceName().toFirstLower()»EditButton.setEnabled(singleSelected);
		    «ENDIF»
			«ENDIF»
			«IF (userTask.metaType == CreateTask || isChangeable())»
			«resolveReferenceName().toFirstLower()»RemoveButton.setEnabled(!selectedElements.isEmpty());
			«ENDIF»
		}
	'''
}

def static String pageReferenceCreateNewButton(ReferenceViewProperty it) {
	'''
		protected org.eclipse.swt.widgets.Button «resolveReferenceName().toFirstLower()»NewButton;

		protected org.eclipse.swt.widgets.Button create«resolveReferenceName()»NewButton() {
			«IF userTask.metaType == UpdateTask»
			org.eclipse.swt.widgets.Button result = getToolkit().createButton(«resolveReferenceName().toFirstLower()»Composite,
				«userTask.getMessagesClass()».newButton, org.eclipse.swt.SWT.PUSH);
			result.setEnabled(!isReadOnly());
		«ELSE»
		org.eclipse.swt.widgets.Button result = new org.eclipse.swt.widgets.Button(«resolveReferenceName().toFirstLower()»Composite, org.eclipse.swt.SWT.PUSH);
			result.setText(«userTask.getMessagesClass()».newButton);
			«ENDIF»
			org.eclipse.swt.layout.GridData gridData = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.LEFT, false, false, 1, 1);
			gridData.widthHint = 80;
			result.setLayoutData(gridData);
			result.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
				public void widgetSelected(org.eclipse.swt.events.SelectionEvent event) {
				    getController().new«resolveReferenceName()»Subtask();
				}
			});

			return result;
		}
	'''
}

def static String pageReferenceCreateAddButton(ReferenceViewProperty it) {
	'''
		protected org.eclipse.swt.widgets.Button «resolveReferenceName().toFirstLower()»AddButton;

		protected org.eclipse.swt.widgets.Button create«resolveReferenceName()»AddButton() {
			«IF userTask.metaType == UpdateTask»
			org.eclipse.swt.widgets.Button result = getToolkit().createButton(«resolveReferenceName().toFirstLower()»Composite,
				«userTask.getMessagesClass()».addButton_«isMany() ? "many" : "one"», org.eclipse.swt.SWT.PUSH);
			result.setEnabled(!isReadOnly());
		«ELSE»
			org.eclipse.swt.widgets.Button result = new org.eclipse.swt.widgets.Button(«resolveReferenceName().toFirstLower()»Composite, org.eclipse.swt.SWT.PUSH);
			result.setText(«userTask.getMessagesClass()».addButton_«isMany() ? "many" : "one"»);
			«ENDIF»
			org.eclipse.swt.layout.GridData gridData = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.LEFT, false, false, 1, 1);
			gridData.widthHint = 80;
			result.setLayoutData(gridData);
			result.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
				public void widgetSelected(org.eclipse.swt.events.SelectionEvent event) {
				    getController().add«resolveReferenceName()»Subtask();
				}
			});

			return result;
		}
	'''
}

def static String pageReferenceCreateEditButton(ReferenceViewProperty it) {
	'''
		protected org.eclipse.swt.widgets.Button «resolveReferenceName().toFirstLower()»EditButton;

		protected org.eclipse.swt.widgets.Button create«resolveReferenceName()»EditButton() {
			«IF userTask.metaType == UpdateTask»
			org.eclipse.swt.widgets.Button result = getToolkit().createButton(«resolveReferenceName().toFirstLower()»Composite,
				«userTask.getMessagesClass()».editButton, org.eclipse.swt.SWT.PUSH);
			result.setEnabled(!isReadOnly());
		«ELSE»
			org.eclipse.swt.widgets.Button result = new org.eclipse.swt.widgets.Button(«resolveReferenceName().toFirstLower()»Composite, org.eclipse.swt.SWT.PUSH);
			result.setText(«userTask.getMessagesClass()».editButton);
			«ENDIF»
			org.eclipse.swt.layout.GridData gridData = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.LEFT, false, false, 1, 1);
			gridData.widthHint = 80;
			result.setLayoutData(gridData);
			result.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
				public void widgetSelected(org.eclipse.swt.events.SelectionEvent event) {
				    getController().edit«resolveReferenceName()»Subtask();
				}
			});

			return result;
		}
	'''
}

def static String pageReferenceCreateRemoveButton(ReferenceViewProperty it) {
	'''
		protected org.eclipse.swt.widgets.Button «resolveReferenceName().toFirstLower()»RemoveButton;

		protected org.eclipse.swt.widgets.Button create«resolveReferenceName()»RemoveButton() {
			«IF userTask.metaType == UpdateTask»
			org.eclipse.swt.widgets.Button result = getToolkit().createButton(«resolveReferenceName().toFirstLower()»Composite,
				«userTask.getMessagesClass()».removeButton, org.eclipse.swt.SWT.PUSH);
			result.setEnabled(!isReadOnly());
		«ELSE»
			org.eclipse.swt.widgets.Button result = new org.eclipse.swt.widgets.Button(«resolveReferenceName().toFirstLower()»Composite, org.eclipse.swt.SWT.PUSH);
			result.setText(«userTask.getMessagesClass()».removeButton);
			«ENDIF»
			org.eclipse.swt.layout.GridData gridData = new org.eclipse.swt.layout.GridData(org.eclipse.swt.SWT.FILL, org.eclipse.swt.SWT.LEFT, false, false, 1, 1);
			gridData.widthHint = 80;
			result.setLayoutData(gridData);
			result.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
				public void widgetSelected(org.eclipse.swt.events.SelectionEvent event) {
				    getController().remove«resolveReferenceName()»Subtask();
				}
			});

			return result;
		}
	'''
}

def static String pageReferenceShowNewSubtask(ReferenceViewProperty it) {
	'''
		public void showNew«resolveReferenceName()»Subtask(«fw("richclient.controller.ParentOfSubtask")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«relatedTransitions.first().to.for.name»> subtaskParent) {
			try {
				«relatedTransitions.first().to.module.getRichClientPackage()».ui.New«relatedTransitions.first().to.for.name»Wizard wizard = (New«relatedTransitions.first().to.for.name»Wizard) org.eclipse.ui.PlatformUI.getWorkbench().getNewWizardRegistry().findWizard(
				        New«relatedTransitions.first().to.for.name»Wizard.ID).createWizard();
				wizard.init(org.eclipse.ui.PlatformUI.getWorkbench(), subtaskParent, getTitle());
				org.eclipse.jface.wizard.WizardDialog wizardDialog = new org.eclipse.jface.wizard.WizardDialog(org.eclipse.swt.widgets.Display.getDefault().getActiveShell(), wizard);
				wizardDialog.create();
				wizardDialog.open();
			} catch (org.eclipse.core.runtime.CoreException e) {
				throw new RuntimeException(e.getMessage(), e);
			}
		}
	'''
}

def static String pageReferenceShowAddSubtask(ReferenceViewProperty it) {
	'''
		public void showAdd«resolveReferenceName()»Subtask(«fw("richclient.controller.ParentOfSubtask")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«relatedTransitions.first().to.for.name»> subtaskParent) {
			org.eclipse.swt.widgets.Shell shell = org.eclipse.ui.PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell();
			«relatedTransitions.first().to.module.getRichClientPackage()».ui.Add«relatedTransitions.first().to.for.name»Dialog dialog = new «relatedTransitions.first().to.module.getRichClientPackage()».ui.Add«relatedTransitions.first().to.for.name»Dialog(shell);
			dialog.init(subtaskParent, getTitle(), «!isMany()»);
			dialog.setBlockOnOpen(true);
			dialog.open();
		}
	'''
}

def static String pageReferenceShowEditSubtask(ReferenceViewProperty it) {
	'''
		public void showEdit«resolveReferenceName()»Subtask(«fw("richclient.controller.ParentOfSubtask")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«relatedTransitions.first().to.for.name»> subtaskParent, «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«relatedTransitions.first().to.for.name» item) {
			if («resolveReferenceName().toFirstLower()»PageCompostite == null) {
				«resolveReferenceName().toFirstLower()»PageCompostite = create«resolveReferenceName()»Page(subtaskParent);
			}
			«resolveReferenceName().toFirstLower()»Page.setFormInput(item);
			stackLayout.topControl = «resolveReferenceName().toFirstLower()»PageCompostite;
			parent.layout();
		}
	'''
}

def static String pageReferenceShowRemoveSubtask(ReferenceViewProperty it) {
	'''
		public void showRemove«resolveReferenceName()»Subtask(«fw("richclient.controller.ParentOfSubtask")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«relatedTransitions.first().to.for.name»> subtaskParent, «relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«relatedTransitions.first().to.for.name» item) {
			String title = «userTask.getMessagesClass()».remove_question_title;
			String message = org.eclipse.osgi.util.NLS.bind(«userTask.getMessagesClass()».remove_question,
				«relatedTransitions.first().to.getMessagesClass()».«target.getMessagesKey()»,
				«userTask.getMessagesClass()».«userTask.for.getMessagesKey()»);
			boolean yes = openQuestion(title, message);
			if (yes) {
				subtaskParent.subtaskCompleted(item);
			} else {
				subtaskParent.subtaskCancelled();
			}
		}
	'''
}

def static String pageReferenceCreatePage(ReferenceViewProperty it) {
	'''
	@org.springframework.beans.factory.annotation.Autowired
		private «relatedTransitions.first().to.module.getRichClientPackage()».ui.«relatedTransitions.first().to.for.name»DetailsPage «resolveReferenceName().toFirstLower()»Page;

		protected org.eclipse.swt.widgets.Composite «resolveReferenceName().toFirstLower()»PageCompostite;

		protected org.eclipse.swt.widgets.Composite create«resolveReferenceName()»Page(«fw("richclient.controller.ParentOfSubtask")»<«relatedTransitions.first().to.module.getRichClientPackage()».data.Rich«relatedTransitions.first().to.for.name»> subtaskParent) {
			«resolveReferenceName().toFirstLower()»Page.setSubtaskParent(subtaskParent, section.getText());
			«IF userTask.metaType == UpdateTask»
			«resolveReferenceName().toFirstLower()»Page.setReadOnly(false);
			«resolveReferenceName().toFirstLower()»Page.initialize(getManagedForm());
			org.eclipse.swt.widgets.Composite result = getToolkit().createComposite(parent, org.eclipse.swt.SWT.NONE);
			getToolkit().paintBordersFor(result);
		«ELSE»
			«resolveReferenceName().toFirstLower()»Page.initialize(getManagedForm());
			org.eclipse.swt.widgets.Composite result = new org.eclipse.swt.widgets.Composite(parent, org.eclipse.swt.SWT.NONE);
			«ENDIF»

			«resolveReferenceName().toFirstLower()»Page.createContents(result);
			return result;
		}
	'''
}

def static String pageSubtaskParent(UserTask it) {
	'''
		private String subtaskParentTitle;

		protected void setSubtaskParent(«fw("richclient.controller.ParentOfSubtask")»<«module.getRichClientPackage()».data.Rich«for.name»> subtaskParent, String parentTitle) {
			subtaskParentTitle = parentTitle;
			getController().setSubtaskParent(subtaskParent);
		}
	'''
}

def static String pageCreateSubtaskButtonBar(UpdateTask it) {
	'''
		protected org.eclipse.swt.widgets.Composite subtaskButtonComposite;

		protected org.eclipse.swt.widgets.Composite createSubtaskButtonBar() {
			org.eclipse.swt.widgets.Composite result = getToolkit().createComposite(«IF viewProperties.typeSelect(ReferenceViewProperty).isEmpty»parent«ELSE»main«ENDIF», org.eclipse.swt.SWT.NONE);
			// create a layout with spacing and margins appropriate for the font size.
			org.eclipse.swt.layout.GridLayout layout = new org.eclipse.swt.layout.GridLayout();
			layout.numColumns = 0; // this is incremented by createButton
			layout.makeColumnsEqualWidth = true;
			layout.marginWidth = 10;
			layout.marginHeight = 10;
			layout.horizontalSpacing = 5;
			layout.verticalSpacing = 5;
			result.setLayout(layout);
			org.eclipse.swt.layout.GridData data = new org.eclipse.swt.layout.GridData(org.eclipse.swt.layout.GridData.HORIZONTAL_ALIGN_END | org.eclipse.swt.layout.GridData.VERTICAL_ALIGN_CENTER);
			result.setLayoutData(data);
			getToolkit().paintBordersFor(result);

			return result;
		}
	'''
}

def static String pageCreateSubtaskOkButton(UpdateTask it) {
	'''
		protected org.eclipse.swt.widgets.Button okButton;

		protected org.eclipse.swt.widgets.Button createOkButton() {
			org.eclipse.swt.widgets.Button result = createButton(subtaskButtonComposite, org.eclipse.jface.dialogs.IDialogConstants.OK_ID, org.eclipse.jface.dialogs.IDialogConstants.OK_LABEL, true);
			result.setVisible(!isReadOnly());
			result.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
				@Override
				public void widgetSelected(org.eclipse.swt.events.SelectionEvent event) {
				    getController().subtaskOk();
				}
			});
			getTargetObservables().put("ok", org.eclipse.jface.databinding.swt.SWTObservables.observeEnabled(result));

			return result;
		}

		protected org.eclipse.swt.widgets.Button getOkButton() {
			return okButton;
		}
	'''
}

def static String pageCreateSubtaskCancelButton(UpdateTask it) {
	'''
		protected org.eclipse.swt.widgets.Button cancelButton;

		protected org.eclipse.swt.widgets.Button createCancelButton() {
			org.eclipse.swt.widgets.Button result;
			if (isReadOnly()) {
				result = createButton(subtaskButtonComposite, org.eclipse.jface.dialogs.IDialogConstants.OK_ID,
				    org.eclipse.jface.dialogs.IDialogConstants.OK_LABEL, true);
			} else {
				result = createButton(subtaskButtonComposite, org.eclipse.jface.dialogs.IDialogConstants.CANCEL_ID,
				    org.eclipse.jface.dialogs.IDialogConstants.CANCEL_LABEL, false);
			}

			result.addSelectionListener(new org.eclipse.swt.events.SelectionAdapter() {
				@Override
				public void widgetSelected(org.eclipse.swt.events.SelectionEvent event) {
				    getController().subtaskCancel();
				}
			});

			return result;
		}

		protected org.eclipse.swt.widgets.Button getCancelButton() {
			return cancelButton;
		}
	'''
}

def static String pageCreateSubtaskButton(UpdateTask it) {
	'''
		protected org.eclipse.swt.widgets.Button createButton(org.eclipse.swt.widgets.Composite buttonBar, int id, String label,
				boolean defaultButton) {
			// increment the number of columns in the button bar
			((org.eclipse.swt.layout.GridLayout) buttonBar.getLayout()).numColumns++;
			org.eclipse.swt.widgets.Button button = getToolkit().createButton(buttonBar, label, org.eclipse.swt.SWT.PUSH);
			button.setText(label);
			button.setData(new Integer(id));
			if (defaultButton) {
				org.eclipse.swt.widgets.Shell shell = buttonBar.getShell();
				if (shell != null) {
				    shell.setDefaultButton(button);
				}
			}
			setButtonLayoutData(button);
			return button;
		}

		protected void setButtonLayoutData(org.eclipse.swt.widgets.Button button) {
			org.eclipse.swt.layout.GridData data = new org.eclipse.swt.layout.GridData(org.eclipse.swt.layout.GridData.HORIZONTAL_ALIGN_FILL);
			int widthHint = 60;
			org.eclipse.swt.graphics.Point minSize = button.computeSize(org.eclipse.swt.SWT.DEFAULT, org.eclipse.swt.SWT.DEFAULT, true);
			data.widthHint = Math.max(widthHint, minSize.x);
			button.setLayoutData(data);
		}
	'''
}

}
