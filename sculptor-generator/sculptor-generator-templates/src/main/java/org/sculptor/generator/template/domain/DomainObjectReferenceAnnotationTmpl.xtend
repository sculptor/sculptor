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
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference
import sculptormetamodel.Attribute
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class DomainObjectReferenceAnnotationTmpl {

	@Inject extension DbHelperBase dbHelperBase
	@Inject extension DbHelper dbHelper
	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def String xmlElementAnnotation(Reference it) {
	'''
		«IF transient»
			@javax.xml.bind.annotation.XmlTransient
		«ELSEIF many»
			@javax.xml.bind.annotation.XmlElementWrapper(name = "«name»")
			@javax.xml.bind.annotation.XmlElement(name = "«name.singular()»")
		«ELSE»
			@javax.xml.bind.annotation.XmlElement(«formatAnnotationParameters(<Object>newArrayList(
				required, "required", "true",
				nullable, "nillable", "true"
			))»)
		«ENDIF»
	'''
}

def String oneReferenceAttributeAnnotations(Reference it) {
	'''
	«IF isJpaAnnotationOnFieldToBeGenerated()»
		«IF isJpaAnnotationToBeGenerated() && from.isPersistent()»
			«oneReferenceJpaAnnotations(it)»
		«ENDIF»
		«IF it.isValidationAnnotationToBeGeneratedForObject()»
			«oneReferenceValidationAnnotations(it)»
		«ENDIF»
	«ENDIF»
	'''
}

def String oneReferenceAppEngineKeyAnnotation(Reference it) {
	'''
		@javax.persistence.Basic
		@javax.persistence.Column(
		«formatAnnotationParameters(<Object>newArrayList(
			true, "name", '"' + it.getDatabaseName() + '"',
			!nullable, "nullable", nullable
		))»)
	'''
}

def String oneReferenceGetterAnnotations(Reference it) {
	'''
	«IF !isJpaAnnotationOnFieldToBeGenerated()»
		«IF isJpaAnnotationToBeGenerated()»
			«oneReferenceJpaAnnotations(it)»
		«ENDIF»
		«IF it.isValidationAnnotationToBeGeneratedForObject()»
			«oneReferenceValidationAnnotations(it)»
		«ENDIF»
	«ENDIF»
	«IF it.isXmlElementToBeGenerated()»
		«xmlElementAnnotation(it)»
	«ENDIF»
	'''
}

def String oneReferenceJpaAnnotations(Reference it) {
	'''
	«IF isJpaAnnotationToBeGenerated() && (from.isPersistent() || (jpa && from.isEmbeddable()))»
		«IF transient»
			@javax.persistence.Transient
		«ELSE»
			«IF it.isBasicTypeReference()»
				«basicTypeJpaAnnotation(it)»
			«ELSEIF it.isEnumReference()»
				«enumJpaAnnotation(it)»
			«ELSE»
				«IF hasOwnDatabaseRepresentation(from) && hasOwnDatabaseRepresentation(to)»
					«IF it.isOneToOne()»
						«oneToOneJpaAnnotation(it)»
					«ELSE»
						«manyToOneJpaAnnotation(it)»
					«ENDIF»
					«oneReferenceOnDeleteJpaAnnotation(it)»
				«ELSE»
					@javax.persistence.Transient
				«ENDIF»
			«ENDIF»
			«IF isJpaProviderHibernate() && cache»
				@org.hibernate.annotations.Cache(usage = «it.getHibernateCacheStrategy()»)
			«ENDIF»
			«IF isJpaProviderHibernate() && it.getHibernateCascadeType() !== null»
				@org.hibernate.annotations.Cascade(«it.getHibernateCascadeType()»)
			«ENDIF»
		«ENDIF»
	«ENDIF»
	'''
}

def String oneReferenceOnDeleteJpaAnnotation(Reference it) {
	'''
		«/* use orphanRemoval in JPA2 */»
	'''
}

def String basicTypeJpaAnnotation(Reference it) {
	'''
		@javax.persistence.Embedded
		«IF isJpaProviderAppEngine() »
			@javax.persistence.OneToOne(fetch = javax.persistence.FetchType.EAGER)
		«ENDIF »
		«IF !useJpaDefaults()»
			@javax.persistence.AttributeOverrides({
				«val elem = <NamedElement>newArrayList()»
				«{
					elem.addAll(to.attributes)
					elem.addAll(to.references.filter(e | e.isBasicTypeReference() || e.isEnumReference()))
					elem.map[e | attributeOverride(e, it.getDatabaseName(), "", nullable)].join(",")
				}»
			})
				«IF it.isAssociationOverrideNeeded()»
					/* TODO: not sufficient if embeddable is used in more than one entity */
					@javax.persistence.AssociationOverrides({
						    «it.to.references.filter(e | !e.isBasicTypeReference() && !e.isEnumReference()).map[e | associationOverride(e, from.getDatabaseName(), nullable)].join(",")»
					})
				«ENDIF»
			«ENDIF»
	'''
}

def String enumJpaAnnotation(Reference it) {
	val ^enum = it.getEnum()
	'''
		@javax.persistence.Column(
			«formatAnnotationParameters(<Object>newArrayList(
				true, "name", '"' + it.getDatabaseName() + '"',
				!nullable, "nullable", false,
				enum.isOfTypeString(), "length", it.getEnumDatabaseLength()
			))»)
		«IF (enum.isOrdinaryEnum())»
			«IF !enum.ordinal»
				@javax.persistence.Enumerated(javax.persistence.EnumType.STRING)
			«ELSE»
				@javax.persistence.Enumerated
			«ENDIF»
		«ELSE»
			@javax.persistence.Convert(converter = «it.enum.domainObjectTypeName»Converter.class)
		«ENDIF»
	'''
}

def String oneToOneJpaAnnotation(Reference it) {
	'''
		@javax.persistence.OneToOne(
			«formatAnnotationParameters(<Object>newArrayList(
				!nullable, "optional", false,
				isRefInverse(), "mappedBy", '"' + opposite.name + '"',
				it.getCascadeType() !== null, "cascade", it.getCascadeType(),
				isOrphanRemoval(it.getCascadeType()), "orphanRemoval", true,
				it.getFetchType() !== null, "fetch", it.getFetchType()
			))»)
		«IF !isRefInverse()»
			@javax.persistence.JoinColumn(
			«formatAnnotationParameters(<Object>newArrayList(
				true, "name", '"' + it.getDatabaseName() + '"',
				!isJpaProviderOpenJpa() && !nullable, "nullable", false,
				it.isSimpleNaturalKey(), "unique", "true",
				true, "foreignKey", "@javax.persistence.ForeignKey(name=\"FK_" + truncateLongDatabaseName(from.getDatabaseName(), it.getDatabaseName()) + "\")"
			))»)
			«IF isJpaProviderHibernate() && it.getHibernateFetchType() !== null»
				@org.hibernate.annotations.Fetch(«it.getHibernateFetchType()»)
			«ENDIF»
		«ENDIF»
	'''
}

def String manyToOneJpaAnnotation(Reference it) {
	'''
		@javax.persistence.ManyToOne(
		«formatAnnotationParameters(<Object>newArrayList(
			!nullable, "optional", false,
			it.getCascadeType() !== null, "cascade", it.getCascadeType(),
			it.getFetchType() !== null, "fetch", it.getFetchType()
		))»)
		«IF !it.hasOpposite() || !opposite.isList()»
			@javax.persistence.JoinColumn(«formatAnnotationParameters(<Object>newArrayList(
				true, "name", '"' + it.getDatabaseName() + '"',
				!isJpaProviderOpenJpa() && !nullable, "nullable", false,
				it.isSimpleNaturalKey(), "unique", "true",
				true, "foreignKey", "@javax.persistence.ForeignKey(name=\"FK_" + truncateLongDatabaseName(from.isEmbeddable() ? from.name.toUpperCase() : from.getDatabaseName(), it.getDatabaseName()) + "\")"
			))»)
			«IF isJpaProviderHibernate() && it.getHibernateFetchType() !== null»
				@org.hibernate.annotations.Fetch(«it.getHibernateFetchType()»)
			«ENDIF»
		«ENDIF»
	'''
}

def String oneReferenceValidationAnnotations(Reference it) {
	'''
		«it.getValidationAnnotations()»
	'''
}

def dispatch String attributeOverride(Object it, String columnPrefix, String attributePrefix, boolean referenceIsNullable) {
	'''
	'''
}

def dispatch String attributeOverride(Attribute it, String columnPrefix, String attributePrefix, boolean referenceIsNullable) {
	'''
		@javax.persistence.AttributeOverride(
			name="«attributePrefix + name»",
			column = @javax.persistence.Column(
			«formatAnnotationParameters(<Object>newArrayList(
				true, "name", '"' + getDatabaseName(columnPrefix, it) + '"',
				!(referenceIsNullable || (!referenceIsNullable && nullable)), "nullable", false,
				it.getDatabaseLength() !== null, "length", it.getDatabaseLength()
			))»))
	'''
}

def dispatch String attributeOverride(Reference it, String columnPrefix, String attributePrefix, boolean referenceIsNullable) {
	'''
		«IF it.isBasicTypeReference()»
			«it.to.attributes.map[a | attributeOverride(a, getDatabaseName(columnPrefix, it), name + ".", it.nullable)].join(",")»
		«ELSEIF it.isEnumReference()»
			«val ^enum = it.getEnum()»
			@javax.persistence.AttributeOverride(
				name="«name»",
				column = @javax.persistence.Column(
				«formatAnnotationParameters(<Object>newArrayList(
					true, "name", '"' + getDatabaseName(columnPrefix, it) + '"',
					!referenceIsNullable, "nullable", false,
					!enum.ordinal, "length", it.getEnumDatabaseLength()
				))»))
		«ENDIF»
	'''
}

def String associationOverride(Reference it, String prefix, boolean referenceIsNullable) {
	'''
		«/* TODO: verify the table and column naming */»
		«IF many»
			@javax.persistence.AssociationOverride(
				name="«name»",
				joinTable = @javax.persistence.JoinTable(
					name="«getDatabaseName(prefix + "_" + from.getDatabaseName(), to)»",
					joinColumns= @javax.persistence.JoinColumn(name = "«prefix»")
					«IF isRefInverse()»
						, inverseJoinColumns= @javax.persistence.JoinColumn(name = "«to.getDatabaseName()»")
					«ENDIF»
			))
		«ELSE»
			@javax.persistence.AssociationOverride(
				name="«name»",
				joinColumns = @javax.persistence.JoinColumn(
					name="«getDatabaseName(from.getDatabaseName(), to)»",
					nullable=true
			))
		«ENDIF»
	'''
}

def String oneReferenceSetterAnnotations(Reference it) {
	'''
	'''
}

def String manyReferenceAttributeAnnotations(Reference it) {
	'''
		«IF isJpaAnnotationOnFieldToBeGenerated()»
			«IF isJpaAnnotationToBeGenerated()»
				«manyReferenceJpaAnnotations(it)»
			«ENDIF»
			«IF it.isValidationAnnotationToBeGeneratedForObject()»
				«manyReferenceValidationAnnotations(it)»
			«ENDIF»
		«ENDIF»
	'''
}

def String manyReferenceGetterAnnotations(Reference it) {
	'''
		«IF !isJpaAnnotationOnFieldToBeGenerated()»
			«IF isJpaAnnotationToBeGenerated()»
				«manyReferenceJpaAnnotations(it)»
			«ENDIF»
			«IF it.isValidationAnnotationToBeGeneratedForObject()»
				«manyReferenceValidationAnnotations(it)»
			«ENDIF»
		«ENDIF»
		«IF it.isXmlElementToBeGenerated()»
			«xmlElementAnnotation(it)»
		«ENDIF»
	'''
}

def String manyReferenceAppEngineKeyAnnotation(Reference it) {
	'''
		@javax.persistence.Column(
			«formatAnnotationParameters(<Object>newArrayList(
				true, "name", '"' + it.getDatabaseName() + '"',
				!nullable, "nullable", nullable
			))»)
	'''
}

def String manyReferenceJpaAnnotations(Reference it) {
	'''
	«IF isJpaAnnotationToBeGenerated() && from.isPersistent()»
		«IF !transient»
			«IF (hasOwnDatabaseRepresentation(from) && hasOwnDatabaseRepresentation(to)) || (jpa && hasOwnDatabaseRepresentation(to) && from.isEmbeddable())»
				«IF it.isOneToMany()»
					«oneToManyJpaAnnotation(it)»
				«ENDIF»
				«IF it.isManyToMany()»
					«manyToManyJpaAnnotation(it)»
				«ENDIF»
				«IF it.isList() && it.hasHint("orderColumn")»
					@javax.persistence.OrderColumn(name="«it.getListIndexColumnName()»")
				«ENDIF»
				«IF orderBy !== null»
					@javax.persistence.OrderBy("«orderBy»")
				«ENDIF»
				«IF isJpaProviderHibernate() && cache»
					@org.hibernate.annotations.Cache(usage = «it.getHibernateCacheStrategy()»)
				«ENDIF»
				«IF isJpaProviderHibernate() && it.getHibernateFetchType() !== null»
					@org.hibernate.annotations.Fetch(«it.getHibernateFetchType()»)
				«ENDIF»
				«IF isJpaProviderHibernate() && it.getHibernateCascadeType() !== null»
					@org.hibernate.annotations.Cascade(«it.getHibernateCascadeType()»)
				«ENDIF»
			«ELSEIF ((hasOwnDatabaseRepresentation(from) && to.isEmbeddable()) ||
				(from.isEmbeddable() && to.isEmbeddable()))»
				«elementCollectionJpaAnnotation(it)»
			«ENDIF»
		«ELSE»
			@javax.persistence.Transient
		«ENDIF»
	«ENDIF»
	'''
}

def String oneToManyJpaAnnotation(Reference it) {
	val isMappedBy = it.hasOpposite() && (getRefCollectionType() != "list")
	'''
		@javax.persistence.OneToMany(
			«formatAnnotationParameters(<Object>newArrayList(
				it.getCascadeType() !== null, "cascade", it.getCascadeType(),
				isOrphanRemoval(it.getCascadeType(), it), "orphanRemoval", true,
				isMappedBy, "mappedBy", '"' + opposite?.name + '"',
				it.getFetchType() !== null, "fetch", it.getFetchType()
			))»)
		«IF !isMappedBy»
			«IF !isRefInverse()»
				@javax.persistence.JoinColumn(
					name="«it.getOppositeForeignKeyName()»",
					foreignKey=@javax.persistence.ForeignKey(
						name="FK_«truncateLongDatabaseName(it.getManyToManyJoinTableName(), it.getOppositeForeignKeyName())»"))
			«ENDIF»
			«/* TODO: add support for unidirectional onetomany relationships with and without jointable */»
			«/*
			«IF !it.isUnidirectionalToManyWithoutJoinTable()»
				@javax.persistence.JoinTable(
					name="«it.getManyToManyJoinTableName()»",
					joinColumns=@javax.persistence.JoinColumn(name="«it.getOppositeForeignKeyName()»"),
					inverseJoinColumns=@javax.persistence.JoinColumn(name="«it.getForeignKeyName()»"))
			«ENDIF»
			 */»
			«IF isRefInverse() && (!it.hasOpposite() || it.isList())»
				@javax.persistence.JoinColumn(
					name="«it.getOppositeForeignKeyName()»",
					foreignKey=@javax.persistence.ForeignKey(
						name="FK_«truncateLongDatabaseName(from.getDatabaseName(), to.getDatabaseName())»"))
			«ENDIF»
		«ENDIF»
	'''
}

def String elementCollectionJpaAnnotation(Reference it) {
	'''
		/* nested element collections are not allowed by jpa, some provider may support this, we not */
		/* TODO: add a constraint for to avoid nested element collections */
			@javax.persistence.ElementCollection(
				«formatAnnotationParameters(<Object>newArrayList(
					it.getFetchType() !== null, "fetch", it.getFetchType()
				))»)
	'''
}

def String elementCollectionTableJpaAnnotation(Reference it) {
	'''
		/* It's not possible to overwrite the collection table later, therefore we can not use it here */
		/*
			@javax.persistence.CollectionTable(
				name="«it.getElementCollectionTableName()»",
				joinColumns=@javax.persistence.JoinColumn(name="«it.getOppositeForeignKeyName()»"))
		*/
	'''
}

def String manyToManyJpaAnnotation(Reference it) {
	'''
		@javax.persistence.ManyToMany(
			«formatAnnotationParameters(<Object>newArrayList(
				it.getCascadeType() !== null, "cascade", it.getCascadeType(),
				isRefInverse(), "mappedBy", '"' + opposite?.name + '"',
				it.getFetchType() !== null, "fetch", it.getFetchType()
			))»)
		«IF !isRefInverse()»
			@javax.persistence.JoinTable(
				name="«it.getManyToManyJoinTableName()»",
				joinColumns=@javax.persistence.JoinColumn(
					name="«it.getOppositeForeignKeyName()»",
					foreignKey=@javax.persistence.ForeignKey(
						name="FK_«truncateLongDatabaseName(it.getManyToManyJoinTableName(), it.getOppositeForeignKeyName())»")),
				inverseJoinColumns=@javax.persistence.JoinColumn(
					name="«it.getForeignKeyName()»",
					foreignKey=@javax.persistence.ForeignKey(
						name="FK_«truncateLongDatabaseName(it.getManyToManyJoinTableName(), it.getForeignKeyName())»")))
		«ENDIF»
	'''
}

def String manyReferenceValidationAnnotations(Reference it) {
	'''
		«it.getValidationAnnotations()»
	'''
}
}
