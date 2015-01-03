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
import org.sculptor.framework.context.ServiceContextStoreAdvice;
import org.sculptor.framework.errorhandling.ErrorHandlingAdvice;
import org.sculptor.framework.persistence.JpaFlushEagerAdvice;
import org.springframework.aop.Advisor;
import org.springframework.aop.aspectj.AspectJExpressionPointcut;
import org.springframework.aop.support.DefaultPointcutAdvisor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AopConfig {

	@Pointcut("execution(public * org.sculptor.examples.boot..serviceapi.*.*(..))")
	public void service() {
	}

	@Pointcut("execution(* get*(..)) || execution(* find*(..))")
	public void readOnlyMethod() {
	}

	@Bean
	public ServiceContextStoreAdvice serviceContextStoreAdvice() {
		return new ServiceContextStoreAdvice();
	}

	@Bean
	public ErrorHandlingAdvice errorHandlingAdvice() {
		return new ErrorHandlingAdvice();
	}

	@Bean
	public JpaFlushEagerAdvice jpaFlushEagerAdvice() {
		return new JpaFlushEagerAdvice();
	}

	@Bean
	public Advisor serviceContextStoreAdvisor() {
		AspectJExpressionPointcut pointcut = new AspectJExpressionPointcut();
		pointcut.setExpression("org.sculptor.examples.boot.config.AopConfig.service()");
		DefaultPointcutAdvisor advisor = new DefaultPointcutAdvisor(pointcut, serviceContextStoreAdvice());
		advisor.setOrder(2);
		return advisor;
	}

	@Bean
	public Advisor errorHandlingAdvisor() {
		AspectJExpressionPointcut pointcut = new AspectJExpressionPointcut();
		pointcut.setExpression("org.sculptor.examples.boot.config.AopConfig.service()");
		DefaultPointcutAdvisor advisor = new DefaultPointcutAdvisor(pointcut, errorHandlingAdvice());
		advisor.setOrder(3);
		return advisor;
	}

	@Bean
	public Advisor jpaFlushEagerAdvisor() {
		AspectJExpressionPointcut pointcut = new AspectJExpressionPointcut();
		pointcut.setExpression("org.sculptor.examples.boot.config.AopConfig.service() && !org.sculptor.examples.boot.config.AopConfig.readOnlyMethod()");
		DefaultPointcutAdvisor advisor = new DefaultPointcutAdvisor(pointcut, jpaFlushEagerAdvice());
		advisor.setOrder(4);
		return advisor;
	}

}
