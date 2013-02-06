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

package org.sculptor.dsl.scoping;

import java.util.List;

import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.impl.AbstractScope;
/**
 * 
 * @author Todd Ferrell
 *
 */
public class Scope extends AbstractScope {
	
	public Scope() {
		this(IScope.NULLSCOPE, true);
	}
	protected Scope(IScope parent, boolean ignoreCase) {
		super(parent, ignoreCase);
		// TODO Auto-generated constructor stub
	}


	private List<IEObjectDescription> elements;


	public IScope getOuterScope() {
		return outer == null ? IScope.NULLSCOPE : outer;
	}

	
	private IScope outer;
	
	public void setOuterScope(IScope outer) {
		this.outer = outer;
	}


	public void setElements(List<IEObjectDescription> elements) {
		this.elements = elements;
	}

	@Override
	protected Iterable<IEObjectDescription> getAllLocalElements() {
		
		return elements;
	}	
}
