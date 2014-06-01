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
package org.sculptor.generator.ext

import java.util.Collection
import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.Module

@ChainOverridable
class Properties {

	@Inject extension PropertiesBase propertiesBase

	def boolean getBooleanProperty(String propertyName) {
		getProperty(propertyName).toLowerCase() == "true"
	}

	def getProperty(String propertyName, String defaultValue) {
		if (hasProperty(propertyName)) getProperty(propertyName) else defaultValue
	}

	def fw(String fwClassName) {
		val propName = "framework." + fwClassName
		getProperty(propName, "org.sculptor." + propName)
	}

	def defaultExtendsClass(String typeName) {
		val propName = typeName.toFirstLower() + ".extends"
		getProperty(propName, "")
	}

	def abstractDomainObjectClass() {
		fw("domain.AbstractDomainObject")
	}

	def consumerInterface() {
		fw("event.EventSubscriber")
	}

	def abstractMessageBeanClass() {
		fw("consumer.AbstractMessageBean")
	}

	def serviceContextClass() {
		fw("errorhandling.ServiceContext")
	}

	def serviceContextStoreAdviceClass() {
		fw("errorhandling.ServiceContextStoreAdvice")
	}

	def serviceContextStoreClass() {
		fw("errorhandling.ServiceContextStore")
	}

	def serviceContextServletFilterClass() {
		fw("errorhandling.ServiceContextServletFilter")
	}

	def servletContainerServiceContextFactoryClass() {
		fw("errorhandling.ServletContainerServiceContextFactory")
	}

	def auditInterceptorClass() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditInterceptor")
		else
			fw("domain.AuditInterceptor")
	}

	def auditableInterface() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditable")
		else
			fw("domain.Auditable")
	}

	def identifiableInterface() {
		fw("domain.Identifiable")
	}

	def applicationExceptionClass() {
		fw("errorhandling.ApplicationException")
	}

	def systemExceptionClass() {
		fw("errorhandling.SystemException")
	}

	def accessBaseWithExceptionClass() {
		fw("accessimpl.AccessBaseWithException")
	}

	def accessBaseClass() {
		fw("accessimpl.AccessBase")
	}

	def genericAccessObjectInterface(String name) {
		val apiName = name.toFirstUpper() + "Access"

		if (hasProperty("framework.accessapi." + apiName))
			fw("accessapi." + apiName)
		else if (hasProperty("framework.accessapi.package"))
			getProperty("framework.accessapi.package") + "." + apiName
		else
			// default name
			fw("accessapi." + apiName)
	}

	// Configuration of access object is pretty flexible.
	// It is documented in default-sculptor-generator.properties
	// and in Developer's Guide.
	def genericAccessObjectImplementation(String name) {
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
			(if(jpa) "Jpa" else "") + (if(hibernate) "Hib" else "") + (if(spring) "Sp" else "")
	}

	def private String mapGenericAccessObjectImplementationPackage(boolean jpa, boolean hibernate, boolean spring) {
		if (hasProperty("framework.accessimpl.package"))
			getProperty("framework.accessimpl.package")
		else {
			val lastPart = (if(jpa) ( if(isJpa2()) "jpa2" else "jpa") else "") + (if(hibernate) "hibernate" else "") +
				(if(spring) "spring" else "")
			fw(if(lastPart == "") "accessimpl" else "accessimpl." + lastPart)
		}
	}

	// Attributes defined by system that should appear last in attribute listings, such as in DDL
	def getSystemAttributesToPutLast() {
		getProperty("systemAttributesToPutLast").split(",").toList
	}

	def databaseTestCaseClass() {
		fw("util.db.IsolatedDatabaseTestCase")
	}

	def fakeObjectInstantiatorClass() {
		fw("util.FakeObjectInstantiator")
	}

	def enumUserTypeClass() {
		fw("accessimpl.GenericEnumUserType")
	}

	def optionEditorClass() {
		fw("propertyeditor.OptionEditor")
	}

	def optionClass() {
		fw("propertyeditor.Option")
	}

	def enumEditorClass() {
		fw("propertyeditor.EnumEditor")
	}

	def cacheProvider() {
		getProperty("cache.provider")
	}

	def pureEjb3() {
		hasProjectNature("pure-ejb3")
	}

	def isEar() {
		getProperty("deployment.type") == "ear"
	}

	def isWar() {
		getProperty("deployment.type") == "war"
	}

	def isRunningInServletContainer() {
		applicationServer() == "tomcat" || applicationServer() == "jetty"
	}

	def applicationServer() {
		getProperty("deployment.applicationServer").toLowerCase()
	}

	def notChangeablePropertySetterVisibility() {
		getProperty("notChangeablePropertySetter.visibility")
	}

	def notChangeableReferenceSetterVisibility() {
		getProperty("notChangeableReferenceSetter.visibility")
	}

	def isDomainObjectToBeGenerated() {
		getBooleanProperty("generate.domainObject")
	}

	def isDomainObjectCompositeKeyClassToBeGenerated() {
		getBooleanProperty("generate.domainObject.compositeKeyClass")
	}

	def isExceptionToBeGenerated() {
		getBooleanProperty("generate.exception")
	}

	def isRepositoryToBeGenerated() {
		getBooleanProperty("generate.repository")
	}

	def isServiceToBeGenerated() {
		getBooleanProperty("generate.service")
	}

	def isServiceProxyToBeGenerated() {
		getBooleanProperty("generate.service.proxy")
	}

	def isResourceToBeGenerated() {
		getBooleanProperty("generate.resource")
	}

	def isRestWebToBeGenerated() {
		getBooleanProperty("generate.restWeb")
	}

	def isSpringRemotingToBeGenerated() {
		getBooleanProperty("generate.springRemoting")
	}

	def getSpringRemotingType() {
		if (isSpringRemotingToBeGenerated())
			getProperty("spring.remoting.type").toLowerCase()
		else
			"N/A"
	}

	def isConsumerToBeGenerated() {
		getBooleanProperty("generate.consumer")
	}

	def isSpringToBeGenerated() {
		getBooleanProperty("generate.spring")
	}

	def isHibernateToBeGenerated() {
		getBooleanProperty("generate.hibernate")
	}

	def isDdlToBeGenerated() {
		getBooleanProperty("generate.ddl")
	}

	def isDdlDropToBeGenerated() {
		getBooleanProperty("generate.ddl.drop")
	}

	def isDatasourceToBeGenerated() {
		getBooleanProperty("generate.datasource")
	}

	def isLogbackConfigToBeGenerated() {
		getBooleanProperty("generate.logbackConfig")
	}

	def isTestToBeGenerated() {
		getBooleanProperty("generate.test")
	}

	def isDbUnitTestDataToBeGenerated() {
		getBooleanProperty("generate.test.dbunitTestData")
	}

	def isEmptyDbUnitTestDataToBeGenerated() {
		getBooleanProperty("generate.test.emptyDbunitTestData")
	}

	def isModuleToBeGenerated(String moduleName) {
		val propertyName = "generate.module." + moduleName
		if (hasProperty(propertyName))
			getBooleanProperty(propertyName)
		else
			true
	}

	def getDbUnitDataSetFile() {
		if (hasProperty("test.dbunit.dataSetFile"))
			getProperty("test.dbunit.dataSetFile")
		else
			null
	}

	def isServiceContextToBeGenerated() {
		getBooleanProperty("generate.serviceContext")
	}

	def isAuditableToBeGenerated() {
		getBooleanProperty("generate.auditable")
	}

	def isUMLToBeGenerated() {
		getBooleanProperty("generate.umlgraph")
	}

	def isModelDocToBeGenerated() {
		getBooleanProperty("generate.modeldoc")
	}

	def isOptimisticLockingToBeGenerated() {
		getBooleanProperty("generate.optimisticLocking")
	}

	def isPubSubToBeGenerated() {
		getBooleanProperty("generate.pubSub")
	}

	def isGapClassToBeGenerated() {
		getBooleanProperty("generate.gapClass")
	}

	def dispatch boolean isGapClassToBeGenerated(String module, String clazz) {
		if (hasProperty("generate.gapClass." + module + "." + clazz))
			getBooleanProperty("generate.gapClass." + module + "." + clazz)
		else if (hasProperty("generate.gapClass." + clazz))
			getBooleanProperty("generate.gapClass." + clazz)
		else
			isGapClassToBeGenerated()
	}

	def dispatch boolean isGapClassToBeGenerated(boolean dslGapClass, boolean dslNoGapClass) {
		if (dslGapClass)
			true
		else ( if(dslNoGapClass) false else isGapClassToBeGenerated() )
	}

	def subPackage(String packageKey) {
		getProperty("package." + packageKey)
	}

	def getDateTimeLibrary() {
		getProperty("datetime.library")
	}

	def getResourceDir(Application application, String name) {
		getResourceDirImpl(name)
	}

	def getResourceDirModule(Module module, String name) {
		getResourceDirImpl(name)
	}

	def private String getResourceDirImpl(String name) {
		switch (name) {
			case "spring": ""
			default: name + "/"
		}
	}

	def getEnumTypeDefFileName(Module module) {
		"Enums-" + module.name + ".hbm.xml"
	}

	def javaHeader() {
		if (getProperty("javaHeader") == "")
			""
		else
			"/* " + getProperty("javaHeader").replaceAll("\n", "\n * ") + "\n */"
	}

	def jpa() {
		jpaProvider() != "none"
	}

	def nosql() {
		getProperty("nosql.provider") != "none"
	}

	def isJpaAnnotationToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation")
	}

	def isJpaAnnotationColumnDefinitionToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation.columnDefinition")
	}

	def isJpaAnnotationOnFieldToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation.onField")
	}

	def isValidationAnnotationToBeGenerated() {
		getBooleanProperty("generate.validation.annotation")
	}

	def isDtoValidationAnnotationToBeGenerated() {
		getBooleanProperty("generate.validation.annotation.dataTransferObject")
	}

	def isSpringAnnotationTxToBeGenerated() {
		getBooleanProperty("generate.spring.annotation.tx")
	}

	def isSpringTxAdviceToBeGenerated() {
		jpa() && (isWar() || !isSpringAnnotationTxToBeGenerated())
	}

	def isSpringDataSourceSupportToBeGenerated() {
		getBooleanProperty("generate.spring.dataSourceSupport")
	}

	def isXstreamAnnotationToBeGenerated() {
		getBooleanProperty("generate.xstream.annotation")
	}

	def isXmlBindAnnotationToBeGenerated() {
		getBooleanProperty("generate.xml.bind.annotation")
	}

	def isXmlBindAnnotationToBeGenerated(String typeName) {
		val propName = "generate.xml.bind.annotation." + typeName.toFirstLower()
		if(hasProperty(propName)) getBooleanProperty(propName) else false
	}

	def isFullyAuditable() {
		getBooleanProperty("generate.fullAuditable")
	}

	def isInjectDrools() {
		getBooleanProperty("generate.injectDrools")
	}

	def isGenerateParameterName() {
		getBooleanProperty("generate.parameterName")
	}

	def jpaProvider() {
		getProperty("jpa.provider").toLowerCase()
	}

	def isJpaProviderHibernate() {
		jpaProvider() == "hibernate" || jpaProvider() == "hibernate3"
	}

	def isJpaProviderHibernate3() {
		jpaProvider() == "hibernate3"
	}

	def isJpaProviderHibernate4() {
		jpaProvider() == "hibernate"
	}

	def isJpaProviderEclipseLink() {
		jpaProvider() == "eclipselink"
	}

	def isJpaProviderDataNucleus() {
		jpaProvider() == "datanucleus"
	}

	def isJpaProviderAppEngine() {
		jpaProvider() == "appengine"
	}

	def isJpaProviderOpenJpa() {
		jpaProvider() == "openjpa"
	}

	def jpaVersion() {
		getProperty("jpa.version")
	}

	def isJpa1() {
		"1.0" == jpaVersion() && jpa()
	}

	def isJpa2() {
		"2.0" == jpaVersion() && jpa()
	}

	def validationProvider() {
		getProperty("validation.provider")
	}

	def testProvider() {
		getProperty("test.provider")
	}

	def databaseJpaTestCaseClass() {
		fw("test.AbstractDbUnitJpaTests")
	}

	def auditEntityListener() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditListener")
		else
			fw("domain.AuditListener")
	}

	def validationEntityListener() {
		if (isValidationAnnotationToBeGenerated())
			"org.sculptor.framework.validation.ValidationEventListener"
		else
			null
	}

	def dispatch String getApplicationContextFile(Application application, String fileName) {
		fileName
	}

	def dispatch String getApplicationContextFile(Module module, String fileName) {
		fileName
	}

	def Collection<String> getSystemAttributes() {
		getProperty("systemAttributes").split(",")
	}

	def isSystemAttribute(Attribute att) {
		getSystemAttributes().contains(att.name)
	}

	def Collection<String> getAuditableAttributes() {
		getProperty("auditableAttributes").split(",")
	}

	def isAuditableAttribute(Attribute att) {
		getAuditableAttributes().contains(att.name)
	}

	def Collection<String> getNotRestRequestParameter() {
		getProperty("rest.notRequestParameter").split(",")
	}

	def isDynamicMenu() {
		if (hasProperty("menu.type"))
			getProperty("menu.type") != "linkbased"
		else
			true
	}

	def getSuffix(String key) {
		getProperty("naming.suffix." + key)
	}

	def persistenceXml() {
		getProperty("jpa.persistenceXmlFile")
	}

	def usePersistenceContextUnitName() {
		!isJpaProviderAppEngine() && !(isEar() && isSpringToBeGenerated())
	}

	def useJpaDefaults() {
		getBooleanProperty("jpa.useJpaDefaults")
	}

	def generateFinders() {
		getBooleanProperty("generate.repository.finders")
	}

	def useIdSuffixInForeigKey() {
		getBooleanProperty("db.useIdSuffixInForeigKey")
	}

	// hook to be overwritten to make additional programatic configuration of properties
	def initPropertiesHook() {
		null
	}
}
