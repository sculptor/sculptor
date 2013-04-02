/*
 * Copyright 2009 The Fornax Project Team, including the original
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
package org.sculptor.framework.test;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.URL;
import java.util.MissingResourceException;

/**
 * This class is typically only used by JUnit test classes.
 * Helper to read content from file in classpath and write content to file.
 * Default charset is ISO-8859-1, but it can be specified to be something else.
 *
 */
public class DataHelper {

    private static final String DEFAULT_CHARSET = "ISO-8859-1";

    public DataHelper() {
    }

    /**
     *
     * @param path path to resource in classpath
     * @return reader to the resource in classpath
     * @throws IOException
     */
    public static BufferedReader reader(String path) throws IOException {
        return reader(path, DEFAULT_CHARSET);
    }

    public static BufferedReader reader(String path, String charset) throws IOException {
        if (path.startsWith("file:/")) {
            // remove "file:/" from path
            File file = new File(path.substring(6));
            BufferedReader reader = new BufferedReader(
                    new InputStreamReader(new FileInputStream(file), charset));
            return reader;
        } else {
            URL sourceUrl = DataHelper.class.getResource(path);
            if (sourceUrl == null) {
                throw new MissingResourceException(path + " not found in classpath", path, "");
            }
            InputStream sourceInput = sourceUrl.openStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(sourceInput, charset));
            return reader;
        }

    }

    public static String content(String path) throws IOException {
        return content(path, DEFAULT_CHARSET);
    }

    public static String content(String path, String charset) throws IOException {
        BufferedReader reader = null;
        try {
            reader = reader(path, charset);
            StringBuffer content = new StringBuffer();
            String line = reader.readLine();
            while (line != null) {
                content.append(line).append("\n");
                line = reader.readLine();
            }
            return content.toString();
        } finally {
            if (reader != null) {
                reader.close();
            }
        }
    }

    public static void write(String path, String content) throws IOException {
        write(path, content, DEFAULT_CHARSET);
    }

    public static void write(String path, String content, String charset) throws IOException {
        BufferedWriter writer = null;
        try {
            writer = new BufferedWriter(new OutputStreamWriter(
                    new FileOutputStream(path),
                    charset));
            writer.write(content);
        } finally {
            if (writer != null) {
                writer.close();
            }
        }
    }

}
