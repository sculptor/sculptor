package org.sculptor.generator.cartridge.builder

import java.util.ArrayList
import org.sculptor.generator.Cartridge

class BuilderCartridge extends Cartridge {
	
	
	override getClassesToBind() {
		val classes = new ArrayList<Class<?>>()
		classes.add(typeof(BuilderTmpl))
		
		classes
	}
	
}
