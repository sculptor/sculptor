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
package org.sculptor.framework.event.annotation;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.*;

import org.junit.Test;
import org.sculptor.framework.event.Event;
import org.sculptor.framework.event.EventBus;
import org.sculptor.framework.event.EventSubscriber;
import org.springframework.beans.factory.BeanCreationException;
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;

public class SubscribeBeanPostProcessorTest {

	@Test
	public void testWithValidEventSubscriber() {
		final DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
		factory.registerBeanDefinition("eventBus", BeanDefinitionBuilder.genericBeanDefinition(TestEventBus.class)
				.getBeanDefinition());
		factory.registerBeanDefinition("eventListener",
				BeanDefinitionBuilder.genericBeanDefinition(ValidEventSubscriber.class).getBeanDefinition());
		final SubscribeBeanPostProcessor bpp = new SubscribeBeanPostProcessor();
		bpp.setBeanFactory(factory);
		factory.addBeanPostProcessor(bpp);

		factory.preInstantiateSingletons();
		TestEventBus eventBus = factory.getBean(TestEventBus.class);
		assertNotNull(eventBus);
		assertEquals(1, eventBus.subscriptions);

		factory.destroySingletons();
		assertEquals(1, eventBus.unsubscriptions);
	}

	@Test
	public void testWithMissingTopic() {
		try {
			final DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
			factory.registerBeanDefinition("eventListener",
					BeanDefinitionBuilder.genericBeanDefinition(EventSubscriberWithoutTopic.class)
							.getBeanDefinition());
			final SubscribeBeanPostProcessor bpp = new SubscribeBeanPostProcessor();
			bpp.setBeanFactory(factory);
			factory.addBeanPostProcessor(bpp);
			factory.preInstantiateSingletons();
			fail("Should have thrown BeanCreationException");
		} catch (BeanCreationException e) {
			String message = e.getCause().getMessage();
			assertTrue(message.contains("No topic specified"));
		}
	}

	@Test
	public void testWithMissingEventBus() {
		try {
			final DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
			factory.registerBeanDefinition("eventListener",
					BeanDefinitionBuilder.genericBeanDefinition(EventSubscriberWithoutEventBus.class)
							.getBeanDefinition());
			final SubscribeBeanPostProcessor bpp = new SubscribeBeanPostProcessor();
			bpp.setBeanFactory(factory);
			factory.addBeanPostProcessor(bpp);
			factory.preInstantiateSingletons();
			fail("Should have thrown BeanCreationException");
		} catch (BeanCreationException e) {
			String message = e.getCause().getMessage();
			assertTrue(message.contains("No event bus specified"));
		}
	}

	@Test
	public void testWithUnknownEventBus() {
		try {
			final DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
			factory.registerBeanDefinition("eventBus", BeanDefinitionBuilder.genericBeanDefinition(TestEventBus.class)
					.getBeanDefinition());
			factory.registerBeanDefinition("eventListener",
					BeanDefinitionBuilder.genericBeanDefinition(EventSubscriberWithUnknownEventBus.class)
							.getBeanDefinition());
			final SubscribeBeanPostProcessor bpp = new SubscribeBeanPostProcessor();
			bpp.setBeanFactory(factory);
			factory.addBeanPostProcessor(bpp);
			factory.preInstantiateSingletons();
			fail("Should have thrown BeanCreationException");
		} catch (BeanCreationException e) {
			String message = e.getCause().getMessage();
			assertTrue(message.contains("Event bus"));
			assertTrue(message.contains("is not available"));
		}
	}

	@Test
	public void testWithInvalidEventBus() {
		try {
			final DefaultListableBeanFactory factory = new DefaultListableBeanFactory();
			factory.registerBeanDefinition("eventBus", BeanDefinitionBuilder.genericBeanDefinition(Object.class)
					.getBeanDefinition());
			factory.registerBeanDefinition("eventListener",
					BeanDefinitionBuilder.genericBeanDefinition(ValidEventSubscriber.class).getBeanDefinition());
			final SubscribeBeanPostProcessor bpp = new SubscribeBeanPostProcessor();
			bpp.setBeanFactory(factory);
			factory.addBeanPostProcessor(bpp);
			factory.preInstantiateSingletons();
			fail("Should have thrown BeanCreationException");
		} catch (BeanCreationException e) {
			String message = e.getCause().getMessage();
			assertTrue(message.contains("Event bus"));
			assertTrue(message.contains("is not of type"));
		}
	}

	@Subscribe(topic = "test", eventBus = "eventBus")
	private static class ValidEventSubscriber implements EventSubscriber {

		@Override
		public void receive(Event event) {
		}
	}

	@Subscribe(eventBus = "eventBus")
	private static class EventSubscriberWithoutTopic implements EventSubscriber {

		@Override
		public void receive(Event event) {
		}
	}

	@Subscribe(topic = "test", eventBus = "")
	private static class EventSubscriberWithoutEventBus implements EventSubscriber {

		@Override
		public void receive(Event event) {
		}
	}

	@Subscribe(topic = "test", eventBus = "unknown")
	private static class EventSubscriberWithUnknownEventBus implements EventSubscriber {

		@Override
		public void receive(Event event) {
		}
	}

	private static class TestEventBus implements EventBus {

		int subscriptions = 0;
		int unsubscriptions = 0;

		@Override
		public boolean publish(String topic, Event event) {
			return true;
		}

		@Override
		public boolean subscribe(String topic, EventSubscriber subscriber) {
			subscriptions++;
			return true;
		}

		@Override
		public boolean unsubscribe(String topic, EventSubscriber subscriber) {
			unsubscriptions++;
			return true;
		}
	}

}
