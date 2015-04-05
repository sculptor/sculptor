/*
 * Copyright 2014 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import javax.inject.Inject;
import javax.inject.Named;

import org.sculptor.generator.configuration.ConfigurationProvider;
import org.sculptor.generator.configuration.MutableConfigurationProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Technical properties to customize the code generation .
 */
public class PropertiesBase {

	private static final Logger LOG = LoggerFactory.getLogger(PropertiesBase.class);

	@Inject
	private ConfigurationProvider configuration;

	/**
	 * Prepare the default values with values inherited from the configuration.
	 */
	@Inject
	private void initDerivedDefaults(@Named("Mutable Defaults") MutableConfigurationProvider defaultConfiguration) {

		if (hasProperty("test.dbunit.dataSetFile")) {
			// don't generate data set file for each service/consumer
			defaultConfiguration.setBoolean("generate.test.dbunitTestData", false);
		}

		// deployment.type = war for Tomcat and Jetty
		if (getProperty("deployment.applicationServer").equalsIgnoreCase("tomcat")
				|| getProperty("deployment.applicationServer").equalsIgnoreCase("jetty")) {
			defaultConfiguration.setString("deployment.type", "war");
		}

		if (getProperty("deployment.applicationServer").equalsIgnoreCase("appengine")) {
			initDerivedDefaultsForAppengine(defaultConfiguration);

		}

		// generate directives
		if (!hasProjectNature("business-tier")) {
			initDerivedDefaultsForNonBusinessTier(defaultConfiguration);
		}

		if (hasProjectNature("business-tier") && hasProjectNature("pure-ejb3")) {
			initDerivedDefaultsForPureEjb3(defaultConfiguration);
		}

		initDerivedDefaultsSystemAttributes(defaultConfiguration);

		// fetch eager single level
		if (getBooleanProperty("generate.singleLevelFetchEager")) {
			defaultConfiguration.setString("default.fetchStrategy", "lazy");
		}

		// deployment.applicationServer = JBoss for ear
		if (getProperty("deployment.type").equals("ear")) {
			defaultConfiguration.setString("deployment.applicationServer", "JBoss");
		}

		// for JBoss AS 7 use Infinispan cache instead of Ehcache
		if (getProperty("deployment.applicationServer").toLowerCase().equals("jboss")) {
			defaultConfiguration.setString("cache.provider", "Infinispan");
			defaultConfiguration.setBoolean("generate.datasource", true);
		}

		// joda-time
		if (getProperty("datetime.library").equals("joda")) {
			initDerivedDefaultsForJoda(defaultConfiguration);
		}

		if (!getProperty("nosql.provider").equals("none")) {
			initDerivedDefaultsForNosql(defaultConfiguration);
		} else if (!getProperty("jpa.provider").equals("none")) {
			initDerivedDefaultsForJpa(defaultConfiguration);
		} else {
			initDerivedDefaultsWithoutPersistence(defaultConfiguration);
		}

		initDerivedDefaultsForRest(defaultConfiguration);

		if (getBooleanProperty("generate.quick")) {
			initQuick(defaultConfiguration);
		}

		LOG.debug("Initialized properties: {}", getAllPConfigurationKeyValues(configuration));
	}

	private void initDerivedDefaultsForRest(MutableConfigurationProvider defaultConfiguration) {
		if (!getBooleanProperty("generate.resource")) {
			defaultConfiguration.setBoolean("generate.restWeb", false);
		}
		if (!getBooleanProperty("generate.restWeb")) {
			String restScaffoldOperations = defaultConfiguration.getString("rest.scaffold.operations");
			restScaffoldOperations = restScaffoldOperations.replaceFirst(",createForm", "");
			restScaffoldOperations = restScaffoldOperations.replaceFirst(",updateForm", "");
			defaultConfiguration.setString("rest.scaffold.operations", restScaffoldOperations);
		}
	}

	private void initQuick(MutableConfigurationProvider defaultConfiguration) {
		defaultConfiguration.setBoolean("generate.ddl", false);
		defaultConfiguration.setBoolean("generate.umlgraph", false);
		defaultConfiguration.setBoolean("generate.modeldoc", false);
	}

	private void initDerivedDefaultsForNonBusinessTier(MutableConfigurationProvider defaultConfiguration) {
		defaultConfiguration.setBoolean("generate.domainObject", false);
		defaultConfiguration.setBoolean("generate.exception", false);
		defaultConfiguration.setBoolean("generate.repository", false);
		defaultConfiguration.setBoolean("generate.service", false);
		defaultConfiguration.setBoolean("generate.consumer", false);
		defaultConfiguration.setBoolean("generate.spring", false);
		defaultConfiguration.setBoolean("generate.hibernate", false);
		defaultConfiguration.setBoolean("generate.ddl", false);
		defaultConfiguration.setBoolean("generate.umlgraph", false);
		defaultConfiguration.setBoolean("generate.modeldoc", false);
	}

	private void initDerivedDefaultsForJpa(MutableConfigurationProvider defaultConfiguration) {
		if (getBooleanProperty("generate.jpa.annotation")) {
			if (!getProperty("jpa.provider").equals("hibernate")) {
				defaultConfiguration.setBoolean("generate.hibernate", false);
				defaultConfiguration.setString("datetime.library", "java");
			}
		}
	}

	private void initDerivedDefaultsForNosql(MutableConfigurationProvider defaultConfiguration) {
		defaultConfiguration.setBoolean("generate.jpa.annotation", false);
		defaultConfiguration.setBoolean("generate.hibernate", false);
		defaultConfiguration.setBoolean("generate.test.dbunitTestData", false);
		defaultConfiguration.setBoolean("generate.test.emptyDbunitTestData", false);
		defaultConfiguration.setString("cache.provider", "none");
		defaultConfiguration.setString("javaType.IDTYPE", "String");
		defaultConfiguration.setBoolean("generate.validation.annotation", false);
		defaultConfiguration.setString("jpa.provider", "none");
		defaultConfiguration.setBoolean("generate.ddl", false);
	}

	private void initDerivedDefaultsWithoutPersistence(MutableConfigurationProvider defaultConfiguration) {
		defaultConfiguration.setBoolean("generate.jpa.annotation", false);
		defaultConfiguration.setBoolean("generate.hibernate", false);
		defaultConfiguration.setBoolean("generate.test.dbunitTestData", false);
		defaultConfiguration.setBoolean("generate.test.emptyDbunitTestData", false);
		defaultConfiguration.setBoolean("generate.datasource", false);
		defaultConfiguration.setString("javaType.IDTYPE", "String");
		defaultConfiguration.setBoolean("generate.validation.annotation", false);
		defaultConfiguration.setBoolean("generate.ddl", false);
		defaultConfiguration.setString("cache.provider", "none");
		// customize by implementing the access obj yourself and define
		// framework.accessimpl.package
		defaultConfiguration.setString("framework.accessimpl.package", fw("accessimpl.todo"));
		defaultConfiguration.setString("framework.accessimpl.prefix", "");
		defaultConfiguration.setString("framework.accessimpl.AccessBase",
				"org.sculptor.framework.accessimpl.todo.AccessBase");
		defaultConfiguration.setString("framework.accessimpl.AccessBaseWithException",
				"org.sculptor.framework.accessimpl.todo.BaseWithException");
	}

	private void initDerivedDefaultsForPureEjb3(MutableConfigurationProvider defaultConfiguration) {
		defaultConfiguration.setString("deployment.type", "ear");
		defaultConfiguration.setBoolean("generate.spring", false);
		defaultConfiguration.setBoolean("generate.resource", false);
		defaultConfiguration.setBoolean("generate.restWeb", false);
		defaultConfiguration.setString("naming.suffix.Impl", "Bean");
		defaultConfiguration.setBoolean("generate.logbackConfig", false);
	}

	private void initDerivedDefaultsForAppengine(MutableConfigurationProvider defaultConfiguration) {
		defaultConfiguration.setString("deployment.type", "war");
		defaultConfiguration.setString("jpa.provider", "appengine");
		defaultConfiguration.setBoolean("generate.ddl", false);
		defaultConfiguration.setBoolean("generate.validation.annotation", false);
		defaultConfiguration.setString("javaType.IDTYPE", "com.google.appengine.api.datastore.Key");
		defaultConfiguration.setString("cache.provider", "memcache");
		defaultConfiguration.setBoolean("generate.test.dbunitTestData", false);
		defaultConfiguration.setBoolean("generate.test.emptyDbunitTestData", false);
	}

	private void initDerivedDefaultsForJoda(MutableConfigurationProvider defaultConfiguration) {
		defaultConfiguration.setString("javaType.Date", "org.joda.time.LocalDate");
		defaultConfiguration.setString("javaType.DateTime", "org.joda.time.DateTime");
		defaultConfiguration.setString("javaType.Timestamp", "org.joda.time.DateTime");

		defaultConfiguration.setString("hibernateType.Date", "org.jadira.usertype.dateandtime.joda.PersistentLocalDate");
		defaultConfiguration.setString("hibernateType.DateTime", "org.jadira.usertype.dateandtime.joda.PersistentDateTime");
		defaultConfiguration.setString("hibernateType.Timestamp", "org.jadira.usertype.dateandtime.joda.PersistentDateTime");

		defaultConfiguration
				.setString(
						"propertyEditor.Date",
						"org.sculptor.framework.propertyeditor.LocalDateEditor(getMessagesAccessor().getMessage(\"format.DatePattern\", \"yyyy-MM-dd\"), true)");
		defaultConfiguration
				.setString(
						"propertyEditor.DateTime",
						"org.sculptor.framework.propertyeditor.DateTimeEditor(getMessagesAccessor().getMessage(\"format.DateTimePattern\", \"yyyy-MM-dd HH:mm\"), true)");
		defaultConfiguration
				.setString(
						"propertyEditor.Timestamp",
						"org.sculptor.framework.propertyeditor.DateTimeEditor(getMessagesAccessor().getMessage(\"format.DateTimePattern\", \"yyyy-MM-dd HH:mm\"), true)");

		defaultConfiguration.setString("framework.xml.DateHandler",
				"org.sculptor.framework.xml.JodaLocalDateHandler");
		defaultConfiguration.setString("framework.xml.TimeStampHandler",
				"org.sculptor.framework.xml.JodaDateTimeHandler");

		defaultConfiguration.setBoolean("generate.auditable.joda", true);
	}

	private void initDerivedDefaultsSystemAttributes(MutableConfigurationProvider defaultConfiguration) {
		if (!getBooleanProperty("generate.auditable")) {
			String value = defaultConfiguration.getString("systemAttributes");
			value = value.replaceAll(",createdBy", "");
			value = value.replaceAll(",createdDate", "");
			value = value.replaceAll(",updatedBy", "");
			value = value.replaceAll(",updatedDate", "");
			value = value.replaceAll(",lastUpdated", "");
			value = value.replaceAll(",lastUpdatedBy", "");
			defaultConfiguration.setString("systemAttributes", value);
		}
	}

	public String getProperty(String propertyName) {
		return configuration.getString(propertyName);
	}

	public boolean hasProperty(String propertyName) {
		return configuration.has(propertyName);
	}

	public boolean getBooleanProperty(String propertyName) {
		return configuration.getBoolean(propertyName);
	}

	Set<String> getPropertyNames() {
		return configuration.keys();
	}

	/**
	 * Gets all properties with a key starting with a prefix.
	 *
	 * @param prefix
	 * @return properties starting with prefix
	 */
	Properties getProperties(String prefix) {
		return getProperties(prefix, false);
	}

	/**
	 * Gets all properties with a key starting with prefix.
	 *
	 * @param prefix
	 * @param removePrefix
	 *			  remove prefix in the resulting properties or not
	 * @return properties starting with prefix
	 */
	Properties getProperties(String prefix, boolean removePrefix) {
		Properties result = new Properties();
		for (String key : getPropertyNames()) {
			if (key.startsWith(prefix)) {
				result.put((removePrefix) ? key.substring(prefix.length()) : key, getProperty(key));
			}
		}
		return result;
	}

	/**
	 * Transforms the given properties to a map with key/value pairs.
	 *
	 * @param properties
	 *			  to transform
	 * @return map containing transformed properties
	 */
	public Map<String, String> getPropertiesAsMap(Properties properties) {
		Map<String, String> result = new HashMap<String, String>();
		for (String key : properties.stringPropertyNames()) {
			result.put(key, properties.getProperty(key));
		}
		return result;
	}

	private String fw(String className) {
		String propName = "framework." + className;
		if (hasProperty(propName)) {
			return getProperty(propName);
		} else {
			return "org.sculptor." + propName;
		}
	}

	public String getServiceContextClass() {
		return fw("context.ServiceContext");
	}

	public String getDbProduct() {
		return getProperty("db.product");
	}

	public String getHibernateDialect() {
		String key = "db." + getDbProduct() + ".hibernate.dialect";
		return getProperty(key);
	}

	public String getDbType(String javaType) {
		String key = "db." + getDbProduct() + ".type." + javaType;
		return getProperty(key);
	}

	public String getDbLength(String javaType) {
		String key = "db." + getDbProduct() + ".length." + javaType;
		if (hasProperty(key)) {
			return getProperty(key);
		} else {
			return null;
		}
	}

	public Integer getMaxDbName() {
		String key = "db." + getDbProduct() + ".maxNameLength";
		return new Integer(getProperty(key));
	}

	public boolean isDbResponsibleForOnDeleteCascade() {
		String key = "db." + getDbProduct() + ".onDeleteCascade";
		return Boolean.valueOf(getProperty(key));
	}

	public String getDefaultCascade(String referenceType) {
		String propertyName = "cascade." + referenceType;
		if (hasProperty(propertyName)) {
			String value = getProperty(propertyName);
			return ("".equals(value) ? null : value);
		} else {
			return null;
		}
	}

	public String getJavaType(String modelType) {
		String key = "javaType." + modelType;
		if (hasProperty(key)) {
			return getProperty(key);
		} else {
			return null;
		}
	}

	public String getJavaTypeImpl(String modelType) {
		String key = "javaType.impl." + modelType;
		if (hasProperty(key)) {
			return getProperty(key);
		} else {
			return null;
		}
	}

	public String mapHibernateType(String modelType) {
		String key = "hibernateType." + modelType;
		if (hasProperty(key)) {
			return getProperty(key);
		} else {
			return null;
		}
	}

	public String getIdType() {
		return getProperty("id.type");
	}

	public String mapPropertyEditor(String modelType) {
		String key = "propertyEditor." + modelType;
		if (hasProperty(key)) {
			return getProperty(key);
		} else {
			return null;
		}
	}

	public String getServiceInterfacePackage() {
		return getProperty("package.serviceInterface");
	}

	public String getServiceImplementationPackage() {
		return getProperty("package.serviceImplementation");
	}

	public String getControllerInterfacePackage() {
		return getProperty("package.controllerInterface");
	}

	public String getRestPackage() {
		return getProperty("package.rest");
	}

	public String getServiceProxyPackage() {
		return getProperty("package.serviceProxy");
	}

	public String getServiceStubPackage() {
		return getProperty("package.serviceStub");
	}

	public String getConsumerPackage() {
		return getProperty("package.consumer");
	}

	public String getXmlMapperPackage() {
		return getProperty("package.xmlmapper");
	}

	public String getDomainPackage() {
		return getProperty("package.domain");
	}

	public String getDtoPackage() {
		return getProperty("package.dto");
	}

	public String getDomainEventPackage() {
		return getProperty("package.domainEvent");
	}

	public String getCommandEventPackage() {
		return getProperty("package.commandEvent");
	}

	public String getRepositoryInterfacePackage() {
		return getProperty("package.repositoryInterface");
	}

	public String getExceptionPackage() {
		return getProperty("package.exception");
	}

	public String getRepositoryImplementationPackage() {
		return getProperty("package.repositoryImplementation");
	}

	public String getAccessInterfacePackage() {
		return getProperty("package.accessInterface");
	}

	public String getAccessImplementationPackage() {
		return getProperty("package.accessImplementation");
	}

	public List<String> scaffoldOperations() {
		String value = getProperty("scaffold.operations");
		String[] operations = value.split(",");
		trim(operations);
		return new ArrayList<String>(Arrays.asList(operations));
	}

	public List<String> restScaffoldOperations() {
		String value = getProperty("rest.scaffold.operations");
		String[] operations = value.split(",");
		trim(operations);
		return new ArrayList<String>(Arrays.asList(operations));
	}

	public String restServiceDelegateOperation(String name) {
		String propName = "rest." + name + ".delegate";
		if (hasProperty(propName)) {
			return getProperty(propName);
		} else {
			return null;
		}
	}

	public List<String> projectNature() {
		String value = getProperty("project.nature");
		String[] operations = value.split(",");
		trim(operations);
		return new ArrayList<String>(Arrays.asList(operations));
	}

	private void trim(String[] strings) {
		for (int i = 0; i < strings.length; i++) {
			strings[i] = strings[i].trim();
		}
	}

	public boolean hasProjectNature(String nature) {
		return projectNature().contains(nature);
	}

	public Map<String, String> singular2pluralDefinitions() {
		Map<String, String> result = new HashMap<String, String>();
		String prefix = "singular2plural.";
		Set<String> names = getPropertyNames();
		for (String key : names) {
			if (key.startsWith(prefix)) {
				result.put(key.substring(prefix.length()), getProperty(key));
			}
		}
		return result;
	}

	/**
	 * Gets a single validation annotation from properties.
	 *
	 * @param annotation
	 *			  shortcut for annotation
	 * @return fully qualified Annotation Class (without leading @)
	 */
	public String mapValidationAnnotation(String annotation) {
		return mapValidationAnnotation(annotation, null);
	}

	/**
	 * Gets a single validation annotation from properties.
	 *
	 * @param annotation
	 *			  shortcut for annotation
	 * @param defaultAnnotation
	 *			  default annotation in case annotation could not be found
	 * @return fully qualified Annotation Class (without leading @)
	 */
	public String mapValidationAnnotation(String annotation, String defaultAnnotation) {
		String key = "validation.annotation." + toFirstUpper(annotation);
		if (hasProperty(key)) {
			return getProperty(key);
		} else {
			return defaultAnnotation;
		}
	}

	/**
	 * First character to upper case.
	 */
	private String toFirstUpper(String name) {
		if (name.length() == 0) {
			return name;
		} else {
			return name.substring(0, 1).toUpperCase() + name.substring(1);
		}
	}

	/**
	 * Gets all configured properties for validation annotations as map.
	 *
	 * @return map with validation annotations
	 */
	public Map<String, String> validationAnnotationDefinitions() {
		return getPropertiesAsMap(getProperties("validation.annotation.", true));
	}

	/**
	 * Returns a sorted list of all key-value pairs defined in given configuration instance.
	 */
	private List<String> getAllPConfigurationKeyValues(ConfigurationProvider configuration) {
		List<String> keyValues = new ArrayList<String>();
		for (String key : configuration.keys()) {
			keyValues.add(key + "=\"" + configuration.getString(key) + "\"");
		}
		Collections.sort(keyValues);
		return keyValues;
	}

}
