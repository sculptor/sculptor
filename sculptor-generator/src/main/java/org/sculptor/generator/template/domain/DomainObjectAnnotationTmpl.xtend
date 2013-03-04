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

class DomainObjectAnnotationTmpl {

def static String domainObjectSubclassAnnotations(DataTransferObject it) {
	'''
	«IF isXmlRootToBeGenerated()»
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
	«IF isXmlRootToBeGenerated()»
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
	«IF isEmbeddable() »
	@javax.persistence.Embeddable
	«ENDIF»
	«IF hasOwnDatabaseRepresentation()»
	@javax.persistence.Entity
		«IF !isInheritanceTypeSingleTable(getRootExtends()) || this == getRootExtends()»
	@javax.persistence.Table(name = "«getDatabaseName()»"« IF hasClassLevelUniqueConstraints() »«uniqueConstraints(it)»«ENDIF»)
		«ENDIF»
		«domainObjectInheritanceAnnotations(it)»
		«IF isJpa2() && cache»
	@javax.persistence.Cacheable
		«ENDIF»
		«IF isJpaProviderHibernate() && cache»
	@org.hibernate.annotations.Cache(usage = «getHibernateCacheStrategy()»)
		«ENDIF»
	«ENDIF»
	'''
}

def static String domainObjectBaseAnnotations(DataTransferObject it) {
	'''
 	«IF isValidationAnnotationToBeGeneratedForObject()»
 		«getValidationAnnotations()»
	«ENDIF»
	«IF !gapClass && isXmlRootToBeGenerated()»
		«xmlRootAnnotation(it)»
	«ENDIF»
	«IF !gapClass && isXstreamAnnotationToBeGenerated()»
		«xstreamAliasAnnotation(it)»
	«ENDIF»
	'''
}

def static String domainObjectBaseAnnotations(DomainObject it) {
	'''
	«IF isJpaAnnotationToBeGenerated() && hasOwnDatabaseRepresentation() && (getValidationEntityListener() != null || getAuditEntityListener() != null)»
	«jpaEntityListenersAnnotation(it) FOR this»
	«ENDIF»
	«IF isValidationAnnotationToBeGeneratedForObject()»
	«getValidationAnnotations()»
	«ENDIF»
	«IF !gapClass && isXmlRootToBeGenerated()»
	«xmlRootAnnotation(it)»
	«ENDIF»
	«IF !gapClass && isXstreamAnnotationToBeGenerated()»
	«xstreamAliasAnnotation(it)»
	«ENDIF»
	'''
}

def static String xmlRootAnnotation(DomainObject it) {
	'''
	@javax.xml.bind.annotation.XmlRootElement(name="«getXmlRootElementName()»")
	'''
}

def static String xstreamAliasAnnotation(DomainObject it) {
	'''
	@com.thoughtworks.xstream.annotations.XStreamAlias("«getXStreamAliasName()»")
	'''
}

/*set EntityListerners for Validation and Audit */
/*TODO: optimize this quick solution */
def static String jpaEntityListenersAnnotation(DomainObject it) {
	'''
	@javax.persistence.EntityListeners({
	«formatAnnotationParameters({ getValidationEntityListener() != null && !isJpa2(), "", getValidationEntityListener() + ".class",
		getAuditEntityListener() != null, "", getAuditEntityListener() + ".class"
	})»})
	'''
}

/*We need to format this carefully beccause it is included in JavaDoc, which is not beautified. */
def static String domainObjectInheritanceAnnotations(DomainObject it) {
	'''
	«IF hasSubClass()»
		«IF isInheritanceTypeSingleTable()»
	@javax.persistence.Inheritance(strategy=javax.persistence.InheritanceType.SINGLE_TABLE)
	«formatAnnotationParameters("@javax.persistence.DiscriminatorColumn", { inheritance.discriminatorColumnName != null, "name", '"' + inheritance.discriminatorColumnName + '"',
	getDiscriminatorType() != "javax.persistence.DiscriminatorType.STRING", "discriminatorType", getDiscriminatorType(),
	inheritance.discriminatorColumnLength != null, "length", inheritance.discriminatorColumnLength,
	isJpaAnnotationColumnDefinitionToBeGenerated(), "columnDefinition", '"' + inheritance.getDiscriminatorColumnDatabaseType() + '"'
		}) »
			«IF !^abstract && discriminatorColumnValue != null»
	@javax.persistence.DiscriminatorValue("«discriminatorColumnValue»")
			«ENDIF»
		«ELSEIF isInheritanceTypeJoined()»
	@javax.persistence.Inheritance(strategy=javax.persistence.InheritanceType.JOINED)
	«IF !isJpa2() && isJpaProviderEclipseLink()»
/*EclipseLink needs discriminator */
	@javax.persistence.DiscriminatorColumn(name="DTYPE", discriminatorType=DiscriminatorType.STRING, length=21)
	«IF !^abstract»
	@javax.persistence.DiscriminatorValue("«name»")
	«ENDIF»
	«ENDIF»
		«ENDIF»
	«ENDIF»
	«IF hasSuperClass()»
		«IF isInheritanceTypeSingleTable(getRootExtends())»
			«IF discriminatorColumnValue != null»
	@javax.persistence.DiscriminatorValue("«discriminatorColumnValue»")
			«ENDIF»
		«ELSEIF isInheritanceTypeJoined(getRootExtends())»
	@javax.persistence.PrimaryKeyJoinColumn(name="«^extends.getExtendsForeignKeyName()»")
			«IF isJpaProviderHibernate()»
	@org.hibernate.annotations.ForeignKey(
		name = "FK_«truncateLongDatabaseName(getDatabaseName(), ^extends.getDatabaseName())»")
			«ELSEIF !isJpa2() && isJpaProviderEclipseLink()»
/*EclipseLink needs discriminator */
	@javax.persistence.DiscriminatorValue("«name»")
			«ENDIF»
		«ENDIF»
	«ENDIF»
	'''
}

def static String uniqueConstraints(DomainObject it) {
	'''
	, uniqueConstraints = @javax.persistence.UniqueConstraint(columnNames={«it.getAllNaturalKeys() SEPARATOR ", " .forEach[ uniqueColumns(it)("")]»})«
	ENDDEFINE»

def static String uniqueColumns(NamedElement it, String columnPrefix) {
	'''"«getDatabaseName(columnPrefix, this)»"«
	ENDDEFINE»

def static String uniqueColumns(Reference it, String columnPrefix) {
	'''« IF isBasicTypeReference() »«
		uniqueColumns(it)(getDatabaseName(columnPrefix, this) + "_") FOREACH to.getAllNaturalKeys() SEPARATOR ", " »« ELSE»"«getDatabaseName(columnPrefix, this)»"«
	ENDIF »	'''
}







}
