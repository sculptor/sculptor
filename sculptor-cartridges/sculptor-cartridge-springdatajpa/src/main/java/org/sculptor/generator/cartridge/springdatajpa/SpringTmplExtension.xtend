/*
 * Copyright 2014 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.cartridge.springdatajpa

import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.template.spring.SpringTmpl
import sculptormetamodel.Application

@ChainOverride
class SpringTmplExtension extends SpringTmpl {

	override String headerNamespaceAdditions(Object it) {
		'''
			xmlns:jpa="http://www.springframework.org/schema/data/jpa"
		'''
	}

	override String headerSchemaLocationAdditions(Object it) {
		'''
			http://www.springframework.org/schema/data/jpa
			http://www.springframework.org/schema/data/jpa/spring-jpa.xsd
		'''
	}

	override String entityManagerFactoryAdditions(Application it, boolean test) {
		'''
			<jpa:repositories base-package="«it.basePackage»" entity-manager-factory-ref="entityManagerFactory" transaction-manager-ref="txManager"/>
		'''
	}

}
