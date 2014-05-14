package org.sculptor.generator.chain

@ChainOverridable
class TestTemplate {

	def String test() {
		"code"
	}

	def String test(int i) {
		'''code«i»'''
	}
	
	def String test2() {
		"code2"
	}
	
	def void voidMethod() {
		
	}
	
	def int intMethod() {
		1
	}
	
	def dispatch String uno(String i) {
		i
	}

	def dispatch Integer uno(Integer i) {
		i
	}
	
	
}
