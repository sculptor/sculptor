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

package org.sculptor.generator.chain;

/**
 * This class provides the logic for chain-linking the overriden methods of an
 * overridable template. The {@link ChainOverridable} annotation applies this
 * class as base class for the overriden templates.
 * 
 * @param <T> the overridable template
 * @see ChainOverridable
 */
public abstract class ChainLink<T extends ChainLink<T>> {

	private T nextLink;

	T[] methodsDispatchHead = null;

	public T[] getMethodsDispatchHead() {
		return methodsDispatchHead;
	}

	public ChainLink(T next) {
		nextLink = next;
	}

	@SuppressWarnings("unchecked")
	public void setMethodsDispatchHead(Object[] methodsDispatchHead) {
		this.methodsDispatchHead = (T[])methodsDispatchHead;		
	}

	protected T getNext() {
		return nextLink;
	}

	protected abstract T[] _getOverridesDispatchArray();

}
