/*
 * Copyright 2010 The Fornax Project Team, including the original
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

package org.sculptor.generator.template.common

import javax.inject.Inject
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Publish
import sculptormetamodel.Subscribe
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class PubSubTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Properties properties

	def String publishAnnotation(Publish it) {
		val eventTypeClass = if (it.eventType == null) null else eventType.getDomainPackage() + "." + eventType.name + ".class"
		'''
		«formatAnnotationParameters("@" + fw("event.annotation.Publish"), <Object>newArrayList(
				eventTypeClass != null, "eventType", eventTypeClass,
				topic != null, "topic", '"' + topic + '"',
				eventBus != null, "eventBus", '"' + eventBus + '"'
			))»
		'''
	}
	
	def String subscribeAnnotation(Subscribe it) {
		'''
		«formatAnnotationParameters("@" + fw("event.annotation.Subscribe"), <Object>newArrayList(
				topic != null, "topic", '"' + topic + '"',
				eventBus != null, "eventBus", '"' + eventBus + '"'
			)) »
		'''
	}

}
