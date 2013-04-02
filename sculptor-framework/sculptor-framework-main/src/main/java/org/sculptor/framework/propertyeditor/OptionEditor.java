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
package org.sculptor.framework.propertyeditor;

import java.beans.PropertyEditor;
import java.beans.PropertyEditorSupport;

import org.apache.commons.beanutils.PropertyUtils;
import org.springframework.beans.PropertyEditorRegistry;

/**
 * This PropertyEditor is typically used to format 
 * options in select lists. It concatenates the defined
 * properties, using the PropertyEditors already registered
 * for the individual properties.
 *
 */
public class OptionEditor extends PropertyEditorSupport {
    private PropertyEditorRegistry registry;
    private String[] properties;
    private String registryPropertyNamePrefix = "";
    private String separator = " | ";

    public OptionEditor(PropertyEditorRegistry registry, String[] properties) {
        this.registry = registry;
        this.properties = properties;
    }
    
    /**
     * @param registry The registry with already registered PropertyEditors that
     *      will be used to format the individual property values.
     * @param properties The names of the properties to concatenate, it may be nested paths
     * @param registryPropertyNamePrefix When looking for PropertyEditors in the registry 
     *      this prefix will be used in front of the property name.
     */
    public OptionEditor(PropertyEditorRegistry registry, String[] properties, String registryPropertyNamePrefix) {
        this(registry, properties);
        this.registryPropertyNamePrefix = registryPropertyNamePrefix;
    }
    
    public String getSeparator() {
        return separator;
    }

    public void setSeparator(String separator) {
        this.separator = separator;
    }

    /**
     * Format the Object as String of concatenated properties.
     */
    public String getAsText() {

        Object value = getValue();
        if (value == null) {
            return "";
        }

        String propertyName = null; // used in error handling below
        try {
            StringBuffer label = new StringBuffer();

            for (int i = 0; i < properties.length; i++) {
                propertyName = properties[i];
                Class<?> propertyType = PropertyUtils.getPropertyType(value, propertyName);
                Object propertyValue = PropertyUtils.getNestedProperty(value, propertyName);
                PropertyEditor editor = registry.findCustomEditor(propertyType, registryPropertyNamePrefix + propertyName);
                if (editor == null) {
                    label.append(propertyValue);
                } else {
                    editor.setValue(propertyValue);
                    label.append(editor.getAsText());
                    editor.setValue(null);
                }
                
                if (i < (properties.length - 1)) {
                    label.append(separator);
                }
            }
            
            return label.toString();
            
        } catch (Exception e) {
            throw new IllegalArgumentException("Couldn't access " + propertyName + 
                    " of " + value.getClass().getName() + " : " +
                    e.getMessage(), e);
        }

    }
    
    /**
     * Parse the value from the given text is not supported by this editor
     */
    public void setAsText(String text) throws IllegalArgumentException {
        throw new UnsupportedOperationException("setAsText not supported by OptionEditor");
    }

}
