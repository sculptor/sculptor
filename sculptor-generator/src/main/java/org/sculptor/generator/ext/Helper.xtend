/*
 * Copyright 2007 The Fornax Project Team, including the original
 * author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *			http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sculptor.generator.ext

import java.util.Collection
import java.util.List
import org.sculptor.generator.util.DependencyConstraints
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.BasicType
import sculptormetamodel.CommandEvent
import sculptormetamodel.Consumer
import sculptormetamodel.DataTransferObject
import sculptormetamodel.DomainEvent
import sculptormetamodel.DomainObject
import sculptormetamodel.Entity
import sculptormetamodel.Enum
import sculptormetamodel.Module
import sculptormetamodel.NamedElement
import sculptormetamodel.Operation
import sculptormetamodel.Parameter
import sculptormetamodel.Reference
import sculptormetamodel.Repository
import sculptormetamodel.RepositoryOperation
import sculptormetamodel.Resource
import sculptormetamodel.Service
import sculptormetamodel.ServiceOperation
import sculptormetamodel.Trait
import sculptormetamodel.TypedElement
import sculptormetamodel.ValueObject

import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*
import org.sculptor.generator.util.SingularPluralConverter
import sculptormetamodel.DomainObjectOperation
import sculptormetamodel.ResourceOperation
import sculptormetamodel.HttpMethod

class Helper {
	def static String fileOutput(String ne, String slot, String text) {
		""
	}

	def static String fileOutput(String ne, String text) {
		""
	}

	def static String javaFileName(String ne) {
		ne
	}

	def static Class<?> metaType(NamedElement ne) {
		(ne as Object).getClass;
	}

	def static String simpleMetaTypeName(NamedElement element) {
		element.metaType.simpleName //name.split("::").last();
	}

	def static String docMetaTypeName(NamedElement element) {
		simpleMetaTypeName(element);
	}

	// Use this witha includeExternal=false to retrieve all DomainObjects except those belonging
	// to external modules
	def static Collection<Repository> getAllRepositories(Application app) {
		app.getAllRepositories(true);
	}

	def static Collection<Repository> getAllRepositories(Module module) {
		module.domainObjects.filter[repository?.name != null].map[repository].sortBy[name];
	}

	def static Collection<Repository> getAllRepositories(Application app, boolean includeExternal) {
		app.modules.map[it.getAllRepositories].flatten
			.filter[includeExternal || !aggregateRoot.module.external].sortBy[name];
	}

	// TODO VYHODIT
	def static isGenerateQuick() {
		false
	}

	def static List<Module> collectChangedModules(Application app) {
		if (!isGenerateQuick())
			app.modules as List<Module>
		else {
			val changed = changedModulesWithDependingModules(app);
			if (changed.isEmpty)
				app.modules as List<Module>
			else {
				debugTrace("Partial: " + app.modules.filter[e | changed.contains(e)].map[m | m.name].join)
				app.modules.filter[e | changed.contains(e)].toList
			}
		}
	}

	// All DomainObjects in the Applications, including those belonging to external modules
	def static Collection<DomainObject> getAllDomainObjects(Application app) {
		getAllDomainObjects(app, true)
	}


	// Use this witha includeExternal=false to retrieve all DomainObjects except those belonging
	// to external modules
	def static Collection<DomainObject> getAllDomainObjects(Application app, boolean includeExternal) {
		app.collectChangedModules().filter[m | includeExternal || !m.external].map[domainObjects].flatten.sortBy[name]
	}

	def static List<Module> changedModulesWithDependingModules(Application app) {
		app.changedModules().map[m | m.modulesDependingOn].flatten.toList;
	}

	def static List<Module> changedModules(Application app) {
		val result = getChangedModules().map(e | e.moduleFor(app));
		if (result.contains(null)) {} else result;
	}

	def static Module moduleFor(String name, Application app) {
		app.modules.findFirst(m | m.name == name)
	}

	def static List<Module> getModulesDependingOn(Module module) {
		DependencyConstraints::getModulesDependingOn(module);
	}

	def static Collection<DomainObject> getNonEnumDomainObjects(Module module) {
		module.domainObjects.filter[d | d.metaType != typeof(sculptormetamodel.Enum)].sortBy[e|e.name];
	}

	def static Collection<Service> getAllServices(Application app) {
		app.getAllServices(true);
	}

	// Use this witha includeExternal=false to retrieve all DomainObjects except those belonging
	// to external modules
	def static Collection<Service> getAllServices(Application app, boolean includeExternal) {
		app.modules.map[services].flatten.filter[s | includeExternal || !s.module.external].sortBy[s|s.name]
	}

	def static Collection<Resource> getAllResources(Application app) {
		app.getAllResources(true);
	}

	// Use this witha includeExternal=false to retrieve all DomainObjects except those belonging
	// to external modules
	def static Collection<Resource> getAllResources(Application app, boolean includeExternal) {
		app.modules.map[resources].flatten.filter[r | includeExternal || !r.module.external].sortBy[name]
	}

	def static Collection<Consumer> getAllConsumers(Application app) {
		app.getAllConsumers(true);
	}

	// Use this witha includeExternal=false to retrieve all DomainObjects except those belonging
	// to external modules
	def static Collection<Consumer> getAllConsumers(Application app, boolean includeExternal) {
		app.modules.map[consumers].flatten.filter[c | includeExternal || !c.module.external].sortBy[name]
	}

	def static boolean hasConsumers(Application app) {
		!app.modules.map[consumers].flatten.isEmpty
	}

	def static String formatJavaDoc(NamedElement element) {
		element.doc.formatJavaDoc
	}

	def static String getServiceapiPackage(Service service) {
		getServiceapiPackage(service.module);
	}

	def static String getServiceimplPackage(Service service) {
		getServiceimplPackage(service.module);
	}

	def static String getRestPackage(Resource resource) {
		getRestPackage(resource.module);
	}

	def static String getServiceproxyPackage(Service service) {
		getServiceproxyPackage(service.module);
	}

	def static String getServicestubPackage(Service service) {
		getServicestubPackage(service.module);
	}

	def static boolean isPagedResult(TypedElement e) {
		e.type == "PagedResult";
	}

	def static String getAccessObjectResultTypeName(RepositoryOperation op) {
		if (op.isPagedResult()) 
			"java.util.List<" + op.domainObjectType.getDomainPackage() + "." + op.domainObjectType.name + ">"
		else
			op.getTypeName();
	}

	def static String getExtendsAndImplementsLitteral(DomainObject domainObject) {
		 domainObject.getExtendsLitteral() + domainObject.getImplementsLitteral()
	}

	def static String getExtendsLitteral(DomainObject domainObject) {
		if (domainObject.getExtendsClassName() == "")
			""
		else
			"extends " + domainObject.getExtendsClassName();
	}

	def static String getExtendsClassNameIfExists(DomainObject domainObject) {
		if (domainObject.getExtends == null)
			domainObject.getDomainPackage() + "." + domainObject.name
		else
			domainObject.getExtends().getDomainPackage() + "." + domainObject.getExtends().name;
	}

	def static String getExtendsClassName(DomainObject domainObject) {
		if ( (domainObject.getExtends() as Object) == null)
			if (domainObject.extendsName == null) domainObject.defaultExtendsClassName() else domainObject.extendsName
		else 
			domainObject.getExtends().getDomainPackage() + "." + domainObject.getExtends().name;
	}

	def static String defaultExtendsClassName(DomainObject domainObject) {
		val result = defaultExtendsClass(domainObject.simpleMetaTypeName())
		if (result == "") abstractDomainObjectClass() else result;
	}

	def static String defaultExtendsClassName(DataTransferObject domainObject) {
	defaultExtendsClass(domainObject.simpleMetaTypeName());
	}

	def static String defaultExtendsClassName(Trait domainObject) {
		defaultExtendsClass(domainObject.simpleMetaTypeName());
	}

	def static List<String> traitInterfaceNames(DomainObject domainObject) {
		domainObject.traits.map[e | e.getDomainPackage() + "." + e.name];
	}

	def static String getImplementsLitteral(DomainObject domainObject) {
		if (domainObject.getImplementsInterfaceNames() == "")
			""
		else if (domainObject.getExtends != null && !domainObject.traitInterfaceNames().isEmpty )
			" implements " + domainObject.traitInterfaceNames().toCommaSeparatedString()
		else if (domainObject.getExtends != null)
			""
		else
			" implements " + domainObject.getImplementsInterfaceNames();
	}

	def static String toCommaSeparatedString(List values) {
		toSeparatedString(values, ",");
	}

	def static boolean isIdentifiable(DomainObject domainObject) {
		domainObject.attributes.exists[e | e.name == "id" && e.getTypeName() == "Long"];
	}

	def static String getImplementsInterfaceNames(DomainObject domainObject) {
		val interfaceNames = domainObject.traitInterfaceNames().toList();
		if (domainObject.isIdentifiable)
			interfaceNames.add(identifiableInterface)

		toCommaSeparatedString(interfaceNames)
	}

	def static String getImplementsInterfaceNames(DataTransferObject domainObject) {
		"java.io.Serializable, java.lang.Cloneable"
	}

	def static String getImplementsInterfaceNames(Trait domainObject) {
		domainObject.getDomainPackage() + "." + domainObject.name + ", java.io.Serializable";
	}

	def static String getImplementsInterfaceNames(DomainEvent domainObject) {
		fw("event.Event") + ", java.io.Serializable"
	}

	def static String getImplementsInterfaceNames(CommandEvent domainObject) {
		fw("event.Event")
	}

	def static String getImplementsInterfaceNames(Entity entity) {
		val list = entity.traitInterfaceNames().toList
		if (entity.auditable)
			list.add(auditableInterface())
		if (entity.isIdentifiable())
			list.add(identifiableInterface())
		if (isFullyAuditable())
			list.add(fw("domain.FullAuditLog") + "<" + entity.getDomainPackage() + "." + entity.name + ">")

		toCommaSeparatedString(list);
	}

	def static String getEjbInterfaces(Service service) {
		val pkg = service.getServiceapiPackage()
		val List<String> list = {}
		if (!service.localInterface && !service.remoteInterface)
			list.add(pkg + "." + service.name)
		if (service.localInterface)
			list.add(pkg + "." + service.name + "Local")
		if (service.remoteInterface)
			list.add(pkg + "." + service.name + "Remote")
		if (service.webService)
			list.add(pkg + "." + service.name + "Endpoint")

		toCommaSeparatedString(list);
	}

	def private static String visibilityImpl(String visibility) {
		switch (visibility) {
				case null : "public "
				case "" : "public "
				case "package" : ""
				default : visibility + " "
		};
	}

	def static String getAccessObjectInterfaceExtends(RepositoryOperation op) {
		val List<String> list = {}
		if (op.hasPagingParameter())
			list.add(fw("accessapi.Pageable"))
		if (op.hasHint("cache"))
			list.add(fw("accessapi.Cacheable"))

		toCommaSeparatedString(list);
	}

	def static String getVisibilityLitteralGetter(Attribute attribute) {
		visibilityImpl(attribute.visibility);
	}

	def static boolean isSetterNeeded(Reference ref) {
		if (jpa())
			if (ref.changeable || (ref.isBasicTypeReference()) || (ref.isEnumReference()))
				!ref.isSetterPrivate()
			else
				notChangeableReferenceSetterVisibility() != "private"
		else
			true;
	}

	def static boolean isSetterNeeded(Attribute attribute) {
		if (jpa())
			if (attribute.changeable)
				!attribute.isSetterPrivate()
			else
				notChangeablePropertySetterVisibility() != "private"
		else
			true;
	}

	def static boolean isSetterPrivate(Attribute attribute) {
		attribute.getVisibilityLitteralSetter() == "private ";
	}

	def static boolean isSetterPrivate(Reference ref) {
		ref.getVisibilityLitteralSetter() == "private "
	}

	def static String getVisibilityLitteralSetter(Attribute attribute) {
		if (attribute.changeable)
			if (hasHint(attribute, "readonly"))
				"protected "
			else
				visibilityImpl(attribute.visibility)
		else
			"private ";
	}

	def static String getVisibilityLitteral(Operation op) {
		visibilityImpl(op.visibility);
	}

	def static boolean isPublicVisibility(Attribute att) {
		att.getVisibilityLitteralGetter().startsWith("public");
	}

	def static boolean isPublicVisibility(Reference ref) {
		ref.getVisibilityLitteralGetter().startsWith("public");
	}

	def static boolean isPublicVisibility(Operation op) {
		op.getVisibilityLitteral().startsWith("public");
	}

	def static String getVisibilityLitteralGetter(Reference ref) {
		visibilityImpl(ref.visibility);
	}

	def static String getVisibilityLitteralSetter(Reference ref) {
		if (ref.changeable)
			if (hasHint(ref, "readonly"))
				"protected "
			else
				visibilityImpl(ref.visibility)
		else
			"private "
	}

	def static String getAbstractLitteral(DomainObject domainObject) {
		if (domainObject.^abstract)
			"abstract "
		else
			"";
	}

	def private static Collection<Attribute> getSuperAllAttributes(DomainObject domainObject) {
		if (domainObject.getExtends == null)
		 {}
		else
			domainObject.getExtends.getAllAttributes();
	}

	def static Collection<Attribute> getAllAttributes(DomainObject domainObject) {
		val allSuper = domainObject.getSuperAllAttributes()
		allSuper.addAll(domainObject.attributes)
		allSuper
	}

	def private static Collection<Reference> getSuperAllReferences(DomainObject domainObject) {
		if (domainObject.getExtends == null)
		 {}
		else
			domainObject.getExtends.getAllReferences();
	}

	def static Collection<Reference> getAllReferences(DomainObject domainObject) {
		val allSuper = domainObject.getSuperAllReferences()
		allSuper.addAll(domainObject.references )
		allSuper
	}

	def static List<NamedElement> getSuperConstructorParameters(DomainObject domainObject) {
		if (domainObject.getExtends == null)
		 {}
		else
			domainObject.getExtends.getConstructorParameters();
	}

	def static List<NamedElement> getConstructorParameters(DomainObject domainObject) {
		var allParams = domainObject.getSuperConstructorParameters()
		allParams.addAll(domainObject.attributes.filter[a | (!a.changeable || a.required)])
		allParams = allParams.filter[a | a != domainObject.getIdAttribute()].toList()
		allParams.addAll(domainObject.references.filter[r | (!r.changeable || r.required)]);
		allParams
	}

	def static List<NamedElement> getLimitedConstructorParameters(DomainObject domainObject) {
		domainObject.getConstructorParameters().filter[e | !e.isNullable() || e.isRequired()].toList
	}

	def static List<NamedElement> getMinimumConstructorParameters(DomainObject domainObject) {
		domainObject.getConstructorParameters().filter[e | !e.isChangeable()].toList
	}

	def static String getDefaultConstructorVisibility(DomainObject domainObject) {
		"protected";
	}

	def static boolean isNullable(NamedElement element) {
		false;
	}

	def static boolean isNullable(Attribute att) {
		att.nullable;
	}

	def static boolean isNullable(Reference ref) {
		ref.nullable;
	}

	def static boolean isRequired(NamedElement element) {
		false;
	}

	def static boolean isRequired(Attribute att) {
		att.required;
	}

	def static boolean isRequired(Reference ref) {
		ref.required;
	}

	def static boolean isChangeable(NamedElement element) {
		false;
	}

	def static boolean isChangeable(Attribute att) {
		att.changeable;
	}

	def static boolean isChangeable(Reference ref) {
		ref.changeable;
	}

	def static boolean isImmutable(DomainObject domainObject) {
		false;
	}

	def static boolean isImmutable(Enum domainObject) {
		true;
	}

	def static boolean isImmutable(ValueObject domainObject) {
		domainObject.immutable;
	}

	def static Collection<Repository> getDelegateRepositories(Service service) {
		val reps = service.operations.filter[op | op.delegate != null].map[op | op.delegate.repository].toList
		reps.addAll(service.repositoryDependencies)
		reps
	}

	def static Collection<Service> getDelegateServices(Service service) {
		val srvc = service.operations.filter[op | op.serviceDelegate != null].map[op | op.serviceDelegate.service].toList
		srvc.addAll(service.serviceDependencies)
		srvc
	}

	def static Collection<Service> getDelegateServices(Resource resource) {
		val res = resource.operations.filter[op | op.delegate?.serviceDelegate != null].map[op | op.delegate.serviceDelegate.service].toList
		res.addAll(resource.serviceDependencies)
		res
	}

	def static String getSetAccessor(NamedElement element) {
		"set" + element.name.toFirstUpper();
	}

	def static String getGetAccessor(NamedElement element) {
		"get" + element.name.toFirstUpper();
	}

	def static String getGetAccessor(TypedElement e) {
		e.getGetAccessor("");
	}

	def static String getAccessObjectName(RepositoryOperation op) {
		if (op.accessObjectName == null || op.accessObjectName == "")
			op.name.toFirstUpper() + "Access" 
		else
			op.accessObjectName.toFirstUpper()
	}

	def static String getAccessBase(RepositoryOperation op) {
		val className = ( if (op.getThrows == null || op.getThrows == "")
				accessBaseClass()
			else
				accessBaseWithExceptionClass())

		if (className.endsWith(">"))
				className
			else
				className + "<Object>"
	}

	def static boolean hasPagingParameter(RepositoryOperation op) {
		op.getPagingParameter() != null
	}

	def static Parameter getPagingParameter(RepositoryOperation op) {
		op.parameters.findFirst(e | e.isPagingParameter())
	}

	def static boolean hasPagingParameter(ServiceOperation op) {
		op.getPagingParameter() != null
	}

	def static Parameter getPagingParameter(ServiceOperation op) {
		op.parameters.findFirst(e | e.isPagingParameter())
	}

	def static boolean isPagingParameter(Parameter param) {
		param.type == "PagingParameter";
	}

	def static boolean isPaged(Operation op) {
		op.hasHint("paged")
	}

	def static Attribute getIdAttribute(DomainObject domainObject) {
		domainObject.getAllAttributes().findFirst(a | a.name == "id");
	}

	def static String getIdAttributeType(DomainObject domainObject) {
		val idAttribute = domainObject.getIdAttribute()
		if (idAttribute == null) null else idAttribute.getTypeName()
	}

	def static Collection<DomainObject> getSubclasses(DomainObject domainObject) {
		domainObject.module.application.getAllDomainObjects().filter[d | d.getExtends == domainObject].toList
	}

	def static Collection<DomainObject> getAllSubclasses(DomainObject domainObject) {
		val subs = domainObject.getSubclasses().toList
		subs.addAll(domainObject.getSubclasses().map[d | d.getAllSubclasses()].flatten)
		subs
	}

	def static boolean hasOwnDatabaseRepresentation(DomainObject domainObject) {
		domainObject.isEntityOrPersistentValueObject();
	}

	// Include Entity and persistent ValueObject,
	// skip BasicType, Enum and non persistent ValueObject
	def static boolean isEntityOrPersistentValueObject(DomainObject domainObject) {
		(domainObject.isPersistent() && domainObject.metaType != typeof(BasicType))
	}

	def static boolean isPersistent(DomainObject domainObject) {
		false
	}

	def static boolean isPersistent(Entity domainObject) {
		true
	}

	def static boolean isPersistent(ValueObject domainObject) {
		domainObject.persistent
	}

	def static boolean isPersistent(DataTransferObject domainObject) {
		false;
	}

	def static boolean isPersistent(BasicType domainObject) {
		true;
	}

	def static boolean isOneToOne(Reference ref) {
		!ref.many && ref.opposite != null && !ref.opposite.many;
	}

	def static boolean isOneToMany(Reference ref) {
		ref.many && ((ref.opposite != null && !ref.opposite.many) || (ref.opposite == null && ref.isInverse()));
	}

	def static boolean isManyToMany(Reference ref) {
		ref.many && ((ref.opposite != null && ref.opposite.many) || (ref.opposite == null && !ref.isInverse()));
	}

	//
	// Hint support
	//
	def static boolean hasHint(NamedElement element, String parameterName) {
		hasHintImpl(element.hint, parameterName);
	}

	def static boolean hasHint(NamedElement element, String parameterName, String separator) {
		getHintImpl(element.hint, parameterName, separator) != null
	}

	def static String getHint(NamedElement element, String parameterName) {
		getHintImpl(element.hint, parameterName, ",;")
	}

	def static String getHintOrDefault(NamedElement element, String parameterName, String defaultValue) {
		ifNull(element.getHint(parameterName), defaultValue);
	}

	def static String getHintOrDefault(NamedElement element, String parameterName, String separator, String defaultValue) {
		ifNull(element.getHint(parameterName, separator), defaultValue);
	}

	def static String ifNull(String value, String defaultValue) {
		if (value == null) defaultValue else value
	}

	def static String ifEmpty(String value, String defaultValue) {
		if (value != null && value.length == 0) defaultValue else value
	}

	def static String ifNullOrEmpty(String value, String defaultValue) {
		if (value == null || value.length == 0) defaultValue else value
	}

	def static String getHint(NamedElement element, String parameterName, String separator) {
		getHintImpl(element.hint, parameterName, separator)
	}

	// TODO CONSTRAINTS
	def static boolean checkCyclicDependencies(Module module) {
		// DependencyConstraints.checkCyclicDependencies(module)
		true
	}

	def static boolean checkAggregateReferences(Application app) {
		// AggregateConstraints.checkAggregateReferences(app);
		true
	}

	def static Collection<String> getAllGeneratedExceptions(Module module) {
		val exc = module.services.map[operations].flatten.map[op | getGeneratedExceptions(op)].flatten.toList
		exc.addAll(module.getAllRepositories().map[operations].flatten.map[op | getGeneratedExceptions(op)].flatten)
		exc
	}

	def static Collection<String> getAllGeneratedWebServiceExceptions(Module module) {
		module.services.filter[e | e.webService].map[operations].flatten
			.map[op | op.getGeneratedExceptions()].flatten.toList
	}

	def static boolean hasNotFoundException(RepositoryOperation op) {
		op.exceptions.contains(getExceptionPackage(op.repository.aggregateRoot.module) + "." + op.repository.aggregateRoot.name + "NotFoundException")
	}

	def static boolean hasNotFoundException(ServiceOperation op) {
		op.exceptions.exists(e|e.endsWith("NotFoundException"))
	}

	// removes last s to make the word into singular
	def static String singular(String str) {
		SingularPluralConverter::toSingular(str)
	}

	// adds s to the end to make the word into plural
	def static String plural(String str) {
		SingularPluralConverter::toPlural(str)
	}

	def static DomainObject getRootExtends(DomainObject domainObject) {
		if (domainObject.getExtends == null)
			domainObject
		else
			domainObject.getExtends.getRootExtends();
	}

	def static List<Reference> getNaturalKeyReferences(DomainObject domainObject) {
		domainObject.references.filter[a | a.naturalKey].toList
	}

	def static List<Reference> getAllNaturalKeyReferences(DomainObject domainObject) {
		if (domainObject.getExtends == null)
			domainObject.getNaturalKeyReferences()
		else {
			val refs = domainObject.getExtends.getAllNaturalKeyReferences()
			refs.addAll(domainObject.getNaturalKeyReferences())
			refs
		}
	}

	def static boolean hasNaturalKey(DomainObject domainObject) {
		!domainObject.getAllNaturalKeyAttributes().isEmpty || !domainObject.getAllNaturalKeyReferences().isEmpty;
	}

	def static List<Attribute> getNaturalKeyAttributes(DomainObject domainObject) {
		domainObject.attributes.filter[a | a.naturalKey].toList
	}

	def static List<Attribute> getAllNaturalKeyAttributes(DomainObject domainObject) {
		if (domainObject.getExtends == null)
			domainObject.getNaturalKeyAttributes()
		else {
			val exts = domainObject.getExtends.getAllNaturalKeyAttributes()
			exts.addAll(domainObject.getNaturalKeyAttributes())
			exts
		}
	}

	def static List<NamedElement> getAllNaturalKeys(DomainObject domainObject) {
		val List<NamedElement> keys = newArrayList()
		keys.addAll(getAllNaturalKeyAttributes(domainObject))
		keys.addAll(getAllNaturalKeyReferences(domainObject))
		keys
	}

	def static boolean isBasicTypeReference(NamedElement ref) {
	false;
	}

	def static boolean isBasicTypeReference(Reference ref) {
		!ref.many && (ref.to.metaType == typeof(BasicType))
	}

	def static List<Reference> getAllBasicTypeReferences(DomainObject domainObject) {
		domainObject.getAllReferences().filter[r | r.isBasicTypeReference()].toList
	}

	def static List<Reference> getBasicTypeReferences(DomainObject domainObject) {
		domainObject.references.filter[r | isBasicTypeReference(r)].toList
	}

	def static boolean isEnumReference(NamedElement ref) {
		false;
	}

	def static boolean isEnumReference(Reference ref) {
		!ref.many && (ref.to.metaType == typeof(Enum))
	}

	def static Collection<Reference> getEnumReferences(DomainObject domainObject) {
		domainObject.references.filter[r | isEnumReference(r)].toList
	}

	def static Collection<Reference> getAllEnumReferences(DomainObject domainObject) {
		val refs = domainObject.getSuperAllEnumReferences()
		refs.addAll(domainObject.getEnumReferences())
		refs
	}

	def private static Collection<Reference> getSuperAllEnumReferences(DomainObject domainObject) {
		if (domainObject.getExtends == null)
		 {}
		else
			domainObject.getExtends.getAllEnumReferences()
	}

	def static Attribute getIdentifierAttribute(sculptormetamodel.Enum enum) {
		if (enum.hasNaturalKey())
			enum.attributes.findFirst[a | a.naturalKey]
		else
			null;
	}

	def static boolean isEmbeddable(DomainObject domainObject) {
		// Only BasicType is embeddable
		((domainObject.metaType == typeof(BasicType)))
	}

	def static boolean isDataTranferObject(DomainObject domainObject) {
		((domainObject.metaType == typeof(DataTransferObject)))
	}

	def static boolean hasSubClass(DomainObject domainObject) {
		((getSubclasses(domainObject) != null) && (!getSubclasses(domainObject).isEmpty))
	}

	def static boolean hasSuperClass(DomainObject domainObject) {
		(domainObject.getExtends != null)
	}

	def static DomainObject getDomainObject(NamedElement elem) {
		error("NamedElement doesn't belong to a DomainObject: " + elem)
		null;
	}

	def static DomainObject getDomainObject(Attribute attribute) {
		(attribute.eContainer as DomainObject)
	}

	def static Operation getOperation(Parameter parameter) {
		(parameter.eContainer as Operation)
	}

	def static RepositoryOperation getRepositoryOperation(Parameter parameter) {
		if (parameter.getOperation().metaType == typeof(RepositoryOperation))
			(parameter.getOperation() as RepositoryOperation)
		else
			null;
	}

	def static ServiceOperation getServiceOperation(Parameter parameter) {
		if (parameter.getOperation().metaType == typeof(ServiceOperation))
			(parameter.getOperation() as ServiceOperation)
		else
			null;
	}

	def static DomainObject getDomainObject(Reference ref) {
		(ref.eContainer as DomainObject)
	}

	def static boolean hasSimpleNaturalKey(DomainObject domainObject) {
		!domainObject.hasCompositeNaturalKey();
	}

	def static boolean hasCompositeNaturalKey(DomainObject domainObject) {
		domainObject.getAllNaturalKeys().size > 1;
	}

	def static boolean isSimpleNaturalKey(Attribute attribute) {
		(attribute.naturalKey && hasSimpleNaturalKey(attribute.getDomainObject()));
	}

	def static boolean isSimpleNaturalKey(Reference ref) {
		(ref.naturalKey && hasSimpleNaturalKey(ref.from));
	}

	def static Attribute getUuid(DomainObject domainObject) {
		domainObject.getAllAttributes().findFirst(e | e.isUuid())
	}

	def static boolean isUuid(Attribute attribute) {
		attribute.name == "uuid";
	}

	def static Collection<sculptormetamodel.Enum> getAllEnums(Application app) {
		app.modules.map[domainObjects].flatten
			.filter[d | metaType(d) == typeof(sculptormetamodel.Enum)].map[(it as sculptormetamodel.Enum)].toSet
	}

	def static boolean isValueObjectReference(Reference ref) {
		!ref.many && (ref.to.metaType == typeof(ValueObject));
	}

	def static List<String> getEntityListeners(DomainObject domainObject) {
		var List<String> list = newArrayList()
		if (domainObject.metaType == typeof(Entity) || domainObject.metaType == typeof(ValueObject))
			list.add(validationEntityListener())
		else
			list = null

		list
	}

	def static String getValidationEntityListener(DomainObject domainObject) {
		if (isValidationAnnotationToBeGenerated() && (domainObject.metaType == typeof(Entity)) || (domainObject.metaType == typeof(ValueObject)))
			validationEntityListener()
		else
			null
	}

	def static String getAuditEntityListener(DomainObject domainObject) {
		null;
	}

	def static String getAuditEntityListener(Entity entity) {
		if (entity.auditable)
			auditEntityListener()
		else
			null;
	}

	def static String dataSourceName(Application app, String persistenceUnitName) {
		if (getDbProduct == "hsqldb-inmemory" && applicationServer() == "jetty")
			"applicationDS"
		else if (app.isDefaultPersistenceUnitName(persistenceUnitName))
			app.name + "DS"
		else
			persistenceUnitName + "DS";
	}

	def static String dataSourceName(Application app) {
		app.dataSourceName(app.persistenceUnitName());
	}

	def static boolean isXmlElementToBeGenerated(Attribute attr) {
	isXmlBindAnnotationToBeGenerated() &&
		isXmlBindAnnotationToBeGenerated(attr.getDomainObject().simpleMetaTypeName());
	}

	def static boolean isXmlElementToBeGenerated(Reference ref) {
		isXmlBindAnnotationToBeGenerated() &&
			isXmlBindAnnotationToBeGenerated(ref.from.simpleMetaTypeName());
	}

	def static boolean isXmlRootToBeGenerated(DomainObject domainObject) {
		isXmlBindAnnotationToBeGenerated() &&
			isXmlBindAnnotationToBeGenerated(domainObject.simpleMetaTypeName()) &&
			("true" == domainObject.getHint("xmlRoot"));
	}

	def static List<String> reversePackageName(String packageName) {
		packageName.split('\\.').reverse();
	}

	def static List<String> supportedCollectionTypes() {
		newArrayList("List", "Set", "Bag", "Map")
	}

	def static List<String> supportedTemporalTypes() {
		newArrayList("Date", "DateTime", "Timestamp")
	}

	def static List<String> supportedNumericTypes() {
		newArrayList("integer", "long", "float", "double", "Integer", "Long", "Float", "Double", "BigInteger", "BigDecimal")
	}

	def static String persistenceUnitName(Application app) {
		if (isJpaProviderAppEngine())
			"transactions-optional"
		else
			app.name + "EntityManagerFactory"
	}

	def static boolean isDefaultPersistenceUnitName(Application app, String unitName) {
		unitName == app.persistenceUnitName();
	}

	def static String persistenceContextUnitName(Repository repository) {
		if (usePersistenceContextUnitName() && repository.aggregateRoot.module.persistenceUnit != "null")
			repository.aggregateRoot.module.persistenceUnit
		else
			""
	}

	def static boolean isString(Attribute attribute) {
		(attribute.type == "String") && !attribute.isCollection();
	}

	def static boolean isBoolean(Attribute attribute) {
		newArrayList("Boolean", "boolean").contains(attribute.type) && !attribute.isCollection();
	}

	def static boolean isNumeric(Attribute attribute) {
	supportedNumericTypes().contains(attribute.type) && !attribute.isCollection();
	}

	def static boolean isTemporal(Attribute attribute) {
	supportedTemporalTypes().contains(attribute.type) && !attribute.isCollection();
	}

	def static boolean isDate(Attribute attribute) {
	attribute.type == "Date";
	}

	def static boolean isDateTime(Attribute attribute) {
	attribute.type == "DateTime" || attribute.type == "Timestamp";
	}

	def static boolean isPrimitive(Attribute attribute) {
		isPrimitiveType(attribute.getTypeName()) && !attribute.isCollection();
	}

	def static boolean isUnownedReference(NamedElement elem) {
		false;
	}

	def static boolean isUnownedReference(Reference ref) {
		(isJpaProviderAppEngine() || nosql()) && ref.from.isPersistent() && !ref.transient && ref.to.hasOwnDatabaseRepresentation()
			&& !ref.hasOwnedHint() && (! ref.from.getAggregate().contains(ref.to) || ref.hasUnownedHint());
	}

	def static boolean hasOwnedHint(Reference ref) {
		ref.hasHint("owned") || (ref.opposite != null && ref.opposite.hasHint("owned"));
	}

	def static boolean hasUnownedHint(Reference ref) {
		ref.hasHint("unowned") || (ref.opposite != null && ref.opposite.hasHint("unowned"));
	}

	def static String unownedReferenceSuffix(NamedElement elem) {
		""
	}

	def static String unownedReferenceSuffix(Reference ref) {
		if (ref.isUnownedReference())
			(if (ref.many) "Ids" else "Id")
		else
			"";
	}

	def static boolean isCollection(Attribute attribute) {
		attribute.collectionType != null && supportedCollectionTypes().contains(attribute.collectionType);
	}

	def static boolean isCollection(Reference reference) {
		reference.collectionType != null && supportedCollectionTypes().contains(reference.collectionType);
	}

	def static boolean isList(Reference ref) {
		"list" == ref.getCollectionType()
	}


	def static boolean useJpaBasicAnnotation(Attribute attr) {
		isJpaProviderAppEngine() && (attr.getTypeName() == "com.google.appengine.api.datastore.Key");
	}

	def static boolean useJpaLobAnnotation(Attribute attr) {
		(attr.type == "Clob" || attr.type == "Blob")
	}

	def static String extendsLitteral(Repository repository) {
		val prop = defaultExtendsClass(repository.simpleMetaTypeName());
		if (prop != '')
			("extends " + prop)
		else
			if (!isSpringToBeGenerated())
				""
			else if (jpa())
				"extends org.springframework.orm.jpa.support.JpaDaoSupport"
			else
				""
	}

	def static String extendsLitteral(Service service) {
		val prop = defaultExtendsClass(service.simpleMetaTypeName())
		if (prop != '')
			"extends " + prop
		else
			"";
	}

	def static String extendsLitteral(Resource resource) {
		val prop = defaultExtendsClass(resource.simpleMetaTypeName())
		if (prop != '')
			"extends " + prop
		else
			"";
	}

	// The root of the aggregate that the domainObject belongs to
	def static DomainObject getAggregateRootObject(DomainObject domainObject) {
		if (domainObject.belongsToAggregate != null)
			domainObject.belongsToAggregate
		else if (domainObject.aggregateRoot)
			domainObject
		else if (!domainObject.isEntityOrPersistentValueObject())
			domainObject
		else
			domainObject.module.application.getAllDomainObjects().filter[e | e.aggregateRoot]
				.findFirst[e | e.getAggregate().contains(domainObject)]
	}

	def static boolean bothEndsInSameAggregateRoot(Reference ref) {
		ref.to.getAggregateRootObject() == ref.from.getAggregateRootObject();
	}

	// All DomainObjects in same aggregate group as the domainObject
	def static Collection<DomainObject> getAggregate(DomainObject domainObject) {
		if (domainObject.isEntityOrPersistentValueObject())
			domainObject.getAggregateImpl()
		else
			newArrayList(domainObject)
	}

	def private static Collection<DomainObject> getAggregateImpl(DomainObject domainObject) {
		if (domainObject.aggregateRoot) {
			domainObject.collectAggregateObjects()
		} else {
			val root = domainObject.getAggregateRootObject()
			if (root == null || root == domainObject) newArrayList(domainObject) else root.getAggregate()
		}
	}

	def private static Collection<DomainObject> collectAggregateObjects(DomainObject domainObject) {
		val List<DomainObject> aggrSet = newArrayList()

		aggrSet.add(domainObject);
		aggrSet.addAll(domainObject.references.filter[e | !e.to.isAggregateRoot && e.to.isEntityOrPersistentValueObject()]
				.map[r | r.to.collectAggregateObjects()].flatten)
		aggrSet
	}

	// when using multiple persistence units it must be possible to define separate JpaFlushEagerInterceptor
	def static String getJpaFlushEagerInterceptorClass(Module module) {
		if (hasProperty("jpa.JpaFlushEagerInterceptor." + module.persistenceUnit))
			getProperty("jpa.JpaFlushEagerInterceptor." + module.persistenceUnit)
		else
			fw("errorhandling.JpaFlushEagerInterceptor")
	}

	def static boolean validateNotNullInConstructor(NamedElement any) {
		false;
	}

	def static boolean validateNotNullInConstructor(Reference ref) {
		(!ref.isNullable() && !ref.changeable && (notChangeableReferenceSetterVisibility() == "private"));
	}

	def static boolean validateNotNullInConstructor(Attribute att) {
	!att.isNullable() && !att.isPrimitive();
	}

	def static Module getModule(NamedElement elem) {
		if (elem == null || elem.metaType == typeof(Module))
			(elem as Module)
		else
			(elem.eContainer as NamedElement).getModule();
	}

	def static String toStringStyle(DomainObject domainObject) {
		if (domainObject.hasHint("toStringStyle"))
			domainObject.getHint("toStringStyle")
		else if (hasProperty("toStringStyle"))
			getProperty("toStringStyle")
		else
			null
	}

	def static boolean isEventSubscriberOperation(Operation op) {
		op.name == "receive" && op.parameters.size == 1 && op.parameters.head.type == fw("event.Event")
	}

	def static String errorCodeType(Module module) {
		if (hasProperty("exception.code.enum")) {
			val enumName = getProperty("exception.code.enum")
			val enumType = module.application.modules.map[domainObjects].flatten.findFirst[e | e.name == enumName]
			if (enumType == null)
				error("You need to define enum " + enumName + " in model for the error codes")
			enumType.getDomainPackage + "." + enumType.name
		} else {
			"int"
		}
	}

	def static boolean isImplementedInGapClass(DomainObjectOperation op) {
		(!op.^abstract && !op.hasHint("trait")) || (op.^abstract && op.hasHint("trait"))
	}

	def static boolean isImplementedInGapClass(ServiceOperation op) {
		(op.delegate == null && op.serviceDelegate == null);
	}

	def static boolean isImplementedInGapClass(ResourceOperation op) {
		(op.delegate == null && !(op.parameters.isEmpty && op.returnString != null && op.httpMethod == HttpMethod::GET));
	}

	def static HttpMethod mapHttpMethod(String methodName) {
		switch (methodName) {
			case "GET" :
				HttpMethod::GET
			case "POST" :
				HttpMethod::POST
			case "PUT" :
				HttpMethod::PUT
			case "DELETE" :
				HttpMethod::DELETE
			default :
				null
		}
	}

	def static String removeSuffix(String str, String suffix) {
		if (str.endsWith(suffix))
			str.substring(0, str.length - suffix.length)
		else
			str
	}

	def static String getDomainResourceName(Resource resource) {
		resource.name.removeSuffix("Resource");
	}

	def static String getXStreamAliasName(DomainObject domainObject) {
		domainObject.name.removeSuffix("DTO").removeSuffix("Dto");
	}

	def static String getXmlRootElementName(DomainObject domainObject) {
		domainObject.name.removeSuffix("DTO").removeSuffix("Dto");
	}

	def static boolean isRestRequestParameter(Parameter param) {
		!getNotRestRequestParameter().contains(param.type);
	}

	def static String getApplicationBasePackage(DomainObject domainObject) {
		domainObject.module.application.basePackage;
	}

	def static String getApplicationBasePackage(Reference reference) {
		getApplicationBasePackage(reference.getDomainObject());
	}

	def static String getApplicationBasePackage(Attribute attribute) {
		getApplicationBasePackage(attribute.getDomainObject());
	}

	def static DomainObject getAggregateRoot(RepositoryOperation op) {
		op.repository.aggregateRoot;
	}

	def static String getAggregateRootTypeName(Repository repository) {
		repository.aggregateRoot.getDomainObjectTypeName();
	}

	def static String getAggregateRootTypeName(RepositoryOperation op) {
		op.repository.getAggregateRootTypeName();
	}

	def static String getAggregateRootPropertiesTypeName(RepositoryOperation op) {
		op.repository.getAggregateRootTypeName() + "Properties";
	}

	def static boolean isOrdinaryEnum(sculptormetamodel.Enum enum) {
		( enum.getIdentifierAttribute() == null )
	}

	def static sculptormetamodel.Enum getEnum(Reference ref) {
		if (ref.isEnumReference())
			(ref.to as sculptormetamodel.Enum)
		else {
			error("Reference is not of type enum")
			null
		}
	}

	def static boolean containsNonOrdinaryEnums(Application application) {
		application.getAllEnums().exists(e|!e.isOrdinaryEnum());
	}

	def static boolean hasParameters(RepositoryOperation op) {
		op.parameters != null && !op.parameters.isEmpty;
	}

	def static boolean hasAttribute(DomainObject domainObject, String name) {
		domainObject.getAllAttributes().exists(a | a.name == name);
	}

	def static boolean hasReference(DomainObject domainObject, String name) {
		domainObject.getAllReferences().exists(a | a.name == name);
	}

	def static boolean hasAttributeOrReference(DomainObject domainObject, String name) {
		domainObject.hasAttribute(name) || domainObject.hasReference(name);
	}

	def private static String getPropertyPath(String propertyName, DomainObject aggregateRoot) {
		if (propertyName.contains("_"))
			propertyName.replaceAll("_", ".")
		else if (aggregateRoot.hasAttributeOrReference(propertyName))
			propertyName
		else if (aggregateRoot.getAllReferences().exists(e | e.to.hasAttributeOrReference(propertyName)))
			aggregateRoot.getAllReferences().findFirst(e | e.to.hasAttributeOrReference(propertyName)).name + "." + propertyName
		else
			null;
	}

	def static String getDomainObjectTypeName(DomainObject domainObject) {
		domainObject.getDomainPackage + "." + domainObject.name
	}

	def static String getGenericResultTypeName(RepositoryOperation op) {
		if (op.collectionType != null || op.isPagedResult())
			op.getTypeName().replaceAll(getDomainObjectTypeName(op.domainObjectType),"R")
		else
			"R"
	}

	def static String getResultTypeName(RepositoryOperation op) {
		if (op.type != null && !op.isPagedResult())
			if (op.isReturningPrimitiveType())
				op.getTypeName.getObjectTypeName
			else
				op.type
		else if (op.domainObjectType != null)
			getDomainObjectTypeName(op.domainObjectType)
		else
			null
	}

	def static String getAccessObjectResultTypeName2(RepositoryOperation op) {
		if (op.isPagedResult())
			"PagedResult<" + op.getResultTypeName() + ">"
		else if (op.collectionType != null)
			"List<" + op.getResultTypeName() + ">"
		else
			op.getResultTypeName()
	}

	def static String getResultTypeNameForMapping(RepositoryOperation op) {
		if (op.useTupleToObjectMapping())
			"javax.persistence.Tuple"
		else
			op.getResultTypeName()
	}

	def static String getNotFoundExceptionName(RepositoryOperation op) {
		(if (op.domainObjectType != null)
			op.domainObjectType.name
		else
			"") + "NotFoundException"
	}

	def static boolean throwsNotFoundException(RepositoryOperation op) {
		op.getThrows != null && op.getThrows.contains(op.getNotFoundExceptionName());
	}

	def static String removeSurrounding(String s, String char) {
		if (s.startsWith(char) && s.endsWith(char))
			s.substring(1, s.length -1)
		else
			s;
	}

	def static boolean hasHintEquals(NamedElement element, String parameterName, String parameterValue) {
		element.hasHint(parameterName) && element.getHint(parameterName) == parameterValue;
	}

	def static boolean isGeneratedFinder(RepositoryOperation op) {
		generateFinders() &&
				!op.hasHint("gap") &&
						(op.isQueryBased() || op.isConditionBased());
	}

	def static boolean isQueryBased(RepositoryOperation op) {
		isJpa2() && op.hasHint("query");
	}

	def static boolean isConditionBased(RepositoryOperation op) {
		(op.hasHint("construct") || op.hasHint("build") || op.hasHint("condition") || op.hasHint("select") || op.name.startsWith("find"));
	}

	// TODO: quick solution, it would be better to implement a new access strategy
	def static boolean useGenericAccessStrategy(RepositoryOperation op) {
		isJpa2() &&
				(op.name == "findAll" ||
				 op.name == "findByQuery" ||
				 op.name == "findByExample" ||
				 op.name == "findByKeys" ||
				 op.name == "findByNaturalKeys" ||
				 op.name == "findByCondition" ||
				 op.name == "findByCriteria");
	}

	def static boolean useTupleToObjectMapping(RepositoryOperation op) {
		isJpa2() && (!op.hasHint("construct") && (op.hasHint("map") || op.isReturningDataTranferObject()))
	}

	def private static boolean isReturningDataTranferObject(RepositoryOperation op) {
		(op.domainObjectType != null && op.domainObjectType.isDataTranferObject());
	}

	def static String buildConditionalCriteria(RepositoryOperation op) {
		val condition = op.getHintOrDefault("condition", ";", "")
		if (condition.containsSqlPart()) {
			condition
		} else {
			(if (op.hasHint("select")) "select "     + op.getHint("select",";") else op.buildSelect()) +
			(if (op.hasHint("condition")) " where "  + op.getHint("condition",";") else op.buildWhere()) +
			(if (op.hasHint("groupBy")) " group by " + op.getHint("groupBy",";") else "") +
			(if (op.hasHint("orderBy")) " order by " + op.getHint("orderBy",";") else "")
		}
	}

	def static String buildQuery(RepositoryOperation op) {
		val query = op.getHintOrDefault("query", ";", "")
		if (query.isNamedQuery() || query.containsSqlPart())
			query
		else
			"select object(o) from " + op.getAggregateRoot().name + " o where " + query
	}

	def private static boolean isNamedQuery(String query) {
		!query.trim().contains(" ")
	}

	def private static boolean containsSqlPart(String query) {
		(query.contains("select") || query.contains("from") || query.contains("where") || query.contains("orderBy"))
	}

	def private static String buildSelect(RepositoryOperation op) {
		if (op.domainObjectType == null || op.isReturningAggregateRoot())
			""
		else
			op.buildSelectFromReturnType()
	}

	def private static boolean isReturningAggregateRoot(RepositoryOperation op) {
		(op.getAggregateRoot() == op.domainObjectType)
	}

	def private static boolean isReturningPrimitiveType(RepositoryOperation op) {
		(op.type != null && isPrimitiveType(op.getTypeName()))
	}

	def private static String buildSelectFromReturnType(RepositoryOperation op) {
		if (op.buildSelectForReference() != null)
			op.buildSelectForReference()
		else if (op.buildSelectUsingAttributes() != null)
			op.buildSelectUsingAttributes()
		else
			error(
				"Could not set select from return type for domain object '" + op.getAggregateRoot().name + "'. " +
				"Add gap or select to repository operation '" + op.name + "' in repository '" + op.repository.name + "'")
	}

	def private static String buildSelectForReference(RepositoryOperation op) {
		val path = op.getReferencePathFromReturnType()
		if (path != null)
			"select " + path
		else
			null
	}

	def private static String buildSelectUsingAttributes(RepositoryOperation op) {
		val returnType = op.domainObjectType
		val aggregateRoot = op.getAggregateRoot()
		val matchingProperties = getMatchingPropertyNamesToSelect(returnType, aggregateRoot)
		if (!matchingProperties.isEmpty)
			"select " + matchingProperties.map[p | p.getPropertyPath(aggregateRoot)].join(", ")
		else
			null
	}

	def private static List<String> getMatchingPropertyNamesToSelect(DomainObject returnType, DomainObject aggregateRoot) {
		returnType.getAllAttributes().filter[attr|getPropertyPath(attr.name, aggregateRoot) != null].map[name].toList
	}

	def private static String buildWhere(RepositoryOperation op) {
		if (op.hasHint("useName"))
			op.buildWhereFromOperationName()
		else
			op.buildWhereFromParameters()
	}

	def private static String buildWhereFromParameters(RepositoryOperation op) {
		val expressions = op.parameters.map[p | p.buildExpression()].join(" and ")
		if (expressions.length > 0)
			" where " + expressions
		else
			""
	}

	def private static String buildExpression(Parameter parameter) {
		val operation = parameter.getRepositoryOperation()
		val aggregateRoot = operation.getAggregateRoot()
		val propertyPath = getPropertyPath(parameter.name, aggregateRoot)
		if (propertyPath != null)
			propertyPath + " = :" + parameter.name
		else
			error(
				"Could not find an attribute '" + parameter.name + "' in domain object '" + aggregateRoot.name + "'. " +
				"Add gap to repository operation '" + operation.name + "' in repository '" + operation.repository.name + "'");
	}

	def private static String buildWhereFromOperationName(RepositoryOperation op) {
		val err="buildWhereFromOperationName is not implemented"
		error(err)
		err
	}

	def static boolean isValidationAnnotationToBeGeneratedForObject(DomainObject domainObject) {
		if (isDataTranferObject(domainObject))
			isValidationAnnotationToBeGenerated() && isDtoValidationAnnotationToBeGenerated()
		else
			isValidationAnnotationToBeGenerated()
	}

	def static boolean isValidationAnnotationToBeGeneratedForObject(Attribute attribute) {
		if (isDataTranferObject(attribute.getDomainObject()))
			isValidationAnnotationToBeGenerated() && isDtoValidationAnnotationToBeGenerated()
		else
			isValidationAnnotationToBeGenerated()
	}

	def static boolean isValidationAnnotationToBeGeneratedForObject(Reference reference) {
		if (isDataTranferObject(reference.getDomainObject()))
			isValidationAnnotationToBeGenerated() && isDtoValidationAnnotationToBeGenerated()
		else
			isValidationAnnotationToBeGenerated()
	}

	// Builder-related extensions
	def static List<Attribute> getBuilderAttributes(DomainObject domainObject) {
		domainObject.getAllAttributes().filter[a | !a.isUuid() && a != domainObject.getIdAttribute() && a.name != "version"].toList
	}

	def static List<Reference> getBuilderReferences(DomainObject domainObject) {
		domainObject.getAllReferences().toList
	}

	def static List<NamedElement> getBuilderConstructorParameters(DomainObject domainObject) {
		domainObject.getConstructorParameters();
	}

	def static List<NamedElement> getBuilderProperties(DomainObject domainObject) {
		val List<NamedElement> retVal = newArrayList
		retVal.addAll(domainObject.getBuilderAttributes)
		retVal.addAll(domainObject.getBuilderReferences)
		retVal
	}

	def static String getBuilderClassName(DomainObject domainObject) {
		domainObject.name + "Builder"
	}

	def static String getBuilderFqn(DomainObject domainObject) {
		domainObject.getBuilderPackage + "." + domainObject.getBuilderClassName()
	}

	def static boolean needsBuilder(DomainObject domainObject) {
		domainObject.^abstract == false;
	}

	def static boolean needsBuilder(Enum domainObject) {
		false;
	}
}
