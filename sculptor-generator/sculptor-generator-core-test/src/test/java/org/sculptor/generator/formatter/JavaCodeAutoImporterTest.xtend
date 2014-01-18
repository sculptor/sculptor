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

package org.sculptor.generator.formatter

import org.junit.Test
import static org.junit.Assert.*

class JavaCodeAutoImporterTest {

	@Test
	def testReplaceQualifiedTypes() {
		val source = new JavaCodeAutoImporter().replaceQualifiedTypes(
			'''
				package com.acme;

				/// Insert imports here ///

				@org.junit.Test(expected = java.lang.IllegalArgumentException.class)
				class Test {
					private java.util.Map<java.lang.String, java.lang.String> map = new java.util.HashMap<java.lang.String, java.lang.String>();
					private com.acme.Foo foo;

					public Test(com.acme.Foo foo) {
						com.acme.Bar bar = foo;
						
						map.put((java.lang.String) "java.util.Properties", (java.lang.String) bar.toString());
						foo = java.util.Properties.get("bar");	// conflict
						bar = com.acme.Foo.bar();
					}

				}
			''', '/// Insert imports here ///')
		assertEquals(
			'''
				package com.acme;

				import com.acme.Bar;
				import com.acme.Foo;
				import java.lang.IllegalArgumentException;
				import java.lang.String;
				import java.util.HashMap;
				import java.util.Map;
				import java.util.Properties;


				@org.junit.Test(expected = IllegalArgumentException.class)
				class Test {
					private Map<String, String> map = new HashMap<String, String>();
					private Foo foo;

					public Test(Foo foo) {
						Bar bar = foo;
						
						map.put((String) "java.util.Properties", (String) bar.toString());
						foo = Properties.get("bar");	// conflict
						bar = Foo.bar();
					}

				}
			'''.toString, source)
	}

	@Test
	def testReplaceQualifiedTypesMethodAccess() {
		val source = new JavaCodeAutoImporter().replaceQualifiedTypes(
			'''
				package com.acme;

				/// Insert imports here ///

				class Test {
					public Test() {
						com.acme.Bar bar = com.acme.Foo.bar();
						return org.springframework.http.HttpStatus.NOT_FOUND.value();
					}

				}
			''', '/// Insert imports here ///')
		assertEquals(
			'''
				package com.acme;

				import com.acme.Bar;
				import com.acme.Foo;
				import org.springframework.http.HttpStatus;


				class Test {
					public Test() {
						Bar bar = Foo.bar();
						return HttpStatus.NOT_FOUND.value();
					}

				}
			'''.toString, source)
	}

	@Test
	def testReplaceQualifiedNamesConstants() {
		val source = new JavaCodeAutoImporter().replaceQualifiedTypes(
			'''
				package com.acme;
				
				/// Insert imports here ///
				
				class Test {

					@javax.persistence.Temporal(javax.persistence.TemporalType.TIMESTAMP)
					private java.util.Date createdDate;

					@org.hibernate.annotations.Cascade(cascade = javax.persistence.CascadeType.ALL)
					@org.hibernate.annotations.Cascade(cascade = org.hibernate.annotations.CascadeType.DELETE_ORPHAN)
					public List<Media> findByTitle(String title) {
						return org.springframework.http.HttpStatus.NOT_FOUND.value();
					}
				
				}
			''', '/// Insert imports here ///')
		assertEquals(
			'''
				package com.acme;
				
				import java.util.Date;
				import javax.persistence.CascadeType;
				import javax.persistence.Temporal;
				import javax.persistence.TemporalType;
				import org.hibernate.annotations.Cascade;
				import org.springframework.http.HttpStatus;
				
				
				class Test {
				
					@Temporal(TemporalType.TIMESTAMP)
					private Date createdDate;

					@Cascade(cascade = CascadeType.ALL)
					@Cascade(cascade = org.hibernate.annotations.CascadeType.DELETE_ORPHAN)
					public List<Media> findByTitle(String title) {
						return HttpStatus.NOT_FOUND.value();
					}
				
				}
			'''.toString, source)
	}

	@Test
	def testReplaceQualifiedTypesVariables() {
		val source = new JavaCodeAutoImporter().replaceQualifiedTypes(
			'''
				package com.acme;
				
				/// Insert imports here ///

				class Test {

					public String getBaseName(Resource resource) {
						String fullPath = resource.toExternalForm();
						String[] parts = fullPath.split("/");
						for (int i = 0; i < parts.length; i++) {
							if (parts[i].endsWith(".ear")) {
								// remove .ear
								String earBaseName = parts[i].substring(0, parts[i].length() - 4);
								return earBaseName;
							}
						}
						return null;
					}
				
				}
			''', '/// Insert imports here ///')
		assertEquals(
			'''
				package com.acme;



				class Test {

					public String getBaseName(Resource resource) {
						String fullPath = resource.toExternalForm();
						String[] parts = fullPath.split("/");
						for (int i = 0; i < parts.length; i++) {
							if (parts[i].endsWith(".ear")) {
								// remove .ear
								String earBaseName = parts[i].substring(0, parts[i].length() - 4);
								return earBaseName;
							}
						}
						return null;
					}

				}
			'''.toString, source)
	}

	@Test
	def testReplaceQualifiedTypesPackageAnnotations() {
		val source = new JavaCodeAutoImporter().replaceQualifiedTypes(
			'''
				@javax.xml.bind.annotation.XmlSchema(namespace = "http://serviceapi.milkyway.helloworld.example.sculptor.org/", elementFormDefault = javax.xml.bind.annotation.XmlNsForm.QUALIFIED)
				package org.sculptor.example.helloworld.milkyway.serviceapi;
				
				/// Insert imports here ///

			''', '/// Insert imports here ///')
		assertEquals(
			'''
				@XmlSchema(namespace = "http://serviceapi.milkyway.helloworld.example.sculptor.org/", elementFormDefault = javax.xml.bind.annotation.XmlNsForm.QUALIFIED)
				package org.sculptor.example.helloworld.milkyway.serviceapi;

				import javax.xml.bind.annotation.XmlSchema;


			'''.toString, source)
	}

	@Test
	def testReplaceQualifiedTypesSameName() {
		val source = new JavaCodeAutoImporter().replaceQualifiedTypes(
			'''
				package org.sculptor.examples.library.util;

				/// Insert imports here ///

				public class EnumMapping extends org.datanucleus.store.mapped.mapping.EnumMapping {
				
				}
			''', '/// Insert imports here ///')
		assertEquals(
			'''
				package org.sculptor.examples.library.util;

				

				public class EnumMapping extends org.datanucleus.store.mapped.mapping.EnumMapping {
				
				}
			'''.toString, source)
	}

}
