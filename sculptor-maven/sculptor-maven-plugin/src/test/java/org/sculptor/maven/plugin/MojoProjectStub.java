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

package org.sculptor.maven.plugin;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.apache.maven.model.Build;
import org.apache.maven.model.Dependency;
import org.apache.maven.model.Model;
import org.apache.maven.model.Resource;
import org.apache.maven.plugin.testing.stubs.MavenProjectStub;

/**
 * Basic MavenProject implementation that can be used for testing.
 */
public class MojoProjectStub extends MavenProjectStub {

	private File projectDir;
	private Properties properties = new Properties();

	public MojoProjectStub(File projectDir) {
		this.projectDir = projectDir;

		String basedir = projectDir.getAbsolutePath();
		getProperties().setProperty("basedir", basedir);

		File pom = new File(getBasedir(), "pom.xml");
		setFile(pom);

		readModel(pom);

		Model model = getModel();
		setGroupId(model.getGroupId());
		setArtifactId(model.getArtifactId());
		setVersion(model.getVersion());
		setName(model.getName());
		setUrl(model.getUrl());
		setPackaging(model.getPackaging());

		Build build = model.getBuild();
		build.setFinalName(model.getArtifactId());
		build.setDirectory(basedir + "/target");
		build.setSourceDirectory(basedir + "/src/main/java");
		build.setOutputDirectory(basedir + "/target/classes");
		build.setTestSourceDirectory(basedir + "/src/test/java");
		build.setTestOutputDirectory(basedir + "/target/test-classes");

		List<Resource> resources = new ArrayList<Resource>();
		Resource resource = new Resource();
		resource.setDirectory(basedir + "/src/main/resources");
		resources.add(resource);
		build.setResources(resources);

		List<Resource> testResources = new ArrayList<Resource>();
		Resource testResource = new Resource();
		testResource.setDirectory(basedir + "/src/test/resources");
		testResources.add(testResource);
		build.setTestResources(testResources);

		setBuild(build);
	}

	@Override
	public File getBasedir() {
		return projectDir;
	}

	@Override
	public Properties getProperties() {
		return properties;
	}

	@Override
	public List<Dependency> getDependencies() {
		return getModel().getDependencies();
	}

	@Override
	public List<Resource> getResources() {
		return getBuild().getResources();
	}

	@Override
	public List<Resource> getTestResources() {
		return getBuild().getTestResources();
	}

}
