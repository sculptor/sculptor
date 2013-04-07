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
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class TemplateModule extends ExtensionModule {
	private static final val Logger LOG = LoggerFactory::getLogger(typeof(TemplateModule))

	override protected configure() {
		super.configure

		findOverrideClass(typeof(ServiceTmpl))
		findOverrideClass(typeof(ServiceEjbTestTmpl))
		findOverrideClass(typeof(ServiceTestTmpl))
		findOverrideClass(typeof(ServiceEjbTmpl))
		findOverrideClass(typeof(JSFCrudGuiConfigContextTmpl))
		findOverrideClass(typeof(TemplateModule))
		findOverrideClass(typeof(DroolsTmpl))
		findOverrideClass(typeof(ModelDocTmpl))
		findOverrideClass(typeof(UMLGraphTmpl))
		findOverrideClass(typeof(ModelDocCssTmpl))
		findOverrideClass(typeof(SpringTmpl))
		findOverrideClass(typeof(SpringIntegrationTmpl))
		findOverrideClass(typeof(DDLTmpl))
		findOverrideClass(typeof(MysqlDDLTmpl))
		findOverrideClass(typeof(OracleDDLTmpl))
		findOverrideClass(typeof(CustomDDLTmpl))
		findOverrideClass(typeof(DatasourceTmpl))
		findOverrideClass(typeof(DbUnitTmpl))
		findOverrideClass(typeof(DomainObjectAnnotationTmpl))
		findOverrideClass(typeof(DomainObjectReferenceAnnotationTmpl))
		findOverrideClass(typeof(DomainObjectNamesTmpl))
		findOverrideClass(typeof(DomainObjectConstructorTmpl))
		findOverrideClass(typeof(DomainObjectTraitTmpl))
		findOverrideClass(typeof(DomainObjectReferenceTmpl))
		findOverrideClass(typeof(DomainObjectKeyTmpl))
		findOverrideClass(typeof(DomainObjectPropertiesTmpl))
		findOverrideClass(typeof(DomainObjectAttributeAnnotationTmpl))
		findOverrideClass(typeof(DomainObjectAttributeTmpl))
		findOverrideClass(typeof(BuilderTmpl))
		findOverrideClass(typeof(DomainObjectTmpl))
		findOverrideClass(typeof(MongoDbConversationDomainObjectRepositoryTmpl))
		findOverrideClass(typeof(MongoDbServiceTestTmpl))
		findOverrideClass(typeof(MongoDbMapperTmpl))
		findOverrideClass(typeof(EclipseLinkTmpl))
		findOverrideClass(typeof(DataNucleusTmpl))
		findOverrideClass(typeof(JPATmpl))
		findOverrideClass(typeof(OpenJpaTmpl))
		findOverrideClass(typeof(HibernateTmpl))
		findOverrideClass(typeof(CamelTmpl))
		findOverrideClass(typeof(LogConfigTmpl))
		findOverrideClass(typeof(PubSubTmpl))
		findOverrideClass(typeof(ExceptionTmpl))
		findOverrideClass(typeof(ConsumerTmpl))
		findOverrideClass(typeof(ConsumerTestTmpl))
		findOverrideClass(typeof(ConsumerEjbTmpl))
		findOverrideClass(typeof(ConsumerEjbTestTmpl))
		findOverrideClass(typeof(AccessObjectTmpl))
		findOverrideClass(typeof(AccessObjectFactoryTmpl))
		findOverrideClass(typeof(RepositoryTmpl))
		findOverrideClass(typeof(RootTmpl))
		findOverrideClass(typeof(RestWebCssTmpl))
		findOverrideClass(typeof(RestWebJspTmpl))
		findOverrideClass(typeof(ResourceTmpl))
		findOverrideClass(typeof(RestWebConfigTmpl))
		findOverrideClass(typeof(RestWebTmpl))
	}

	def <T> void findOverrideClass(Class<T> clazz) {
		var newClazz = clazz
		val clsName = clazz.name
		val overrideName = clsName.substring("org.sculptor.".length) + "Override"
		try {
			val overrideClass = Class::forName(overrideName)
			if (clazz.isAssignableFrom(overrideClass)) {
				LOG.error("Installing override {} insted of {}", overrideName, clsName)
				newClazz = (overrideClass as Class<T>)
			} else {
				LOG.error("Override {} have to be inherited from {} -> skipping override", overrideName, clsName)
			}
		} catch (Throwable th) {
			// Ignore error - use default class
		}

		// Bind override if available
		if (clazz == newClazz) {
			bind(clazz)
		} else {
			bind(clazz).to(newClazz)
		}
	}
}