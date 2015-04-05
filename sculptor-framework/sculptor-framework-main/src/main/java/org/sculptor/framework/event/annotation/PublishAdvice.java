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

import java.lang.reflect.Constructor;
import java.util.Date;

import org.apache.commons.beanutils.ConstructorUtils;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.sculptor.framework.context.ServiceContext;
import org.sculptor.framework.event.Event;
import org.sculptor.framework.event.EventBus;
import org.sculptor.framework.util.FactoryHelper;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

/**
 * Advice that publish event to the topic and eventBus specified by the
 * {@link Publish} annotation. If eventType is not specified by the annotation
 * one of the return value or method parameters must be an {@link Event}, which
 * is published. When eventType is specified in the annotation then a new event
 * of this type is created using a constructor matching the method return value
 * or method parameters.
 */
@Aspect
public class PublishAdvice implements ApplicationContextAware {

    private ApplicationContext applicationContext;

    @Around("@annotation(publish)")
    public Object publish(ProceedingJoinPoint joinPoint, Publish publish) throws Throwable {
		if (applicationContext == null) {
			throw new IllegalArgumentException("No ApplicationContext autowired - advice must be configured by Spring");
		}

        Object retVal = joinPoint.proceed();

        String topic = publish.topic();
        Event event = null;
        if (publish.eventType() == NullEventType.class) {
            if (retVal instanceof Event) {
                event = (Event) retVal;
            } else {
                for (Object each : joinPoint.getArgs()) {
                    if (each instanceof Event) {
                        event = (Event) each;
                        break;
                    }
                }
            }
        } else {
            event = createEvent(publish.eventType(), retVal, joinPoint.getArgs());
        }

        if (event == null) {
            throw new IllegalArgumentException(
                    "Return value or some argument need to be of event type, or match constructor of specified eventType");
        }

        EventBus eventBus = getEventBus(publish.eventBus());
        eventBus.publish(topic, event);

        return retVal;
    }

    protected EventBus getEventBus(String name) {
        Object bean = getApplicationContext().getBean(name);
        if (!(bean instanceof EventBus)) {
            throw new IllegalStateException("Wrong EventBus type, got: " + bean.getClass().getName());
        }
        return (EventBus) bean;
    }

    private Event createEvent(Class<?> clazz, Object retVal, Object[] args) {
        Object occured;
        if (isJoda(clazz)) {
            occured = createJodaDateTime();
        } else {
            occured = new Date();
        }

        Event event = null;
        if (retVal != null) {
            try {
                Object[] constructorParams = { occured, retVal };
                Object raw = ConstructorUtils.invokeConstructor(clazz, constructorParams);
                event = (Event) raw;
            } catch (Exception e) {
            }
        }

        try {
            Object[] filteredArgs = removeServiceContext(args);
            Object[] constructorParams;
            if (filteredArgs.length > 0 && filteredArgs[0] != null && filteredArgs[0].getClass() == occured.getClass()) {
                // already got a timestamp as first arg
                constructorParams = filteredArgs;
            } else if (filteredArgs.length == 0) {
                constructorParams = new Object[] { occured };
            } else {
                constructorParams = new Object[filteredArgs.length + 1];
                constructorParams[0] = occured;
                System.arraycopy(filteredArgs, 0, constructorParams, 1, filteredArgs.length);
            }

            Object raw = ConstructorUtils.invokeConstructor(clazz, constructorParams);
            event = (Event) raw;
        } catch (Exception e) {
        }

        return event;
    }

    private Object[] removeServiceContext(Object[] args) {
        if (args.length > 1 && args[0] instanceof ServiceContext) {
            Object[] result = new Object[args.length - 1];
            System.arraycopy(args, 1, result, 0, result.length);
            return result;
        }

        return args;
    }

    /**
     * Check if joda date time library is used, without introducing runtime
     * dependency.
     */
    private boolean isJoda(Class<?> clazz) {
        for (Constructor<?> each : clazz.getConstructors()) {
            Class<?>[] parameterTypes = each.getParameterTypes();
            if (parameterTypes.length > 0) {
                if (parameterTypes[0].getName().startsWith("org.joda.time.")) {
                    return true;
                }
            }
        }
        return false;
    }

    private Object createJodaDateTime() {
        return FactoryHelper.newInstanceFromName("org.joda.time.DateTime");
    }

    protected ApplicationContext getApplicationContext() {
        return applicationContext;
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.applicationContext = applicationContext;
    }

}
