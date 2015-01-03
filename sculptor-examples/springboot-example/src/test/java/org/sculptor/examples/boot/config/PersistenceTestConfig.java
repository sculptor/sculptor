/*
 * Copyright 2014 The Sculptor Project Team, including the original 
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
package org.sculptor.examples.boot.config;

import javax.sql.DataSource;

import org.apache.commons.dbcp.BasicDataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Profile("test")
@Configuration
@TestPropertySource({ "classpath:/generated-spring.properties", "classpath:/spring-test.properties" })
/*
 * Springs TransactionInterceptor has to be the first interceptor in the
 * interceptor chain of the methods markes with @Transactional (order = 1)
 */
@EnableTransactionManagement(order = 1)
/*
 * We need to be configured at last (Ordered.LOWEST_PRECEDENCE) because our
 * entityManagerFactory has to override the one provided by Spring Boot
 * HibernateJpaAutoConfiguration
 */
@Order(Ordered.LOWEST_PRECEDENCE)
public class PersistenceTestConfig {

	@Bean
	public DataSource hsqldbDataSource() {
		BasicDataSource dataSource = new BasicDataSource();
		dataSource.setDriverClassName("org.hsqldb.jdbcDriver");
		dataSource.setUrl("jdbc:hsqldb:mem:library");
		dataSource.setUsername("sa");
		dataSource.setPassword("");
		return dataSource;
	}

	@Bean
	public LocalContainerEntityManagerFactoryBean entityManagerFactory(DataSource dataSource) {
		final LocalContainerEntityManagerFactoryBean emfBean = new LocalContainerEntityManagerFactoryBean();
		emfBean.setPersistenceXmlLocation("META-INF/persistence-test.xml");
		emfBean.setDataSource(dataSource);
		return emfBean;
	}

}
