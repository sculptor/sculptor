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

package org.sculptor.framework.accessimpl.mongodb;

import java.io.IOException;

import com.mongodb.TransactionOptions;
import com.mongodb.WriteConcern;
import com.mongodb.client.ClientSession;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * This Servlet Filter should be placed in front of Servlets to facilitate lazy
 * loading of DomainObject associations in view.
 * 
 * @author Patrik Nordwall, Pavel Tavoda
 * 
 */
public class DbManagerFilter extends OncePerRequestFilter {
	TransactionOptions transactionOptions = TransactionOptions.builder().writeConcern(WriteConcern.MAJORITY).build();

	public DbManagerFilter() {
	}

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
			throws ServletException, IOException {

		DbManager dbManager = lookupDbManager();

		try (ClientSession session = dbManager.startSession()) {
			session.startTransaction(transactionOptions);
			filterChain.doFilter(request, response);
		}
	}

	protected DbManager lookupDbManager() {
		WebApplicationContext context = WebApplicationContextUtils
				.getRequiredWebApplicationContext(getServletContext());
		return context.getBean("mongodbManager", DbManager.class);
	}

	public TransactionOptions getTransactionOptions() {
		return transactionOptions;
	}

	public void setTransactionOptions(TransactionOptions transactionOptions) {
		this.transactionOptions = transactionOptions;
	}
}
