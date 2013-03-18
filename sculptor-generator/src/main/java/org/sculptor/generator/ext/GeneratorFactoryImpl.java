package org.sculptor.generator.ext;

public class GeneratorFactoryImpl {
	private static GeneratorFactory gFactoryInstance = new GeneratorFactoryStaticImpl();

	public static final GeneratorFactory getInstance() {
		return gFactoryInstance;
	}
}
