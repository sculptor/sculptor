/*
 * (C) Copyright Factory4Solutions a.s. 2010
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
package org.sculptor.framework.drools;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Collection;

import org.drools.core.util.DroolsStreamUtils;
import org.kie.internal.agent.KnowledgeAgent;
import org.kie.internal.agent.KnowledgeAgentFactory;
import org.kie.internal.definition.KnowledgePackage;
import org.kie.internal.io.ResourceFactory;

public class DroolsCompiler {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		String changeSet=null;
		String outputDir=".";
		if (args.length == 0) {
			System.err.println("ERROR: change-set not specified");
		} else if (args.length > 2) {
			System.err.println("ERROR: too many parameters specified");
		} else if (! (new File(args[0])).canRead()) {
			System.err.println("ERROR: change-set not readable");
		} else if (args.length == 2 && ! (new File(args[1])).isDirectory()) {
			System.err.println("ERROR: Second parameter '"+args[1]+"' is not pointing to directory");
		} else {
			changeSet=args[0];
			outputDir=args.length == 2 ? args[1] : outputDir;
		}

		if (changeSet == null) {
			System.out.println("DroolsCompiler <change-set.xml> [output-directory]\n" +
					"\tProgram compile specified changet-set.xml and produce packages in binary form.\n\n" +
					"\tchange-set.xml   - XML file in changeset format (look to Drools documentation)\n"+
					"\toutput-directory - name of output directory where packages are exported");
		} else {
			compileChangeSet(changeSet, outputDir);
			System.exit(0);
		}
	}

	private static void compileChangeSet(String changeSet, String outputDir) {
		Long start=System.currentTimeMillis();
		KnowledgeAgent kAgent = KnowledgeAgentFactory.newKnowledgeAgent( "CompilerAgent" );
		kAgent.applyChangeSet(ResourceFactory.newFileResource(changeSet));
		Collection<KnowledgePackage> kPackages = kAgent.getKnowledgeBase().getKnowledgePackages();

		for (KnowledgePackage kPackage : kPackages) {
			String packageName = kPackage.getName();
			try {
				String fileName=outputDir+"/"+packageName+".pkg";
				DroolsStreamUtils.streamOut(new FileOutputStream(fileName), kPackage);
				System.out.println("File '"+fileName+"' was created.");
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		System.out.format("Compilation time: %,dms\n", System.currentTimeMillis() - start);
	}
}