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

import java.io.File
import java.io.FileWriter
import java.util.Collection
import java.util.List
import javax.inject.Inject
import org.sculptor.generator.util.DependencyConstraints
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import org.sculptor.generator.util.SingularPluralConverter
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.BasicType
import sculptormetamodel.CommandEvent
import sculptormetamodel.Consumer
import sculptormetamodel.DataTransferObject
import sculptormetamodel.DomainEvent
import sculptormetamodel.DomainObject
import sculptormetamodel.DomainObjectOperation
import sculptormetamodel.Entity
import sculptormetamodel.Enum
import sculptormetamodel.HttpMethod
import sculptormetamodel.Module
import sculptormetamodel.NamedElement
import sculptormetamodel.Operation
import sculptormetamodel.Parameter
import sculptormetamodel.Reference
import sculptormetamodel.Repository
import sculptormetamodel.RepositoryOperation
import sculptormetamodel.Resource
import sculptormetamodel.ResourceOperation
import sculptormetamodel.Service
import sculptormetamodel.ServiceOperation
import sculptormetamodel.Trait
import sculptormetamodel.TypedElement
import sculptormetamodel.ValueObject
import org.sculptor.generator.util.GenericAccessObjectManager
import org.eclipse.jdt.core.formatter.CodeFormatter
import org.eclipse.text.edits.TextEdit
import org.eclipse.jface.text.IDocument
import org.eclipse.jface.text.Document
import org.eclipse.jdt.core.ToolFactory
import java.util.regex.Pattern
import java.util.HashMap
import org.slf4j.LoggerFactory

class Helper {
	static val LOG = LoggerFactory::getLogger(typeof(Helper))

	@Inject var SingularPluralConverter singularPluralConverter
	@Inject var GenericAccessObjectManager genericAccessObjectManager

	@Inject extension Properties properties
	@Inject extension PropertiesBase propertiesBase
	@Inject extension HelperBase helperBase

	static val JAVA_EXT = ".java"

	def public String fileOutput(String fileName, OutputSlot slot, String text) {
		val fName = if (fileName.endsWith(JAVA_EXT))
				// convert package name to directory hierarchy
				fileName.substring(0, fileName.length - JAVA_EXT.length).replaceAll("\\.", "/") + JAVA_EXT
			else
				fileName
		val flTr = processPath(getProperty("outputSlot.path."+slot.name) + "/" + fName)

		val fl = new File(flTr)
		val overwrite = getProperty("outputSlot.overwrite."+slot.name, "false")
		if (!fl.exists || (fl.exists && "true" == overwrite)) {
			fl.parentFile.mkdirs()
			var out = new FileWriter(fl)
			out.write(if (fileName.endsWith(JAVA_EXT)) formatJavaCode(flTr, text) else text)
			out.close()
			LOG.debug("Created file : " + fl)
		} else {
			LOG.debug("Skipped file : " + fl)
		}
		""
	}

	def private formatJavaCode(String path, String code) {
		val newCode = extractJavaTypes(code)

		var String retVal = null
		val TextEdit textEdit = getCodeFormatter().format(CodeFormatter::K_COMPILATION_UNIT.bitwiseOr(CodeFormatter::F_INCLUDE_COMMENTS), newCode, 0, newCode.length(), 0, "\n")
		val IDocument doc = new Document(newCode)
		try {
			textEdit.apply(doc)
			retVal = doc.get()
		} catch (Exception e) {
			LOG.error("Error formating code for '{}'. Using original code from generator", path)
			retVal = code
		}
		retVal
	}

	var CodeFormatter codeFormatter

	def private getCodeFormatter() {
		if (codeFormatter == null) {
			val classLoader = Thread::currentThread().getContextClassLoader() ?: this.^class.getClassLoader()
			val props = new java.util.Properties()
			props.load(classLoader.getResourceAsStream("default-java-code-formatter.properties"))
			getProperty("java.code.formatter.props", "").split("[,; ]").forEach [
				val stream = classLoader.getResourceAsStream(it)
				if (stream != null) {
					LOG.debug("Loading properties for Java code formatter from file '{}'", it)
					props.load(classLoader.getResourceAsStream(it))
				} else {
					LOG.warn("File '{}' with properties for Java code formatter not found", it)
				}
			]
			codeFormatter = ToolFactory::createCodeFormatter(props)
		}
		codeFormatter
	}

	val typePattern = Pattern::compile("(([a-z]\\w+\\.)+([A-Z]\\w++))(\\s*[^(])")
	val anotPattern = Pattern::compile("@([a-z]\\w+(\\.\\w+)++)\\s*\\(")
	val packagePattern = Pattern::compile("package.*;")

	def private extractJavaTypes(String code) {
		val hm = new HashMap<String, String>()

		var matcher = typePattern.matcher(code)
		var sb = new StringBuffer()
		while(matcher.find) {
			val shortClass = matcher.group(3)
			var String repl
			if (hm.containsKey(shortClass) && !matcher.group(1).equals(hm.get(shortClass))
					|| matcher.group(1).startsWith("this.")
					|| shortClass.substring(0, 1).toUpperCase != shortClass.substring(0, 1)
			) {
				repl = matcher.group(0)
			} else {
				hm.put(shortClass, matcher.group(1))
				repl = shortClass + matcher.group(4)
			}
			matcher.appendReplacement(sb, repl);
		}
		matcher.appendTail(sb)

		matcher = anotPattern.matcher(sb.toString)
		sb = new StringBuffer()
		while(matcher.find) {
			val shortClass = matcher.group(2).substring(1)
			var String repl
			if (hm.containsKey(shortClass) && !matcher.group(1).equals(hm.get(shortClass))
					|| shortClass.substring(0, 1).toUpperCase != shortClass.substring(0, 1)
			) {
				repl = matcher.group(0)
			} else {
				hm.put(shortClass, matcher.group(1))
				repl = "@" + shortClass + "("
			}
			matcher.appendReplacement(sb, repl);
		}
		matcher.appendTail(sb)

		val matcher2 = packagePattern.matcher(sb.toString)
		matcher2.find
		sb.insert(matcher2.end, hm.values.sortBy[it].map["\nimport " + it + ";"].join)

		return sb.toString
	}

	def String javaFileName(String ne) {
		ne + ".java"
	}

	def String simpleMetaTypeName(NamedElement element) {
		element.^class.simpleName //name.split("::").last();
	}

	def String docMetaTypeName(NamedElement element) {
		simpleMetaTypeName(element);
	}

	// Use this witha includeExternal=false to retrieve all DomainObjects except those belonging
	// to external modules
	def dispatch Collection<Repository> getAllRepositories(Application app) {
		app.getAllRepositories(true);
	}

	def dispatch Collection<Repository> getAllRepositories(Module module) {
		module.domainObjects.filter[repository?.name != null].map[repository].sortBy[name];
	}

	def Collection<Repository> getAllRepositories(Application app, boolean includeExternal) {
		app.modules.map[it.getAllRepositories].flatten
			.filter[includeExternal || !aggregateRoot.module.external].sortBy[name];
	}

	// TODO VYHODIT
	def isGenerateQuick() {
		false
	}

	def List<Module> collectChangedModules(Application app) {
		if (!isGenerateQuick())
			app.modules
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
	def public Collection<DomainObject> getAllDomainObjects(Application app) {
		getAllDomainObjects(app, true)
	}


	// Use this witha includeExternal=false to retrieve all DomainObjects except those belonging
	// to external modules
	def Collection<DomainObject> getAllDomainObjects(Application app, boolean includeExternal) {
		app.collectChangedModules().filter[m | includeExternal || !m.external].map[domainObjects].flatten.sortBy[name]
	}

	def List<Module> changedModulesWithDependingModules(Application app) {
		app.changedModules().map[m | m.modulesDependingOn].flatten.toList;
	}

	def List<Module> changedModules(Application app) {
		val result = getChangedModules().map(e | e.moduleFor(app));
		if (result.contains(null)) newArrayList else result;
	}

	def Module moduleFor(String name, Application app) {
		app.modules.findFirst(m | m.name == name)
	}

	def List<Module> getModulesDependingOn(Module module) {
		DependencyConstraints::getModulesDependingOn(module);
	}

	def Collection<DomainObject> getNonEnumDomainObjects(Module module) {
		module.domainObjects.filter[d | !(d instanceof sculptormetamodel.Enum)].sortBy[e|e.name];
	}

	def Collection<Service> getAllServices(Application app) {
		app.getAllServices(true);
	}

	// Use this witha includeExternal=false to retrieve all DomainObjects except those belonging
	// to external modules
	def Collection<Service> getAllServices(Application app, boolean includeExternal) {
		app.modules.map[services].flatten.filter[s | includeExternal || !s.module.external].sortBy[s|s.name]
	}

	def Collection<Resource> getAllResources(Application app) {
		app.getAllResources(true);
	}

	// Use this witha includeExternal=false to retrieve all DomainObjects except those belonging
	// to external modules
	def Collection<Resource> getAllResources(Application app, boolean includeExternal) {
		app.modules.map[resources].flatten.filter[r | includeExternal || !r.module.external].sortBy[name]
	}

	def Collection<Consumer> getAllConsumers(Application app) {
		app.getAllConsumers(true);
	}

	// Use this witha includeExternal=false to retrieve all DomainObjects except those belonging
	// to external modules
	def Collection<Consumer> getAllConsumers(Application app, boolean includeExternal) {
		app.modules.map[consumers].flatten.filter[c | includeExternal || !c.module.external].sortBy[name]
	}

	def boolean hasConsumers(Application app) {
		!app.modules.map[consumers].flatten.isEmpty
	}

	def String formatJavaDoc(NamedElement element) {
		element.doc.formatJavaDoc
	}

	def String getServiceapiPackage(Service service) {
		getServiceapiPackage(service.module);
	}

	def String getServiceimplPackage(Service service) {
		getServiceimplPackage(service.module);
	}

	def String getRestPackage(Resource resource) {
		getRestPackage(resource.module);
	}

	def String getServiceproxyPackage(Service service) {
		getServiceproxyPackage(service.module);
	}

	def String getServicestubPackage(Service service) {
		getServicestubPackage(service.module);
	}

	def boolean isPagedResult(TypedElement e) {
		e.type == "PagedResult";
	}

	def String getAccessObjectResultTypeName(RepositoryOperation op) {
		if (op.isPagedResult()) 
			"java.util.List<" + op.domainObjectType.getDomainPackage() + "." + op.domainObjectType.name + ">"
		else
			op.getTypeName();
	}

	def String getExtendsAndImplementsLitteral(DomainObject domainObject) {
		 domainObject.getExtendsLitteral() + domainObject.getImplementsLitteral()
	}

	def String getExtendsLitteral(DomainObject domainObject) {
		if (domainObject.getExtendsClassName() == "")
			""
		else
			"extends " + domainObject.getExtendsClassName();
	}

	def String getExtendsClassNameIfExists(DomainObject domainObject) {
		if (domainObject.getExtends == null)
			domainObject.getDomainPackage() + "." + domainObject.name
		else
			domainObject.getExtends().getDomainPackage() + "." + domainObject.getExtends().name;
	}

	def String getExtendsClassName(DomainObject domainObject) {
		if ( (domainObject.getExtends() as Object) == null)
			if (domainObject.extendsName == null) domainObject.defaultExtendsClassName() else domainObject.extendsName
		else 
			domainObject.getExtends().getDomainPackage() + "." + domainObject.getExtends().name;
	}

	def dispatch String defaultExtendsClassName(DomainObject domainObject) {
		val result = defaultExtendsClass(domainObject.simpleMetaTypeName())
		if (result == "") abstractDomainObjectClass() else result;
	}

	def dispatch String defaultExtendsClassName(DataTransferObject domainObject) {
	defaultExtendsClass(domainObject.simpleMetaTypeName());
	}

	def dispatch String defaultExtendsClassName(Trait domainObject) {
		defaultExtendsClass(domainObject.simpleMetaTypeName());
	}

	def List<String> traitInterfaceNames(DomainObject domainObject) {
		domainObject.traits.map[e | e.getDomainPackage() + "." + e.name]
	}

	def String getImplementsLitteral(DomainObject domainObject) {
		if (domainObject.getImplementsInterfaceNames() == "")
			""
		else if (domainObject.getExtends != null && !domainObject.traitInterfaceNames().isEmpty )
			" implements " + domainObject.traitInterfaceNames().toCommaSeparatedString()
		else if (domainObject.getExtends != null)
			""
		else
			" implements " + domainObject.getImplementsInterfaceNames();
	}

	def String toCommaSeparatedString(List<String> values) {
		values.join(",")
	}

	def boolean isIdentifiable(DomainObject domainObject) {
		domainObject.attributes.exists[e | e.name == "id" && e.getTypeName() == "Long"];
	}

	def dispatch String getImplementsInterfaceNames(DomainObject domainObject) {
//		val interfaceNames = <String>newArrayList()
//		interfaceNames.addAll(domainObject.traitInterfaceNames())
//		if (domainObject.isIdentifiable)
//			interfaceNames.add(identifiableInterface)
//
//		toCommaSeparatedString(interfaceNames)

		val str = domainObject.traitInterfaceNames().join(",")
		if (domainObject.isIdentifiable)
			str + if (str.empty) identifiableInterface else "," + identifiableInterface
		else
			str
	}

	def dispatch String getImplementsInterfaceNames(DataTransferObject domainObject) {
		"java.io.Serializable, java.lang.Cloneable"
	}

	def dispatch String getImplementsInterfaceNames(Trait domainObject) {
		domainObject.getDomainPackage() + "." + domainObject.name + ", java.io.Serializable";
	}

	def dispatch String getImplementsInterfaceNames(DomainEvent domainObject) {
		fw("event.Event") + ", java.io.Serializable"
	}

	def dispatch String getImplementsInterfaceNames(CommandEvent domainObject) {
		fw("event.Event")
	}

	def dispatch String getImplementsInterfaceNames(Entity entity) {
		val list = <String> newArrayList()
		list.addAll(entity.traitInterfaceNames())
		if (entity.auditable)
			list.add(auditableInterface())
		if (entity.isIdentifiable())
			list.add(identifiableInterface())
		if (isFullyAuditable())
			list.add(fw("domain.FullAuditLog") + "<" + entity.getDomainPackage() + "." + entity.name + ">")

		toCommaSeparatedString(list);
	}

	def String getEjbInterfaces(Service service) {
		val pkg = service.getServiceapiPackage()
		val List<String> list = newArrayList
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

	def private String visibilityImpl(String visibility) {
		switch (visibility) {
				case null : "public "
				case "" : "public "
				case "package" : ""
				default : visibility + " "
		};
	}

	def String getAccessObjectInterfaceExtends(RepositoryOperation op) {
		val List<String> list = newArrayList
		if (op.hasPagingParameter())
			list.add(fw("accessapi.Pageable"))
		if (op.hasHint("cache"))
			list.add(fw("accessapi.Cacheable"))

		toCommaSeparatedString(list);
	}

	def dispatch String getVisibilityLitteralGetter(Attribute attribute) {
		visibilityImpl(attribute.visibility);
	}

	def dispatch boolean isSetterNeeded(Reference ref) {
		if (jpa())
			if (ref.changeable || (ref.isBasicTypeReference()) || (ref.isEnumReference()))
				!ref.isSetterPrivate()
			else
				notChangeableReferenceSetterVisibility() != "private"
		else
			true;
	}

	def dispatch boolean isSetterNeeded(Attribute attribute) {
		if (jpa())
			if (attribute.changeable)
				!attribute.isSetterPrivate()
			else
				notChangeablePropertySetterVisibility() != "private"
		else
			true;
	}

	def dispatch boolean isSetterPrivate(Attribute attribute) {
		attribute.getVisibilityLitteralSetter() == "private ";
	}

	def dispatch boolean isSetterPrivate(Reference ref) {
		ref.getVisibilityLitteralSetter() == "private "
	}

	def dispatch String getVisibilityLitteralSetter(Attribute attribute) {
		if (attribute.changeable)
			if (hasHint(attribute, "readonly"))
				"protected "
			else
				visibilityImpl(attribute.visibility)
		else
			"private ";
	}

	def String getVisibilityLitteral(Operation op) {
		visibilityImpl(op.visibility);
	}

	def dispatch boolean isPublicVisibility(Attribute att) {
		att.getVisibilityLitteralGetter().startsWith("public");
	}

	def dispatch boolean isPublicVisibility(Reference ref) {
		ref.getVisibilityLitteralGetter().startsWith("public");
	}

	def dispatch boolean isPublicVisibility(Operation op) {
		op.getVisibilityLitteral().startsWith("public");
	}

	def dispatch String getVisibilityLitteralGetter(Reference ref) {
		visibilityImpl(ref.visibility);
	}

	def dispatch String getVisibilityLitteralSetter(Reference ref) {
		if (ref.changeable)
			if (hasHint(ref, "readonly"))
				"protected "
			else
				visibilityImpl(ref.visibility)
		else
			"private "
	}

	def String getAbstractLitteral(DomainObject domainObject) {
		if (domainObject.^abstract)
			"abstract "
		else
			"";
	}

	def private Collection<Attribute> getSuperAllAttributes(DomainObject domainObject) {
		if (domainObject.getExtends == null)
			newArrayList
		else
			domainObject.getExtends.getAllAttributes();
	}

	def Collection<Attribute> getAllAttributes(DomainObject domainObject) {
		val allSuper = domainObject.getSuperAllAttributes()
		allSuper.addAll(domainObject.attributes)
		allSuper
	}

	def private Collection<Reference> getSuperAllReferences(DomainObject domainObject) {
		if (domainObject.getExtends == null)
			newArrayList
		else
			domainObject.getExtends.getAllReferences();
	}

	def Collection<Reference> getAllReferences(DomainObject domainObject) {
		val allSuper = domainObject.getSuperAllReferences()
		allSuper.addAll(domainObject.references )
		allSuper
	}

	def List<NamedElement> getSuperConstructorParameters(DomainObject domainObject) {
		if (domainObject.getExtends == null)
			newArrayList()
		else
			domainObject.getExtends.getConstructorParameters();
	}

	def List<NamedElement> getConstructorParameters(DomainObject domainObject) {
		var allParams = domainObject.getSuperConstructorParameters()
		allParams.addAll(domainObject.attributes.filter[a | (!a.changeable || a.required)])
		allParams = allParams.filter[a | a != domainObject.getIdAttribute()].toList()
		allParams.addAll(domainObject.references.filter[r | (!r.changeable || r.required)]);
		allParams
	}

	def List<NamedElement> getLimitedConstructorParameters(DomainObject domainObject) {
		domainObject.getConstructorParameters().filter[e | !e.isNullable() || e.isRequired()].toList
	}

	def List<NamedElement> getMinimumConstructorParameters(DomainObject domainObject) {
		domainObject.getConstructorParameters().filter[e | !e.isChangeable()].toList
	}

	def String getDefaultConstructorVisibility(DomainObject domainObject) {
		"protected";
	}

	def dispatch boolean isNullable(NamedElement element) {
		false;
	}

	def dispatch boolean isNullable(Attribute att) {
		att.nullable;
	}

	def dispatch boolean isNullable(Reference ref) {
		ref.nullable;
	}

	def dispatch boolean isRequired(NamedElement element) {
		false;
	}

	def dispatch boolean isRequired(Attribute att) {
		att.required;
	}

	def dispatch boolean isRequired(Reference ref) {
		ref.required;
	}

	def dispatch boolean isChangeable(NamedElement element) {
		false;
	}

	def dispatch boolean isChangeable(Attribute att) {
		att.changeable;
	}

	def dispatch boolean isChangeable(Reference ref) {
		ref.changeable;
	}

	def dispatch boolean isImmutable(DomainObject domainObject) {
		false;
	}

	def dispatch boolean isImmutable(Enum domainObject) {
		true;
	}

	def dispatch boolean isImmutable(ValueObject domainObject) {
		domainObject.immutable;
	}

	def Collection<Repository> getDelegateRepositories(Service service) {
		val reps = service.operations.filter[op | op.delegate != null].map[op | op.delegate.repository].toList
		reps.addAll(service.repositoryDependencies)
		reps.toSet
	}

	def dispatch Collection<Service> getDelegateServices(Service service) {
		val srvc = service.operations.filter[op | op.serviceDelegate != null].map[op | op.serviceDelegate.service].toList
		srvc.addAll(service.serviceDependencies)
		srvc.toSet
	}

	def dispatch Collection<Service> getDelegateServices(Resource resource) {
		val res = resource.operations.filter[op | op.delegate?.serviceDelegate != null].map[op | op.delegate.serviceDelegate.service].toList
		res.addAll(resource.serviceDependencies)
		res.toSet
	}

	def String getSetAccessor(NamedElement element) {
		"set" + element.name.toFirstUpper();
	}

	def dispatch String getGetAccessor(NamedElement element) {
		"get" + element.name.toFirstUpper();
	}

	def dispatch String getGetAccessor(TypedElement e) {
		e.getGetAccessor("");
	}

	def String getAccessNormalizedName(RepositoryOperation op) {
		if (op.accessObjectName == null || op.accessObjectName == "")
			op.name.toFirstUpper() + "Access" 
		else
			op.accessObjectName.toFirstUpper()
	}

	def String getAccessBase(RepositoryOperation op) {
		val className = ( if (op.getThrows == null || op.getThrows == "")
				accessBaseClass()
			else
				accessBaseWithExceptionClass())

		if (className.endsWith(">"))
				className
			else
				className + "<Object>"
	}

	def dispatch boolean hasPagingParameter(RepositoryOperation op) {
		op.getPagingParameter() != null
	}

	def dispatch Parameter getPagingParameter(RepositoryOperation op) {
		op.parameters.findFirst(e | e.isPagingParameter())
	}

	def dispatch boolean hasPagingParameter(ServiceOperation op) {
		op.getPagingParameter() != null
	}

	def dispatch Parameter getPagingParameter(ServiceOperation op) {
		op.parameters.findFirst(e | e.isPagingParameter())
	}

	def boolean isPagingParameter(Parameter param) {
		param.type == "PagingParameter";
	}

	def boolean isPaged(Operation op) {
		op.hasHint("paged")
	}

	def Attribute getIdAttribute(DomainObject domainObject) {
		domainObject.getAllAttributes().findFirst(a | a.name == "id");
	}

	def String getIdAttributeType(DomainObject domainObject) {
		val idAttribute = domainObject.getIdAttribute()
		if (idAttribute == null) null else idAttribute.getTypeName()
	}

	def Collection<DomainObject> getSubclasses(DomainObject domainObject) {
		domainObject.module.application.getAllDomainObjects().filter[d | d.getExtends == domainObject].toSet
	}

	def Collection<DomainObject> getAllSubclasses(DomainObject domainObject) {
		val subs = domainObject.getSubclasses().toList
		subs.addAll(domainObject.getSubclasses().map[d | d.getAllSubclasses()].flatten)
		subs.toSet
	}

	def boolean hasOwnDatabaseRepresentation(DomainObject domainObject) {
		domainObject.isEntityOrPersistentValueObject();
	}

	// Include Entity and persistent ValueObject,
	// skip BasicType, Enum and non persistent ValueObject
	def boolean isEntityOrPersistentValueObject(DomainObject domainObject) {
		(domainObject.isPersistent() && ! (domainObject instanceof BasicType))
	}

	def dispatch boolean isPersistent(DomainObject domainObject) {
		false
	}

	def dispatch boolean isPersistent(Entity domainObject) {
		true
	}

	def dispatch boolean isPersistent(ValueObject domainObject) {
		domainObject.persistent
	}

	def dispatch boolean isPersistent(DataTransferObject domainObject) {
		false;
	}

	def dispatch boolean isPersistent(BasicType domainObject) {
		true;
	}

	def boolean isOneToOne(Reference ref) {
		!ref.many && ref.opposite != null && !ref.opposite.many;
	}

	def boolean isOneToMany(Reference ref) {
		ref.many && ((ref.opposite != null && !ref.opposite.many) || (ref.opposite == null && ref.isInverse()));
	}

	def boolean isManyToMany(Reference ref) {
		ref.many && ((ref.opposite != null && ref.opposite.many) || (ref.opposite == null && !ref.isInverse()));
	}

	//
	// Hint support
	//
	def boolean hasHint(NamedElement element, String parameterName) {
		hasHintImpl(element.hint, parameterName);
	}

	def boolean hasHint(NamedElement element, String parameterName, String separator) {
		getHintImpl(element.hint, parameterName, separator) != null
	}

	def String getHint(NamedElement element, String parameterName) {
		getHintImpl(element.hint, parameterName, ",;")
	}

	def String getHintOrDefault(NamedElement element, String parameterName, String defaultValue) {
		ifNull(element.getHint(parameterName), defaultValue);
	}

	def String getHintOrDefault(NamedElement element, String parameterName, String separator, String defaultValue) {
		ifNull(element.getHint(parameterName, separator), defaultValue);
	}

	def String ifNull(String value, String defaultValue) {
		if (value == null) defaultValue else value
	}

	def String ifEmpty(String value, String defaultValue) {
		if (value != null && value.length == 0) defaultValue else value
	}

	def String ifNullOrEmpty(String value, String defaultValue) {
		if (value == null || value.length == 0) defaultValue else value
	}

	def String getHint(NamedElement element, String parameterName, String separator) {
		getHintImpl(element.hint, parameterName, separator)
	}

	// TODO CONSTRAINTS
	def boolean checkCyclicDependencies(Module module) {
		// DependencyConstraints.checkCyclicDependencies(module)
		true
	}

	def boolean checkAggregateReferences(Application app) {
		// AggregateConstraints.checkAggregateReferences(app);
		true
	}

	def Collection<String> getAllGeneratedExceptions(Module module) {
		val exc = module.services.map[operations].flatten.map[op | getGeneratedExceptions(op)].flatten.toList
		exc.addAll(module.getAllRepositories().map[operations].flatten.map[op | getGeneratedExceptions(op)].flatten)
		exc.toSet
	}

	def Collection<String> getAllGeneratedWebServiceExceptions(Module module) {
		module.services.filter[e | e.webService].map[operations].flatten
			.map[op | op.getGeneratedExceptions()].flatten.toSet
	}

	def dispatch boolean hasNotFoundException(RepositoryOperation op) {
		op.exceptions.contains(getExceptionPackage(op.repository.aggregateRoot.module) + "." + op.repository.aggregateRoot.name + "NotFoundException")
	}

	def dispatch boolean hasNotFoundException(ServiceOperation op) {
		op.exceptions.exists(e|e.endsWith("NotFoundException"))
	}

	// removes last s to make the word into singular
	def String singular(String str) {
		singularPluralConverter.toSingular(str)
	}

	// adds s to the end to make the word into plural
	def String plural(String str) {
		singularPluralConverter.toPlural(str)
	}

	def DomainObject getRootExtends(DomainObject domainObject) {
		if (domainObject?.getExtends == null)
			domainObject
		else
			domainObject.getExtends.getRootExtends();
	}

	def List<Reference> getNaturalKeyReferences(DomainObject domainObject) {
		domainObject.references.filter[a | a.naturalKey].toList
	}

	def List<Reference> getAllNaturalKeyReferences(DomainObject domainObject) {
		if (domainObject.getExtends == null)
			domainObject.getNaturalKeyReferences()
		else {
			val refs = domainObject.getExtends.getAllNaturalKeyReferences()
			refs.addAll(domainObject.getNaturalKeyReferences())
			refs
		}
	}

	def boolean hasNaturalKey(DomainObject domainObject) {
		!domainObject.getAllNaturalKeyAttributes().isEmpty || !domainObject.getAllNaturalKeyReferences().isEmpty;
	}

	def List<Attribute> getNaturalKeyAttributes(DomainObject domainObject) {
		domainObject.attributes.filter[a | a.naturalKey].toList
	}

	def List<Attribute> getAllNaturalKeyAttributes(DomainObject domainObject) {
		if (domainObject.getExtends == null)
			domainObject.getNaturalKeyAttributes()
		else {
			val exts = domainObject.getExtends.getAllNaturalKeyAttributes()
			exts.addAll(domainObject.getNaturalKeyAttributes())
			exts
		}
	}

	def List<NamedElement> getAllNaturalKeys(DomainObject domainObject) {
		val List<NamedElement> keys = newArrayList()
		keys.addAll(getAllNaturalKeyAttributes(domainObject))
		keys.addAll(getAllNaturalKeyReferences(domainObject))
		keys
	}

	def dispatch boolean isBasicTypeReference(NamedElement ref) {
	false;
	}

	def dispatch boolean isBasicTypeReference(Reference ref) {
		!ref.many && (ref.to instanceof BasicType)
	}

	def List<Reference> getAllBasicTypeReferences(DomainObject domainObject) {
		domainObject.getAllReferences().filter[r | r.isBasicTypeReference()].toList
	}

	def List<Reference> getBasicTypeReferences(DomainObject domainObject) {
		domainObject.references.filter[r | isBasicTypeReference(r)].toList
	}

	def dispatch boolean isEnumReference(NamedElement ref) {
		false;
	}

	def dispatch boolean isEnumReference(Reference ref) {
		!ref.many && (ref.to instanceof sculptormetamodel.Enum)
	}

	def Collection<Reference> getEnumReferences(DomainObject domainObject) {
		domainObject.references.filter[r | isEnumReference(r)].toList
	}

	def Collection<Reference> getAllEnumReferences(DomainObject domainObject) {
		val refs = domainObject.getSuperAllEnumReferences()
		refs.addAll(domainObject.getEnumReferences())
		refs
	}

	def private Collection<Reference> getSuperAllEnumReferences(DomainObject domainObject) {
		if (domainObject.getExtends == null)
			newArrayList
		else
			domainObject.getExtends.getAllEnumReferences()
	}

	def Attribute getIdentifierAttribute(sculptormetamodel.Enum ^enum) {
		if (enum.hasNaturalKey())
			enum.attributes.findFirst[a | a.naturalKey]
		else
			null;
	}

	def boolean isEmbeddable(DomainObject domainObject) {
		// Only BasicType is embeddable
		domainObject instanceof BasicType
	}

	def boolean isDataTranferObject(DomainObject domainObject) {
		domainObject instanceof DataTransferObject
	}

	def boolean hasSubClass(DomainObject domainObject) {
		((getSubclasses(domainObject) != null) && (!getSubclasses(domainObject).isEmpty))
	}

	def boolean hasSuperClass(DomainObject domainObject) {
		(domainObject.getExtends != null)
	}

	def dispatch DomainObject getDomainObject(NamedElement elem) {
		error("NamedElement doesn't belong to a DomainObject: " + elem)
		null;
	}

	def dispatch DomainObject getDomainObject(Attribute attribute) {
		(attribute.eContainer as DomainObject)
	}

	def Operation getOperation(Parameter parameter) {
		(parameter.eContainer as Operation)
	}

	def RepositoryOperation getRepositoryOperation(Parameter parameter) {
		if (parameter.getOperation() instanceof RepositoryOperation)
			(parameter.getOperation() as RepositoryOperation)
		else
			null;
	}

	def ServiceOperation getServiceOperation(Parameter parameter) {
		if (parameter.getOperation() instanceof ServiceOperation)
			(parameter.getOperation() as ServiceOperation)
		else
			null;
	}

	def dispatch DomainObject getDomainObject(Reference ref) {
		(ref.eContainer as DomainObject)
	}

	def boolean hasSimpleNaturalKey(DomainObject domainObject) {
		!domainObject.hasCompositeNaturalKey();
	}

	def boolean hasCompositeNaturalKey(DomainObject domainObject) {
		domainObject.getAllNaturalKeys().size > 1;
	}

	def dispatch boolean isSimpleNaturalKey(Attribute attribute) {
		(attribute.naturalKey && hasSimpleNaturalKey(attribute.getDomainObject()));
	}

	def dispatch boolean isSimpleNaturalKey(Reference ref) {
		(ref.naturalKey && hasSimpleNaturalKey(ref.from));
	}

	def Attribute getUuid(DomainObject domainObject) {
		domainObject.getAllAttributes().findFirst(e | e.isUuid())
	}

	def boolean isUuid(Attribute attribute) {
		attribute.name == "uuid";
	}

	def Collection<sculptormetamodel.Enum> getAllEnums(Application app) {
		app.modules.map[domainObjects].flatten
			.filter[d | d instanceof sculptormetamodel.Enum].map[(it as sculptormetamodel.Enum)].toSet
	}

	def boolean isValueObjectReference(Reference ref) {
		!ref.many && ref.to instanceof ValueObject
	}

	def List<String> getEntityListeners(DomainObject domainObject) {
		var List<String> list = newArrayList()
		if (domainObject instanceof Entity || domainObject instanceof ValueObject)
			list.add(validationEntityListener())
		else
			list = null

		list
	}

	def String getValidationEntityListener(DomainObject domainObject) {
		if (isValidationAnnotationToBeGenerated() && (domainObject instanceof Entity) || (domainObject instanceof ValueObject))
			validationEntityListener()
		else
			null
	}

	def dispatch String getAuditEntityListener(DomainObject domainObject) {
		null;
	}

	def dispatch String getAuditEntityListener(Entity entity) {
		if (entity.auditable)
			auditEntityListener()
		else
			null;
	}

	def String dataSourceName(Application app, String persistenceUnitName) {
		if (getDbProduct == "hsqldb-inmemory" && applicationServer() == "jetty")
			"applicationDS"
		else if (app.isDefaultPersistenceUnitName(persistenceUnitName))
			app.name + "DS"
		else
			persistenceUnitName + "DS";
	}

	def String dataSourceName(Application app) {
		app.dataSourceName(app.persistenceUnitName());
	}

	def dispatch boolean isXmlElementToBeGenerated(Attribute attr) {
	isXmlBindAnnotationToBeGenerated() &&
		isXmlBindAnnotationToBeGenerated(attr.getDomainObject().simpleMetaTypeName());
	}

	def dispatch boolean isXmlElementToBeGenerated(Reference ref) {
		isXmlBindAnnotationToBeGenerated() &&
			isXmlBindAnnotationToBeGenerated(ref.from.simpleMetaTypeName());
	}

	def boolean isXmlRootToBeGenerated(DomainObject domainObject) {
		isXmlBindAnnotationToBeGenerated() &&
			isXmlBindAnnotationToBeGenerated(domainObject.simpleMetaTypeName()) &&
			("true" == domainObject.getHint("xmlRoot"));
	}

	def List<String> reversePackageName(String packageName) {
		packageName.split('\\.').reverse();
	}

	def List<String> supportedCollectionTypes() {
		newArrayList("List", "Set", "Bag", "Map")
	}

	def List<String> supportedTemporalTypes() {
		newArrayList("Date", "DateTime", "Timestamp")
	}

	def List<String> supportedNumericTypes() {
		newArrayList("integer", "long", "float", "double", "Integer", "Long", "Float", "Double", "BigInteger", "BigDecimal")
	}

	def String persistenceUnitName(Application app) {
		if (isJpaProviderAppEngine())
			"transactions-optional"
		else
			app.name + "EntityManagerFactory"
	}

	def boolean isDefaultPersistenceUnitName(Application app, String unitName) {
		unitName == app.persistenceUnitName();
	}

	def String persistenceContextUnitName(Repository repository) {
		if (usePersistenceContextUnitName() && repository.aggregateRoot.module.persistenceUnit != "null")
			repository.aggregateRoot.module.persistenceUnit
		else
			""
	}

	def boolean isString(Attribute attribute) {
		(attribute.type == "String") && !attribute.isCollection();
	}

	def boolean isBoolean(Attribute attribute) {
		newArrayList("Boolean", "boolean").contains(attribute.type) && !attribute.isCollection();
	}

	def boolean isNumeric(Attribute attribute) {
	supportedNumericTypes().contains(attribute.type) && !attribute.isCollection();
	}

	def boolean isTemporal(Attribute attribute) {
	supportedTemporalTypes().contains(attribute.type) && !attribute.isCollection();
	}

	def boolean isDate(Attribute attribute) {
	attribute.type == "Date";
	}

	def boolean isDateTime(Attribute attribute) {
	attribute.type == "DateTime" || attribute.type == "Timestamp";
	}

	def boolean isPrimitive(Attribute attribute) {
		isPrimitiveType(attribute.getTypeName()) && !attribute.isCollection();
	}

	def dispatch boolean isUnownedReference(NamedElement elem) {
		false;
	}

	def dispatch boolean isUnownedReference(Reference ref) {
		(isJpaProviderAppEngine() || nosql()) && ref.from.isPersistent() && !ref.transient && ref.to.hasOwnDatabaseRepresentation()
			&& !ref.hasOwnedHint() && (! ref.from.getAggregate().contains(ref.to) || ref.hasUnownedHint());
	}

	def boolean hasOwnedHint(Reference ref) {
		ref.hasHint("owned") || (ref.opposite != null && ref.opposite.hasHint("owned"));
	}

	def boolean hasUnownedHint(Reference ref) {
		ref.hasHint("unowned") || (ref.opposite != null && ref.opposite.hasHint("unowned"));
	}

	def dispatch String unownedReferenceSuffix(NamedElement elem) {
		""
	}

	def dispatch String unownedReferenceSuffix(Reference ref) {
		if (ref.isUnownedReference())
			(if (ref.many) "Ids" else "Id")
		else
			"";
	}

	def dispatch boolean isCollection(Attribute attribute) {
		attribute.collectionType != null && supportedCollectionTypes().contains(attribute.collectionType);
	}

	def dispatch boolean isCollection(Reference reference) {
		reference.collectionType != null && supportedCollectionTypes().contains(reference.collectionType);
	}

	def boolean isList(Reference ref) {
		"list" == ref.getCollectionType()
	}


	def boolean useJpaBasicAnnotation(Attribute attr) {
		isJpaProviderAppEngine() && (attr.getTypeName() == "com.google.appengine.api.datastore.Key");
	}

	def boolean useJpaLobAnnotation(Attribute attr) {
		(attr.type == "Clob" || attr.type == "Blob")
	}

	def dispatch String extendsLitteral(Repository repository) {
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

	def dispatch String extendsLitteral(Service service) {
		val prop = defaultExtendsClass(service.simpleMetaTypeName())
		if (prop != '')
			"extends " + prop
		else
			"";
	}

	def dispatch String extendsLitteral(Resource resource) {
		val prop = defaultExtendsClass(resource.simpleMetaTypeName())
		if (prop != '')
			"extends " + prop
		else
			"";
	}

	// The root of the aggregate that the domainObject belongs to
	def DomainObject getAggregateRootObject(DomainObject domainObject) {
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

	def boolean bothEndsInSameAggregateRoot(Reference ref) {
		ref.to.getAggregateRootObject() == ref.from.getAggregateRootObject();
	}

	// All DomainObjects in same aggregate group as the domainObject
	def Collection<DomainObject> getAggregate(DomainObject domainObject) {
		if (domainObject.isEntityOrPersistentValueObject())
			domainObject.getAggregateImpl()
		else
			newArrayList(domainObject)
	}

	def private Collection<DomainObject> getAggregateImpl(DomainObject domainObject) {
		if (domainObject.aggregateRoot) {
			domainObject.collectAggregateObjects()
		} else {
			val root = domainObject.getAggregateRootObject()
			if (root == null || root == domainObject) newArrayList(domainObject) else root.getAggregate()
		}
	}

	def private Collection<DomainObject> collectAggregateObjects(DomainObject domainObject) {
		val List<DomainObject> aggrSet = newArrayList()

		aggrSet.add(domainObject);
		aggrSet.addAll(domainObject.references.filter[e | !e.to.isAggregateRoot && e.to.isEntityOrPersistentValueObject()]
				.map[r | r.to.collectAggregateObjects()].flatten)
		aggrSet
	}

	// when using multiple persistence units it must be possible to define separate JpaFlushEagerInterceptor
	def String getJpaFlushEagerInterceptorClass(Module module) {
		if (hasProperty("jpa.JpaFlushEagerInterceptor." + module.persistenceUnit))
			getProperty("jpa.JpaFlushEagerInterceptor." + module.persistenceUnit)
		else
			fw("errorhandling.JpaFlushEagerInterceptor")
	}

	def dispatch boolean validateNotNullInConstructor(NamedElement any) {
		false;
	}

	def dispatch boolean validateNotNullInConstructor(Reference ref) {
		(!ref.isNullable() && !ref.changeable && (notChangeableReferenceSetterVisibility() == "private"));
	}

	def dispatch boolean validateNotNullInConstructor(Attribute att) {
	!att.isNullable() && !att.isPrimitive();
	}

	def Module getModule(NamedElement elem) {
		if (elem == null || elem instanceof Module)
			(elem as Module)
		else
			(elem.eContainer as NamedElement).getModule();
	}

	def String toStringStyle(DomainObject domainObject) {
		if (domainObject.hasHint("toStringStyle"))
			domainObject.getHint("toStringStyle")
		else if (hasProperty("toStringStyle"))
			getProperty("toStringStyle")
		else
			null
	}

	def boolean isEventSubscriberOperation(Operation op) {
		op.name == "receive" && op.parameters.size == 1 && op.parameters.head.type == fw("event.Event")
	}

	def String errorCodeType(Module module) {
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

	def dispatch boolean isImplementedInGapClass(DomainObjectOperation op) {
		(!op.^abstract && !op.hasHint("trait")) || (op.^abstract && op.hasHint("trait"))
	}

	def dispatch boolean isImplementedInGapClass(ServiceOperation op) {
		(op.delegate == null && op.serviceDelegate == null);
	}

	def dispatch boolean isImplementedInGapClass(ResourceOperation op) {
		(op.delegate == null && !(op.parameters.isEmpty && op.returnString != null && op.httpMethod == HttpMethod::GET));
	}

	def HttpMethod mapHttpMethod(String methodName) {
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

	def String removeSuffix(String str, String suffix) {
		if (str.endsWith(suffix))
			str.substring(0, str.length - suffix.length)
		else
			str
	}

	def String getDomainResourceName(Resource resource) {
		resource.name.removeSuffix("Resource");
	}

	def String getXStreamAliasName(DomainObject domainObject) {
		domainObject.name.removeSuffix("DTO").removeSuffix("Dto");
	}

	def String getXmlRootElementName(DomainObject domainObject) {
		domainObject.name.removeSuffix("DTO").removeSuffix("Dto");
	}

	def boolean isRestRequestParameter(Parameter param) {
		!getNotRestRequestParameter().contains(param.type);
	}

	def dispatch String getApplicationBasePackage(DomainObject domainObject) {
		domainObject.module.application.basePackage;
	}

	def dispatch String getApplicationBasePackage(Reference reference) {
		getApplicationBasePackage(reference.getDomainObject());
	}

	def dispatch String getApplicationBasePackage(Attribute attribute) {
		getApplicationBasePackage(attribute.getDomainObject());
	}

	def DomainObject getAggregateRoot(RepositoryOperation op) {
		op.repository.aggregateRoot;
	}

	def dispatch String getAggregateRootTypeName(Repository repository) {
		repository.aggregateRoot.getDomainObjectTypeName();
	}

	def dispatch String getAggregateRootTypeName(RepositoryOperation op) {
		op.repository.getAggregateRootTypeName();
	}

	def String getAggregateRootPropertiesTypeName(RepositoryOperation op) {
		op.repository.getAggregateRootTypeName() + "Properties";
	}

	def boolean isOrdinaryEnum(sculptormetamodel.Enum ^enum) {
		( enum.getIdentifierAttribute() == null )
	}

	def sculptormetamodel.Enum getEnum(Reference ref) {
		if (ref.isEnumReference())
			(ref.to as sculptormetamodel.Enum)
		else {
			error("Reference is not of type enum")
			null
		}
	}

	def boolean containsNonOrdinaryEnums(Application application) {
		application.getAllEnums().exists(e|!e.isOrdinaryEnum());
	}

	def boolean hasParameters(RepositoryOperation op) {
		op.parameters != null && !op.parameters.isEmpty;
	}

	def boolean hasAttribute(DomainObject domainObject, String name) {
		domainObject.getAllAttributes().exists(a | a.name == name);
	}

	def boolean hasReference(DomainObject domainObject, String name) {
		domainObject.getAllReferences().exists(a | a.name == name);
	}

	def boolean hasAttributeOrReference(DomainObject domainObject, String name) {
		domainObject.hasAttribute(name) || domainObject.hasReference(name);
	}

	def private String getPropertyPath(String propertyName, DomainObject aggregateRoot) {
		if (propertyName.contains("_"))
			propertyName.replaceAll("_", ".")
		else if (aggregateRoot.hasAttributeOrReference(propertyName))
			propertyName
		else if (aggregateRoot.getAllReferences().exists(e | e.to.hasAttributeOrReference(propertyName)))
			aggregateRoot.getAllReferences().findFirst(e | e.to.hasAttributeOrReference(propertyName)).name + "." + propertyName
		else
			null;
	}

	def String getDomainObjectTypeName(DomainObject domainObject) {
		domainObject.getDomainPackage + "." + domainObject.name
	}

	def String getGenericResultTypeName(RepositoryOperation op) {
		if (op.collectionType != null || op.isPagedResult())
			op.getTypeName().replaceAll(getDomainObjectTypeName(op.domainObjectType),"R")
		else
			"R"
	}

	def String getResultTypeName(RepositoryOperation op) {
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

	def String getAccessObjectResultTypeName2(RepositoryOperation op) {
		if (op.isPagedResult())
			"PagedResult<" + op.getResultTypeName() + ">"
		else if (op.collectionType != null)
			"List<" + op.getResultTypeName() + ">"
		else
			op.getResultTypeName()
	}

	def String getResultTypeNameForMapping(RepositoryOperation op) {
		if (op.useTupleToObjectMapping())
			"javax.persistence.Tuple"
		else
			op.getResultTypeName()
	}

	def String getNotFoundExceptionName(RepositoryOperation op) {
		getExceptionPackage(op.module) + "." +
		(if (op.domainObjectType != null)
			op.domainObjectType.name
		else
			"") + "NotFoundException"
	}

	def boolean throwsNotFoundException(RepositoryOperation op) {
		op.getThrows != null && op.getThrows.contains(op.getNotFoundExceptionName());
	}

	def String removeSurrounding(String s, String char) {
		if (s.startsWith(char) && s.endsWith(char))
			s.substring(1, s.length -1)
		else
			s;
	}

	def boolean hasHintEquals(NamedElement element, String parameterName, String parameterValue) {
		element.hasHint(parameterName) && element.getHint(parameterName) == parameterValue;
	}

	def boolean isGeneratedFinder(RepositoryOperation op) {
		generateFinders() &&
				!op.hasHint("gap") &&
						(op.isQueryBased() || op.isConditionBased());
	}

	def boolean isQueryBased(RepositoryOperation op) {
		isJpa2() && op.hasHint("query");
	}

	def boolean isConditionBased(RepositoryOperation op) {
		(op.hasHint("construct") || op.hasHint("build") || op.hasHint("condition") || op.hasHint("select") || op.name.startsWith("find"));
	}

	// TODO: quick solution, it would be better to implement a new access strategy
	def boolean useGenericAccessStrategy(RepositoryOperation op) {
		isJpa2() &&
				(op.name == "findAll" ||
				 op.name == "findByQuery" ||
				 op.name == "findByExample" ||
				 op.name == "findByKeys" ||
				 op.name == "findByNaturalKeys" ||
				 op.name == "findByCondition" ||
				 op.name == "findByCriteria");
	}

	def boolean useTupleToObjectMapping(RepositoryOperation op) {
		isJpa2() && (!op.hasHint("construct") && (op.hasHint("map") || op.isReturningDataTranferObject()))
	}

	def private boolean isReturningDataTranferObject(RepositoryOperation op) {
		(op.domainObjectType != null && op.domainObjectType.isDataTranferObject());
	}

	def String buildConditionalCriteria(RepositoryOperation op) {
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

	def String buildQuery(RepositoryOperation op) {
		val query = op.getHintOrDefault("query", ";", "")
		if (query.isNamedQuery() || query.containsSqlPart())
			query
		else
			"select object(o) from " + op.getAggregateRoot().name + " o where " + query
	}

	def private boolean isNamedQuery(String query) {
		!query.trim().contains(" ")
	}

	def private boolean containsSqlPart(String query) {
		(query.contains("select") || query.contains("from") || query.contains("where") || query.contains("orderBy"))
	}

	def private String buildSelect(RepositoryOperation op) {
		if (op.domainObjectType == null || op.isReturningAggregateRoot())
			""
		else
			op.buildSelectFromReturnType()
	}

	def private boolean isReturningAggregateRoot(RepositoryOperation op) {
		(op.getAggregateRoot() == op.domainObjectType)
	}

	def private boolean isReturningPrimitiveType(RepositoryOperation op) {
		(op.type != null && isPrimitiveType(op.getTypeName()))
	}

	def private String buildSelectFromReturnType(RepositoryOperation op) {
		if (op.buildSelectForReference() != null)
			op.buildSelectForReference()
		else if (op.buildSelectUsingAttributes() != null)
			op.buildSelectUsingAttributes()
		else
			error(
				"Could not set select from return type for domain object '" + op.getAggregateRoot().name + "'. " +
				"Add gap or select to repository operation '" + op.name + "' in repository '" + op.repository.name + "'")
			""
	}

	def private String buildSelectForReference(RepositoryOperation op) {
		val path = op.getReferencePathFromReturnType()
		if (path != null)
			"select " + path
		else
			null
	}

	def private String buildSelectUsingAttributes(RepositoryOperation op) {
		val returnType = op.domainObjectType
		val aggregateRoot = op.getAggregateRoot()
		val matchingProperties = getMatchingPropertyNamesToSelect(returnType, aggregateRoot)
		if (!matchingProperties.isEmpty)
			"select " + matchingProperties.map[p | p.getPropertyPath(aggregateRoot)].join(", ")
		else
			null
	}

	def private List<String> getMatchingPropertyNamesToSelect(DomainObject returnType, DomainObject aggregateRoot) {
		returnType.getAllAttributes().filter[attr|getPropertyPath(attr.name, aggregateRoot) != null].map[name].toList
	}

	def private String buildWhere(RepositoryOperation op) {
		if (op.hasHint("useName"))
			op.buildWhereFromOperationName()
		else
			op.buildWhereFromParameters()
	}

	def private String buildWhereFromParameters(RepositoryOperation op) {
		val expressions = op.parameters.map[p | p.buildExpression()].join(" and ")
		if (expressions.length > 0)
			" where " + expressions
		else
			""
	}

	def private String buildExpression(Parameter parameter) {
		val operation = parameter.getRepositoryOperation()
		val aggregateRoot = operation.getAggregateRoot()
		val propertyPath = getPropertyPath(parameter.name, aggregateRoot)
		if (propertyPath != null)
			propertyPath + " = :" + parameter.name
		else {
			error(
				"Could not find an attribute '" + parameter.name + "' in domain object '" + aggregateRoot.name + "'. " +
				"Add gap to repository operation '" + operation.name + "' in repository '" + operation.repository.name + "'")
			""
		}
	}

	def private String buildWhereFromOperationName(RepositoryOperation op) {
		val err="buildWhereFromOperationName is not implemented"
		error(err)
		err
	}

	def dispatch boolean isValidationAnnotationToBeGeneratedForObject(DomainObject domainObject) {
		if (isDataTranferObject(domainObject))
			isValidationAnnotationToBeGenerated() && isDtoValidationAnnotationToBeGenerated()
		else
			isValidationAnnotationToBeGenerated()
	}

	def dispatch boolean isValidationAnnotationToBeGeneratedForObject(Attribute attribute) {
		if (isDataTranferObject(attribute.getDomainObject()))
			isValidationAnnotationToBeGenerated() && isDtoValidationAnnotationToBeGenerated()
		else
			isValidationAnnotationToBeGenerated()
	}

	def dispatch boolean isValidationAnnotationToBeGeneratedForObject(Reference reference) {
		if (isDataTranferObject(reference.getDomainObject()))
			isValidationAnnotationToBeGenerated() && isDtoValidationAnnotationToBeGenerated()
		else
			isValidationAnnotationToBeGenerated()
	}

	// Builder-related extensions
	def List<Attribute> getBuilderAttributes(DomainObject domainObject) {
		domainObject.getAllAttributes().filter[a | !a.isUuid() && a != domainObject.getIdAttribute() && a.name != "version"].toList
	}

	def List<Reference> getBuilderReferences(DomainObject domainObject) {
		domainObject.getAllReferences().toList
	}

	def List<NamedElement> getBuilderConstructorParameters(DomainObject domainObject) {
		domainObject.getConstructorParameters();
	}

	def List<NamedElement> getBuilderProperties(DomainObject domainObject) {
		val List<NamedElement> retVal = newArrayList
		retVal.addAll(domainObject.getBuilderAttributes)
		retVal.addAll(domainObject.getBuilderReferences)
		retVal
	}

	def String getBuilderClassName(DomainObject domainObject) {
		domainObject.name + "Builder"
	}

	def String getBuilderFqn(DomainObject domainObject) {
		domainObject.getBuilderPackage + "." + domainObject.getBuilderClassName()
	}

	def dispatch boolean needsBuilder(DomainObject domainObject) {
		domainObject.^abstract == false;
	}

	def dispatch boolean needsBuilder(Enum domainObject) {
		false;
	}

	/**
	 * Get the generic type declaration for generic access objects.
	 */
	def String getGenericType(RepositoryOperation op) {
		genericAccessObjectManager.getGenericType(op)
	}

	def boolean isGenericAccessObject(RepositoryOperation op) {
		genericAccessObjectManager.isGenericAccessObject(op)
	}

	def boolean hasAccessObjectPersistentClassConstructor(RepositoryOperation op) {
		genericAccessObjectManager.isPersistentClassConstructor(op)
	}

	def dispatch void addDefaultValues(Repository repository) {
		repository.getOperations().forEach[op | addDefaultValues(op)]
	}

	def dispatch void addDefaultValues(RepositoryOperation operation) {
		val strategy = genericAccessObjectManager.getStrategy(operation.getName())
		if (strategy != null) {
			strategy.addDefaultValues(operation);
		}
	}
}
