package org.eclipselabs.xtext.utils.unittesting;

import org.eclipse.xtext.junit4.IInjectorProvider;
import org.eclipse.xtext.junit4.IRegistryConfigurator;
import org.eclipse.xtext.junit4.XtextRunner;
import org.junit.runners.model.FrameworkMethod;
import org.junit.runners.model.InitializationError;
import org.junit.runners.model.Statement;

public class XtextRunner2 extends XtextRunner {

	public XtextRunner2(Class<?> klass) throws InitializationError {
		super(klass);
	}

	@Override
	protected Statement methodBlock(FrameworkMethod method) {
		IInjectorProvider injectorProvider = getOrCreateInjectorProvider();
		if (injectorProvider instanceof IRegistryConfigurator) {
			
			final Statement methodBlock = super.methodBlock(method);
			
			final IRegistryConfigurator registryConfigurator = (IRegistryConfigurator) injectorProvider;
			registryConfigurator.setupRegistry();
			
			// ATU: move this line up because super.methodBlock(method) will call
			// <DSL>InjectorProvider.getInjector(), 
			// and because <DSL>InjectorProvider.setupRegistry() should be called afterwards.
			// 
			//final Statement methodBlock = super.methodBlock(method);
			
			return new Statement() {
				@Override
				public void evaluate() throws Throwable {
					try {
						methodBlock.evaluate();
					} finally {
						registryConfigurator.restoreRegistry();
					}
				}
			};
		}else{
			return super.methodBlock(method);
		}
	}
}
