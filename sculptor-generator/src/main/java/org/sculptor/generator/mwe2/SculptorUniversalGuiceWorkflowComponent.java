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
import java.util.Collection;

import org.eclipse.emf.mwe.core.WorkflowContext;
import org.eclipse.emf.mwe.core.issues.Issues;
import org.eclipse.emf.mwe.core.lib.AbstractWorkflowComponent2;
import org.eclipse.emf.mwe.core.monitor.ProgressMonitor;

import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Module;

public class SculptorUniversalGuiceWorkflowComponent extends AbstractWorkflowComponent2 {

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
		checkRequiredConfigProperty("inputSlot", inputSlot, issues);
		checkRequiredConfigProperty("moduleClass", guiceModule, issues);
		checkRequiredConfigProperty("action", action, issues);
	}

	@Override
	protected void invokeInternal(WorkflowContext ctx, ProgressMonitor m, Issues issues) {
		long start = System.currentTimeMillis();
		issues.addWarning(this, "Starting action " + action);
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

		// Resolve module
		Module module=null;
		try {
			Class<?> forName = Class.forName(guiceModule);
			Object moduleInst = forName.newInstance();
			if (moduleInst instanceof Module) {
				module = (Module) moduleInst;
			} else {
				issues.addError("Module '"+guiceModule+"' is not instance of com.google.inject.Module");
			}
		} catch (Throwable th) {
			issues.addError("Error creating module '"+guiceModule+"': " + th.getMessage());
		}

		// Resolve action (method to run)
		Class<?> actionClass = null;
		Method actionMethod = null;
		try {
			int lastDot = action.lastIndexOf('.');
			actionClass = Class.forName(action.substring(0, lastDot));
			try {
				actionMethod = actionClass.getMethod(action.substring(lastDot + 1), inputData.getClass());
			} catch (Throwable th) {
				actionMethod = actionClass.getMethod(action.substring(lastDot + 1), inputData.getClass().getInterfaces()[0]);
			}
		} catch (Throwable th) {
			issues.addError("Error creating action '"+action+"': " + th.getMessage());
		}

		// Run action
		if (!issues.hasErrors()){
			Injector injector = Guice.createInjector(module);
			Object actionObj = injector.getInstance(actionClass);

			// execute the transformation
			Object result;
			try {
				result = actionMethod.invoke(actionObj, inputData);
				if (outputSlot != null) {
					ctx.set(outputSlot, result);
				}
			} catch (Throwable th) {
				issues.addError("Error invoking action '"+action+"': " + th.getMessage());
			}
		}
		issues.addWarning(this, "Action done in "+(System.currentTimeMillis() - start)+" ms");
	}

}
