package org.sculptor.generator.template

import org.sculptor.generator.ext.ExtensionModule
import org.sculptor.generator.template.camel.CamelTmpl
import org.sculptor.generator.template.common.ExceptionTmpl
import org.sculptor.generator.template.common.LogConfigTmpl
import org.sculptor.generator.template.common.PubSubTmpl
import org.sculptor.generator.template.consumer.ConsumerEjbTestTmpl
import org.sculptor.generator.template.consumer.ConsumerEjbTmpl
import org.sculptor.generator.template.consumer.ConsumerTestTmpl
import org.sculptor.generator.template.consumer.ConsumerTmpl
import org.sculptor.generator.template.db.CustomDDLTmpl
import org.sculptor.generator.template.db.DDLTmpl
import org.sculptor.generator.template.db.DatasourceTmpl
import org.sculptor.generator.template.db.DbUnitTmpl
import org.sculptor.generator.template.db.MysqlDDLTmpl
import org.sculptor.generator.template.db.OracleDDLTmpl
import org.sculptor.generator.template.doc.ModelDocCssTmpl
import org.sculptor.generator.template.doc.ModelDocTmpl
import org.sculptor.generator.template.doc.UMLGraphTmpl
import org.sculptor.generator.template.domain.BuilderTmpl
import org.sculptor.generator.template.domain.DomainObjectAnnotationTmpl
import org.sculptor.generator.template.domain.DomainObjectAttributeAnnotationTmpl
import org.sculptor.generator.template.domain.DomainObjectAttributeTmpl
import org.sculptor.generator.template.domain.DomainObjectConstructorTmpl
import org.sculptor.generator.template.domain.DomainObjectKeyTmpl
import org.sculptor.generator.template.domain.DomainObjectNamesTmpl
import org.sculptor.generator.template.domain.DomainObjectPropertiesTmpl
import org.sculptor.generator.template.domain.DomainObjectReferenceAnnotationTmpl
import org.sculptor.generator.template.domain.DomainObjectReferenceTmpl
import org.sculptor.generator.template.domain.DomainObjectTmpl
import org.sculptor.generator.template.domain.DomainObjectTraitTmpl
import org.sculptor.generator.template.drools.DroolsTmpl
import org.sculptor.generator.template.jpa.DataNucleusTmpl
import org.sculptor.generator.template.jpa.EclipseLinkTmpl
import org.sculptor.generator.template.jpa.HibernateTmpl
import org.sculptor.generator.template.jpa.JPATmpl
import org.sculptor.generator.template.jpa.OpenJpaTmpl
import org.sculptor.generator.template.mongodb.MongoDbConversationDomainObjectRepositoryTmpl
import org.sculptor.generator.template.mongodb.MongoDbMapperTmpl
import org.sculptor.generator.template.mongodb.MongoDbServiceTestTmpl
import org.sculptor.generator.template.repository.AccessObjectFactoryTmpl
import org.sculptor.generator.template.repository.AccessObjectTmpl
import org.sculptor.generator.template.repository.RepositoryTmpl
import org.sculptor.generator.template.rest.ResourceTmpl
import org.sculptor.generator.template.rest.RestWebConfigTmpl
import org.sculptor.generator.template.rest.RestWebCssTmpl
import org.sculptor.generator.template.rest.RestWebJspTmpl
import org.sculptor.generator.template.rest.RestWebTmpl
import org.sculptor.generator.template.service.ServiceEjbTestTmpl
import org.sculptor.generator.template.service.ServiceEjbTmpl
import org.sculptor.generator.template.service.ServiceTestTmpl
import org.sculptor.generator.template.service.ServiceTmpl
import org.sculptor.generator.template.spring.SpringTmpl
import org.sculptor.generator.template.springint.SpringIntegrationTmpl
import org.sculptor.generator.template.web.JSFCrudGuiConfigContextTmpl

class TemplateModule extends ExtensionModule {
	override protected configure() {
		super.configure

		bind(typeof(ServiceTmpl))
		bind(typeof(ServiceEjbTestTmpl))
		bind(typeof(ServiceTestTmpl))
		bind(typeof(ServiceEjbTmpl))
		bind(typeof(JSFCrudGuiConfigContextTmpl))
		bind(typeof(TemplateModule))
		bind(typeof(DroolsTmpl))
		bind(typeof(ModelDocTmpl))
		bind(typeof(UMLGraphTmpl))
		bind(typeof(ModelDocCssTmpl))
		bind(typeof(SpringTmpl))
		bind(typeof(SpringIntegrationTmpl))
		bind(typeof(DDLTmpl))
		bind(typeof(MysqlDDLTmpl))
		bind(typeof(OracleDDLTmpl))
		bind(typeof(CustomDDLTmpl))
		bind(typeof(DatasourceTmpl))
		bind(typeof(DbUnitTmpl))
		bind(typeof(DomainObjectAnnotationTmpl))
		bind(typeof(DomainObjectReferenceAnnotationTmpl))
		bind(typeof(DomainObjectNamesTmpl))
		bind(typeof(DomainObjectConstructorTmpl))
		bind(typeof(DomainObjectTraitTmpl))
		bind(typeof(DomainObjectReferenceTmpl))
		bind(typeof(DomainObjectKeyTmpl))
		bind(typeof(DomainObjectPropertiesTmpl))
		bind(typeof(DomainObjectAttributeAnnotationTmpl))
		bind(typeof(DomainObjectAttributeTmpl))
		bind(typeof(BuilderTmpl))
		bind(typeof(DomainObjectTmpl))
		bind(typeof(MongoDbConversationDomainObjectRepositoryTmpl))
		bind(typeof(MongoDbServiceTestTmpl))
		bind(typeof(MongoDbMapperTmpl))
		bind(typeof(EclipseLinkTmpl))
		bind(typeof(DataNucleusTmpl))
		bind(typeof(JPATmpl))
		bind(typeof(OpenJpaTmpl))
		bind(typeof(HibernateTmpl))
		bind(typeof(CamelTmpl))
		bind(typeof(LogConfigTmpl))
		bind(typeof(PubSubTmpl))
		bind(typeof(ExceptionTmpl))
		bind(typeof(ConsumerTmpl))
		bind(typeof(ConsumerTestTmpl))
		bind(typeof(ConsumerEjbTmpl))
		bind(typeof(ConsumerEjbTestTmpl))
		bind(typeof(AccessObjectTmpl))
		bind(typeof(AccessObjectFactoryTmpl))
		bind(typeof(RepositoryTmpl))
		bind(typeof(RootTmpl))
		bind(typeof(RestWebCssTmpl))
		bind(typeof(RestWebJspTmpl))
		bind(typeof(ResourceTmpl))
		bind(typeof(RestWebConfigTmpl))
		bind(typeof(RestWebTmpl))
	}
}