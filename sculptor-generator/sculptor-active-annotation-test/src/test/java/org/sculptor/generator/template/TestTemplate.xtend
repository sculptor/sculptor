package org.sculptor.generator.template

import org.sculptor.generator.chain.ChainOverridable

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
	
	
}
