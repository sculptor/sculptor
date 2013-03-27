/*
 * Copyright 2013 The Sculptor Project Team, including the original 
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

package org.sculptor.dsl.ui.outline

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.outline.IOutlineNode
import org.eclipse.xtext.ui.editor.outline.impl.DefaultOutlineTreeProvider
import org.eclipse.xtext.ui.editor.outline.impl.DocumentRootNode
import org.sculptor.dsl.sculptordsl.DslModel
import org.sculptor.dsl.sculptordsl.DslParameter
import org.sculptor.dsl.sculptordsl.DslRepositoryOperation
import org.sculptor.dsl.sculptordsl.DslServiceOperation

/**
 * Customization of the default outline structure.
 * <p>
 * The following model elements are skipped in the outline:
 * <ul>
 * <li>Root node of type {@link DslModel}
 * <li>Type of {@link DslParameter}
 * <li>Return type of {@link DslRepositoryOperation} and {@link DslServiceOperation}
 * </ul>
 * <p>
 * see http://www.eclipse.org/Xtext/documentation.html#outline
 */
class SculptordslOutlineTreeProvider extends DefaultOutlineTreeProvider {

	override protected _createChildren(DocumentRootNode parentNode, EObject modelElement) {
		modelElement.eContents.forEach[
			createNode(parentNode, it)
		]
	}

	def protected boolean _isLeaf(DslParameter parameter) {
		true
	}

	def protected _createChildren(IOutlineNode parentNode, DslParameter parameter) {
	}

	def protected boolean _isLeaf(DslRepositoryOperation op) {
		op.parameters.empty
	}

	def protected _createChildren(IOutlineNode parentNode, DslRepositoryOperation op) {
		op.eContents.forEach[
			createNode(parentNode, it)
		]
	}

	def protected boolean _isLeaf(DslServiceOperation op) {
		op.parameters.empty
	}

	def protected _createChildren(IOutlineNode parentNode, DslServiceOperation op) {
		op.eContents.forEach[
			createNode(parentNode, it)
		]
	}
	
}
