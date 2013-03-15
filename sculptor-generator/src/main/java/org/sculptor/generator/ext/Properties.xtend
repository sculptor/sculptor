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
import org.sculptor.generator.util.PropertiesBase

class Properties {
	extension PropertiesBase propBase = GeneratorFactory::propertiesBase

	def boolean getBooleanProperty(String propertyName) {
		getProperty(propertyName).toLowerCase() == "true";
	}

	def String getProperty(String propertyName, String defaultValue) {
		if (hasProperty(propertyName)) getProperty(propertyName) else defaultValue;
	}

	def String fw(String fwClassName) {
		val propName = "framework." + fwClassName

		if (hasProperty(propName))
			getProperty(propName)
		else
			"org.sculptor." + propName
	}

	def String defaultExtendsClass(String typeName) {
		val propName = typeName.toFirstLower() + ".extends"
		if (hasProperty(propName))
			getProperty(propName)
		else
			"";
	}

	def String abstractDomainObjectClass() {
		fw("domain.AbstractDomainObject");
	}

	def String consumerInterface() {
		fw("event.EventSubscriber");
	}

	def String abstractMessageBeanClass() {
		fw("consumer.AbstractMessageBean2");
	}

	def String serviceContextClass() {
		fw("errorhandling.ServiceContext");
	}

	def String serviceContextStoreAdviceClass() {
		fw("errorhandling.ServiceContextStoreAdvice");
	}

	def String serviceContextStoreClass() {
		fw("errorhandling.ServiceContextStore");
	}

	def String serviceContextServletFilterClass() {
		fw("errorhandling.ServiceContextServletFilter");
	}

	def String servletContainerServiceContextFactoryClass() {
		fw("errorhandling.ServletContainerServiceContextFactory");
	}

	def String auditInterceptorClass() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditInterceptor")
		else 
			fw("domain.AuditInterceptor")
	}

	def String auditableInterface() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditable")
		else
			fw("domain.Auditable");
	}

	def String identifiableInterface() {
		fw("domain.Identifiable");
	}

	def String applicationExceptionClass() {
		fw("errorhandling.ApplicationException");
	}

	def String systemExceptionClass() {
		fw("errorhandling.SystemException");
	}

	def String accessBaseWithExceptionClass() {
		fw("accessimpl.AccessBaseWithException");
	}

	def String accessBaseClass() {
		fw("accessimpl.AccessBase");
	}

	def String genericAccessObjectInterface(String name) {
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
	def String genericAccessObjectImplementation(String name) {
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

	def private String mapGenericAccessObjectImplementationPrefix(boolean jpa, boolean hibernate, boolean spring) {
		if (hasProperty("framework.accessimpl.prefix"))
			getProperty("framework.accessimpl.prefix")
		else
			(if (jpa) "Jpa" else "") +
			(if (hibernate) "Hib" else "") +
			(if (spring) "Sp" else "")
	}

	def private String mapGenericAccessObjectImplementationPackage(boolean jpa, boolean hibernate, boolean spring) {
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
	def Collection<String> getSystemAttributesToPutLast() {
		getProperty("systemAttributesToPutLast").split(",");
	}

	def String databaseTestCaseClass() {
		fw("util.db.IsolatedDatabaseTestCase");
	}

	def String fakeObjectInstantiatorClass() {
		fw("util.FakeObjectInstantiator");
	}

	def String enumUserTypeClass() {
		fw("accessimpl.GenericEnumUserType");
	}

	def String jpaFlowExecutionListenerListenerClass() {
	if (isJpaProviderEclipseLink() || isJpaProviderDataNucleus())
			fw("web.jpa.JpaFlowExecutionListener")
		else
			"org.springframework.webflow.persistence.JpaFlowExecutionListener";
	}

	def String openHibernateSessionInConversationListenerClass() {
		fw("web.hibernate.OpenHibernateSessionInConversationListener");
	}

	def String disconnectHibernateInterceptor() {
		fw("web.hibernate.DisconnectHibernateInterceptor");
	}

	def String webExceptionUtilClass() {
		fw("web.errorhandling.ExceptionUtil");
	}

	def String webExceptionAdviceClass() {
		fw("web.errorhandling.ExceptionAdvice");
	}

	def String conversationDomainObjectRepositoryInterface() {
		fw("web.hibernate.ConversationDomainObjectRepository");
	}

	def String conversationDomainObjectJpaRepositoryImplClass() {
		fw("web.jpa.ConversationDomainObjectJpaRepositoryImpl");
	}

	def String optionEditorClass() {
		fw("propertyeditor.OptionEditor");
	}

	def String optionClass() {
		fw("propertyeditor.Option");
	}

	def String enumEditorClass() {
		fw("propertyeditor.EnumEditor");
	}

	def String cacheProvider() {
		getProperty("cache.provider");
	}

	def Boolean pureEjb3() {
		hasProjectNature("pure-ejb3");
	}

	def Boolean isEar() {
		getProperty("deployment.type") == "ear";
	}

	def Boolean isWar() {
		getProperty("deployment.type") == "war";
	}

	def Boolean isRunningInServletContainer() {
		applicationServer() == "tomcat" || applicationServer() == "jetty";
	}

	def String applicationServer() {
		getProperty("deployment.applicationServer").toLowerCase();
	}

	def String notChangeablePropertySetterVisibility() {
		getProperty("notChangeablePropertySetter.visibility");
	}

	def String notChangeableReferenceSetterVisibility() {
		getProperty("notChangeableReferenceSetter.visibility");
	}

	def boolean isGuiDefaultsToBeCreated() {
		getBooleanProperty("gui.createDefaults");
	}

	def boolean isJSFCrudGuiToBeGenerated() {
		getBooleanProperty("generate.jsfCrudGui");
	}

	def boolean isRcpCrudGuiToBeGenerated() {
		getBooleanProperty("generate.rcpCrudGui");
	}

	def boolean isRapCrudGuiToBeGenerated() {
		getBooleanProperty("generate.rapCrudGui");
	}

	def boolean isBuilderToBeGenerated() {
		getBooleanProperty("generate.domainObject.builder");
	}

	def boolean isDomainObjectToBeGenerated() {
		getBooleanProperty("generate.domainObject");
	}

	def boolean isDomainObjectCompositeKeyClassToBeGenerated() {
		getBooleanProperty("generate.domainObject.compositeKeyClass");
	}

	def boolean isExceptionToBeGenerated() {
		getBooleanProperty("generate.exception");
	}

	def boolean isRepositoryToBeGenerated() {
		getBooleanProperty("generate.repository");
	}

	def boolean isServiceToBeGenerated() {
		getBooleanProperty("generate.service");
	}

	def boolean isServiceProxyToBeGenerated() {
		getBooleanProperty("generate.service.proxy");
	}

	def boolean isResourceToBeGenerated() {
		getBooleanProperty("generate.resource");
	}

	def boolean isRestWebToBeGenerated() {
		getBooleanProperty("generate.restWeb");
	}

	def boolean isSpringRemotingToBeGenerated() {
		getBooleanProperty("generate.springRemoting");
	}

	def String getSpringRemotingType() {
		if (isSpringRemotingToBeGenerated())
			getProperty("spring.remoting.type").toLowerCase()
		else
			"N/A";
	}

	def boolean isConsumerToBeGenerated() {
		getBooleanProperty("generate.consumer");
	}

	def boolean isSpringToBeGenerated() {
		getBooleanProperty("generate.spring");
	}

	def boolean isHibernateToBeGenerated() {
		getBooleanProperty("generate.hibernate");
	}

	def boolean isDdlToBeGenerated() {
		getBooleanProperty("generate.ddl");
	}

	def boolean isDdlDropToBeGenerated() {
		getBooleanProperty("generate.ddl.drop");
	}

	def boolean isDatasourceToBeGenerated() {
		getBooleanProperty("generate.datasource");
	}

	def boolean isLogbackConfigToBeGenerated() {
		getBooleanProperty("generate.logbackConfig");
	}

	def boolean isTestToBeGenerated() {
		getBooleanProperty("generate.test");
	}

	def boolean isDbUnitTestDataToBeGenerated() {
		getBooleanProperty("generate.test.dbunitTestData");
	}

	def boolean isEmptyDbUnitTestDataToBeGenerated() {
		getBooleanProperty("generate.test.emptyDbunitTestData");
	}

	def boolean isModuleToBeGenerated(String moduleName) {
		val propertyName = "generate.module." + moduleName;
		if (hasProperty(propertyName))
			getBooleanProperty(propertyName)
		else
			true;
	}

	def String getDbUnitDataSetFile() {
		if (hasProperty("test.dbunit.dataSetFile"))
			getProperty("test.dbunit.dataSetFile")
		else
			null;
	}

	def boolean isServiceContextToBeGenerated() {
		getBooleanProperty("generate.serviceContext");
	}

	def boolean isAuditableToBeGenerated() {
		getBooleanProperty("generate.auditable");
	}

	def boolean isUMLToBeGenerated() {
		getBooleanProperty("generate.umlgraph");
	}

	def boolean isModelDocToBeGenerated() {
		getBooleanProperty("generate.modeldoc");
	}

	def boolean isOptimisticLockingToBeGenerated() {
		getBooleanProperty("generate.optimisticLocking");
	}

	def boolean isPubSubToBeGenerated() {
		getBooleanProperty("generate.pubSub");
	}

	def boolean isGapClassToBeGenerated() {
		getBooleanProperty("generate.gapClass");
	}

	def boolean isGapClassToBeGenerated(String module, String clazz) {
		if (hasProperty("generate.gapClass." + module + "." + clazz))
			getBooleanProperty("generate.gapClass." + module + "." + clazz)
		else if (hasProperty("generate.gapClass." + clazz))
			getBooleanProperty("generate.gapClass." + clazz)
		else
			isGapClassToBeGenerated();
	}

	def boolean isGapClassToBeGenerated(boolean dslGapClass, boolean dslNoGapClass) {
		if (dslGapClass)
			true
		else
			( if (dslNoGapClass) false else isGapClassToBeGenerated() );
	}

	def String subPackage(String packageKey) {
		getProperty("package." + packageKey);
	}

	def String getDateTimeLibrary() {
		getProperty("datetime.library");
	}

	def boolean isHighlightMissingMessageResources() {
		getBooleanProperty("gui.highlightMissingMessageResources");
	}

	def boolean isStubService() {
		getBooleanProperty("gui.stubService");
	}

	def String getResourceDir(Application application, String name) {
		getResourceDirImpl(name);
	}

	def String getResourceDir(Module module, String name) {
		getResourceDirImpl(name);
	}

	def private String getResourceDirImpl(String name) {
		switch (name) {
			case "spring" : ""
			default: name + "/"
		}
	}

	def String getEnumTypeDefFileName(Module module) {
		"Enums-" + module.name + ".hbm.xml";
	}

	def String javaHeader() {
		if (getProperty("javaHeader") == "")
			""
		else
		"/* " + getProperty("javaHeader").replaceAll("\n", "\n * ") + "\n */"
	}

	def boolean jpa() {
		jpaProvider() != "none"
	}

	def boolean nosql() {
		getProperty("nosql.provider") != "none";
	}

	def boolean mongoDb() {
		getProperty("nosql.provider") == "mongoDb";
	}

	def boolean isJpaAnnotationToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation");
	}

	def boolean isJpaAnnotationColumnDefinitionToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation.columnDefinition");
	}

	def boolean isJpaAnnotationOnFieldToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation.onField");
	}

	def boolean isValidationAnnotationToBeGenerated() {
		getBooleanProperty("generate.validation.annotation");
	}

	def boolean isDtoValidationAnnotationToBeGenerated() {
		getBooleanProperty("generate.validation.annotation.dataTransferObject");
	}

	def boolean isSpringAnnotationTxToBeGenerated() {
		getBooleanProperty("generate.spring.annotation.tx");
	}

	def boolean isSpringDataSourceSupportToBeGenerated() {
		getBooleanProperty("generate.spring.dataSourceSupport");
	}

	def boolean isXstreamAnnotationToBeGenerated() {
		getBooleanProperty("generate.xstream.annotation");
	}

	def boolean isXmlBindAnnotationToBeGenerated() {
		getBooleanProperty("generate.xml.bind.annotation");
	}

	def boolean isXmlBindAnnotationToBeGenerated(String typeName) {
		val propName = "generate.xml.bind.annotation." + typeName.toFirstLower()
		if (hasProperty(propName)) getBooleanProperty(propName) else false;
	}

	def boolean isFullyAuditable() {
		getBooleanProperty("generate.fullAuditable");
	}

	def boolean isInjectDrools() {
		getBooleanProperty("generate.injectDrools");
	}

	def boolean isGenerateParameterName() {
		getBooleanProperty("generate.parameterName");
	}

	def String jpaProvider() {
		getProperty("jpa.provider").toLowerCase();
	}

	def boolean isJpaProviderHibernate() {
		jpaProvider() == "hibernate" || jpaProvider() == "hibernate3";
	}

	def boolean isJpaProviderHibernate3() {
		jpaProvider() == "hibernate3";
	}

	def boolean isJpaProviderHibernate4() {
		jpaProvider() == "hibernate";
	}

	def boolean isJpaProviderEclipseLink() {
		jpaProvider() == "eclipselink";
	}

	def boolean isJpaProviderDataNucleus() {
		jpaProvider() == "datanucleus";
	}

	def boolean isJpaProviderAppEngine() {
		jpaProvider() == "appengine";
	}

	def boolean isJpaProviderOpenJpa() {
		jpaProvider() == "openjpa";
	}

	def String jpaVersion() {
		getProperty("jpa.version");
	}

	def boolean isJpa1() {
		"1.0" == jpaVersion() && jpa();
	}

	def boolean isJpa2() {
		"2.0" == jpaVersion() && jpa();
	}

	def String validationProvider() {
		getProperty("validation.provider");
	}

	def String testProvider() {
		getProperty("test.provider");
	}

	def String databaseJpaTestCaseClass() {
		fw("test.AbstractDbUnitJpaTests");
	}

	def String auditEntityListener() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditListener")
		else
			fw("domain.AuditListener");
	}

	def String validationEntityListener() {
		if (isValidationAnnotationToBeGenerated())
			"org.sculptor.framework.validation.ValidationEventListener"
		else
			null;
	}

	def String getApplicationContextFile(Application application, String fileName) {
		fileName;
	}

	def String getApplicationContextFile(Module module, String fileName) {
		fileName;
	}

	def Collection<String> getSystemAttributes() {
		getProperty("systemAttributes").split(",");
	}

	def boolean isSystemAttribute(Attribute att) {
		getSystemAttributes().contains(att.name);
	}

	def Collection<String> getAuditableAttributes() {
		getProperty("auditableAttributes").split(",");
	}

	def boolean isAuditableAttribute(Attribute att) {
		getAuditableAttributes().contains(att.name);
	}

	def Collection<String> getNotRestRequestParameter() {
		getProperty("rest.notRequestParameter").split(",");
	}

	def boolean isDynamicMenu() {
		if (hasProperty("menu.type"))
			getProperty("menu.type") != "linkbased"
		else
			true;
	}

	def String getSuffix(String key) {
		getProperty("naming.suffix." + key);
	}

	def String persistenceXml() {
		getProperty("jpa.persistenceXmlFile");
	}

	def boolean usePersistenceContextUnitName() {
	!isJpaProviderAppEngine() && !(isEar() && isSpringToBeGenerated());
	}

	def boolean useJpaDefaults() {
		getBooleanProperty("jpa.useJpaDefaults");
	}

	def boolean generateFinders() {
		getBooleanProperty("generate.repository.finders");
	}

	def boolean useIdSuffixInForeigKey() {
		getBooleanProperty("db.useIdSuffixInForeigKey");
	}

	// hook to be overwritten to make additional programatic configuration of properties
	def initPropertiesHook() {
		null;
	}
}
