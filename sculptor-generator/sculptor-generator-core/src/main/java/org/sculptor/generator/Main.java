/*
 * Copyright 2013 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.sculptor.generator;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

public class Main {

	public static void main(String[] args) {
		CommandLine line = null;
		Options options = getOptions();
		try {
			line = new GnuParser().parse(options, args);
		} catch (final ParseException exp) {
			System.out.println(exp.getMessage());
			final HelpFormatter formatter = new HelpFormatter();
			formatter.printHelp("java -jar sculptor-generator.jar [OPTIONS]", options);
			System.exit(-1);
		}

		if (!SculptorGeneratorRunner.run(line.getOptionValue("model"))) {
			System.exit(1);
		}
	}

	@SuppressWarnings("static-access")
	public static Options getOptions() {
		final Options options = new Options();
		Option optModel = OptionBuilder.withArgName("model").withDescription("Model file").hasArg().isRequired()
				.withValueSeparator(' ').create("model");
		options.addOption(optModel);
		return options;
	}

}
