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
package org.sculptor.dsl

import org.eclipse.xtext.conversion.IValueConverterService
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider
import org.sculptor.dsl.validation.SculptordslSyntaxErrorMessageProvider
import org.sculptor.dsl.conversion.SculptordslValueConverters

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class SculptordslRuntimeModule extends AbstractSculptordslRuntimeModule {

	def Class<? extends ISyntaxErrorMessageProvider> bindISyntaxErrorMessageProvider() {
		typeof(SculptordslSyntaxErrorMessageProvider)
	}

	override Class<? extends IValueConverterService> bindIValueConverterService() {
		typeof(SculptordslValueConverters)
	}

}
