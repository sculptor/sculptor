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

class DomainObjectReferenceAnnotationTmpl {

def static String xmlElementAnnotation(Reference it) {
	'''
	«IF transient»
	    @javax.xml.bind.annotation.XmlTransient
	«ELSEIF many»
		@javax.xml.bind.annotation.XmlElementWrapper(name = "«name»")
		@javax.xml.bind.annotation.XmlElement(name = "«name.singular()»")
	«ELSE»
	    @javax.xml.bind.annotation.XmlElement(«formatAnnotationParameters({ required, "required", "true",
		    		nullable, "nillable", "true"
		    	})»)
	«ENDIF»
	'''
}

def static String oneReferenceAttributeAnnotations(Reference it) {
	'''
	«IF isJpaAnnotationOnFieldToBeGenerated()»
		«IF isJpaAnnotationToBeGenerated() && from.isPersistent()»
			«oneReferenceJpaAnnotations(it)»
		«ENDIF»
		«IF isValidationAnnotationToBeGeneratedForObject()»
			«oneReferenceValidationAnnotations(it)»
		«ENDIF»
		«ENDIF»
	'''
}

def static String oneReferenceAppEngineKeyAnnotation(Reference it) {
	'''
		@javax.persistence.Basic
		@javax.persistence.Column(
	    	«formatAnnotationParameters({ true, "name", '"' + getDatabaseName() + '"',
	    		!nullable, "nullable", nullable
	    	})»)
	'''
}

def static String oneReferenceGetterAnnotations(Reference it) {
	'''
	«IF !isJpaAnnotationOnFieldToBeGenerated()»
		«IF isJpaAnnotationToBeGenerated()»
			«oneReferenceJpaAnnotations(it)»
		«ENDIF»
		«IF isValidationAnnotationToBeGeneratedForObject()»
			«oneReferenceValidationAnnotations(it)»
		«ENDIF»
		«ENDIF»
		«IF isXmlElementToBeGenerated()»
		«xmlElementAnnotation(it)»
	«ENDIF»
	'''
}

def static String oneReferenceJpaAnnotations(Reference it) {
	'''
	«IF isJpaAnnotationToBeGenerated() && (from.isPersistent() || (isJpa2() && from.isEmbeddable()))»
		«IF transient»
			@javax.persistence.Transient
		«ELSE»
			«IF isBasicTypeReference()»
			    «basicTypeJpaAnnotation(it)»
			«ELSEIF isEnumReference()»
			    «enumJpaAnnotation(it)»
			«ELSE»
				«IF isJpa2() || (hasOwnDatabaseRepresentation(from) && hasOwnDatabaseRepresentation(to))»
					«IF isOneToOne()»
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
				@org.hibernate.annotations.Cache(usage = «getHibernateCacheStrategy()»)
			«ENDIF»
			«IF isJpaProviderHibernate() && getHibernateCascadeType() != null»
				@org.hibernate.annotations.Cascade(«getHibernateCascadeType()»)
			«ENDIF»
		«ENDIF»
	«ENDIF»
	'''
}

def static String oneReferenceOnDeleteJpaAnnotation(Reference it) {
	'''
	/*use orphanRemoval in JPA2 */
	«IF isJpa1() && isJpaProviderHibernate() && hasOpposite() && isDbOnDeleteCascade(opposite)»
	@org.hibernate.annotations.OnDelete(action = org.hibernate.annotations.OnDeleteAction.CASCADE)
	«ENDIF»
	'''
}

def static String basicTypeJpaAnnotation(Reference it) {
	'''
	    @javax.persistence.Embedded
	    «IF isJpaProviderAppEngine() »
	    @javax.persistence.OneToOne(fetch = javax.persistence.FetchType.EAGER)
	    «ENDIF »
			«IF !useJpaDefaults()»
	    @javax.persistence.AttributeOverrides({
				«it.{}.addAll(to.attributes).addAll(to.references.filter(e | e.isBasicTypeReference() || e.isEnumReference())) SEPARATOR ",".forEach[attributeOverride(it)(getDatabaseName(), "", nullable)]»
			})
				«IF isJpa2() && isAssociationOverrideNeeded()»
				/*TODO: not sufficient if embeddable is used in more than one entity */
			@javax.persistence.AssociationOverrides({
				    «it.to.references.filter(e | !e.isBasicTypeReference() && !e.isEnumReference()) SEPARATOR ",".forEach[associationOverride(it)(from.getDatabaseName(), nullable)]»
			})
			   «ENDIF»
			«ENDIF»
	'''
}

def static String enumJpaAnnotation(Reference it) {
	'''
		«val enum = it.getEnum()»
			@javax.persistence.Column(
				«formatAnnotationParameters({ true, "name", '"' + getDatabaseName() + '"',
				    !nullable, "nullable", false,
				    enum.isOfTypeString(), "length", getEnumDatabaseLength()
				})»)
	    «IF (enum.isOrdinaryEnum())»
				«IF !enum.ordinal»
				@javax.persistence.Enumerated(javax.persistence.EnumType.STRING)
				«ELSE»
				@javax.persistence.Enumerated
				«ENDIF»
	    «ELSE»
				«nonOrdinaryEnumTypeAnnotation(it)»
	    «ENDIF»
	'''
}

def static String nonOrdinaryEnumTypeAnnotation(Reference it) {
	'''
		«val enum = it.getEnum()»
			«IF isJpaProviderHibernate()»
				«hibernateEnumTypeAnnotation(it)»
			«ELSEIF isJpaProviderEclipseLink()»
				@org.eclipse.persistence.annotations.Convert("EnumConverter")
			«ELSEIF isJpaProviderOpenJpa()»
				@org.apache.openjpa.persistence.jdbc.Strategy("«getApplicationBasePackage()».util.EnumHandler")
			«ENDIF»
	'''
}

def static String hibernateEnumTypeAnnotation(Reference it) {
	'''
		«val enum = it.getEnum()»
		«IF isJpa1()»
			@org.hibernate.annotations.Type(type="«enum.name»")
		«ELSE»
			«val INTEGER = it.4»
			@org.hibernate.annotations.Type(
			type="«getApplicationBasePackage()».util.EnumUserType",
			parameters = {
				@org.hibernate.annotations.Parameter(name = "enumClass", value = "«enum.getDomainObjectTypeName()»")
				«IF (!enum.isOfTypeString())»
				, @org.hibernate.annotations.Parameter(name = "type", value = "«INTEGER»")
				«ENDIF»
				})
		«ENDIF»
	'''
}

def static String oneToOneJpaAnnotation(Reference it) {
	'''
		@javax.persistence.OneToOne(
			«formatAnnotationParameters({ !nullable, "optional", false,
				isInverse(), "mappedBy", '"' + opposite.name + '"',
				getCascadeType() != null, "cascade", getCascadeType(),
				isOrphanRemoval(getCascadeType()), "orphanRemoval", true,
				getFetchType() != null, "fetch", getFetchType()
			})»)
	«IF !isInverse()»
	    @javax.persistence.JoinColumn(
	    	«formatAnnotationParameters({ true, "name", '"' + getDatabaseName() + '"',
				    !isJpaProviderOpenJpa() && !nullable, "nullable", false,
		    	isSimpleNaturalKey() && (isJpa2() || isJpaProviderHibernate()), "unique", "true"
		    	})»)
		«IF isJpaProviderHibernate()»
		@org.hibernate.annotations.ForeignKey(name = "FK_«truncateLongDatabaseName(from.getDatabaseName(), getDatabaseName())»")
				«IF getHibernateFetchType() != null»
				@org.hibernate.annotations.Fetch(«getHibernateFetchType()»)
				«ENDIF»
		«ENDIF»
	«ENDIF»
	'''
}

def static String manyToOneJpaAnnotation(Reference it) {
	'''
	    @javax.persistence.ManyToOne(
			«formatAnnotationParameters({ !nullable, "optional", false,
				getCascadeType() != null, "cascade", getCascadeType(),
				getFetchType() != null, "fetch", getFetchType()
			})»)
	«IF !hasOpposite() || !opposite.isList()»
	    @javax.persistence.JoinColumn(«formatAnnotationParameters({ true, "name", '"' + getDatabaseName() + '"',
				    !isJpaProviderOpenJpa() && !nullable, "nullable", false,
		    	isSimpleNaturalKey() && (isJpa2() || isJpaProviderHibernate()), "unique", "true"
		    	})»)
		«IF isJpaProviderHibernate()»
			/*TODO: set databasename for embeddables (basictype) to avoid this case handling ? */
		  «IF isJpa2() && from.isEmbeddable()»
			@org.hibernate.annotations.ForeignKey(name = "FK_«truncateLongDatabaseName(from.name.toUpperCase(), getDatabaseName())»")
		  «ELSE»
			@org.hibernate.annotations.ForeignKey(name = "FK_«truncateLongDatabaseName(from.getDatabaseName(), getDatabaseName())»")
		  «ENDIF»
				«IF getHibernateFetchType() != null»
				@org.hibernate.annotations.Fetch(«getHibernateFetchType()»)
				«ENDIF»
			«ELSEIF isJpaProviderOpenJpa()»
			/*OpenJPA delete parent/child in an incorrect order */
			/*TODO: watch issue OPENJPA-1936 */
				«IF isJpa2() && from.isEmbeddable()»
			@org.apache.openjpa.persistence.jdbc.ForeignKey(
				name = "FK_«truncateLongDatabaseName(from.name.toUpperCase(), getDatabaseName())»",
				deleteAction=org.apache.openjpa.persistence.jdbc.ForeignKeyAction.NULL)
				«ELSE»
			@org.apache.openjpa.persistence.jdbc.ForeignKey(
				name = "FK_«truncateLongDatabaseName(from.getDatabaseName(), getDatabaseName())»",
				deleteAction=org.apache.openjpa.persistence.jdbc.ForeignKeyAction.NULL)
				«ENDIF»
			«ENDIF»
	«ENDIF»
	'''
}

def static String oneReferenceValidationAnnotations(Reference it) {
	'''
	«getValidationAnnotations()»
	'''
}

def static String attributeOverride(Object it, String columnPrefix, String attributePrefix, boolean referenceIsNullable) {
	'''
	'''
}

def static String attributeOverride(Attribute it, String columnPrefix, String attributePrefix, boolean referenceIsNullable) {
	'''
		@javax.persistence.AttributeOverride(
			name="«attributePrefix + name»",
			column = @javax.persistence.Column(
				«formatAnnotationParameters({ true, "name", '"' + getDatabaseName(columnPrefix, this) + '"',
				    !(referenceIsNullable || (!referenceIsNullable && nullable)), "nullable", false,
				    getDatabaseLength() != null, "length", getDatabaseLength()
				})»))
	'''
}

def static String attributeOverride(Reference it, String columnPrefix, String attributePrefix, boolean referenceIsNullable) {
	'''
		«IF isBasicTypeReference()»
			«it.to.attributes SEPARATOR ",".forEach[attributeOverride(it)(getDatabaseName(columnPrefix, this), name + ".", this.nullable)]»
		«ELSEIF isEnumReference()»
		«val enum = it.getEnum()»
			@javax.persistence.AttributeOverride(
				name="«name»",
				column = @javax.persistence.Column(
				«formatAnnotationParameters({ true, "name", '"' + getDatabaseName(columnPrefix, this) + '"',
				    !referenceIsNullable, "nullable", false,
				    !enum.ordinal, "length", getEnumDatabaseLength()
				})»))
		«ENDIF»
	'''
}

def static String associationOverride(Reference it, String prefix, boolean referenceIsNullable) {
	'''
		/*TODO: verify the table and column naming */
		«IF many»
			@javax.persistence.AssociationOverride(
				name="«name»",
				joinTable = @javax.persistence.JoinTable(
				    name="«getDatabaseName(prefix + "_" + from.getDatabaseName(), to)»",
				    joinColumns= @javax.persistence.JoinColumn(name = "«prefix»")
				    «IF isInverse()»
				    , inverseJoinColumns= @javax.persistence.JoinColumn(name = "«to.getDatabaseName()»")
				    «ENDIF»
				    ))
		«ELSE»
			@javax.persistence.AssociationOverride(
				name="«name»",
				joinColumns = @javax.persistence.JoinColumn(
				    name="«getDatabaseName(from.getDatabaseName(), to)»",
				    nullable=true))
		«ENDIF»
	'''
}

def static String oneReferenceSetterAnnotations(Reference it) {
	'''
	'''
}

def static String manyReferenceAttributeAnnotations(Reference it) {
	'''
	«IF isJpaAnnotationOnFieldToBeGenerated()»
	    «IF isJpaAnnotationToBeGenerated()»
		    «manyReferenceJpaAnnotations(it)»
	    «ENDIF»
	    «IF isValidationAnnotationToBeGeneratedForObject()»
		    «manyReferenceValidationAnnotations(it)»
	    «ENDIF»
	«ENDIF»
	'''
}

def static String manyReferenceGetterAnnotations(Reference it) {
	'''
	«IF !isJpaAnnotationOnFieldToBeGenerated()»
	    «IF isJpaAnnotationToBeGenerated()»
		    «manyReferenceJpaAnnotations(it)»
	    «ENDIF»
	    «IF isValidationAnnotationToBeGeneratedForObject()»
		    «manyReferenceValidationAnnotations(it)»
	    «ENDIF»
	«ENDIF»
	«IF isXmlElementToBeGenerated()»
			«xmlElementAnnotation(it)»
		«ENDIF»
	'''
}

def static String manyReferenceAppEngineKeyAnnotation(Reference it) {
	'''
		@javax.persistence.Column(
	    	«formatAnnotationParameters({ true, "name", '"' + getDatabaseName() + '"',
	    		!nullable, "nullable", nullable
	    	})»)
	'''
}

def static String manyReferenceJpaAnnotations(Reference it) {
	'''
	«IF isJpaAnnotationToBeGenerated() && from.isPersistent()»
		«IF !transient»
		  «IF (hasOwnDatabaseRepresentation(from) && hasOwnDatabaseRepresentation(to)) || (isJpa2() && hasOwnDatabaseRepresentation(to) && from.isEmbeddable())»
			«IF isOneToMany()»
				«oneToManyJpaAnnotation(it)»
			«ENDIF»
			«IF isManyToMany()»
				«manyToManyJpaAnnotation(it)»
			«ENDIF»
				«IF isJpa2() && isList() && hasHint("orderColumn")»
				    @javax.persistence.OrderColumn(name="«getListIndexColumnName()»")
				«ENDIF»
			«IF orderBy != null»
				@javax.persistence.OrderBy("«orderBy»")
			«ENDIF»
			«IF isJpaProviderHibernate() && cache»
				@org.hibernate.annotations.Cache(usage = «getHibernateCacheStrategy()»)
			«ENDIF»
			«IF isJpaProviderHibernate() && getHibernateFetchType() != null»
				@org.hibernate.annotations.Fetch(«getHibernateFetchType()»)
			«ENDIF»
			«IF isJpaProviderHibernate() && getHibernateCascadeType() != null»
				@org.hibernate.annotations.Cascade(«getHibernateCascadeType()»)
			«ENDIF»
				«ELSEIF isJpa2() && ((hasOwnDatabaseRepresentation(from) && to.isEmbeddable()) ||
				        (from.isEmbeddable() && to.isEmbeddable()))»
				    «elementCollectionJpaAnnotation(it)»
				«ENDIF»
		«ELSE»
			@javax.persistence.Transient
		«ENDIF»
	«ENDIF»
	'''
}

def static String oneToManyJpaAnnotation(Reference it) {
	'''
		@javax.persistence.OneToMany(
			«formatAnnotationParameters({ getCascadeType() != null, "cascade", getCascadeType(),
				isOrphanRemoval(getCascadeType(), this), "orphanRemoval", true,
				hasOpposite() && (getCollectionType() != "list"), "mappedBy", '"' + opposite.name + '"',
				getFetchType() != null, "fetch", getFetchType()
			})»)
	«IF isJpaProviderHibernate() && !isInverse()»
		@org.hibernate.annotations.ForeignKey(
			name = "FK_«truncateLongDatabaseName(getManyToManyJoinTableName(), getOppositeForeignKeyName())»"
			, inverseName = "FK_«truncateLongDatabaseName(getManyToManyJoinTableName(), getForeignKeyName())»")
	«ENDIF»
	/*TODO: add support for unidirectional onetomany relationships with and without jointable */
	/*
	«IF !isUnidirectionalToManyWithoutJoinTable() && isJpa2()»
		@javax.persistence.JoinTable(
			name = "«getManyToManyJoinTableName()»",
			joinColumns = @javax.persistence.JoinColumn(name = "«getOppositeForeignKeyName()»"),
			inverseJoinColumns = @javax.persistence.JoinColumn(name = "«getForeignKeyName()»"))
	«ENDIF»
	 */
	«IF isInverse() && (!hasOpposite() || isList())»
		@javax.persistence.JoinColumn(name = "«getOppositeForeignKeyName()»")
			«IF isJpaProviderHibernate()»
		@org.hibernate.annotations.ForeignKey(name = "FK_«truncateLongDatabaseName(from.getDatabaseName(), to.getDatabaseName())»")
			«ENDIF »
	«ENDIF»
		«IF isJpa1() && isList() && isJpaProviderHibernate()»
	    @org.hibernate.annotations.IndexColumn(name="«getListIndexColumnName()»")
	«ENDIF »
		«IF isJpa1() && isJpaProviderEclipseLink() && !to.isAggregateRoot()»
	    @org.eclipse.persistence.annotations.PrivateOwned
	«ENDIF»
	'''
}

def static String elementCollectionJpaAnnotation(Reference it) {
	'''
		/*nested element collections are not allowed by jpa, some provider may support this, we not */
		/*TODO: add a constraint for to avoid nested element collections */
			@javax.persistence.ElementCollection(
				«formatAnnotationParameters({ getFetchType() != null, "fetch", getFetchType()
				})»)
	'''
}

def static String elementCollectionTableJpaAnnotation(Reference it) {
	'''
		/*It's not possible to overwrite the collection table later, therefore we can not use it here */
		/*
			@javax.persistence.CollectionTable(
				name="«getElementCollectionTableName()»",
				joinColumns = @javax.persistence.JoinColumn(name = "«getOppositeForeignKeyName()»"))
			*/
	'''
}

def static String manyToManyJpaAnnotation(Reference it) {
	'''
		@javax.persistence.ManyToMany(
			«formatAnnotationParameters({ getCascadeType() != null, "cascade", getCascadeType(),
				isInverse(), "mappedBy", '"' + opposite.name + '"',
				getFetchType() != null, "fetch", getFetchType()
			})»)
	«IF !isInverse()»
		@javax.persistence.JoinTable(
			name = "«getManyToManyJoinTableName()»",
			joinColumns = @javax.persistence.JoinColumn(name = "«getOppositeForeignKeyName()»"),
			inverseJoinColumns = @javax.persistence.JoinColumn(name = "«getForeignKeyName()»"))
			«IF isJpaProviderHibernate()»
		@org.hibernate.annotations.ForeignKey(
			name = "FK_«truncateLongDatabaseName(getManyToManyJoinTableName(), getOppositeForeignKeyName())»",
			inverseName = "FK_«truncateLongDatabaseName(getManyToManyJoinTableName(), getForeignKeyName())»")
			«ENDIF »
	«ENDIF»
	'''
}

def static String manyReferenceValidationAnnotations(Reference it) {
	'''
	«getValidationAnnotations()»
	'''
}
}
