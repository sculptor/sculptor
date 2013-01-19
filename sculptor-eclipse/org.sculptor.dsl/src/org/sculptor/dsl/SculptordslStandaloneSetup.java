
package org.sculptor.dsl;

import org.sculptor.dsl.SculptordslStandaloneSetupGenerated;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class SculptordslStandaloneSetup extends SculptordslStandaloneSetupGenerated{

	public static void doSetup() {
		new SculptordslStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

