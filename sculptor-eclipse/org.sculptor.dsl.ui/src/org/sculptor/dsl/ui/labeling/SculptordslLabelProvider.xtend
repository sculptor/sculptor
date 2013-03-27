/*
 * Copyright 2013 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License")
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

package org.sculptor.dsl.ui.labeling

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslAttribute
import org.sculptor.dsl.sculptordsl.DslBasicType
import org.sculptor.dsl.sculptordsl.DslCollectionType
import org.sculptor.dsl.sculptordsl.DslConsumer
import org.sculptor.dsl.sculptordsl.DslEntity
import org.sculptor.dsl.sculptordsl.DslEnum
import org.sculptor.dsl.sculptordsl.DslImport
import org.sculptor.dsl.sculptordsl.DslModel
import org.sculptor.dsl.sculptordsl.DslModule
import org.sculptor.dsl.sculptordsl.DslParameter
import org.sculptor.dsl.sculptordsl.DslReference
import org.sculptor.dsl.sculptordsl.DslRepository
import org.sculptor.dsl.sculptordsl.DslRepositoryOperation
import org.sculptor.dsl.sculptordsl.DslService
import org.sculptor.dsl.sculptordsl.DslServiceOperation
import org.sculptor.dsl.sculptordsl.DslTrait
import org.sculptor.dsl.sculptordsl.DslValueObject

/**
 * Provides labels for a EObjects.
 * 
 * see http://www.eclipse.org/Xtext/documentation/latest/xtext.html#labelProvider
 */
class SculptordslLabelProvider extends DefaultEObjectLabelProvider {

	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate)
	}

	def text(EObject modelElement) {
		val feature = modelElement.eClass.getEStructuralFeature("name")
		if (feature != null) {
			val property = modelElement.eGet(feature)
			if (property != null && typeof(String).^class.isAssignableFrom(property.^class)) {
				return property
			}
		}
		null
	}

	def text(DslModel model) {
		"model"
	}

	def text(DslImport imp) {
		val uri = imp.getImportURI()
		val i = uri.lastIndexOf('/')
		var String name
		if (i != -1) {
			name = uri.substring(i + 1)
		} else {
			name = uri
		}
		"import " + name
	}

	def text(DslAttribute attribute) {
		if (attribute.name == null) {
			return null
		}
		(if (attribute.key) "* " else "") + attribute.name 
	}

	def text(DslServiceOperation op) {
		if (op.name == null) {
			return null
		}
		op.name + (if (op.delegateHolder != null && op.delegateHolder.delegate != null) " => " else "")
	}

	def text(DslReference ref) {
		if (ref.name == null) {
			return null
		}
		(if (ref.key) "* " else "") + ref.name
				+ (if (ref.collectionType == DslCollectionType::NONE || ref.collectionType == null)  "" else " []")
	}

	override image(Object obj) {
		"default.gif"
	}

	def image(DslImport obj) {
		"import.gif"
	}

	def image(DslApplication obj) {
		"application.gif"
	}

	def image(DslModule obj) {
		"module.gif"
	}

	def image(DslEntity obj) {
		"entity.gif"
	}

	def image(DslValueObject obj) {
		"valueobject.gif"
	}

	def image(DslBasicType obj) {
		"basictype.gif"
	}

	def image(DslEnum obj) {
		"enum.gif"
	}

	def image(DslTrait obj) {
		"trait.gif"
	}

	def image(DslRepository obj) {
		"repository.gif"
	}

	def image(DslRepositoryOperation obj) {
		"operation.gif"
	}

	def image(DslService obj) {
		"service.gif"
	}

	def image(DslConsumer obj) {
		"consumer.gif"
	}

	def image(DslServiceOperation obj) {
		"operation.gif"
	}

	def image(DslParameter obj) {
		"parameter.gif"
	}

	def image(DslReference obj) {
		"reference.gif"
	}

	def image(DslAttribute obj) {
		"attribute.gif"
	}

}
