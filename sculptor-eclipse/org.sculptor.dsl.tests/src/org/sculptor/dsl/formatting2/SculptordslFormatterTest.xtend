package org.sculptor.dsl.formatting2

import javax.inject.Inject
import org.eclipse.xtext.formatting2.FormatterPreferenceKeys
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.eclipse.xtext.testing.formatter.FormatterTestHelper
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.^extension.ExtendWith;
import org.sculptor.dsl.tests.SculptordslInjectorProvider

@ExtendWith(typeof(InjectionExtension))
@InjectWith(SculptordslInjectorProvider)
class SculptordslFormatterTest {
	
	@Inject extension FormatterTestHelper

	/**
	 * This example tests if the formatted document equals the unformatted document.
	 * This is the most convenient way to test a formatter.
	 */
	@Test def void example1() {
		assertFormatted[
			toBeFormatted = '''
				import "foo"
				import "bar"
				
				ApplicationPart Test {
				
					Module mod {
				
						Entity Test {
						}
				
						Service Test2 {
						}
				
					}
				
				}
			'''
		]
	}

	/**
	* This example tests whether a messy document is being formatted properly.
	* In contrast to the first example, this approach also allows to test formatting strategies that are input-aware.
	* Example: "Change newLines between tokens to be one at minimum, two at maximum."
	* Here, it depends on the formatters input document whether there will be one or two newLines on the output.
	*/
	@Test def void example2() {
		assertFormatted[
			expectation = '''
				import "foo"
				import "bar"
				
				ApplicationPart Test {
					Module mod {
						Entity Test {
						}
						Service Test2 {
						}
					}
				}
			'''
			toBeFormatted = '''
				import    "foo"   
				import    "bar"				
				   
				    
				    
				
				ApplicationPart   Test   {   Module    mod   {   Entity   Test   {}  Service   Test2   {}   }   }
			'''
		]
	}

	/**
	* This example shows how to test property-dependent formatting behavior.
	*/
	@Test def void example3() {
		assertFormatted[
			preferences[
				put(FormatterPreferenceKeys.indentation, " ")
			]
			expectation = '''
				ApplicationPart Test {
				 Module mod {
				  Entity Test {
				  }
				 }
				}
			'''
			toBeFormatted = '''
				ApplicationPart   Test   {   Module mod   {   Entity   Test   {}   }   }
			'''
		]
	}

}