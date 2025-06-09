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

package org.sculptor.dsl.conversion

import com.google.inject.Inject
import org.eclipse.xtext.common.services.DefaultTerminalConverters
import org.eclipse.xtext.conversion.IValueConverter
import org.eclipse.xtext.conversion.ValueConverter
import org.eclipse.xtext.conversion.impl.QualifiedNameValueConverter

/**
 * Registers additional {@link IValueConverter}s.
 * <p>
 * see http://www.eclipse.org/Xtext/documentation.html#valueconverter
 */
class SculptordslValueConverters extends DefaultTerminalConverters {

	@Inject QualifiedNameValueConverter qnValueConverter

	@ValueConverter(rule="DslJavaIdentifier")
	def IValueConverter<String> javaIdentifier() {
		qnValueConverter
	}

}
