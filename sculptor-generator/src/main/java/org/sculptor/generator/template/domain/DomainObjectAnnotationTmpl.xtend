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

import sculptormetamodel.DataTransferObject
import sculptormetamodel.DomainObject
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference
import sculptormetamodel.Trait

import static org.sculptor.generator.ext.Properties.*
import static org.sculptor.generator.template.domain.DomainObjectAnnotationTmpl.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.util.HelperBase.*

class DomainObjectAnnotationTmpl {

def static String domainObjectSubclassAnnotations(DataTransferObject it) {
	'''
	«IF it.isXmlRootToBeGenerated()»
		«xmlRootAnnotation(it)»
	«ENDIF»
	«IF isXstreamAnnotationToBeGenerated()»
		«xstreamAliasAnnotation(it)»
	«ENDIF»
	'''
}

def static String domainObjectSubclassAnnotations(Trait it) {
	'''
	'''
}

def static String domainObjectSubclassAnnotations(DomainObject it) {
	'''
	«IF it.isXmlRootToBeGenerated()»
		«xmlRootAnnotation(it)»
	«ENDIF»
	«IF isXstreamAnnotationToBeGenerated()»
		«xstreamAliasAnnotation(it)»
	«ENDIF»
	'''
}

/*We need to format this carefully because it is included in JavaDoc, which is not beautified. */
def static String domainObjectAnnotations(DomainObject it) {
	'''
		«IF it.isEmbeddable() »
			@javax.persistence.Embeddable
		«ENDIF»
		«IF it.hasOwnDatabaseRepresentation()»
			@javax.persistence.Entity
			«IF !isInheritanceTypeSingleTable(it.getRootExtends()) || it == it.getRootExtends()»
				@javax.persistence.Table(name = "«it.getDatabaseName()»"« IF it.hasClassLevelUniqueConstraints() »«uniqueConstraints(it)»«ENDIF»)
			«ENDIF»
			«domainObjectInheritanceAnnotations(it)»
			«IF isJpa2() && cache»
				@javax.persistence.Cacheable
			«ENDIF»
			«IF isJpaProviderHibernate() && cache»
				@org.hibernate.annotations.Cache(usage = «it.getHibernateCacheStrategy()»)
			«ENDIF»
		«ENDIF»
	'''
}

def static String domainObjectBaseAnnotations(DataTransferObject it) {
	'''
		«IF it.isValidationAnnotationToBeGeneratedForObject()»
			«it.getValidationAnnotations()»
		«ENDIF»
		«IF !gapClass && it.isXmlRootToBeGenerated()»
			«xmlRootAnnotation(it)»
		«ENDIF»
		«IF !gapClass && isXstreamAnnotationToBeGenerated()»
			«xstreamAliasAnnotation(it)»
		«ENDIF»
	'''
}

def static String domainObjectBaseAnnotations(DomainObject it) {
	'''
		«IF isJpaAnnotationToBeGenerated() && it.hasOwnDatabaseRepresentation() && (it.getValidationEntityListener() != null || it.getAuditEntityListener() != null)»
		«jpaEntityListenersAnnotation(it)»
		«ENDIF»
		«IF it.isValidationAnnotationToBeGeneratedForObject()»
		«it.getValidationAnnotations()»
		«ENDIF»
		«IF !gapClass && it.isXmlRootToBeGenerated()»
		«xmlRootAnnotation(it)»
		«ENDIF»
		«IF !gapClass && isXstreamAnnotationToBeGenerated()»
		«xstreamAliasAnnotation(it)»
		«ENDIF»
	'''
}

def static String xmlRootAnnotation(DomainObject it) {
	'''
		@javax.xml.bind.annotation.XmlRootElement(name="«it.getXmlRootElementName()»")
	'''
}

def static String xstreamAliasAnnotation(DomainObject it) {
	'''
		@com.thoughtworks.xstream.annotations.XStreamAlias("«it.getXStreamAliasName()»")
	'''
}

/*set EntityListerners for Validation and Audit */
/*TODO: optimize this quick solution */
def static String jpaEntityListenersAnnotation(DomainObject it) {
	'''
		@javax.persistence.EntityListeners({
		«formatAnnotationParameters(<Object>newArrayList(it.getValidationEntityListener() != null && !isJpa2(), "", it.getValidationEntityListener() + ".class",
			it.getAuditEntityListener() != null, "", it.getAuditEntityListener() + ".class"))»})
	'''
}

/*We need to format this carefully beccause it is included in JavaDoc, which is not beautified. */
def static String domainObjectInheritanceAnnotations(DomainObject it) {
	'''
	«IF it.hasSubClass()»
		«IF it.isInheritanceTypeSingleTable()»
			@javax.persistence.Inheritance(strategy=javax.persistence.InheritanceType.SINGLE_TABLE)
			«formatAnnotationParameters("@javax.persistence.DiscriminatorColumn", <Object>newArrayList( inheritance.discriminatorColumnName != null, "name", '"' + inheritance.discriminatorColumnName + '"',
				it.getDiscriminatorType() != "javax.persistence.DiscriminatorType.STRING", "discriminatorType", it.getDiscriminatorType(),
				inheritance.discriminatorColumnLength != null, "length", inheritance.discriminatorColumnLength,
				isJpaAnnotationColumnDefinitionToBeGenerated(), "columnDefinition", '"' + inheritance.getDiscriminatorColumnDatabaseType() + '"'
			)) »
			«IF !^abstract && discriminatorColumnValue != null»
				@javax.persistence.DiscriminatorValue("«discriminatorColumnValue»")
			«ENDIF»
		«ELSEIF it.isInheritanceTypeJoined()»
			@javax.persistence.Inheritance(strategy=javax.persistence.InheritanceType.JOINED)
			«IF !isJpa2() && isJpaProviderEclipseLink()»
				/* EclipseLink needs discriminator */
				@javax.persistence.DiscriminatorColumn(name="DTYPE", discriminatorType=DiscriminatorType.STRING, length=21)
				«IF !^abstract»
				@javax.persistence.DiscriminatorValue("«name»")
				«ENDIF»
			«ENDIF»
		«ENDIF»
	«ENDIF»
	«IF it.hasSuperClass()»
		«IF isInheritanceTypeSingleTable(it.getRootExtends())»
			«IF discriminatorColumnValue != null»
				@javax.persistence.DiscriminatorValue("«discriminatorColumnValue»")
			«ENDIF»
		«ELSEIF isInheritanceTypeJoined(it.getRootExtends())»
			@javax.persistence.PrimaryKeyJoinColumn(name="«^extends.getExtendsForeignKeyName()»")
			«IF isJpaProviderHibernate()»
				@org.hibernate.annotations.ForeignKey(
					name = "FK_«truncateLongDatabaseName(it.getDatabaseName(), ^extends.getDatabaseName())»")
			«ELSEIF !isJpa2() && isJpaProviderEclipseLink()»
				/* EclipseLink needs discriminator */
				@javax.persistence.DiscriminatorValue("«name»")
			«ENDIF»
		«ENDIF»
	«ENDIF»
	'''
}

def static String uniqueConstraints(DomainObject it) {
	'''
	, uniqueConstraints = @javax.persistence.UniqueConstraint(columnNames={«it.getAllNaturalKeys().map[k | uniqueColumns(k,"")].join(", ")»})
	'''
}

def static String uniqueColumns(NamedElement it, String columnPrefix) {
	'''"«getDatabaseName(columnPrefix, it)»"'''
}

def static String uniqueColumns(Reference it, String columnPrefix) {
	'''«IF it.isBasicTypeReference()»
		«to.getAllNaturalKeys().map[k | uniqueColumns(k, getDatabaseName(columnPrefix, it) + "_")].join(", ")»
		«ELSE»"«getDatabaseName(columnPrefix, it)»"«ENDIF»	'''
}

}
