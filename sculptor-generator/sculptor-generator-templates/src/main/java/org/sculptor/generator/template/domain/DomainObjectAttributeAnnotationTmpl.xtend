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

package org.sculptor.generator.template.domain

import javax.inject.Inject
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.DbHelperBase
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Attribute
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class DomainObjectAttributeAnnotationTmpl {

	@Inject extension DbHelperBase dbHelperBase
	@Inject extension DbHelper dbHelper
	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def String attributeAnnotations(Attribute it) {
	'''
		«IF isJpaAnnotationOnFieldToBeGenerated()»
			«IF isJpaAnnotationToBeGenerated() && it.getDomainObject().isPersistent() »
				«jpaAnnotations(it)»
			«ENDIF»
			«IF it.isValidationAnnotationToBeGeneratedForObject()»
				«validationAnnotations(it)»
			«ENDIF»
		«ENDIF»
	'''
}

def String propertyGetterAnnotations(Attribute it) {
	'''
		«IF !isJpaAnnotationOnFieldToBeGenerated()»
			«IF isJpaAnnotationToBeGenerated() && it.getDomainObject().isPersistent() »
				«jpaAnnotations(it)»
			«ENDIF»
			«IF it.isValidationAnnotationToBeGeneratedForObject()»
				«validationAnnotations(it)»
			«ENDIF»
		«ENDIF»
		«IF it.isXmlElementToBeGenerated()»
			«xmlElementAnnotation(it)»
		«ENDIF»
	'''
}

def String xmlElementAnnotation(Attribute it) {
	'''
		«IF transient»
			@javax.xml.bind.annotation.XmlTransient
		«ELSE»
			@javax.xml.bind.annotation.XmlElement(«formatAnnotationParameters(<Object>newArrayList(required, "required", "true",
				nullable, "nillable", "true"
			))»)
			«IF it.getTypeName() == "org.joda.time.LocalDate"»
				@javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter(«fw("xml.JodaLocalDateXmlAdapter")».class)
			«ELSEIF it.getTypeName() == "org.joda.time.DateTime"»
				@javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter(«fw("xml.JodaDateTimeXmlAdapter")».class)
			«ENDIF»
			«IF it.isDate()»
				@javax.xml.bind.annotation.XmlSchemaType(name="date")
			«ENDIF»
		«ENDIF»
	'''
}

def String jpaAnnotations(Attribute it) {
	'''
		«IF transient»
			@javax.persistence.Transient
		«ELSE»
			«IF it.isCollection()»
				«IF isJpa2()»
					«elementCollectionAnnotations(it)»
				«ELSE»
					@javax.persistence.Transient
				«ENDIF»
			«ELSE»
				«IF name == "id"»
					«idAnnotations(it)»
				«ELSEIF name == "version"»
					«versionAnnotations(it)»
				«ELSEIF name == "createdDate" || name == "lastUpdated" »
					«auditAnnotations(it)»
				«ELSE»
					«columnAnnotations(it)»
				«ENDIF»
				«IF it.useJpaLobAnnotation()»
					@javax.persistence.Lob
				«ENDIF»
				«IF it.useJpaBasicAnnotation()»
					@javax.persistence.Basic
				«ENDIF»
				«IF index»
					«indexAnnotations(it)»
				«ENDIF»
			«ENDIF»
		«ENDIF»
	'''
}

def String idAnnotations(Attribute it) {
	'''
		@javax.persistence.Id
		«IF isJpaProviderAppEngine()»
			@javax.persistence.GeneratedValue(strategy = javax.persistence.GenerationType.IDENTITY)
		«ELSEIF isJpa1() && isJpaProviderEclipseLink()»
			@javax.persistence.GeneratedValue(strategy = javax.persistence.GenerationType.AUTO)
			//    possible bug in eclipselink produces incorrect ddl for hsqldb (IDENTITY)
			//    @javax.persistence.GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "«it.getDomainObject().name»Sequence")
			@javax.persistence.SequenceGenerator(name = "«it.getDomainObject().name»Sequence", initialValue = 10)
		«ELSE»
			@javax.persistence.GeneratedValue(strategy = javax.persistence.GenerationType.AUTO)
		«ENDIF»
		@javax.persistence.Column(name="«it.getDatabaseName()»")
	'''
}

def String versionAnnotations(Attribute it) {
	'''
		@javax.persistence.Version
		@javax.persistence.Column(«formatAnnotationParameters(<Object>newArrayList(true, "name", '"' + it.getDatabaseName() + '"',
			!isJpaProviderAppEngine() && !nullable, "nullable", nullable))»)
	'''
}

def String auditAnnotations(Attribute it) {
	val dbType = if (isJpaAnnotationColumnDefinitionToBeGenerated()) getDatabaseType() else null
	'''
		«IF isJpaProviderHibernate() && it.isJodaTemporal()»
			@org.hibernate.annotations.Type(type="«it.getHibernateType()»")
		«ELSEIF isJpaProviderEclipseLink() && it.isJodaTemporal()»
			@org.eclipse.persistence.annotations.Convert("JodaConverter")
		«ELSEIF isJpaProviderOpenJpa() && it.isJodaTemporal()»
			@org.apache.openjpa.persistence.jdbc.Strategy("«it.getApplicationBasePackage()».util.JodaHandler")
		«ELSEIF isJpaProviderAppEngine()»
			@javax.persistence.Temporal(javax.persistence.TemporalType.DATE)
		«ELSE»
			@javax.persistence.Temporal(javax.persistence.TemporalType.TIMESTAMP)
		«ENDIF»
		@javax.persistence.Column(
		«formatAnnotationParameters(<Object>newArrayList(true, "name", '"' + it.getDatabaseName() + '"',
			!nullable, "nullable", nullable,
			dbType != null, "columnDefinition", '"' + dbType + '"'
		))»)
	'''
}

def String columnAnnotations(Attribute it) {
	val dbType = if (isJpaAnnotationColumnDefinitionToBeGenerated()) getDatabaseType() else null
	'''
		@javax.persistence.Column(
		«formatAnnotationParameters(<Object>newArrayList( true, "name", '"' + it.getDatabaseName() + '"',
			!nullable, "nullable", nullable,
			it.getDatabaseLength() != null, "length", it.getDatabaseLength(),
			(it.isUuid() || it.isSimpleNaturalKey()) && (isJpa2() || isJpaProviderHibernate()) && !isJpaProviderAppEngine(), "unique", "true",
			dbType != null, "columnDefinition", '"' + dbType + '"'
		))»)
		«columnDateAnnotations(it)»
	'''
}

def String columnDateAnnotations(Attribute it) {
	'''
		«IF isJpaProviderHibernate() && it.getHibernateType() != null»
			@org.hibernate.annotations.Type(type="«it.getHibernateType()»")
		«ELSEIF isJpaProviderEclipseLink() && it.isJodaTemporal()»
			@org.eclipse.persistence.annotations.Convert("JodaConverter")
		«ELSEIF isJpaProviderOpenJpa() && it.isJodaTemporal()»
			@org.apache.openjpa.persistence.jdbc.Strategy("«it.getApplicationBasePackage()».util.JodaHandler")
		«ELSE»
			«IF it.isDate()»
				@javax.persistence.Temporal(javax.persistence.TemporalType.DATE)
			«ELSEIF it.isDateTime()»
				@javax.persistence.Temporal(javax.persistence.TemporalType.TIMESTAMP)
			«ENDIF»
		«ENDIF»
	'''
}

def String indexAnnotations(Attribute it) {
	'''
		«IF isJpaProviderHibernate()»
			@org.hibernate.annotations.Index(name="«it.getDatabaseName()»")
		«ELSEIF isJpaProviderOpenJpa()»
			@org.apache.openjpa.persistence.jdbc.Index(name="«it.getDatabaseName()»")
		«ENDIF»
	'''
}

def String elementCollectionAnnotations(Attribute it) {
	'''
		«/* TODO: change support for fetchtype, add a keyword */»
		@javax.persistence.ElementCollection(
			«formatAnnotationParameters(<Object>newArrayList(it.getFetchType() != null, "fetch", it.getFetchType()))»)
		«IF !useJpaDefaults()»
				«elementCollectionTableJpaAnnotation(it)»
		«ENDIF»
	'''
}

def String elementCollectionTableJpaAnnotation(Attribute it) {
	'''
		/*
		 It's not possible to overwrite the collection table later,
		 therefore not set it for embeddables
		*/
		«IF !it.getDomainObject().isEmbeddable()»
			@javax.persistence.CollectionTable(
			name="«it.getElementCollectionTableName()»",
			joinColumns = @javax.persistence.JoinColumn(name = "«it.getDomainObject().getDatabaseName() + (if (useIdSuffixInForeigKey()) "_ID" else "")»"))
			@javax.persistence.Column(
			«formatAnnotationParameters(<Object>newArrayList(true, "name", '"' + it.getDatabaseName().toLowerCase().singular().toUpperCase() + '"'))»)
		«ENDIF»
	'''
}

def String validationAnnotations(Attribute it) {
	'''
		«/* exclude persistence controlled properties */»
		«IF name != "id" && name != "version" && !it.isUuid()»
			«it.getValidationAnnotations()»
		«ENDIF»
	'''
}

def String propertySetterAnnotations(Attribute it) {
	""
}

}
