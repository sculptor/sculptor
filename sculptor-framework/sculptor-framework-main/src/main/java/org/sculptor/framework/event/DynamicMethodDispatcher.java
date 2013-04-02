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
package org.sculptor.framework.event;

import java.lang.reflect.InvocationTargetException;

import org.apache.commons.beanutils.MethodUtils;

public class DynamicMethodDispatcher {

    /**
     * Runtime dispatch to method with correct event parameter type
     */
    public static void dispatch(Object target, Event event, String methodName) {
        try {
            MethodUtils.invokeMethod(target, methodName, event);
        } catch (InvocationTargetException e) {
            if (e.getTargetException() instanceof RuntimeException) {
                throw (RuntimeException) e.getTargetException();
            } else {
                throw new UnsupportedOperationException(e.getTargetException());
            }
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new UnsupportedOperationException(e);
        }
    }

}
