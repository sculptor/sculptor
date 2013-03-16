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

class GeneratorFactory {
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

	def static Helper helper() {
		helperImpl
	}

	def static HelperBase helperBase() {
		helperBaseImpl
	}

	def static Properties properties() {
		propertiesImpl
	}

	def static PropertiesBase propertiesBase() {
		propertiesBaseImpl
	}

	def static DbHelperBase dbHelperBase() {
		dbHelperBaseImpl
	}

	def static DbHelper dbHelper() {
		dbHelperImpl
	}

	def static XmlHelperBase xmlHelperBase() {
		xmlHelperBaseImpl
	}

	def static UmlGraphHelper umlGraphHelper() {
		umlGraphHelperImpl
	}

	def static ServiceTmpl serviceTmpl() {
		serviceTmplImpl
	}
	
	def static ServiceEjbTestTmpl serviceEjbTestTmpl() {
		serviceEjbTestTmplImpl
	}
	
	def static ServiceTestTmpl serviceTestTmpl() {
		serviceTestTmplImpl
	}
	
	def static ServiceEjbTmpl serviceEjbTmpl() {
		serviceEjbTmplImpl
	}
	
	def static JSFCrudGuiConfigContextTmpl jSFCrudGuiConfigContextTmpl() {
		jSFCrudGuiConfigContextTmplImpl
	}
	
	def static DroolsTmpl droolsTmpl() {
		droolsTmplImpl
	}
	
	def static ModelDocTmpl modelDocTmpl() {
		modelDocTmplImpl
	}
	
	def static UMLGraphTmpl uMLGraphTmpl() {
		uMLGraphTmplImpl
	}
	
	def static ModelDocCssTmpl modelDocCssTmpl() {
		modelDocCssTmplImpl
	}
	
	def static SpringTmpl springTmpl() {
		springTmplImpl
	}
	
	def static SpringIntegrationTmpl springIntegrationTmpl() {
		springIntegrationTmplImpl
	}
	
	def static DDLTmpl dDLTmpl() {
		dDLTmplImpl
	}
	
	def static MysqlDDLTmpl mysqlDDLTmpl() {
		mysqlDDLTmplImpl
	}
	
	def static OracleDDLTmpl oracleDDLTmpl() {
		oracleDDLTmplImpl
	}
	
	def static CustomDDLTmpl customDDLTmpl() {
		customDDLTmplImpl
	}
	
	def static DatasourceTmpl datasourceTmpl() {
		datasourceTmplImpl
	}
	
	def static DbUnitTmpl dbUnitTmpl() {
		dbUnitTmplImpl
	}
	
	def static DomainObjectAnnotationTmpl domainObjectAnnotationTmpl() {
		domainObjectAnnotationTmplImpl
	}
	
	def static DomainObjectReferenceAnnotationTmpl domainObjectReferenceAnnotationTmpl() {
		domainObjectReferenceAnnotationTmplImpl
	}
	
	def static DomainObjectNamesTmpl domainObjectNamesTmpl() {
		domainObjectNamesTmplImpl
	}
	
	def static DomainObjectConstructorTmpl domainObjectConstructorTmpl() {
		domainObjectConstructorTmplImpl
	}
	
	def static DomainObjectTraitTmpl domainObjectTraitTmpl() {
		domainObjectTraitTmplImpl
	}
	
	def static DomainObjectReferenceTmpl domainObjectReferenceTmpl() {
		domainObjectReferenceTmplImpl
	}
	
	def static DomainObjectKeyTmpl domainObjectKeyTmpl() {
		domainObjectKeyTmplImpl
	}
	
	def static DomainObjectPropertiesTmpl domainObjectPropertiesTmpl() {
		domainObjectPropertiesTmplImpl
	}
	
	def static DomainObjectAttributeAnnotationTmpl domainObjectAttributeAnnotationTmpl() {
		domainObjectAttributeAnnotationTmplImpl
	}
	
	def static DomainObjectAttributeTmpl domainObjectAttributeTmpl() {
		domainObjectAttributeTmplImpl
	}
	
	def static BuilderTmpl builderTmpl() {
		builderTmplImpl
	}
	
	def static DomainObjectTmpl domainObjectTmpl() {
		domainObjectTmplImpl
	}
	
	def static MongoDbConversationDomainObjectRepositoryTmpl mongoDbConversationDomainObjectRepositoryTmpl() {
		mongoDbConversationDomainObjectRepositoryTmplImpl
	}
	
	def static MongoDbServiceTestTmpl mongoDbServiceTestTmpl() {
		mongoDbServiceTestTmplImpl
	}
	
	def static MongoDbMapperTmpl mongoDbMapperTmpl() {
		mongoDbMapperTmplImpl
	}
	
	def static EclipseLinkTmpl eclipseLinkTmpl() {
		eclipseLinkTmplImpl
	}
	
	def static DataNucleusTmpl dataNucleusTmpl() {
		dataNucleusTmplImpl
	}
	
	def static JPATmpl jPATmpl() {
		jPATmplImpl
	}
	
	def static OpenJpaTmpl openJpaTmpl() {
		openJpaTmplImpl
	}
	
	def static HibernateTmpl hibernateTmpl() {
		hibernateTmplImpl
	}
	
	def static CamelTmpl camelTmpl() {
		camelTmplImpl
	}
	
	def static LogConfigTmpl logConfigTmpl() {
		logConfigTmplImpl
	}
	
	def static PubSubTmpl pubSubTmpl() {
		pubSubTmplImpl
	}
	
	def static ExceptionTmpl exceptionTmpl() {
		exceptionTmplImpl
	}
	
	def static ConsumerTmpl consumerTmpl() {
		consumerTmplImpl
	}
	
	def static ConsumerTestTmpl consumerTestTmpl() {
		consumerTestTmplImpl
	}
	
	def static ConsumerEjbTmpl consumerEjbTmpl() {
		consumerEjbTmplImpl
	}
	
	def static ConsumerEjbTestTmpl consumerEjbTestTmpl() {
		consumerEjbTestTmplImpl
	}
	
	def static AccessObjectTmpl accessObjectTmpl() {
		accessObjectTmplImpl
	}
	
	def static AccessObjectFactoryTmpl accessObjectFactoryTmpl() {
		accessObjectFactoryTmplImpl
	}
	
	def static RepositoryTmpl repositoryTmpl() {
		repositoryTmplImpl
	}
	
	def static RootTmpl rootTmpl() {
		rootTmplImpl
	}

	def static RestWebCssTmpl restWebCssTmpl() {
		restWebCssTmplImpl
	}
	
	def static RestWebJspTmpl restWebJspTmpl() {
		restWebJspTmplImpl
	}
	
	def static ResourceTmpl resourceTmpl() {
		resourceTmplImpl
	}
	
	def static RestWebConfigTmpl restWebConfigTmpl() {
		restWebConfigTmplImpl
	}
	
	def static RestWebTmpl restWebTmpl() {
		restWebTmplImpl
	}
}