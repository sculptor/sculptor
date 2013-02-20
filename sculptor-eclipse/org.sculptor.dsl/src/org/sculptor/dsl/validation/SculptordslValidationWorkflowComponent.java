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

package org.sculptor.dsl.validation;

import java.util.Collection;
import java.util.Collections;
import java.util.List;

import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.Diagnostician;
import org.eclipse.emf.mwe.core.WorkflowContext;
import org.eclipse.emf.mwe.core.issues.Issues;
import org.eclipse.emf.mwe.core.lib.WorkflowComponentWithModelSlot;
import org.eclipse.emf.mwe.core.monitor.ProgressMonitor;
import org.eclipse.xtext.EcoreUtil2;
import org.sculptor.dsl.sculptordsl.DslModel;

import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;

public class SculptordslValidationWorkflowComponent extends WorkflowComponentWithModelSlot {

	@Override
	protected void invokeInternal(WorkflowContext ctx, ProgressMonitor m, Issues issues) {
		Collection<?> slotContent = (Collection<?>) ctx.get(getModelSlot());
		if (slotContent == null) {
			issues.addError(String.format("Slot %s is empty", getModelSlot()));
		} else {

			// retrieve models from model slot
			List<DslModel> models = Lists.newArrayList();
			for (Resource r : Iterables.filter(slotContent, Resource.class)) {
				for (DslModel model : EcoreUtil2.eAllOfType(r.getContents().get(0), DslModel.class)) {
					models.add(model);
				}
			}
			if (models.isEmpty()) {
				issues.addError(this, "No DslModel instance found in model slot", slotContent, null, null);
			} else {

				// validate models
				for (DslModel model : models) {
					Diagnostic diagnostic = Diagnostician.INSTANCE.validate(model);
					switch (diagnostic.getSeverity()) {
					case Diagnostic.ERROR:
						issues.addError(this, diagnostic.getMessage(), diagnostic.getData().get(0),
								diagnostic.getException(), Collections.emptyList());
						break;
					case Diagnostic.WARNING:
						issues.addWarning(this, diagnostic.getMessage(), diagnostic.getData().get(0),
								diagnostic.getException(), null);
						break;
					}
				}
			}
		}
	}

}
