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
package org.sculptor.framework.event.annotation;

import java.util.HashMap;
import java.util.Map;

import org.sculptor.framework.event.EventBus;
import org.sculptor.framework.event.EventSubscriber;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.config.DestructionAwareBeanPostProcessor;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.core.Ordered;

/**
 * For all subscriber beans (implementations of the {@link EventSubscriber}
 * interface marked with the {@link Subscribe} annotation) the specified topic
 * is subscribed from the selected event bus.
 */
public class SubscribeBeanPostProcessor implements DestructionAwareBeanPostProcessor, ApplicationContextAware,
        InitializingBean, Ordered {

    private static final Logger LOG = LoggerFactory.getLogger(SubscribeBeanPostProcessor.class);

    private ApplicationContext applicationContext;
    private int order = 1000;

    private final Map<String, EventSubscriber> managedSubscribers = new HashMap<String, EventSubscriber>();

    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        if (bean instanceof EventSubscriber && isAnnotationPresent(bean)) {
            EventSubscriber subscriber = (EventSubscriber) bean;

            managedSubscribers.put(beanName, subscriber);
        }
        return bean;
    }

    @Override
    public Object postProcessAfterInitialization(final Object bean, final String beanName) throws BeansException {
        EventSubscriber subscriber = managedSubscribers.get(beanName);
        if (subscriber != null) {
            EventBus eventBus = getEventBus(eventBusName(subscriber));
            eventBus.subscribe(topic(subscriber), subscriber);
        }
        return bean;
    }

    @Override
    public void postProcessBeforeDestruction(Object bean, String beanName) throws BeansException {
        if (managedSubscribers.containsKey(beanName)) {
            try {
                EventSubscriber subscriber = managedSubscribers.get(beanName);
                EventBus eventBus = getEventBus(eventBusName(subscriber));
                eventBus.unsubscribe(topic(subscriber), subscriber);
            } catch (Exception e) {
                LOG.error("An exception occurred while unsubscribing an event listener", e);
            } finally {
                managedSubscribers.remove(beanName);
            }
        }
    }

    private boolean isAnnotationPresent(Object bean) {
        return getAnnotation(bean) != null;
    }

    Subscribe getAnnotation(Object bean) {
        return getAnnotation(bean.getClass());
    }

    Subscribe getAnnotation(Class<?> clazz) {
        if (clazz == null || clazz == Object.class) {
            return null;
        }
        boolean foundIt = clazz.isAnnotationPresent(Subscribe.class);
        if (foundIt) {
            return clazz.getAnnotation(Subscribe.class);
        }
        // recursive call with super class
        return getAnnotation(clazz.getSuperclass());

    }

    private String eventBusName(Object bean) {
        Subscribe annotation = getAnnotation(bean);
        if (annotation != null) {
            return annotation.eventBus();
        } else {
            throw new IllegalArgumentException("Missing annotation");
        }
    }

    private String topic(Object bean) {
        Subscribe annotation = getAnnotation(bean);
        if (annotation != null) {
            return annotation.topic();
        } else {
            throw new IllegalArgumentException("Missing annotation");
        }
    }

    protected EventBus getEventBus(String name) {
        Object bean = getApplicationContext().getBean(name);
        if (!(bean instanceof EventBus)) {
            throw new IllegalStateException("Wrong EventBus type, got: " + bean.getClass().getName());
        }
        return (EventBus) bean;
    }

    @Override
    public void afterPropertiesSet() throws Exception {
    }

    /**
     * @return the ApplicationContext this Bean Post Processor is registered in
     */
    protected ApplicationContext getApplicationContext() {
        return applicationContext;
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.applicationContext = applicationContext;
    }

    @Override
    public int getOrder() {
        return order;
    }

    /**
     * Processing order of this BeanPostProcessor, use last. Default is 1000.
     */
    public void setOrder(int order) {
        this.order = order;
    }

}
