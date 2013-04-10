package org.sculptor.generator

class ExtensionPoint<T extends ExtensionPoint<?>> {
	var T next
	
	def T getNext() {
		next
	}
	
	def void setNext(ExtensionPoint<?> next) {
		this.next = next as T
	}
	
}