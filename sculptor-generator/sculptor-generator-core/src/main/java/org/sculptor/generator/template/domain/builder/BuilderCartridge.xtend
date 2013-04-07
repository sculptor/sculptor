package org.sculptor.generator.template.domain.builder

import java.util.ArrayList
import org.sculptor.generator.Cartridge

class BuilderCartridge extends Cartridge {
	
	
	override void configure() {
	}
	
	override getClassesToBind() {
		val classes = new ArrayList<Class<?>>()
		classes.add(typeof(BuilderTmpl))
		
		classes
	}
	
}