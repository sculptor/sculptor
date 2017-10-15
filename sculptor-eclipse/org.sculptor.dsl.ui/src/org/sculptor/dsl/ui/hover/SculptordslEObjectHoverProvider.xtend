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

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.hover.html.DefaultEObjectHoverProvider

/**
 * This {@link DefaultEObjectHoverProvider} removes the prefix "Dsl" from the selected objects class name.
 */
class SculptordslEObjectHoverProvider extends DefaultEObjectHoverProvider {

	override protected getFirstLine(EObject o) {
		val className = o.eClass().getName()
		val label = getLabel(o)
		(if (className.startsWith("Dsl"))
			className.substring(3)
		else
			className) + if(label !== null) " <b>" + label + "</b>" else ""
	}

}
