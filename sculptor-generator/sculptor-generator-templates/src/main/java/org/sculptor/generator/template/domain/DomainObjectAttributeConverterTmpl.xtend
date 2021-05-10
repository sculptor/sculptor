/*
 * Copyright 2019 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.template.domain

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Enum

@ChainOverridable
class DomainObjectAttributeConverterTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

	def String domainObjectAttributeConverter(Enum it) {
		val identifierAttribute  = it.identifierAttribute
		fileOutput(javaFileName(getDomainPackage() + "." + name + "Converter"), OutputSlot.TO_GEN_SRC, '''
			�javaHeader�
			package �domainPackage�;

			/// Sculptor code formatter imports ///

			@javax.persistence.Converter
			public class �name�Converter implements javax.persistence.AttributeConverter<�name�, �identifierAttribute.typeName.getObjectTypeName()�> {

				@Override
				public �identifierAttribute.typeName.getObjectTypeName()� convertToDatabaseColumn(�name� �name.toFirstLower�) {
					return �name.toFirstLower� == null
							? null
							: �name.toFirstLower�.get�identifierAttribute.name.toFirstUpper�();
				}

				@Override
				public �name� convertToEntityAttribute(�identifierAttribute.typeName.getObjectTypeName()� �identifierAttribute.name�) {
					return �identifierAttribute.name� == null
							? null
							: �name�.from�identifierAttribute.name.toFirstUpper�(�identifierAttribute.name�);
				}

			}
		'''
		)
	}
}
