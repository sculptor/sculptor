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

import java.util.Collections;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.sculptor.framework.event.EventBus;
import org.sculptor.framework.event.EventSubscriber;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.beans.factory.BeanFactoryAware;
import org.springframework.beans.factory.BeanNotOfRequiredTypeException;
import org.springframework.beans.factory.ListableBeanFactory;
import org.springframework.beans.factory.NoSuchBeanDefinitionException;
import org.springframework.beans.factory.config.DestructionAwareBeanPostProcessor;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.util.StringUtils;

/**
 * For all subscriber beans (implementations of the {@link EventSubscriber}
 * interface marked with the {@link Subscribe} annotation) the specified topic
 * is subscribed from the selected event bus.
 */
public class SubscribeBeanPostProcessor implements DestructionAwareBeanPostProcessor, Ordered, BeanFactoryAware {

	private static final Logger LOG = LoggerFactory.getLogger(SubscribeBeanPostProcessor.class);

	private ListableBeanFactory beanFactory;
	private int order = Ordered.LOWEST_PRECEDENCE - 1;
	private final Set<String> subscriberBeanNames = Collections
			.newSetFromMap(new ConcurrentHashMap<String, Boolean>(64));

	@Override
	public Object postProcessBeforeInitialization(final Object bean, final String beanName) throws BeansException {
		return bean;
	}

	@Override
	public Object postProcessAfterInitialization(final Object bean, final String beanName) throws BeansException {
		if (bean instanceof EventSubscriber) {
			Subscribe annotation = getAnnotation(bean.getClass(), beanName);
			if (annotation != null) {
				LOG.debug("Subscribing the event listener '{}' to event bus '{}' with topic '{}", beanName,
						annotation.eventBus(), annotation.topic());
				EventBus eventBus = getEventBus(annotation.eventBus(), beanName);
				eventBus.subscribe(annotation.topic(), (EventSubscriber) bean);
				subscriberBeanNames.add(beanName);
			}
		}
		return bean;
	}

	@Override
	public void postProcessBeforeDestruction(final Object bean, final String beanName) throws BeansException {
		if (subscriberBeanNames.contains(beanName)) {
			Subscribe annotation = getAnnotation(bean.getClass(), beanName);
			LOG.debug("Unsubscribing the event listener '{}' from event bus '{}' with topic '{}", beanName,
					annotation.eventBus(), annotation.topic());
			try {
				EventBus eventBus = getEventBus(annotation.eventBus(), beanName);
				eventBus.unsubscribe(annotation.topic(), (EventSubscriber) bean);
			} catch (Exception e) {
				LOG.error("Unsubscribing the event listener '{}' failed", beanName, e);
			} finally {
				subscriberBeanNames.remove(beanName);
			}
		}
	}

	protected Subscribe getAnnotation(Class<?> beanClass, String beanName) {
		Subscribe annotation = AnnotationUtils.findAnnotation(beanClass, Subscribe.class);
		if (annotation != null) {
			if (StringUtils.isEmpty(annotation.topic())) {
				throw new RuntimeException("No topic specified in event subscriber '" + beanName + "'");
			}
			if (StringUtils.isEmpty(annotation.eventBus())) {
				throw new RuntimeException("No event bus specified in event subscriber '" + beanName
						+ "'");
			}
		}
		return annotation;
	}

	protected EventBus getEventBus(String eventBusName, String subscriberName) {
		try {
			return beanFactory.getBean(eventBusName, EventBus.class);
		} catch (NoSuchBeanDefinitionException e) {
			throw new RuntimeException("Event bus '" + eventBusName
					+ "' specified in event subscriber '" + subscriberName + "' is not available");
		} catch (BeanNotOfRequiredTypeException e) {
			throw new RuntimeException("Event bus '" + eventBusName
					+ "' specified in event subscriber '" + subscriberName + "' is not of type '" + EventBus.class
					+ "''");
		}
	}

	@Override
	public int getOrder() {
		return order;
	}

	/**
	 * Processing order of this BeanPostProcessor, use last. Default is
	 * <code>Ordered.LOWEST_PRECEDENCE - 1</code>.
	 */
	public void setOrder(int order) {
		this.order = order;
	}

	@Override
	public void setBeanFactory(BeanFactory beanFactory) throws BeansException {
		if (!(beanFactory instanceof ListableBeanFactory)) {
			throw new IllegalArgumentException("Expected instance of 'ListableBeanFactory' but got '"
					+ beanFactory.getClass() + "'");
		}
		this.beanFactory = (ListableBeanFactory) beanFactory;
	}

}
