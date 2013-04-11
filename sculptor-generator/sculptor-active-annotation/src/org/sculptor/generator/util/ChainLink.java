package org.sculptor.generator.util;

public abstract class ChainLink<T extends ChainLink<?>> {
	private T nextLink;

	public ChainLink(T next) {
		// TODO check for NULL
		// can be null only when created from templates and extension in generator-core
		nextLink = next;
	}
	
	public ChainLink() {
		
	}
	
	public void setNext(ChainLink<?> next) {
		nextLink = (T) next;
	}

	public T getNext() {
		return nextLink;
	}
}
