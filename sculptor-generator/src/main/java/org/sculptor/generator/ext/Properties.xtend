/*
 * Copyright 2007 The Fornax Project Team, including the original
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

package org.sculptor.generator.ext

import java.util.Collection
import sculptormetamodel.Application
import sculptormetamodel.Module
import sculptormetamodel.Attribute

import static org.sculptor.generator.util.PropertiesBase.*

class Properties {

	def static boolean getBooleanProperty(String propertyName) {
		getProperty(propertyName).toLowerCase() == "true";
	}

	def static String getProperty(String propertyName, String defaultValue) {
		if (hasProperty(propertyName)) getProperty(propertyName) else defaultValue;
	}

	def static String fw(String fwClassName) {
		val propName = "framework." + fwClassName

		if (hasProperty(propName))
			getProperty(propName)
		else
			"org.fornax.cartridges.sculptor." + propName
	}

	def static String defaultExtendsClass(String typeName) {
		val propName = typeName.toFirstLower() + ".extends"
		if (hasProperty(propName))
			getProperty(propName)
		else
			"";
	}

	def static String abstractDomainObjectClass() {
		fw("domain.AbstractDomainObject");
	}

	def static String consumerInterface() {
		fw("event.EventSubscriber");
	}

	def static String abstractMessageBeanClass() {
		fw("consumer.AbstractMessageBean2");
	}

	def static String serviceContextClass() {
		fw("errorhandling.ServiceContext");
	}

	def static String serviceContextStoreAdviceClass() {
		fw("errorhandling.ServiceContextStoreAdvice");
	}

	def static String serviceContextStoreClass() {
		fw("errorhandling.ServiceContextStore");
	}

	def static String serviceContextServletFilterClass() {
		fw("errorhandling.ServiceContextServletFilter");
	}

	def static String servletContainerServiceContextFactoryClass() {
		fw("errorhandling.ServletContainerServiceContextFactory");
	}

	def static String auditInterceptorClass() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditInterceptor")
		else 
			fw("domain.AuditInterceptor")
	}

	def static String auditableInterface() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditable")
		else
			fw("domain.Auditable");
	}

	def static String identifiableInterface() {
		fw("domain.Identifiable");
	}

	def static String applicationExceptionClass() {
		fw("errorhandling.ApplicationException");
	}

	def static String systemExceptionClass() {
		fw("errorhandling.SystemException");
	}

	def static String accessBaseWithExceptionClass() {
		fw("accessimpl.AccessBaseWithException");
	}

	def static String accessBaseClass() {
		fw("accessimpl.AccessBase");
	}

	def static String genericAccessObjectInterface(String name) {
		val apiName = name.toFirstUpper() + "Access"

		if (hasProperty("framework.accessapi." + apiName))
			fw("accessapi." + apiName)
		else if (hasProperty("framework.accessapi.package"))
			getProperty("framework.accessapi.package") + "." + apiName
		else
			// default name
			fw("accessapi." + apiName);
	}

	// Configuration of access object is pretty flexible.
	// It is documented in default-sculptor-generator.properties
	// and in Developer's Guide.
	def static String genericAccessObjectImplementation(String name) {
		val jpa = isJpaAnnotationToBeGenerated()
		val hibernate = (!jpa || isJpaProviderHibernate()) && !isJpa2()

		// don't use Spring when using jpa
		val spring = !jpa && isSpringToBeGenerated() && isJpaProviderHibernate()
		val implName = name.toFirstUpper() + "AccessImpl"
		if (hasProperty("framework.accessimpl." + implName))
			fw("accessimpl." + implName)
		else
			mapGenericAccessObjectImplementationPackage(jpa, hibernate, spring) + "." +
				mapGenericAccessObjectImplementationPrefix(jpa, hibernate, spring) + implName
	}

	def private static String mapGenericAccessObjectImplementationPrefix(boolean jpa, boolean hibernate, boolean spring) {
		if (hasProperty("framework.accessimpl.prefix"))
			getProperty("framework.accessimpl.prefix")
		else
			(if (jpa) "Jpa" else "") +
			(if (hibernate) "Hib" else "") +
			(if (spring) "Sp" else "")
	}

	def private static String mapGenericAccessObjectImplementationPackage(boolean jpa, boolean hibernate, boolean spring) {
		if (hasProperty("framework.accessimpl.package"))
			getProperty("framework.accessimpl.package")
		else {
			val lastPart =
				(if (jpa) ( if (isJpa2()) "jpa2" else "jpa") else "") +
				(if (hibernate) "hibernate" else "") +
				(if (spring) "spring" else "");
			fw( if (lastPart == "" ) "accessimpl" else "accessimpl." + lastPart)
		}
	}

	// Attributes defined by system that should appear last in attribute listings, such as in DDL
	def static Collection<String> getSystemAttributesToPutLast() {
		getProperty("systemAttributesToPutLast").split(",");
	}

	def static String databaseTestCaseClass() {
		fw("util.db.IsolatedDatabaseTestCase");
	}

	def static String fakeObjectInstantiatorClass() {
		fw("util.FakeObjectInstantiator");
	}

	def static String enumUserTypeClass() {
		fw("accessimpl.GenericEnumUserType");
	}

	def static String jpaFlowExecutionListenerListenerClass() {
	if (isJpaProviderEclipseLink() || isJpaProviderDataNucleus())
			fw("web.jpa.JpaFlowExecutionListener")
		else
			"org.springframework.webflow.persistence.JpaFlowExecutionListener";
	}

	def static String openHibernateSessionInConversationListenerClass() {
		fw("web.hibernate.OpenHibernateSessionInConversationListener");
	}

	def static String disconnectHibernateInterceptor() {
		fw("web.hibernate.DisconnectHibernateInterceptor");
	}

	def static String webExceptionUtilClass() {
		fw("web.errorhandling.ExceptionUtil");
	}

	def static String webExceptionAdviceClass() {
		fw("web.errorhandling.ExceptionAdvice");
	}

	def static String conversationDomainObjectRepositoryInterface() {
		fw("web.hibernate.ConversationDomainObjectRepository");
	}

	def static String conversationDomainObjectJpaRepositoryImplClass() {
		fw("web.jpa.ConversationDomainObjectJpaRepositoryImpl");
	}

	def static String optionEditorClass() {
		fw("propertyeditor.OptionEditor");
	}

	def static String optionClass() {
		fw("propertyeditor.Option");
	}

	def static String enumEditorClass() {
		fw("propertyeditor.EnumEditor");
	}

	def static String cacheProvider() {
		getProperty("cache.provider");
	}

	def static Boolean pureEjb3() {
		hasProjectNature("pure-ejb3");
	}

	def static Boolean isEar() {
		getProperty("deployment.type") == "ear";
	}

	def static Boolean isWar() {
		getProperty("deployment.type") == "war";
	}

	def static Boolean isRunningInServletContainer() {
		applicationServer() == "tomcat" || applicationServer() == "jetty";
	}

	def static String applicationServer() {
		getProperty("deployment.applicationServer").toLowerCase();
	}

	def static String notChangeablePropertySetterVisibility() {
		getProperty("notChangeablePropertySetter.visibility");
	}

	def static String notChangeableReferenceSetterVisibility() {
		getProperty("notChangeableReferenceSetter.visibility");
	}

	def static boolean isGuiDefaultsToBeCreated() {
		getBooleanProperty("gui.createDefaults");
	}

	def static boolean isJSFCrudGuiToBeGenerated() {
		getBooleanProperty("generate.jsfCrudGui");
	}

	def static boolean isRcpCrudGuiToBeGenerated() {
		getBooleanProperty("generate.rcpCrudGui");
	}

	def static boolean isRapCrudGuiToBeGenerated() {
		getBooleanProperty("generate.rapCrudGui");
	}

	def static boolean isBuilderToBeGenerated() {
		getBooleanProperty("generate.domainObject.builder");
	}

	def static boolean isDomainObjectToBeGenerated() {
		getBooleanProperty("generate.domainObject");
	}

	def static boolean isDomainObjectCompositeKeyClassToBeGenerated() {
		getBooleanProperty("generate.domainObject.compositeKeyClass");
	}

	def static boolean isExceptionToBeGenerated() {
		getBooleanProperty("generate.exception");
	}

	def static boolean isRepositoryToBeGenerated() {
		getBooleanProperty("generate.repository");
	}

	def static boolean isServiceToBeGenerated() {
		getBooleanProperty("generate.service");
	}

	def static boolean isServiceProxyToBeGenerated() {
		getBooleanProperty("generate.service.proxy");
	}

	def static boolean isResourceToBeGenerated() {
		getBooleanProperty("generate.resource");
	}

	def static boolean isRestWebToBeGenerated() {
		getBooleanProperty("generate.restWeb");
	}

	def static boolean isSpringRemotingToBeGenerated() {
		getBooleanProperty("generate.springRemoting");
	}

	def static String getSpringRemotingType() {
		if (isSpringRemotingToBeGenerated())
			getProperty("spring.remoting.type").toLowerCase()
		else
			"N/A";
	}

	def static boolean isConsumerToBeGenerated() {
		getBooleanProperty("generate.consumer");
	}

	def static boolean isSpringToBeGenerated() {
		getBooleanProperty("generate.spring");
	}

	def static boolean isHibernateToBeGenerated() {
		getBooleanProperty("generate.hibernate");
	}

	def static boolean isDdlToBeGenerated() {
		getBooleanProperty("generate.ddl");
	}

	def static boolean isDdlDropToBeGenerated() {
		getBooleanProperty("generate.ddl.drop");
	}

	def static boolean isDatasourceToBeGenerated() {
		getBooleanProperty("generate.datasource");
	}

	def static boolean isLogbackConfigToBeGenerated() {
		getBooleanProperty("generate.logbackConfig");
	}

	def static boolean isTestToBeGenerated() {
		getBooleanProperty("generate.test");
	}

	def static boolean isDbUnitTestDataToBeGenerated() {
		getBooleanProperty("generate.test.dbunitTestData");
	}

	def static boolean isEmptyDbUnitTestDataToBeGenerated() {
		getBooleanProperty("generate.test.emptyDbunitTestData");
	}

	def static boolean isModuleToBeGenerated(String moduleName) {
		val propertyName = "generate.module." + moduleName;
		if (hasProperty(propertyName))
			getBooleanProperty(propertyName)
		else
			true;
	}

	def static String getDbUnitDataSetFile() {
		if (hasProperty("test.dbunit.dataSetFile"))
			getProperty("test.dbunit.dataSetFile")
		else
			null;
	}

	def static boolean isServiceContextToBeGenerated() {
		getBooleanProperty("generate.serviceContext");
	}

	def static boolean isAuditableToBeGenerated() {
		getBooleanProperty("generate.auditable");
	}

	def static boolean isUMLToBeGenerated() {
		getBooleanProperty("generate.umlgraph");
	}

	def static boolean isModelDocToBeGenerated() {
		getBooleanProperty("generate.modeldoc");
	}

	def static boolean isOptimisticLockingToBeGenerated() {
		getBooleanProperty("generate.optimisticLocking");
	}

	def static boolean isPubSubToBeGenerated() {
		getBooleanProperty("generate.pubSub");
	}

	def static boolean isGapClassToBeGenerated() {
		getBooleanProperty("generate.gapClass");
	}

	def static boolean isGapClassToBeGenerated(String module, String clazz) {
		if (hasProperty("generate.gapClass." + module + "." + clazz))
			getBooleanProperty("generate.gapClass." + module + "." + clazz)
		else if (hasProperty("generate.gapClass." + clazz))
			getBooleanProperty("generate.gapClass." + clazz)
		else
			isGapClassToBeGenerated();
	}

	def static boolean isGapClassToBeGenerated(boolean dslGapClass, boolean dslNoGapClass) {
		if (dslGapClass)
			true
		else
			( if (dslNoGapClass) false else isGapClassToBeGenerated() );
	}

	def static String subPackage(String packageKey) {
		getProperty("package." + packageKey);
	}

	def static String getDateTimeLibrary() {
		getProperty("datetime.library");
	}

	def static boolean isHighlightMissingMessageResources() {
		getBooleanProperty("gui.highlightMissingMessageResources");
	}

	def static boolean isStubService() {
		getBooleanProperty("gui.stubService");
	}

	def static String getResourceDir(Application application, String name) {
		getResourceDirImpl(name);
	}

	def static String getResourceDir(Module module, String name) {
		getResourceDirImpl(name);
	}

	def private static String getResourceDirImpl(String name) {
		switch (name) {
			case "spring" : ""
			default: name + "/"
		}
	}

	def static String getEnumTypeDefFileName(Module module) {
		"Enums-" + module.name + ".hbm.xml";
	}

	def static String javaHeader() {
		if (getProperty("javaHeader") == "")
			""
		else
		"/* " + getProperty("javaHeader").replaceAll("\n", "\n * ") + "\n */"
	}

	def static boolean jpa() {
		jpaProvider() != "none"
	}

	def static boolean nosql() {
		getProperty("nosql.provider") != "none";
	}

	def static boolean mongoDb() {
		getProperty("nosql.provider") == "mongoDb";
	}

	def static boolean isJpaAnnotationToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation");
	}

	def static boolean isJpaAnnotationColumnDefinitionToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation.columnDefinition");
	}

	def static boolean isJpaAnnotationOnFieldToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation.onField");
	}

	def static boolean isValidationAnnotationToBeGenerated() {
		getBooleanProperty("generate.validation.annotation");
	}

	def static boolean isDtoValidationAnnotationToBeGenerated() {
		getBooleanProperty("generate.validation.annotation.dataTransferObject");
	}

	def static boolean isSpringAnnotationTxToBeGenerated() {
		getBooleanProperty("generate.spring.annotation.tx");
	}

	def static boolean isSpringDataSourceSupportToBeGenerated() {
		getBooleanProperty("generate.spring.dataSourceSupport");
	}

	def static boolean isXstreamAnnotationToBeGenerated() {
		getBooleanProperty("generate.xstream.annotation");
	}

	def static boolean isXmlBindAnnotationToBeGenerated() {
		getBooleanProperty("generate.xml.bind.annotation");
	}

	def static boolean isXmlBindAnnotationToBeGenerated(String typeName) {
		val propName = "generate.xml.bind.annotation." + typeName.toFirstLower()
		if (hasProperty(propName)) getBooleanProperty(propName) else false;
	}

	def static boolean isFullyAuditable() {
		getBooleanProperty("generate.fullAuditable");
	}

	def static boolean isInjectDrools() {
		getBooleanProperty("generate.injectDrools");
	}

	def static boolean isGenerateParameterName() {
		getBooleanProperty("generate.parameterName");
	}

	def static String jpaProvider() {
		getProperty("jpa.provider").toLowerCase();
	}

	def static boolean isJpaProviderHibernate() {
		jpaProvider() == "hibernate" || jpaProvider() == "hibernate3";
	}

	def static boolean isJpaProviderHibernate3() {
		jpaProvider() == "hibernate3";
	}

	def static boolean isJpaProviderHibernate4() {
		jpaProvider() == "hibernate";
	}

	def static boolean isJpaProviderEclipseLink() {
		jpaProvider() == "eclipselink";
	}

	def static boolean isJpaProviderDataNucleus() {
		jpaProvider() == "datanucleus";
	}

	def static boolean isJpaProviderAppEngine() {
		jpaProvider() == "appengine";
	}

	def static boolean isJpaProviderOpenJpa() {
		jpaProvider() == "openjpa";
	}

	def static String jpaVersion() {
		getProperty("jpa.version");
	}

	def static boolean isJpa1() {
		"1.0" == jpaVersion() && jpa();
	}

	def static boolean isJpa2() {
		"2.0" == jpaVersion() && jpa();
	}

	def static String validationProvider() {
		getProperty("validation.provider");
	}

	def static String testProvider() {
		getProperty("test.provider");
	}

	def static String databaseJpaTestCaseClass() {
		fw("test.AbstractDbUnitJpaTests");
	}

	def static String auditEntityListener() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditListener")
		else
			fw("domain.AuditListener");
	}

	def static String validationEntityListener() {
		if (isValidationAnnotationToBeGenerated())
			"org.fornax.cartridges.sculptor.framework.validation.ValidationEventListener"
		else
			null;
	}

	def static String getApplicationContextFile(Application application, String fileName) {
		fileName;
	}

	def static String getApplicationContextFile(Module module, String fileName) {
		fileName;
	}

	def static Collection<String> getSystemAttributes() {
		getProperty("systemAttributes").split(",");
	}

	def static boolean isSystemAttribute(Attribute att) {
		getSystemAttributes().contains(att.name);
	}

	def static Collection<String> getAuditableAttributes() {
		getProperty("auditableAttributes").split(",");
	}

	def static boolean isAuditableAttribute(Attribute att) {
		getAuditableAttributes().contains(att.name);
	}

	def static Collection<String> getNotRestRequestParameter() {
		getProperty("rest.notRequestParameter").split(",");
	}

	def static boolean isDynamicMenu() {
		if (hasProperty("menu.type"))
			getProperty("menu.type") != "linkbased"
		else
			true;
	}

	def static String getSuffix(String key) {
		getProperty("naming.suffix." + key);
	}

	def static String persistenceXml() {
		getProperty("jpa.persistenceXmlFile");
	}

	def static boolean usePersistenceContextUnitName() {
	!isJpaProviderAppEngine() && !(isEar() && isSpringToBeGenerated());
	}

	def static boolean useJpaDefaults() {
		getBooleanProperty("jpa.useJpaDefaults");
	}

	def static boolean generateFinders() {
		getBooleanProperty("generate.repository.finders");
	}

	def static boolean useIdSuffixInForeigKey() {
		getBooleanProperty("db.useIdSuffixInForeigKey");
	}

	// hook to be overwritten to make additional programatic configuration of properties
	def static initPropertiesHook() {
		null;
	}
}
