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

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import org.sculptor.framework.event.Event;

/**
 * Publishes an {@link Event} to the specified <code>topic</code> and
 * <code>eventBus</code>.
 * <p>
 * If <code>eventType</code> is not specified (or set to {@link NullEventType})
 * then the return value or one of the parameters of the annotated method must
 * be an {@link Event}, which is then published. If <code>eventType</code> is
 * specified then a new {@link Event} of this type is created using a
 * constructor matching return value or the parameters of the annotated method.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Publish {

    String topic();

    Class<? extends Event> eventType() default NullEventType.class;

    String eventBus() default "eventBus";

}
