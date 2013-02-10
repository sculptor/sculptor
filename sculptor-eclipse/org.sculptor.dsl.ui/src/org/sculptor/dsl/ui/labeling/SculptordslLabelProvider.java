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

package org.sculptor.dsl.ui.labeling;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider;
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider;
import org.sculptor.dsl.sculptordsl.DslApplication;
import org.sculptor.dsl.sculptordsl.DslAttribute;
import org.sculptor.dsl.sculptordsl.DslBasicType;
import org.sculptor.dsl.sculptordsl.DslCollectionType;
import org.sculptor.dsl.sculptordsl.DslConsumer;
import org.sculptor.dsl.sculptordsl.DslEntity;
import org.sculptor.dsl.sculptordsl.DslEnum;
import org.sculptor.dsl.sculptordsl.DslImport;
import org.sculptor.dsl.sculptordsl.DslModel;
import org.sculptor.dsl.sculptordsl.DslModule;
import org.sculptor.dsl.sculptordsl.DslParameter;
import org.sculptor.dsl.sculptordsl.DslReference;
import org.sculptor.dsl.sculptordsl.DslRepository;
import org.sculptor.dsl.sculptordsl.DslRepositoryOperation;
import org.sculptor.dsl.sculptordsl.DslService;
import org.sculptor.dsl.sculptordsl.DslServiceOperation;
import org.sculptor.dsl.sculptordsl.DslTrait;
import org.sculptor.dsl.sculptordsl.DslValueObject;

import com.google.inject.Inject;

/**
 * Provides labels for a EObjects.
 * 
 * see http://www.eclipse.org/Xtext/documentation/latest/xtext.html#labelProvider
 */
public class SculptordslLabelProvider extends DefaultEObjectLabelProvider {

	@Inject
	public SculptordslLabelProvider(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}

	public String text(EObject modelElement) {
		EStructuralFeature feature = modelElement.eClass().getEStructuralFeature("name");
		if (feature != null) {
			Object property = modelElement.eGet(feature);
			if (property != null && String.class.isAssignableFrom(property.getClass())) {
				return (String) property;
			}
		}
		return null;
	}

	public String text(DslModel model) {
		return "model";
	}

	public String text(DslImport imp) {
		String uri = imp.getImportURI();
		int i = uri.lastIndexOf('/');
		String name;
		if (i != -1) {
			name = uri.substring(i + 1);
		} else {
			name = uri;
		}
		return "import " + name;
	}

	public String text(DslAttribute attribute) {
		if (attribute.getName() == null) {
			return null;
		}
		return (attribute.isKey() ? "* " : "") + attribute.getName();
	}

	public String text(DslServiceOperation op) {
		if (op.getName() == null) {
			return null;
		}
		return op.getName() + (op.getDelegateHolder() != null && op.getDelegateHolder().getDelegate() != null ? " => " : "");
	}

	public String text(DslReference ref) {
		if (ref.getName() == null) {
			return null;
		}
		return (ref.isKey() ? "* " : "") + ref.getName()
				+ (ref.getCollectionType() == DslCollectionType.NONE || ref.getCollectionType() == null ? "" : " []");
	}

	@Override
	public String image(Object obj) {
		return "default.gif";
	}

	public String image(DslImport obj) {
		return "import.gif";
	}

	public String image(DslApplication obj) {
		return "application.gif";
	}

	public String image(DslModule obj) {
		return "module.gif";
	}

	public String image(DslEntity obj) {
		return "entity.gif";
	}

	public String image(DslValueObject obj) {
		return "valueobject.gif";
	}

	public String image(DslBasicType obj) {
		return "basictype.gif";
	}

	public String image(DslEnum obj) {
		return "enum.gif";
	}

	public String image(DslTrait obj) {
		return "trait.gif";
	}

	public String image(DslRepository obj) {
		return "repository.gif";
	}

	public String image(DslRepositoryOperation obj) {
		return "operation.gif";
	}

	public String image(DslService obj) {
		return "service.gif";
	}

	public String image(DslConsumer obj) {
		return "consumer.gif";
	}

	public String image(DslServiceOperation obj) {
		return "operation.gif";
	}

	public String image(DslParameter obj) {
		return "parameter.gif";
	}

	public String image(DslReference obj) {
		return "reference.gif";
	}

	public String image(DslAttribute obj) {
		return "attribute.gif";
	}
}
