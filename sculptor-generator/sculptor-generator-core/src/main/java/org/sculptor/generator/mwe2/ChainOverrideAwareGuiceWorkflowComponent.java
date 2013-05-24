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

package org.sculptor.generator.mwe2;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.eclipse.emf.mwe.core.WorkflowContext;
import org.eclipse.emf.mwe.core.issues.Issues;
import org.eclipse.emf.mwe.core.lib.AbstractWorkflowComponent2;
import org.eclipse.emf.mwe.core.monitor.ProgressMonitor;
import org.sculptor.generator.chain.ChainOverrideAwareModule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Module;

public class ChainOverrideAwareGuiceWorkflowComponent extends AbstractWorkflowComponent2 {

	private static final Logger LOG = LoggerFactory.getLogger(ChainOverrideAwareGuiceWorkflowComponent.class);

	private String inputSlot;
	private String outputSlot;
	private String guiceModule;
	private String action;

	public void setInputSlot(String modelSlot) {
		this.inputSlot = modelSlot;
	}

	public void setOutputSlot(String outputSlot) {
		this.outputSlot = outputSlot;
	}

	public void setGuiceModule(String guiceModule) {
		this.guiceModule = guiceModule;
	}

	public void setAction(String action) {
		this.action = action;
	}

	@Override
	protected void checkConfigurationInternal(Issues issues) {
		LOG.debug("Configuration: inputSlot=" + inputSlot + ", outputSlot=" + outputSlot + ", guiceModule="
				+ guiceModule + ", action=" + action);
		checkRequiredConfigProperty("inputSlot", inputSlot, issues);
		checkRequiredConfigProperty("action", action, issues);
	}

	@Override
	protected void invokeInternal(WorkflowContext ctx, ProgressMonitor m, Issues issues) {

		// Resolve slots
		Object inputData = ctx.get(inputSlot);
		if (inputData == null) {
			issues.addError(String.format("Slot %s is empty", inputSlot));
		} else if (inputData instanceof Collection) {
			Collection<?> inputDataCollection = (Collection<?>) inputData;
			if (inputDataCollection.size() == 1) {
				inputData = inputDataCollection.iterator().next();
			}
		}

		// Resolve action (method to run)
		Class<?> actionClass = null;
		Method actionMethod = null;
		try {
			int lastDot = action.lastIndexOf('.');
			actionClass = Class.forName(action.substring(0, lastDot));
			Class<?> inputDataClass = inputData.getClass();
			if (Collection.class.isAssignableFrom(inputDataClass)) {
				inputDataClass = ((Collection<?>) inputData).iterator().next().getClass();
			}
			try {
				actionMethod = actionClass.getMethod(action.substring(lastDot + 1), inputDataClass);
			} catch (Throwable th) {
				actionMethod = actionClass.getMethod(action.substring(lastDot + 1), inputDataClass.getInterfaces()[0]);
			}
		} catch (Throwable th) {
			issues.addError(this, "Error creating action '"+action+"'", null, th, null);
		}

		// Create Guice injector for specified Guice module (if not specified
		// then use ChainOverrideAwareModule with given actionClass instead)
		Injector injector = null;
		if (!issues.hasErrors()) {
			try {
				if (guiceModule == null) {
					Module module = new ChainOverrideAwareModule(actionClass);
					injector = Guice.createInjector(module);
				} else {
					Class<?> forName = Class.forName(guiceModule);
					Object moduleInst = forName.newInstance();
					if (moduleInst instanceof Module) {
						injector = Guice.createInjector((Module) moduleInst);
					} else {
						issues.addError("Module '" + guiceModule + "' is not instance of com.google.inject.Module");
					}
				}
			} catch (Throwable th) {
				issues.addError(this, "Error creating module '" + guiceModule + "'", null, th, null);
			}
		}

		// Run action
		if (!issues.hasErrors()){
			LOG.debug("Running action '" + action + "'");
			Object actionObj = injector.getInstance(actionClass);
			Object result;
			try {
				if (inputData instanceof Collection) {
					List<Object> arrResult = new ArrayList<Object>();
					for (Object obj : (Collection<?>) inputData) {
						arrResult.add(actionMethod.invoke(actionObj, obj));
					}
					result = arrResult;
				} else {
					result = actionMethod.invoke(actionObj, inputData);
				}
				if (outputSlot != null) {
					ctx.set(outputSlot, result);
				}
			} catch (Throwable th) {
				issues.addError(this, "Error invoking action '"+action+"'", null, th, null);
			}
		}
	}

}
