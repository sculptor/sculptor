/*
 * Copyright 2007 The Fornax Project Team, including the original
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

package org.sculptor.generator.template.consumer

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Consumer

class ConsumerEjbTmpl {

	@Inject private var ConsumerTmpl consumerTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties

	/* Used for pure-ejb3, i.e. without spring */
	def String messageBeanInterceptors(Consumer it) {
		'''
		@javax.interceptor.Interceptors({
		«fw("errorhandling.ServiceContextStoreInterceptor")».class,
			«fw("errorhandling.ErrorHandlingInterceptor")».class«IF jpa()»,
			«module.getJpaFlushEagerInterceptorClass()».class}«ENDIF»)
		'''
	}

	/* Used for pure-ejb3, i.e. without spring */
	def String messageBeanImplBase(Consumer it) {
		fileOutput(javaFileName(getConsumerPackage() + "." + name + getSuffix("Impl") + "Base"), OutputSlot::TO_GEN_SRC, '''
		«javaHeader()»
		package «getConsumerPackage()»;

		/**
		 * Generated EJB MessageDrivenBean implementation of «name»
		 * <p>
		 * You must define resource mapping ConnectionFactory and invalidMessageQueue, 
		 * like this in jboss.xml:
		 * <pre>
		 *       &lt;message-driven&gt;
		 *             &lt;ejb-name&gt;eventConsumer&lt;/ejb-name&gt;
		 *             &lt;resource-ref&gt;
		 *                 &lt;res-ref-name&gt;jms/QueueFactory&lt;/res-ref-name&gt;
		 *                 &lt;jndi-name&gt;ConnectionFactory&lt;/jndi-name&gt;
		 *             &lt;/resource-ref&gt;
		 *             &lt;resource-ref&gt;
		 *                 &lt;res-ref-name&gt;jms/invalidMessageQueue&lt;/res-ref-name&gt;
		 *                 &lt;jndi-name&gt;queue/«module.application.name.toLowerCase()».invalidMessageQueue&lt;/jndi-name&gt;
		 *             &lt;/resource-ref&gt;
		 *         &lt;/message-driven&gt;
		 * </pre>
		 *
		 * <p>Make sure that subclass defines the following annotations:
		 * <pre>
		«messageBeanAnnotation(it)»
		«messageBeanInterceptors(it)»
		 * </pre>
		 */
		public abstract class «name + getSuffix("Impl")»Base extends «^abstractMessageBeanClass()» {
		«consumerTmpl.serialVersionUID(it)»
			public «name + getSuffix("Impl")»Base() {
			}

			«consumerTmpl.serviceDependencies(it)»
			«consumerTmpl.repositoryDependencies(it)»

			«jmsConnection(it)»
			«invalidMessageQueue(it)»

			«consumerTmpl.consumeMethodBase(it)»
			
			«consumerTmpl.consumerHook(it)»

		}
		'''
		)
	}

	def String messageBeanAnnotation(Consumer it) {
		'''
		@javax.ejb.MessageDriven(name="«name.toFirstLower()»",
		messageListenerInterface=javax.jms.MessageListener.class,
		activationConfig =
		{
			@javax.ejb.ActivationConfigProperty(propertyName="destinationType",
			propertyValue="javax.jms.Queue"),
			@javax.ejb.ActivationConfigProperty(propertyName="destination",
			propertyValue="«IF channel == null || channel == ""»queue/«name»Queue«ELSE»«channel»«ENDIF»")
		})
		'''
	}

	def String jmsConnection(Consumer it) {
		'''
		@javax.annotation.Resource(name = "jms/QueueFactory")
		private javax.jms.ConnectionFactory connectionFactory;
		private javax.jms.Connection connection;

			@Override
			protected javax.jms.Connection getJmsConnection() {
				try {
					if (connection == null) {
					    connection = connectionFactory.createConnection();
					    connection.start();
					}
					return connection;
				} catch (Exception e) {
					getLog().error("Can't create JmsConnection: " + e.getMessage(), e);
					return null;
				}
			}
			
			@javax.annotation.PreDestroy
			public void ejbRemove() {
				closeConnection();
			}

		@Override
			protected void closeConnection() {
				try {
					if (connection != null) {
					    connection.close();
					}
				} catch (Exception ignore) {
				} finally {
					connection = null;
				}
			}
		'''
	}

	def String invalidMessageQueue(Consumer it) {
		'''
		@javax.annotation.Resource(name = "jms/invalidMessageQueue")
		private javax.jms.Queue invalidMessageQueue;

		protected javax.jms.Destination getInvalidMessageQueue() {
			return invalidMessageQueue;
		}
		'''
	}

	/* Used for pure-ejb3, i.e. without spring */
	def String messageBeanImplSubclass(Consumer it) {
		fileOutput(javaFileName(getConsumerPackage() + "." + name + getSuffix("Impl")), OutputSlot::TO_SRC, '''
		«javaHeader()»
		package «getConsumerPackage()»;

		/**
		 * EJB MessageDrivenBean implementation of «name».
		 * <p>
		 * You must define resource mapping ConnectionFactory and invalidMessageQueue, 
		 * like this in jboss.xml:
		 * <pre>
		 *       &lt;message-driven&gt;
		 *             &lt;ejb-name&gt;eventConsumer&lt;/ejb-name&gt;
		 *             &lt;resource-ref&gt;
		 *                 &lt;res-ref-name&gt;jms/QueueFactory&lt;/res-ref-name&gt;
		 *                 &lt;jndi-name&gt;ConnectionFactory&lt;/jndi-name&gt;
		 *             &lt;/resource-ref&gt;
		 *             &lt;resource-ref&gt;
		 *                 &lt;res-ref-name&gt;jms/invalidMessageQueue&lt;/res-ref-name&gt;
		 *                 &lt;jndi-name&gt;queue/«module.application.name.toLowerCase()».invalidMessageQueue&lt;/jndi-name&gt;
		 *             &lt;/resource-ref&gt;
		 *         &lt;/message-driven&gt;
		 * </pre>
		 */
		«messageBeanAnnotation(it)»
		«messageBeanInterceptors(it)»
		public class «name + getSuffix("Impl")» extends «name + getSuffix("Impl")»Base implements javax.jms.MessageListener {
		«consumerTmpl.serialVersionUID(it)»
			public «name + getSuffix("Impl")»() {
			}

			«consumerTmpl.otherDependencies(it)»

		«consumerTmpl.consumeMethodSubclass(it)»

		}
		'''
		)
	}

}
