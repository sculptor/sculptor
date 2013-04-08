package org.sculptor.generator.template

import sculptormetamodel.Application

class RootTmplBase {
	
	var RootTmplBase next
	
	def RootTmplBase getNext() {
		next
	}
	def String Root(Application it) {
		next.Root(it)
	}
}