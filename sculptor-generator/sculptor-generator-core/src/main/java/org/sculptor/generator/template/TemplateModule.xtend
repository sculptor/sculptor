package org.sculptor.generator.template

import com.google.inject.Scopes
import java.util.List
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

	val templateClasses = #[
		typeof(ServiceTmpl),
		typeof(ServiceEjbTestTmpl),
		typeof(ServiceTestTmpl),
		typeof(ServiceEjbTmpl),
		typeof(JSFCrudGuiConfigContextTmpl),
		typeof(TemplateModule),
		typeof(DroolsTmpl),
		typeof(ModelDocTmpl),
		typeof(UMLGraphTmpl),
		typeof(ModelDocCssTmpl),
		typeof(SpringTmpl),
		typeof(SpringIntegrationTmpl),
		typeof(DDLTmpl),
		typeof(MysqlDDLTmpl),
		typeof(OracleDDLTmpl),
		typeof(CustomDDLTmpl),
		typeof(DatasourceTmpl),
		typeof(DbUnitTmpl),
		typeof(DomainObjectAnnotationTmpl),
		typeof(DomainObjectReferenceAnnotationTmpl),
		typeof(DomainObjectNamesTmpl),
		typeof(DomainObjectConstructorTmpl),
		typeof(DomainObjectTraitTmpl),
		typeof(DomainObjectReferenceTmpl),
		typeof(DomainObjectKeyTmpl),
		typeof(DomainObjectPropertiesTmpl),
		typeof(DomainObjectAttributeAnnotationTmpl),
		typeof(DomainObjectAttributeTmpl),
		typeof(DomainObjectTmpl),
		typeof(MongoDbConversationDomainObjectRepositoryTmpl),
		typeof(MongoDbServiceTestTmpl),
		typeof(MongoDbMapperTmpl),
		typeof(EclipseLinkTmpl),
		typeof(DataNucleusTmpl),
		typeof(JPATmpl),
		typeof(OpenJpaTmpl),
		typeof(HibernateTmpl),
		typeof(CamelTmpl),
		typeof(LogConfigTmpl),
		typeof(PubSubTmpl),
		typeof(ExceptionTmpl),
		typeof(ConsumerTmpl),
		typeof(ConsumerTestTmpl),
		typeof(ConsumerEjbTmpl),
		typeof(ConsumerEjbTestTmpl),
		typeof(AccessObjectTmpl),
		typeof(AccessObjectFactoryTmpl),
		typeof(RepositoryTmpl),
		typeof(RootTmpl),
		typeof(RestWebCssTmpl),
		typeof(RestWebJspTmpl),
		typeof(ResourceTmpl),
		typeof(RestWebConfigTmpl),
		typeof(RestWebTmpl)
	]
	
	override List<Class<?>> getGeneratorClasses() {
		templateClasses as List<Class<?>>
	}
	
	override protected configure() {
		super.configure

		templateClasses.forEach[findOverrideClass]
		
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
			bind(clazz).in(Scopes::SINGLETON)
		} else {
			bind(clazz).to(newClazz).in(Scopes::SINGLETON)
		}
	}
	
	/**
	 * Get the configured cartridge names, including both internal Sculptor cartridges, and cartridges configured by
	 * application.
	 * TODO: Implement by getting list of cartridge classes from properties
	 * 
	 * @return List of cartridge fully qualified class names
	 */
	override List<String> getCartridgeNames() {
		#["org.sculptor.generator.template.domain.builder.BuilderCartridge"];
	}


}