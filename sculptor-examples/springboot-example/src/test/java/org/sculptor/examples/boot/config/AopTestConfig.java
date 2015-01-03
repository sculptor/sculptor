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

import org.aspectj.lang.annotation.Pointcut;
import org.sculptor.framework.errorhandling.ErrorHandlingAdvice;
import org.springframework.aop.Advisor;
import org.springframework.aop.aspectj.AspectJExpressionPointcut;
import org.springframework.aop.support.DefaultPointcutAdvisor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.Profile;

@Profile("test")
@Configuration
@Import(AopConfig.class)
public class AopTestConfig {

	@Pointcut("execution(public * org.sculptor.examples.boot..domain.*Repository.*(..))")
	public void repository() {
	}

	/**
	 * In unit tests we need error handling on the repository methods as well.
	 */
	@Bean
	public Advisor repositoryAdvisor(ErrorHandlingAdvice advice) {
		AspectJExpressionPointcut pointcut = new AspectJExpressionPointcut();
		pointcut.setExpression("org.sculptor.examples.boot.config.AopTestConfig.repository()");
		return new DefaultPointcutAdvisor(pointcut, advice);
	}

}
