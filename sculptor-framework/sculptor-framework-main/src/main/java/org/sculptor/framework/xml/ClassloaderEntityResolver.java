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
package org.sculptor.framework.xml;

import java.io.IOException;
import java.io.InputStream;

import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * This class is used for loading XML schemas or DTDs from classpath.
 * The last part, the file name after the last /, of the systemId is
 * used together with a resouce prefix (e.g. schemas/) to locate the 
 * resource in classpath. 
 *
 */
public class ClassloaderEntityResolver implements EntityResolver {
    
    private String resourceNamePrefix = "";  // root of classpath
    private ClassLoader classLoader = ClassloaderEntityResolver.class.getClassLoader();
    
    /**
     * Constructor without resource name prefix, i.e. the resource
     * is located in the root of the classpath.
     *
     */
    public ClassloaderEntityResolver() {
    }
    
    /**
     * @param resourceNamePrefix custom prefix of the resources, e.g. "schemas/"
     */
    public ClassloaderEntityResolver(String resourceNamePrefix) {
        this.resourceNamePrefix = resourceNamePrefix;
    }
    
    public void setClassLoader(ClassLoader classLoader) {
        this.classLoader = classLoader;
    }

    public InputSource resolveEntity(String publicId, String systemId)
        throws SAXException, IOException {

        if (systemId == null) {
            return null;
        }
        
        try {
            String resourceName = resolveResourceName(systemId);
            InputStream inputStream =    
                classLoader.getResourceAsStream(resourceName);
            if (inputStream == null) {
                return null;
            }
            return new InputSource(inputStream);
        } catch (Exception e) {
            // No action; just let the null InputSource pass through
            return null;
        }
    }
    
    private String resolveResourceName(String systemId) {
        int i = systemId.lastIndexOf('/');
        String name;
        if (i == -1) {
            name = systemId;
        } else {
            name = systemId.substring(i+1);
        }
        return (resourceNamePrefix + name);
    }
}

