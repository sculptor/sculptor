package org.sculptor.generator.ext

import org.sculptor.generator.ext.Helper
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.PropertiesBase
import org.sculptor.generator.util.DbHelperBase

import org.sculptor.generator.template.service.ServiceTmpl
import org.sculptor.generator.template.service.ServiceEjbTestTmpl
import org.sculptor.generator.template.service.ServiceTestTmpl
import org.sculptor.generator.template.service.ServiceEjbTmpl
import org.sculptor.generator.template.web.JSFCrudGuiConfigContextTmpl
import org.sculptor.generator.template.drools.DroolsTmpl
import org.sculptor.generator.template.doc.ModelDocTmpl
import org.sculptor.generator.template.doc.UMLGraphTmpl
import org.sculptor.generator.template.doc.ModelDocCssTmpl
import org.sculptor.generator.template.spring.SpringTmpl
import org.sculptor.generator.template.springint.SpringIntegrationTmpl
import org.sculptor.generator.template.db.DDLTmpl
import org.sculptor.generator.template.db.MysqlDDLTmpl
import org.sculptor.generator.template.db.OracleDDLTmpl
import org.sculptor.generator.template.db.CustomDDLTmpl
import org.sculptor.generator.template.db.DatasourceTmpl
import org.sculptor.generator.template.db.DbUnitTmpl
import org.sculptor.generator.template.domain.DomainObjectAnnotationTmpl
import org.sculptor.generator.template.domain.DomainObjectReferenceAnnotationTmpl
import org.sculptor.generator.template.domain.DomainObjectNamesTmpl
import org.sculptor.generator.template.domain.DomainObjectConstructorTmpl
import org.sculptor.generator.template.domain.DomainObjectTraitTmpl
import org.sculptor.generator.template.domain.DomainObjectReferenceTmpl
import org.sculptor.generator.template.domain.DomainObjectKeyTmpl
import org.sculptor.generator.template.domain.DomainObjectPropertiesTmpl
import org.sculptor.generator.template.domain.DomainObjectAttributeAnnotationTmpl
import org.sculptor.generator.template.domain.DomainObjectAttributeTmpl
import org.sculptor.generator.template.domain.BuilderTmpl
import org.sculptor.generator.template.domain.DomainObjectTmpl
import org.sculptor.generator.template.mongodb.MongoDbConversationDomainObjectRepositoryTmpl
import org.sculptor.generator.template.mongodb.MongoDbServiceTestTmpl
import org.sculptor.generator.template.mongodb.MongoDbMapperTmpl
import org.sculptor.generator.template.jpa.EclipseLinkTmpl
import org.sculptor.generator.template.jpa.DataNucleusTmpl
import org.sculptor.generator.template.jpa.JPATmpl
import org.sculptor.generator.template.jpa.OpenJpaTmpl
import org.sculptor.generator.template.jpa.HibernateTmpl
import org.sculptor.generator.template.camel.CamelTmpl
import org.sculptor.generator.template.common.LogConfigTmpl
import org.sculptor.generator.template.common.PubSubTmpl
import org.sculptor.generator.template.common.ExceptionTmpl
import org.sculptor.generator.template.consumer.ConsumerTmpl
import org.sculptor.generator.template.consumer.ConsumerTestTmpl
import org.sculptor.generator.template.consumer.ConsumerEjbTmpl
import org.sculptor.generator.template.consumer.ConsumerEjbTestTmpl
import org.sculptor.generator.template.repository.AccessObjectTmpl
import org.sculptor.generator.template.repository.AccessObjectFactoryTmpl
import org.sculptor.generator.template.repository.RepositoryTmpl
import org.sculptor.generator.template.rest.RestWebCssTmpl
import org.sculptor.generator.template.rest.RestWebJspTmpl
import org.sculptor.generator.template.rest.ResourceTmpl
import org.sculptor.generator.template.rest.RestWebConfigTmpl
import org.sculptor.generator.template.rest.RestWebTmpl
import org.sculptor.generator.template.RootTmpl
import org.sculptor.generator.util.XmlHelperBase

class GeneratorFactoryStaticImpl implements GeneratorFactory {
	// Extensions
	private static val propertiesBaseImpl = new PropertiesBase
	private static val helperBaseImpl = new HelperBase
	private static val helperImpl = new Helper
	private static val propertiesImpl = new Properties
	private static val dbHelperImpl = new DbHelper
	private static val dbHelperBaseImpl = new DbHelperBase
	private static val xmlHelperBaseImpl = new XmlHelperBase
	private static val umlGraphHelperImpl = new UmlGraphHelper

	// Templates
	private static val serviceTmplImpl = new ServiceTmpl
	private static val serviceEjbTestTmplImpl = new ServiceEjbTestTmpl
	private static val serviceTestTmplImpl = new ServiceTestTmpl
	private static val serviceEjbTmplImpl = new ServiceEjbTmpl
	private static val jSFCrudGuiConfigContextTmplImpl = new JSFCrudGuiConfigContextTmpl
	private static val droolsTmplImpl = new DroolsTmpl
	private static val modelDocTmplImpl = new ModelDocTmpl
	private static val uMLGraphTmplImpl = new UMLGraphTmpl
	private static val modelDocCssTmplImpl = new ModelDocCssTmpl
	private static val springTmplImpl = new SpringTmpl
	private static val springIntegrationTmplImpl = new SpringIntegrationTmpl
	private static val dDLTmplImpl = new DDLTmpl
	private static val mysqlDDLTmplImpl = new MysqlDDLTmpl
	private static val oracleDDLTmplImpl = new OracleDDLTmpl
	private static val customDDLTmplImpl = new CustomDDLTmpl
	private static val datasourceTmplImpl = new DatasourceTmpl
	private static val dbUnitTmplImpl = new DbUnitTmpl
	private static val domainObjectAnnotationTmplImpl = new DomainObjectAnnotationTmpl
	private static val domainObjectReferenceAnnotationTmplImpl = new DomainObjectReferenceAnnotationTmpl
	private static val domainObjectNamesTmplImpl = new DomainObjectNamesTmpl
	private static val domainObjectConstructorTmplImpl = new DomainObjectConstructorTmpl
	private static val domainObjectTraitTmplImpl = new DomainObjectTraitTmpl
	private static val domainObjectReferenceTmplImpl = new DomainObjectReferenceTmpl
	private static val domainObjectKeyTmplImpl = new DomainObjectKeyTmpl
	private static val domainObjectPropertiesTmplImpl = new DomainObjectPropertiesTmpl
	private static val domainObjectAttributeAnnotationTmplImpl = new DomainObjectAttributeAnnotationTmpl
	private static val domainObjectAttributeTmplImpl = new DomainObjectAttributeTmpl
	private static val builderTmplImpl = new BuilderTmpl
	private static val domainObjectTmplImpl = new DomainObjectTmpl
	private static val mongoDbConversationDomainObjectRepositoryTmplImpl = new MongoDbConversationDomainObjectRepositoryTmpl
	private static val mongoDbServiceTestTmplImpl = new MongoDbServiceTestTmpl
	private static val mongoDbMapperTmplImpl = new MongoDbMapperTmpl
	private static val eclipseLinkTmplImpl = new EclipseLinkTmpl
	private static val dataNucleusTmplImpl = new DataNucleusTmpl
	private static val jPATmplImpl = new JPATmpl
	private static val openJpaTmplImpl = new OpenJpaTmpl
	private static val hibernateTmplImpl = new HibernateTmpl
	private static val camelTmplImpl = new CamelTmpl
	private static val logConfigTmplImpl = new LogConfigTmpl
	private static val pubSubTmplImpl = new PubSubTmpl
	private static val exceptionTmplImpl = new ExceptionTmpl
	private static val consumerTmplImpl = new ConsumerTmpl
	private static val consumerTestTmplImpl = new ConsumerTestTmpl
	private static val consumerEjbTmplImpl = new ConsumerEjbTmpl
	private static val consumerEjbTestTmplImpl = new ConsumerEjbTestTmpl
	private static val accessObjectTmplImpl = new AccessObjectTmpl
	private static val accessObjectFactoryTmplImpl = new AccessObjectFactoryTmpl
	private static val repositoryTmplImpl = new RepositoryTmpl
	private static val rootTmplImpl = new RootTmpl
	private static val restWebCssTmplImpl = new RestWebCssTmpl
	private static val restWebJspTmplImpl = new RestWebJspTmpl
	private static val resourceTmplImpl = new ResourceTmpl
	private static val restWebConfigTmplImpl = new RestWebConfigTmpl
	private static val restWebTmplImpl = new RestWebTmpl

	override Helper helper() {
		helperImpl
	}

	override HelperBase helperBase() {
		helperBaseImpl
	}

	override Properties properties() {
		propertiesImpl
	}

	override PropertiesBase propertiesBase() {
		propertiesBaseImpl
	}

	override DbHelperBase dbHelperBase() {
		dbHelperBaseImpl
	}

	override DbHelper dbHelper() {
		dbHelperImpl
	}

	override XmlHelperBase xmlHelperBase() {
		xmlHelperBaseImpl
	}

	override UmlGraphHelper umlGraphHelper() {
		umlGraphHelperImpl
	}

	override ServiceTmpl serviceTmpl() {
		serviceTmplImpl
	}
	
	override ServiceEjbTestTmpl serviceEjbTestTmpl() {
		serviceEjbTestTmplImpl
	}
	
	override ServiceTestTmpl serviceTestTmpl() {
		serviceTestTmplImpl
	}
	
	override ServiceEjbTmpl serviceEjbTmpl() {
		serviceEjbTmplImpl
	}
	
	override JSFCrudGuiConfigContextTmpl jSFCrudGuiConfigContextTmpl() {
		jSFCrudGuiConfigContextTmplImpl
	}
	
	override DroolsTmpl droolsTmpl() {
		droolsTmplImpl
	}
	
	override ModelDocTmpl modelDocTmpl() {
		modelDocTmplImpl
	}
	
	override UMLGraphTmpl uMLGraphTmpl() {
		uMLGraphTmplImpl
	}
	
	override ModelDocCssTmpl modelDocCssTmpl() {
		modelDocCssTmplImpl
	}
	
	override SpringTmpl springTmpl() {
		springTmplImpl
	}
	
	override SpringIntegrationTmpl springIntegrationTmpl() {
		springIntegrationTmplImpl
	}
	
	override DDLTmpl dDLTmpl() {
		dDLTmplImpl
	}
	
	override MysqlDDLTmpl mysqlDDLTmpl() {
		mysqlDDLTmplImpl
	}
	
	override OracleDDLTmpl oracleDDLTmpl() {
		oracleDDLTmplImpl
	}
	
	override CustomDDLTmpl customDDLTmpl() {
		customDDLTmplImpl
	}
	
	override DatasourceTmpl datasourceTmpl() {
		datasourceTmplImpl
	}
	
	override DbUnitTmpl dbUnitTmpl() {
		dbUnitTmplImpl
	}
	
	override DomainObjectAnnotationTmpl domainObjectAnnotationTmpl() {
		domainObjectAnnotationTmplImpl
	}
	
	override DomainObjectReferenceAnnotationTmpl domainObjectReferenceAnnotationTmpl() {
		domainObjectReferenceAnnotationTmplImpl
	}
	
	override DomainObjectNamesTmpl domainObjectNamesTmpl() {
		domainObjectNamesTmplImpl
	}
	
	override DomainObjectConstructorTmpl domainObjectConstructorTmpl() {
		domainObjectConstructorTmplImpl
	}
	
	override DomainObjectTraitTmpl domainObjectTraitTmpl() {
		domainObjectTraitTmplImpl
	}
	
	override DomainObjectReferenceTmpl domainObjectReferenceTmpl() {
		domainObjectReferenceTmplImpl
	}
	
	override DomainObjectKeyTmpl domainObjectKeyTmpl() {
		domainObjectKeyTmplImpl
	}
	
	override DomainObjectPropertiesTmpl domainObjectPropertiesTmpl() {
		domainObjectPropertiesTmplImpl
	}
	
	override DomainObjectAttributeAnnotationTmpl domainObjectAttributeAnnotationTmpl() {
		domainObjectAttributeAnnotationTmplImpl
	}
	
	override DomainObjectAttributeTmpl domainObjectAttributeTmpl() {
		domainObjectAttributeTmplImpl
	}
	
	override BuilderTmpl builderTmpl() {
		builderTmplImpl
	}
	
	override DomainObjectTmpl domainObjectTmpl() {
		domainObjectTmplImpl
	}
	
	override MongoDbConversationDomainObjectRepositoryTmpl mongoDbConversationDomainObjectRepositoryTmpl() {
		mongoDbConversationDomainObjectRepositoryTmplImpl
	}
	
	override MongoDbServiceTestTmpl mongoDbServiceTestTmpl() {
		mongoDbServiceTestTmplImpl
	}
	
	override MongoDbMapperTmpl mongoDbMapperTmpl() {
		mongoDbMapperTmplImpl
	}
	
	override EclipseLinkTmpl eclipseLinkTmpl() {
		eclipseLinkTmplImpl
	}
	
	override DataNucleusTmpl dataNucleusTmpl() {
		dataNucleusTmplImpl
	}
	
	override JPATmpl jPATmpl() {
		jPATmplImpl
	}
	
	override OpenJpaTmpl openJpaTmpl() {
		openJpaTmplImpl
	}
	
	override HibernateTmpl hibernateTmpl() {
		hibernateTmplImpl
	}
	
	override CamelTmpl camelTmpl() {
		camelTmplImpl
	}
	
	override LogConfigTmpl logConfigTmpl() {
		logConfigTmplImpl
	}
	
	override PubSubTmpl pubSubTmpl() {
		pubSubTmplImpl
	}
	
	override ExceptionTmpl exceptionTmpl() {
		exceptionTmplImpl
	}
	
	override ConsumerTmpl consumerTmpl() {
		consumerTmplImpl
	}
	
	override ConsumerTestTmpl consumerTestTmpl() {
		consumerTestTmplImpl
	}
	
	override ConsumerEjbTmpl consumerEjbTmpl() {
		consumerEjbTmplImpl
	}
	
	override ConsumerEjbTestTmpl consumerEjbTestTmpl() {
		consumerEjbTestTmplImpl
	}
	
	override AccessObjectTmpl accessObjectTmpl() {
		accessObjectTmplImpl
	}
	
	override AccessObjectFactoryTmpl accessObjectFactoryTmpl() {
		accessObjectFactoryTmplImpl
	}
	
	override RepositoryTmpl repositoryTmpl() {
		repositoryTmplImpl
	}
	
	override RootTmpl rootTmpl() {
		rootTmplImpl
	}

	override RestWebCssTmpl restWebCssTmpl() {
		restWebCssTmplImpl
	}
	
	override RestWebJspTmpl restWebJspTmpl() {
		restWebJspTmplImpl
	}
	
	override ResourceTmpl resourceTmpl() {
		resourceTmplImpl
	}
	
	override RestWebConfigTmpl restWebConfigTmpl() {
		restWebConfigTmplImpl
	}
	
	override RestWebTmpl restWebTmpl() {
		restWebTmplImpl
	}
}