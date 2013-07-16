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
					@javax.persistence.Temporal(javax.persistence.TemporalType.TIMESTAMP)
					private java.util.Date createdDate;
				
					public Test(com.acme.Foo foo) {
						com.acme.Bar bar = foo;
						
						map.put((java.lang.String) "java.util.Properties", (java.lang.String) bar.toString());
						foo = java.util.Properties.get("bar");	// conflict
						bar = com.acme.Foo.bar();
					}

					@Cascade(cascade = javax.persistence.CascadeType.ALL)
					@Cascade(cascade = org.hibernate.annotations.CascadeType.DELETE_ORPHAN)
					public List<Media> findByTitle(String title) {
						List<ConditionalCriteria> condition = org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor(Media.class)
								.withProperty(org.sculptor.example.library.media.domain.MediaProperties.title()).eq(title).build();
				
						List<Media> result = findByCondition(condition);
						return result;
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
				import java.util.Date;
				import java.util.HashMap;
				import java.util.Map;
				import java.util.Properties;
				import javax.persistence.CascadeType;
				import javax.persistence.Temporal;
				import javax.persistence.TemporalType;
				import org.junit.Test;
				import org.sculptor.example.library.media.domain.MediaProperties;
				import org.sculptor.framework.accessapi.ConditionalCriteriaBuilder;
				
				
				@Test(expected = IllegalArgumentException.class)
				class Test {
					private Map<String, String> map = new HashMap<String, String>();
					private Foo foo;
					@Temporal(TemporalType.TIMESTAMP)
					private Date createdDate;
				
					public Test(Foo foo) {
						Bar bar = foo;
						
						map.put((String) "java.util.Properties", (String) bar.toString());
						foo = Properties.get("bar");	// conflict
						bar = Foo.bar();
					}
				
					@Cascade(cascade = CascadeType.ALL)
					@Cascade(cascade = org.hibernate.annotations.CascadeType.DELETE_ORPHAN)
					public List<Media> findByTitle(String title) {
						List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Media.class)
								.withProperty(MediaProperties.title()).eq(title).build();
				
						List<Media> result = findByCondition(condition);
						return result;
					}
				
				}
			'''.toString, source)
	}

}
