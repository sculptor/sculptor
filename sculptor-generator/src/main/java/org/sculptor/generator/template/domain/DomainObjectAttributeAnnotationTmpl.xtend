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

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class DomainObjectAttributeAnnotationTmpl {

def static String attributeAnnotations(Attribute it) {
	'''
	«IF isJpaAnnotationOnFieldToBeGenerated()»
		«IF isJpaAnnotationToBeGenerated() && getDomainObject().isPersistent() »
			«jpaAnnotations(it)»
		«ENDIF»
		«IF isValidationAnnotationToBeGeneratedForObject()»
			«validationAnnotations(it)»
		«ENDIF»
	«ENDIF»
	'''
}

def static String propertyGetterAnnotations(Attribute it) {
	'''
	«IF !isJpaAnnotationOnFieldToBeGenerated()»
		«IF isJpaAnnotationToBeGenerated() && getDomainObject().isPersistent() »
			«jpaAnnotations(it)»
		«ENDIF»
		«IF isValidationAnnotationToBeGeneratedForObject()»
			«validationAnnotations(it)»
		«ENDIF»
	«ENDIF»
	«IF isXmlElementToBeGenerated()»
		«xmlElementAnnotation(it)»
	«ENDIF»
	'''
}

def static String xmlElementAnnotation(Attribute it) {
	'''
	«IF transient»
	    @javax.xml.bind.annotation.XmlTransient
	«ELSE»
	    @javax.xml.bind.annotation.XmlElement(«formatAnnotationParameters({ required, "required", "true",
		    		nullable, "nillable", "true"
		    	})»)
		«IF getTypeName() == "org.joda.time.LocalDate"»
		@javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter(«fw("xml.JodaLocalDateXmlAdapter")».class)
		«ELSEIF getTypeName() == "org.joda.time.DateTime"»
		@javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter(«fw("xml.JodaDateTimeXmlAdapter")».class)
		«ENDIF»
		«IF isDate()»
		@javax.xml.bind.annotation.XmlSchemaType(name="date")
		«ENDIF»
	«ENDIF»
	'''
}

def static String jpaAnnotations(Attribute it) {
	'''
	«IF transient»
		@javax.persistence.Transient
	«ELSE»
		«IF isCollection()»
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
		    «IF useJpaLobAnnotation()»
		    	@javax.persistence.Lob
		    «ENDIF»
		    «IF useJpaBasicAnnotation()»
			    @javax.persistence.Basic
			«ENDIF»
			«IF index»
				«indexAnnotations(it)»
			«ENDIF»
		«ENDIF»
	«ENDIF»
	'''
}

def static String idAnnotations(Attribute it) {
	'''
	@javax.persistence.Id
	«IF isJpaProviderAppEngine()»
	@javax.persistence.GeneratedValue(strategy = javax.persistence.GenerationType.IDENTITY)
	«ELSEIF isJpa1() && isJpaProviderEclipseLink()»
		@javax.persistence.GeneratedValue(strategy = javax.persistence.GenerationType.AUTO)
//    possible bug in eclipselink produces incorrect ddl for hsqldb (IDENTITY)
//    @javax.persistence.GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "«getDomainObject().name»Sequence")
		@javax.persistence.SequenceGenerator(name = "«getDomainObject().name»Sequence", initialValue = 10)
	«ELSE»
	@javax.persistence.GeneratedValue(strategy = javax.persistence.GenerationType.AUTO)
	«ENDIF»
		@javax.persistence.Column(name="«getDatabaseName()»")
	'''
}

def static String versionAnnotations(Attribute it) {
	'''
		@javax.persistence.Version
		@javax.persistence.Column(«formatAnnotationParameters({ true, "name", '"' + getDatabaseName() + '"',
			!nullable, "nullable", nullable})»)
	'''
}

def static String auditAnnotations(Attribute it) {
	'''
	«val dbType = it.isJpaAnnotationColumnDefinitionToBeGenerated() ? getDatabaseType() : null»
	«IF isJpaProviderHibernate() && isJodaTemporal()»
	@org.hibernate.annotations.Type(type="«getHibernateType()»")
	«ELSEIF isJpaProviderEclipseLink() && isJodaTemporal()»
		@org.eclipse.persistence.annotations.Convert("JodaConverter")
	«ELSEIF isJpaProviderOpenJpa() && isJodaTemporal()»
		@org.apache.openjpa.persistence.jdbc.Strategy("«getApplicationBasePackage()».util.JodaHandler")
	«ELSE»
	@javax.persistence.Temporal(javax.persistence.TemporalType.TIMESTAMP)
	«ENDIF»
		@javax.persistence.Column(
		«formatAnnotationParameters({ true, "name", '"' + getDatabaseName() + '"',
			!nullable, "nullable", nullable,
			dbType != null, "columnDefinition", '"' + dbType + '"'
		})»)
	'''
}

def static String columnAnnotations(Attribute it) {
	'''
	«val dbType = it.isJpaAnnotationColumnDefinitionToBeGenerated() ? getDatabaseType() : null»
		@javax.persistence.Column(
		«formatAnnotationParameters({ true, "name", '"' + getDatabaseName() + '"',
			!nullable, "nullable", nullable,
			getDatabaseLength() != null, "length", getDatabaseLength(),
			(isUuid() || isSimpleNaturalKey()) && (isJpa2() || isJpaProviderHibernate()), "unique", "true",
			dbType != null, "columnDefinition", '"' + dbType + '"'
		})»)
		«columnDateAnnotations(it)»
	'''
}

def static String columnDateAnnotations(Attribute it) {
	'''
		«IF isJpaProviderHibernate() && getHibernateType() != null»
		@org.hibernate.annotations.Type(type="«getHibernateType()»")
		«ELSEIF isJpaProviderEclipseLink() && isJodaTemporal()»
		@org.eclipse.persistence.annotations.Convert("JodaConverter")
		«ELSEIF isJpaProviderOpenJpa() && isJodaTemporal()»
		@org.apache.openjpa.persistence.jdbc.Strategy("«getApplicationBasePackage()».util.JodaHandler")
		«ELSE»
			«IF isDate()»
		@javax.persistence.Temporal(javax.persistence.TemporalType.DATE)
			«ELSEIF isDateTime()»
		@javax.persistence.Temporal(javax.persistence.TemporalType.TIMESTAMP)
			«ENDIF»
		«ENDIF»
	'''
}

def static String indexAnnotations(Attribute it) {
	'''
		«IF isJpaProviderHibernate()»
		@org.hibernate.annotations.Index(name="«getDatabaseName()»")
		«ELSEIF isJpaProviderOpenJpa()»
		@org.apache.openjpa.persistence.jdbc.Index(name="«getDatabaseName()»")
		«ENDIF»
	'''
}

def static String elementCollectionAnnotations(Attribute it) {
	'''
	/*TODO: change support for fetchtype, add a keyword */
	@javax.persistence.ElementCollection(
			«formatAnnotationParameters({ getFetchType() != null, "fetch", getFetchType()
			})»)
	«IF !useJpaDefaults()»
			«elementCollectionTableJpaAnnotation(it)»
	«ENDIF»
	'''
}

def static String elementCollectionTableJpaAnnotation(Attribute it) {
	'''
		/*
			It's not possible to overwrite the collection table later,
			therefore not set it for embeddabkes
			*/
		«IF !getDomainObject().isEmbeddable()»
				@javax.persistence.CollectionTable(
				name="«getElementCollectionTableName()»",
				joinColumns = @javax.persistence.JoinColumn(name = "«getDomainObject().getDatabaseName() + ((useIdSuffixInForeigKey()) ? "_ID" : "")»"))
			@javax.persistence.Column(
			«formatAnnotationParameters({ true, "name", '"' + getDatabaseName().toLowerCase().singular().toUpperCase() + '"'
			})»)
		«ENDIF»
	'''
}

def static String validationAnnotations(Attribute it) {
	'''
	/*exclude persistence controlled properties */
	«IF name != "id" && name != "version" && !isUuid()»
		«getValidationAnnotations()»
	«ENDIF»
	'''
}

def static String propertySetterAnnotations(Attribute it) {
	'''
	'''
}
}
