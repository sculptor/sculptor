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

import java.util.Collection;
import java.util.List;

import org.eclipse.emf.mwe.core.WorkflowContext;
import org.eclipse.emf.mwe.core.issues.Issues;
import org.eclipse.emf.mwe.core.lib.AbstractWorkflowComponent2;
import org.eclipse.emf.mwe.core.monitor.ProgressMonitor;
import org.sculptor.dsl.sculptordsl.DslApplication;
import org.sculptor.generator.SculptorDslTransformation;
import org.sculptor.generator.template.RootTmpl;

import sculptormetamodel.Application;

import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;

public class SculptorDslTransformationWorkflowComponent extends AbstractWorkflowComponent2 {

	private String modelSlot;
	private String outputSlot;

	public void setModelSlot(String modelSlot) {
		this.modelSlot = modelSlot;
	}

	public void setOutputSlot(String outputSlot) {
		this.outputSlot = outputSlot;
	}

	@Override
	protected void checkConfigurationInternal(Issues issues) {
		checkRequiredConfigProperty("modelSlot", modelSlot, issues);
		checkRequiredConfigProperty("outputSlot", outputSlot, issues);
	}

	@Override
	protected void invokeInternal(WorkflowContext ctx, ProgressMonitor m, Issues issues) {
		Collection<?> slotContent = (Collection<?>) ctx.get(modelSlot);
		if (slotContent == null) {
			issues.addError(String.format("Slot %s is empty", modelSlot));
		} else {

			// retrieve models from model slot
			List<DslApplication> applications = Lists.newArrayList();
			for (DslApplication application : Iterables.filter(slotContent, DslApplication.class)) {
				applications.add(application);
			}
			if (applications.isEmpty()) {
				issues.addError(this, "No DslApplication instance found in model slot", slotContent, null, null);
			} else {

				// execute the transformation
				Application transformed = new SculptorDslTransformation().transform(applications.get(0));
				ctx.set(outputSlot, transformed);
//				RootTmpl.Root(transformed);
			}
		}
	}

}
