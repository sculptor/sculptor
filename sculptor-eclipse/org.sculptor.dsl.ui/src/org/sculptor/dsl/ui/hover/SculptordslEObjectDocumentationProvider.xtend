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
package org.sculptor.dsl.ui.hover

import org.eclipse.emf.ecore.EAttribute
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.change.FeatureMapEntry
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider

/**
 * This {@link IEObjectDocumentationProvider} returns the value of the given objects attribute "doc".
 */
class SculptordslEObjectDocumentationProvider implements IEObjectDocumentationProvider {

	override getDocumentation(EObject o) {
		for (EAttribute eAttribute : o.eClass.EAllAttributes) {
			if (!eAttribute.isMany() && eAttribute.getEType().getInstanceClass() != typeof(FeatureMapEntry)) {
				if ("doc".equalsIgnoreCase(eAttribute.getName())) {
					return o.eGet(eAttribute) as String
				}
			}
		}
		null
	}

}
