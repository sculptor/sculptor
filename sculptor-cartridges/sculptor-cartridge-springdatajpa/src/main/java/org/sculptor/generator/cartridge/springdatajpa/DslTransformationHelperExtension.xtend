/*
 * Copyright 2015 The Sculptor Project Team, including the original 
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

import org.sculptor.dsl.sculptordsl.DslRepository
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.transform.DslTransformationHelper

@ChainOverride
class DslTransformationHelperExtension extends DslTransformationHelper {

	override boolean hasGapOperations(DslRepository dslRepository) {
		false
	}

}
