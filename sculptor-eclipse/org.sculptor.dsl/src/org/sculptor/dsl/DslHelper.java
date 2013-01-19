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

package org.sculptor.dsl;

import java.util.ArrayList;
import java.util.List;

import org.sculptor.dsl.sculptordsl.DslApplication;
import org.sculptor.dsl.sculptordsl.DslCommandEvent;
import org.sculptor.dsl.sculptordsl.DslDataTransferObject;
import org.sculptor.dsl.sculptordsl.DslDomainEvent;
import org.sculptor.dsl.sculptordsl.DslDomainObject;
import org.sculptor.dsl.sculptordsl.DslEntity;
import org.sculptor.dsl.sculptordsl.DslModule;
import org.sculptor.dsl.sculptordsl.DslSimpleDomainObject;
import org.sculptor.dsl.sculptordsl.DslValueObject;

/**
 * Java utilities for extension functions
 * 
 */
public class DslHelper {

    public static void debugTrace(String msg) {
        System.out.println(msg);
    }

    /**
     * Throws a RuntimeException to stop the generation with an error message.
     * 
     * @param msg
     *            message to log
     */
    public static void error(String msg) {
        System.err.println(msg);
        throw new RuntimeException(msg);
    }

    public static List<? extends DslSimpleDomainObject> getSubclasses(DslSimpleDomainObject domainObject) {
        if (domainObject instanceof DslDomainObject) {
            return getSubclasses((DslDomainObject) domainObject);
        } else if (domainObject instanceof DslDataTransferObject) {
            return getSubclasses((DslDataTransferObject) domainObject);
        } else {
            throw new IllegalArgumentException(String.valueOf(domainObject));
        }
    }

    public static List<DslDomainObject> getSubclasses(DslDomainObject domainObject) {
        List<DslDomainObject> subclasses = new ArrayList<DslDomainObject>();
        DslApplication application = (DslApplication) domainObject.eContainer().eContainer();
        List<DslModule> modules = application.getModules();
        for (DslModule module : modules) {
            List<DslSimpleDomainObject> domainObjects = module.getDomainObjects();
            for (DslSimpleDomainObject simpleDomainObj : domainObjects) {
                if (simpleDomainObj instanceof DslDomainObject) {
                    DslDomainObject domainObj = (DslDomainObject) simpleDomainObj;
                    if (domainObj.getExtendsName() != null && domainObj.getExtendsName().equals(domainObject.getName())) {
                        subclasses.add(domainObj);
                    } else if (getExtends(domainObj) != null && getExtends(domainObj).equals(domainObject)) {
                        subclasses.add(domainObj);
                    }
                }
            }
        }
        return subclasses;
    }

    public static DslSimpleDomainObject getExtends(DslSimpleDomainObject domainObject) {
        DslSimpleDomainObject result = null;
        String extendsName = null;
        if (domainObject instanceof DslEntity) {
            result = ((DslEntity) domainObject).getExtends();
            extendsName = ((DslEntity) domainObject).getExtendsName();
        } else if (domainObject instanceof DslValueObject) {
            result = ((DslValueObject) domainObject).getExtends();
            extendsName = ((DslValueObject) domainObject).getExtendsName();
        } else if (domainObject instanceof DslCommandEvent) {
            result = ((DslCommandEvent) domainObject).getExtends();
            extendsName = ((DslCommandEvent) domainObject).getExtendsName();
        } else if (domainObject instanceof DslDomainEvent) {
            result = ((DslDomainEvent) domainObject).getExtends();
            extendsName = ((DslDomainEvent) domainObject).getExtendsName();
        } else if (domainObject instanceof DslDataTransferObject) {
            result = ((DslDataTransferObject) domainObject).getExtends();
            extendsName = ((DslDataTransferObject) domainObject).getExtendsName();
        }

        if (result == null && extendsName != null) {
            DslApplication application = (DslApplication) domainObject.eContainer().eContainer();
            result = findDomainObjectByName(extendsName, application);
        }
        return result;
    }

    public static List<? extends DslSimpleDomainObject> getAllSubclasses(DslSimpleDomainObject domainObject) {
        if (domainObject instanceof DslDomainObject) {
            return getAllSubclasses((DslDomainObject) domainObject);
        } else if (domainObject instanceof DslDataTransferObject) {
            return getAllSubclasses((DslDataTransferObject) domainObject);
        } else {
            throw new IllegalArgumentException(String.valueOf(domainObject));
        }
    }

    public static List<DslDataTransferObject> getAllSubclasses(DslDataTransferObject domainObject) {
        List<DslDataTransferObject> subclasses = getSubclasses(domainObject);
        for (DslDataTransferObject subclass : new ArrayList<DslDataTransferObject>(subclasses)) {
            subclasses.addAll(getAllSubclasses(subclass));
        }
        return subclasses;
    }

    public static List<DslDataTransferObject> getSubclasses(DslDataTransferObject domainObject) {
        List<DslDataTransferObject> subclasses = new ArrayList<DslDataTransferObject>();
        DslApplication application = (DslApplication) domainObject.eContainer().eContainer();
        List<DslModule> modules = application.getModules();
        for (DslModule module : modules) {
            List<DslSimpleDomainObject> domainObjects = module.getDomainObjects();
            for (DslSimpleDomainObject simpleDomainObj : domainObjects) {
                if (simpleDomainObj instanceof DslDataTransferObject) {
                    DslDataTransferObject domainObj = (DslDataTransferObject) simpleDomainObj;
                    if (domainObj.getExtendsName() != null && domainObj.getExtendsName().equals(domainObject.getName())) {
                        subclasses.add(domainObj);
                    } else if (domainObj.getExtends() != null && domainObj.getExtends().equals(domainObject)) {
                        subclasses.add(domainObj);
                    }
                }
            }
        }
        return subclasses;
    }

    public static List<DslDomainObject> getAllSubclasses(DslDomainObject domainObject) {
        List<DslDomainObject> subclasses = getSubclasses(domainObject);
        for (DslDomainObject subclass : new ArrayList<DslDomainObject>(subclasses)) {
            subclasses.addAll(getAllSubclasses(subclass));
        }
        return subclasses;
    }

    public static DslSimpleDomainObject findDomainObjectByName(String name, DslApplication application) {
        List<DslModule> modules = application.getModules();
        for (DslModule module : modules) {
            for (DslSimpleDomainObject domainObj : module.getDomainObjects()) {
                if (domainObj.getName().equals(name)) {
                    return domainObj;
                }
            }
        }
        return null;
    }

}
