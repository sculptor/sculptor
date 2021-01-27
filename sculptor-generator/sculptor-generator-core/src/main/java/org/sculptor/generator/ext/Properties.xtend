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
import java.util.List

@ChainOverridable
class Properties {

	@Inject extension PropertiesBase propertiesBase

	def boolean getBooleanProperty(String propertyName) {
		getProperty(propertyName).toLowerCase() == "true"
	}

	def String getProperty(String propertyName, String defaultValue) {
		if (hasProperty(propertyName)) getProperty(propertyName) else defaultValue
	}

	/*
	 * Extension point to generate properties with specified prefix
	 */
	private def String printProperties(String prefix, java.util.Properties props, boolean asMapProps) {

		'''
		«IF getBooleanProperty("generate.shortPropertyComment")»
			<!-- START - Properties derived from base name '«prefix»' -->
		«ELSE»
			<!-- START
			Properties derived from base name '«prefix»'.
			REPLACE value by defining new property value with = e.g.:
				«prefix».existingProperty=newValue
			or REMOVE property by setting value to *NONE* like:
				«prefix».existingProperty=*NONE*
			or ADD property by defining new property with =! e.g.:
				«prefix».newProperty=!newValue
			-->
		«ENDIF»
		«IF asMapProps»
			«FOR e : getPropertiesAsMap(prefix + ".", props).entrySet»
				<prop key="«e.key»">«e.value»</prop>
			«ENDFOR»
		«ELSE»
			«FOR e : getPropertiesAsMap(prefix + ".", props).entrySet»
				«IF e.value.startsWith("#REF#")»
					<property name="«e.key»" ref="«e.value.substring(5)»"/>
				«ELSE»
					<property name="«e.key»" value="«e.value»"/>
				«ENDIF»
			«ENDFOR»
		«ENDIF»
		<!-- END -->
		'''
	}

	def String printProperties(String prefix) {
		printProperties(prefix, null, false);
	}

	def String printProperties(String prefix, java.util.Properties props) {
		printProperties(prefix, props, false);
	}

	def String printPropertiesForHash(String prefix, java.util.Properties props) {
		printProperties(prefix, props, true);
	}

	def String fw(String fwClassName) {
		val propName = "framework." + fwClassName
		getProperty(propName, "org.sculptor." + propName)
	}

	def String defaultExtendsClass(String typeName) {
		val propName = typeName.toFirstLower() + ".extends"
		getProperty(propName, "")
	}

	def String abstractDomainObjectClass() {
		fw("domain.AbstractDomainObject")
	}

	def String consumerInterface() {
		fw("event.EventSubscriber")
	}

	def String abstractMessageBeanClass() {
		fw("consumer.AbstractMessageBean")
	}

	def String serviceContextClass() {
		fw("context.ServiceContext")
	}

	def String serviceContextStoreAdviceClass() {
		fw("context.ServiceContextStoreAdvice")
	}

	def String serviceContextStoreClass() {
		fw("context.ServiceContextStore")
	}

	def String serviceContextServletFilterClass() {
		fw("context.ServiceContextServletFilter")
	}

	def String servletContainerServiceContextFactoryClass() {
		fw("context.ServletContainerServiceContextFactory")
	}

	def String auditInterceptorClass() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditInterceptor")
		else if (getBooleanProperty("generate.auditable.legacy"))
			fw("domain.DateAuditInterceptor")
		else
			fw("domain.AuditInterceptor")
	}

	def String auditableInterface() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditable")
		else if (getBooleanProperty("generate.auditable.legacy"))
			fw("domain.DateAuditable")
		else
			fw("domain.Auditable")
	}

	def String identifiableInterface() {
		fw("domain.Identifiable")
	}

	def String applicationExceptionClass() {
		fw("errorhandling.ApplicationException")
	}

	def String systemExceptionClass() {
		fw("errorhandling.SystemException")
	}

	def String accessBaseWithExceptionClass() {
		fw("accessimpl.AccessBaseWithException")
	}

	def String accessBaseClass() {
		fw("accessimpl.AccessBase")
	}

	def String genericAccessObjectInterface(String name) {
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
	def String genericAccessObjectImplementation(String name) {
		val jpa = isJpaAnnotationToBeGenerated()

		// don't use Spring when using jpa
		val spring = !jpa && isSpringToBeGenerated() && isJpaProviderHibernate()
		val implName = name.toFirstUpper() + "AccessImpl"
		if (hasProperty("framework.accessimpl." + implName))
			fw("accessimpl." + implName)
		else
			mapGenericAccessObjectImplementationPackage(jpa, spring) + "." +
				mapGenericAccessObjectImplementationPrefix(jpa, spring) + implName
	}

	def private String mapGenericAccessObjectImplementationPrefix(boolean jpa, boolean spring) {
		if (hasProperty("framework.accessimpl.prefix"))
			getProperty("framework.accessimpl.prefix")
		else
			(if(jpa) "Jpa" else "") + (if(spring) "Sp" else "")
	}

	def private String mapGenericAccessObjectImplementationPackage(boolean jpa, boolean spring) {
		if (hasProperty("framework.accessimpl.package"))
			getProperty("framework.accessimpl.package")
		else {
			val lastPart = (if(jpa) "jpa" else "") + (if(spring) "spring" else "")
			fw(if(lastPart == "") "accessimpl" else "accessimpl." + lastPart)
		}
	}

	// Attributes defined by system that should appear last in attribute listings, such as in DDL
	def List<String> getSystemAttributesToPutLast() {
		getProperty("systemAttributesToPutLast").split(",").toList
	}

	def String databaseTestCaseClass() {
		fw("util.db.IsolatedDatabaseTestCase")
	}

	def String fakeObjectInstantiatorClass() {
		fw("util.FakeObjectInstantiator")
	}

	def String enumUserTypeClass() {
		fw("accessimpl.GenericEnumUserType")
	}

	def String optionEditorClass() {
		fw("propertyeditor.OptionEditor")
	}

	def String optionClass() {
		fw("propertyeditor.Option")
	}

	def String enumEditorClass() {
		fw("propertyeditor.EnumEditor")
	}

	def String cacheProvider() {
		getProperty("cache.provider")
	}

	def boolean pureEjb3() {
		hasProjectNature("pure-ejb3")
	}

	def boolean isEar() {
		getProperty("deployment.type") == "ear"
	}

	def boolean isWar() {
		getProperty("deployment.type") == "war"
	}

	def boolean isRunningInServletContainer() {
		applicationServer() == "tomcat" || applicationServer() == "jetty"
	}

	def String applicationServer() {
		getProperty("deployment.applicationServer").toLowerCase()
	}

	def String notChangeablePropertySetterVisibility() {
		getProperty("notChangeablePropertySetter.visibility")
	}

	def String notChangeableReferenceSetterVisibility() {
		getProperty("notChangeableReferenceSetter.visibility")
	}

	def boolean isDomainObjectToBeGenerated() {
		getBooleanProperty("generate.domainObject")
	}

	def boolean isDomainObjectCompositeKeyClassToBeGenerated() {
		getBooleanProperty("generate.domainObject.compositeKeyClass")
	}

	def boolean isExceptionToBeGenerated() {
		getBooleanProperty("generate.exception")
	}

	def boolean isRepositoryToBeGenerated() {
		getBooleanProperty("generate.repository")
	}

	def boolean isServiceToBeGenerated() {
		getBooleanProperty("generate.service")
	}

	def boolean isServiceProxyToBeGenerated() {
		getBooleanProperty("generate.service.proxy")
	}

	def boolean isResourceToBeGenerated() {
		getBooleanProperty("generate.resource")
	}

	def boolean isRestWebToBeGenerated() {
		getBooleanProperty("generate.restWeb")
	}

	def boolean isSpringRemotingToBeGenerated() {
		getBooleanProperty("generate.springRemoting")
	}

	def String getSpringRemotingType() {
		if (isSpringRemotingToBeGenerated())
			getProperty("spring.remoting.type").toLowerCase()
		else
			"N/A"
	}

	def boolean isConsumerToBeGenerated() {
		getBooleanProperty("generate.consumer")
	}

	def boolean isSpringToBeGenerated() {
		getBooleanProperty("generate.spring")
	}

	def boolean isHibernateToBeGenerated() {
		getBooleanProperty("generate.hibernate")
	}

	def boolean isDdlToBeGenerated() {
		getBooleanProperty("generate.ddl")
	}

	def boolean isDdlDropToBeGenerated() {
		getBooleanProperty("generate.ddl.drop")
	}

	def boolean isDatasourceToBeGenerated() {
		getBooleanProperty("generate.datasource")
	}

	def boolean isLogbackConfigToBeGenerated() {
		getBooleanProperty("generate.logbackConfig")
	}

	def boolean isTestToBeGenerated() {
		getBooleanProperty("generate.test")
	}

	def boolean isDbUnitTestDataToBeGenerated() {
		getBooleanProperty("generate.test.dbunitTestData")
	}

	def boolean isEmptyDbUnitTestDataToBeGenerated() {
		getBooleanProperty("generate.test.emptyDbunitTestData")
	}

	def String dbunitTestDataRowsFull() {
		getProperty("generate.test.dbunitTestDataRows.full")
	}

	def String dbunitTestDataRowsMixed() {
		getProperty("generate.test.dbunitTestDataRows.mixed")
	}

	def String dbunitTestDataRowsMinimal() {
		getProperty("generate.test.dbunitTestDataRows.minimal")
	}

	def int dbunitTestDataRowsMixedProbability() {
		Integer.parseInt(getProperty("generate.test.dbunitTestDataRows.mixed.probability"))
	}

	int testRowsAll = -1;
	def int dbunitTestDataRowsAll() {
		if (testRowsAll == -1) {
			testRowsAll = getFrom(dbunitTestDataRowsFull()) + getFrom(dbunitTestDataRowsMixed())
					+ getFrom(dbunitTestDataRowsMinimal())
		}
		return testRowsAll;
	}

	def int dbunitTestDataIdBase() {
		Integer.parseInt(getProperty("generate.test.dbunitTestDataIdBase"))
	}

	def boolean isModuleToBeGenerated(String moduleName) {
		val propertyName = "generate.module." + moduleName
		if (hasProperty(propertyName))
			getBooleanProperty(propertyName)
		else
			true
	}

	def String getDbUnitDataSetFile() {
		if (hasProperty("test.dbunit.dataSetFile"))
			getProperty("test.dbunit.dataSetFile")
		else
			null
	}

	def boolean isServiceContextToBeGenerated() {
		getBooleanProperty("generate.serviceContext")
	}

	def boolean isAuditableToBeGenerated() {
		getBooleanProperty("generate.auditable")
	}

	def boolean isUMLToBeGenerated() {
		getBooleanProperty("generate.umlgraph")
	}

	def boolean isModelDocToBeGenerated() {
		getBooleanProperty("generate.modeldoc")
	}

	def boolean isOptimisticLockingToBeGenerated() {
		getBooleanProperty("generate.optimisticLocking")
	}

	def boolean isPubSubToBeGenerated() {
		getBooleanProperty("generate.pubSub")
	}

	def boolean isGapClassToBeGenerated() {
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

	def String subPackage(String packageKey) {
		getProperty("package." + packageKey)
	}

	def String getDateTimeLibrary() {
		getProperty("datetime.library")
	}

	def String getResourceDir(Application application, String name) {
		getResourceDirImpl(name)
	}

	def String getResourceDirModule(Module module, String name) {
		getResourceDirImpl(name)
	}

	def private String getResourceDirImpl(String name) {
		switch (name) {
			case "spring": ""
			default: name + "/"
		}
	}

	def String getEnumTypeDefFileName(Module module) {
		"Enums-" + module.name + ".hbm.xml"
	}

	def String javaHeader() {
		if (getProperty("javaHeader") == "")
			""
		else
			"/* " + getPropertyWithSubstitute("javaHeader").replaceAll("\n", "\n * ") + "\n */"
	}

	def String getEntityManagerFactoryType() {
		getProperty("generate.entityManagerFactoryType")
	}

	def String getEntityManagerFactoryTestType() {
		getProperty("test.generate.entityManagerFactoryType")
	}


	def boolean jpa() {
		jpaProvider() != "none"
	}

	def boolean nosql() {
		getProperty("nosql.provider") != "none"
	}

	def boolean isJpaAnnotationToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation")
	}

	def boolean isJpaAnnotationColumnDefinitionToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation.columnDefinition")
	}

	def boolean isJpaAnnotationOnFieldToBeGenerated() {
		getBooleanProperty("generate.jpa.annotation.onField")
	}

	def boolean isValidationAnnotationToBeGenerated() {
		getBooleanProperty("generate.validation.annotation")
	}

	def boolean isDtoValidationAnnotationToBeGenerated() {
		getBooleanProperty("generate.validation.annotation.dataTransferObject")
	}

	def boolean isSpringAnnotationTxToBeGenerated() {
		getBooleanProperty("generate.spring.annotation.tx")
	}

	def boolean isSpringTxAdviceToBeGenerated() {
		isWar() && jpa() && !isSpringAnnotationTxToBeGenerated()
	}

	def boolean isSpringDataSourceSupportToBeGenerated() {
		getBooleanProperty("generate.spring.dataSourceSupport")
	}

	def boolean isXstreamAnnotationToBeGenerated() {
		getBooleanProperty("generate.xstream.annotation")
	}

	def boolean isXmlBindAnnotationToBeGenerated() {
		getBooleanProperty("generate.xml.bind.annotation")
	}

	def boolean isXmlBindAnnotationToBeGenerated(String typeName) {
		val propName = "generate.xml.bind.annotation." + typeName.toFirstLower()
		if(hasProperty(propName)) getBooleanProperty(propName) else false
	}

	def boolean isFullyAuditable() {
		getBooleanProperty("generate.fullAuditable")
	}

	def boolean isInjectDrools() {
		getBooleanProperty("generate.injectDrools")
	}

	def boolean isGenerateParameterName() {
		getBooleanProperty("generate.parameterName")
	}

	def String jpaProvider() {
		getProperty("jpa.provider").toLowerCase()
	}

	def boolean isJpaProviderHibernate() {
		jpaProvider() == "hibernate"
	}

	def boolean isJpaProviderEclipseLink() {
		jpaProvider() == "eclipselink"
	}

	def boolean isJpaProviderDataNucleus() {
		jpaProvider() == "datanucleus"
	}

	def boolean isJpaProviderAppEngine() {
		jpaProvider() == "appengine"
	}

	def boolean isJpaProviderOpenJpa() {
		jpaProvider() == "openjpa"
	}

	def String getJpaProviderClass() {
		switch 1 {
			case isJpaProviderHibernate()   : 'org.hibernate.jpa.HibernatePersistenceProvider'
			case isJpaProviderEclipseLink() : 'org.eclipse.persistence.jpa.PersistenceProvider'
			case isJpaProviderDataNucleus(),
			case isJpaProviderAppEngine()   : 'org.datanucleus.api.jpa.PersistenceProviderImpl'
			case isJpaProviderOpenJpa()     : 'org.apache.openjpa.persistence.PersistenceProviderImpl'
		}
	}

	def String validationProvider() {
		getProperty("validation.provider")
	}

	def String testProvider() {
		getProperty("test.provider")
	}

	def String databaseJpaTestCaseClass() {
		fw("test.AbstractDbUnitJpaTests")
	}

	def String auditEntityListener() {
		if (getBooleanProperty("generate.auditable.joda"))
			fw("domain.JodaAuditListener")
		else if (getBooleanProperty("generate.auditable.legacy"))
			fw("domain.DateAuditListener")
		else
			fw("domain.AuditListener")
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

	def boolean isSystemAttribute(Attribute att) {
		getSystemAttributes().contains(att.name)
	}

	def Collection<String> getAuditableAttributes() {
		getProperty("auditableAttributes").split(",")
	}

	def boolean isAuditableAttribute(Attribute att) {
		getAuditableAttributes().contains(att.name)
	}

	def Collection<String> getNotRestRequestParameter() {
		getProperty("rest.notRequestParameter").split(",")
	}

	def boolean isDynamicMenu() {
		if (hasProperty("menu.type"))
			getProperty("menu.type") != "linkbased"
		else
			true
	}

	def String getSuffix(String key) {
		getProperty("naming.suffix." + key)
	}

	def String persistenceXml() {
		getProperty("jpa.persistenceXmlFile")
	}

	def boolean usePersistenceContextUnitName() {
		!isJpaProviderAppEngine() && !(isEar() && isSpringToBeGenerated())
	}

	def boolean useJpaDefaults() {
		getBooleanProperty("jpa.useJpaDefaults")
	}

	def boolean generateFinders() {
		getBooleanProperty("generate.repository.finders")
	}

	def boolean useIdSuffixInForeigKey() {
		getBooleanProperty("db.useIdSuffixInForeigKey")
	}

}
