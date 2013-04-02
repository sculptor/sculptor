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

import java.beans.PropertyEditorSupport;

import org.springframework.context.MessageSource;
import org.springframework.context.support.MessageSourceAccessor;

/**
 * This PropertyEditor is typically used to format 
 * options in select lists. It concatenates the defined
 * properties, using the PropertyEditors already registered
 * for the individual properties.
 *
 */
public class EnumEditor<T extends Enum<T>> extends PropertyEditorSupport {
	private Class<T> enumClass;
	private MessageSource messages;
	private String messagesKeyPrefix;

	public EnumEditor(Class<T> enumClass, MessageSource messages, String messagesKeyPrefix) {
        this.enumClass = enumClass;
        this.messages = messages;
        this.messagesKeyPrefix = (messagesKeyPrefix.endsWith(".") ? messagesKeyPrefix : messagesKeyPrefix + ".");
    }

    protected MessageSource getMessages() {
        return messages;
    }

    /**
     * It is convenient to use the
     * {@link org.springframework.context.support.MessageSourceAccessor}
     * to fetch messages. Note that it uses
     * the locale held by
     * {@link org.springframework.context.i18nLocaleContextHolder}.
     */
    protected MessageSourceAccessor getMessagesAccessor() {
        return new MessageSourceAccessor(messages);
    }
    
    protected String getMessagesKeyPrefix() {
		return messagesKeyPrefix;
	}

    /**
     * Format the Enum as translated String
     */
    public String getAsText() {
        Enum<?> value = (Enum<?>) getValue();
        if (value == null) {
            return "";
        }

        String text = getMessagesAccessor().getMessage(messagesKeyPrefix + value.name(), (String) null);
        if (text == null) {
            return value.toString();
        } else {
            return text;
        }
    }
    
    /**
     * Parse the value from the given text is not supported by this editor
     */
    public void setAsText(String text) throws IllegalArgumentException {
        if (text == null || text.equals("")) {
            setValue(null);
            return;
        }
        Enum<?> value = Enum.valueOf(enumClass, text);
        setValue(value);
    }
}
