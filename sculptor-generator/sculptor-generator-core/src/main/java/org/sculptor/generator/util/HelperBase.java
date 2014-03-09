/*
 * Copyright 2013 The Sculptor Project Team, including the original 
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

package org.sculptor.generator.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Properties;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.inject.Inject;

import org.sculptor.generator.SculptorGeneratorException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import sculptormetamodel.Application;
import sculptormetamodel.Attribute;
import sculptormetamodel.BasicType;
import sculptormetamodel.CommandEvent;
import sculptormetamodel.Consumer;
import sculptormetamodel.DataTransferObject;
import sculptormetamodel.DomainEvent;
import sculptormetamodel.DomainObject;
import sculptormetamodel.DomainObjectTypedElement;
import sculptormetamodel.Entity;
import sculptormetamodel.EnumConstructorParameter;
import sculptormetamodel.EnumValue;
import sculptormetamodel.Module;
import sculptormetamodel.NamedElement;
import sculptormetamodel.Operation;
import sculptormetamodel.Parameter;
import sculptormetamodel.Reference;
import sculptormetamodel.Repository;
import sculptormetamodel.RepositoryOperation;
import sculptormetamodel.Resource;
import sculptormetamodel.ResourceOperation;
import sculptormetamodel.SculptormetamodelFactory;
import sculptormetamodel.Service;
import sculptormetamodel.ServiceOperation;
import sculptormetamodel.TypedElement;
import sculptormetamodel.ValueObject;
import sculptormetamodel.impl.SculptormetamodelFactoryImpl;

/**
 * Utilities for code generation and transformation. It is used from oAW
 * templates and transformations via oAW extensions.
 * 
 */
public class HelperBase {

	private static final Logger LOG = LoggerFactory.getLogger(HelperBase.class);
	
	private PropertiesBase propBase;

	private PrimitiveTypeMapper primitiveTypeMapper = new PrimitiveTypeMapper();
	private Map<String, String> collectionInterfaceTypeMapper = new HashMap<String, String>();
	private Map<String, String> collectionImplTypeMapper = new HashMap<String, String>();

	@Inject
	protected void init(PropertiesBase propBase) {
		this.propBase = propBase;
		collectionInterfaceTypeMapper.put("list", propBase.getJavaType("List"));
		collectionInterfaceTypeMapper.put("bag", propBase.getJavaType("Bag"));
		collectionInterfaceTypeMapper.put("map", propBase.getJavaType("Map"));
		collectionInterfaceTypeMapper.put("set", propBase.getJavaType("Set"));
		collectionInterfaceTypeMapper.put(null, propBase.getJavaType("Set"));

		collectionImplTypeMapper.put("list", propBase.getJavaTypeImpl("List"));
		collectionImplTypeMapper.put("bag", propBase.getJavaTypeImpl("Bag"));
		collectionImplTypeMapper.put("map", propBase.getJavaTypeImpl("Map"));
		collectionImplTypeMapper.put("set", propBase.getJavaTypeImpl("Set"));
		collectionImplTypeMapper.put(null, propBase.getJavaTypeImpl("Set"));
	}

	private static Application app;

	public static void printEnvironment() {
		LOG.warn("######################################################");
		LOG.warn("# Runtime environment");
		LOG.warn("######################################################");

		// Print properties
		LOG.warn("Properties:");
		Properties props = System.getProperties();
		for (Map.Entry<Object,Object> key : props.entrySet()) {
			LOG.warn("    " + key.getKey() + " = " + key.getValue());
		}

		LOG.warn("Environment:");
		Map<String, String> env = System.getenv();
		for (Map.Entry<String,String> key : env.entrySet()) {
			LOG.warn("    " + key.getKey() + " = " + key.getValue());
		}
		LOG.warn("######################################################");
	}

	private static final Pattern envPattern = Pattern.compile("\\$\\{[^}]*\\}");

	public String processPath(String input) {
		Matcher matcher = envPattern.matcher(input);
		StringBuffer out = new StringBuffer();
		while(matcher.find()) {
			String match = matcher.group();
			String envVar = match.substring(2, match.length() - 1);
			String replacement = System.getProperty(envVar);
			if (replacement == null) {
				replacement = System.getenv(envVar);
			}
			matcher.appendReplacement(out, replacement == null ? envVar : replacement);
		}
		matcher.appendTail(out);
		return out.toString();
	}

	public String getDomainPackage(DomainObject domainObject) {
		if (domainObject instanceof DataTransferObject) {
			return getDomainPackage((DataTransferObject) domainObject);
		}
		if (domainObject instanceof DomainEvent) {
			return getDomainPackage((DomainEvent) domainObject);
		}
		if (domainObject instanceof CommandEvent) {
			return getDomainPackage((CommandEvent) domainObject);
		}
		if (domainObject.getPackage() == null || domainObject.getPackage().equals("")) {
			return getDomainPackage(domainObject.getModule());
		} else {
			return concatPackage(getBasePackage(domainObject.getModule()), domainObject.getPackage());
		}
	}

	public String getDomainPackage(DataTransferObject dto) {
		if (dto.getPackage() == null || dto.getPackage().equals("")) {
			return getDtoPackage(dto.getModule());
		} else {
			return concatPackage(getBasePackage(dto.getModule()), dto.getPackage());
		}
	}

	public String getDomainPackage(DomainEvent event) {
		if (event.getPackage() == null || event.getPackage().equals("")) {
			return getDomainEventPackage(event.getModule());
		} else {
			return concatPackage(getBasePackage(event.getModule()), event.getPackage());
		}
	}

	public String getDomainPackage(CommandEvent event) {
		if (event.getPackage() == null || event.getPackage().equals("")) {
			return getCommandEventPackage(event.getModule());
		} else {
			return concatPackage(getBasePackage(event.getModule()), event.getPackage());
		}
	}

	public String getServiceapiPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getServiceInterfacePackage());
	}

	public String getServiceimplPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getServiceImplementationPackage());
	}

	public String getRestPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getRestPackage());
	}

	public String getServiceproxyPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getServiceProxyPackage());
	}

	public String getConsumerPackage(Consumer consumer) {
		return concatPackage(getBasePackage(consumer.getModule()), propBase.getConsumerPackage());
	}

	public String getXmlMapperPackage(Consumer consumer) {
		return concatPackage(getBasePackage(consumer.getModule()), propBase.getXmlMapperPackage());
	}

	public String getAccessapiPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getAccessInterfacePackage());
	}

	public String getAccessimplPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getAccessImplementationPackage());
	}

	public String getDomainPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getDomainPackage());
	}

	public String getDtoPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getDtoPackage());
	}

	public String getDomainEventPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getDomainEventPackage());
	}

	public String getCommandEventPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getCommandEventPackage());
	}

	public String getRepositoryimplPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getRepositoryImplementationPackage());
	}

	public String getRepositoryapiPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getRepositoryInterfacePackage());
	}

	public String getExceptionPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getExceptionPackage());
	}

	public String getMapperPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getMapperPackage());
	}

	private String concatPackage(String pkg1, String pkg2) {
		if (pkg2 == null || pkg2.equals("")) {
			return pkg1;
		}
		return pkg1 + "." + pkg2;
	}

	public String getBasePackage(Module module) {
		String base = module.getBasePackage();
		if (base == null) {
			base = module.getApplication().getBasePackage();
			if (module.getName() != null && !module.getName().equals("")) {
				base += "." + module.getName();
			}
		}
		return base;
	}

	public Collection<RepositoryOperation> distinctOperations(Repository repository) {
		LinkedHashMap<String, RepositoryOperation> distinctOperations = new LinkedHashMap<String, RepositoryOperation>();
		for (RepositoryOperation op : (List<RepositoryOperation>) repository.getOperations()) {
			String opKey = distinctOperationKey(op);
			if (!distinctOperations.containsKey(opKey)) {
				distinctOperations.put(opKey, op);
			}
		}
		return distinctOperations.values();
	}

	private String distinctOperationKey(RepositoryOperation op) {
		StringBuilder buf = new StringBuilder();
		buf.append(op.getName());
		if (op.isDelegateToAccessObject()) {
			buf.append("=>");
		}
		if (op.getAccessObjectName() != null) {
			buf.append(op.getAccessObjectName());
		}
		return buf.toString();
	}

	public Collection<String> exceptions(Operation op) {
		String throwsString = op.getThrows();
		if (throwsString == null || throwsString.equals("")) {
			return new ArrayList<String>();
		}
		String[] exceptions = throwsString.split(",");
		Module module = operationModule(op);
		for (int i = 0; i < exceptions.length; i++) {
			exceptions[i] = fullyQualifiedException(exceptions[i], module);
		}
		return Arrays.asList(exceptions);
	}

	private String fullyQualifiedException(String e, Module module) {
		String mappedName = getJavaType(e.trim()).trim();
		if (isGeneratedException(mappedName)) {
			return getExceptionPackage(module) + "." + mappedName;
		} else {
			return mappedName;
		}
	}

	private String fullyQualifiedThrows(Operation op) {
		Collection<String> exceptions = exceptions(op);
		Module module = operationModule(op);
		StringBuffer sb = new StringBuffer();
		for (String exc : exceptions) {
			if (sb.length() > 0) {
				sb.append(",");
			}
			sb.append(fullyQualifiedException(exc, module));
		}
		return sb.toString();
	}

	private boolean isGeneratedException(String e) {
		return e.indexOf('.') == -1;
	}

	public Collection<String> getGeneratedExceptions(Operation op) {
		String throwsString = op.getThrows();
		if (throwsString == null || throwsString.equals("")) {
			return new ArrayList<String>();
		}
		String[] exceptions = throwsString.split(",");
		List<String> generatedExceptions = new ArrayList<String>();
		for (int i = 0; i < exceptions.length; i++) {
			String e = exceptions[i].trim();
			String mappedName = getJavaType(e).trim();
			if (isGeneratedException(mappedName)) {
				generatedExceptions.add(mappedName);
			}
		}
		return generatedExceptions;
	}

	public String getTypeName(Reference ref) {
		return getDomainPackage(ref.getTo()) + "." + ref.getTo().getName();
	}

	public String getTypeName(TypedElement element) {
		String type = getJavaTypeOrVoid(element.getType());
		return surroundWithCollectionType(type, element, false);
	}

	public String getTypeName(DomainObjectTypedElement element) {
		return getTypeName(element, true);
	}

	public String getTypeName(DomainObjectTypedElement element, boolean surroundWithCollectionType) {
		String typeName = getJavaTypeOrVoid(element.getType());
		String type = typeName;
		String domainObjectTypeName = null;
		if (element.getDomainObjectType() != null) {
			domainObjectTypeName = getJavaTypeOrVoid(getDomainPackage(element.getDomainObjectType()) + "."
					+ element.getDomainObjectType().getName());
			type = domainObjectTypeName;
		}

		if (typeName != null && !typeName.equals("void") && domainObjectTypeName != null && !domainObjectTypeName.equals("void")) {
			type = typeName + "<" + domainObjectTypeName + ">";
		}

		return (surroundWithCollectionType ? surroundWithCollectionType(type, element, false) : type);
	}

	public String getImplTypeName(TypedElement element) {
		String type = getJavaTypeImpl(element.getType());
		return surroundWithCollectionType(type, element, true);
	}

	private String surroundWithCollectionType(String type, TypedElement typedElement, boolean collectionImpl) {
		if (typedElement.getCollectionType() == null || typedElement.getCollectionType().equals("") || type == null
				|| type.equals("") || type.equals("void")) {
			return type;
		} else {
			String mappedCollectionType = (collectionImpl ? getJavaTypeImpl(typedElement.getCollectionType())
					: getJavaType(typedElement.getCollectionType()));
			if (typedElement.getCollectionType().equals("Map")) {
				String keyType = getMapKeyType((DomainObjectTypedElement) typedElement);
				mappedCollectionType += "<" + keyType + ", " + type + ">";
			} else {
				mappedCollectionType += "<" + type + ">";
			}
			return mappedCollectionType;
		}
	}

	private String getMapKeyType(DomainObjectTypedElement element) {
		// DomainObject domainObject = element.getMapKeyDomainObjectType();
		// if (domainObject != null) {
		// return getJavaTypeOrVoid(getDomainPackage(domainObject) + "." +
		// domainObject.getName());
		// }
		String type = element.getMapKeyType();
		if (type != null) {
			return type;
		}
		return "Object";
	}

	private String getJavaTypeOrVoid(String type) {
		if (type == null || type.equals("")) {
			return "void";
		}
		return getJavaType(type);
	}

	public String getJavaType(String modelType) {
		String javaType = propBase.getJavaType(modelType);
		if (javaType == null) {
			return modelType;
		} else {
			return javaType;
		}
	}

	private String getJavaTypeImpl(String modelType) {
		String javaType = propBase.getJavaTypeImpl(modelType);
		if (javaType == null) {
			return getJavaType(modelType);
		} else {
			return javaType;
		}
	}

	/**
	 * Java interface for the collection type.
	 * 
	 * @see #getCollectionType(sculptormetamodel.Reference)
	 */
	public String getCollectionInterfaceType(Reference ref) {
		String collectionType = getCollectionType(ref);
		return getCollectionInterfaceType(collectionType);
	}

	private String getCollectionInterfaceType(String collectionType) {
		String result = collectionInterfaceTypeMapper.get(collectionType);
		if (result == null) {
			result = collectionInterfaceTypeMapper.get(null);
		}
		return result;
	}

	/**
	 * Java implementation class for the collection type.
	 * 
	 * @see #getCollectionType(sculptormetamodel.Reference)
	 */
	public String getCollectionImplType(Reference ref) {
		String collectionType = getCollectionType(ref);
		return getCollectionImplType(collectionType);
	}

	private String getCollectionImplType(String collectionType) {
		String result = collectionImplTypeMapper.get(collectionType);
		if (result == null) {
			result = collectionImplTypeMapper.get(null);
		}
		return result;
	}

	/**
	 * Collection type can be set, list, bag or map. It corresponds to the
	 * Hibernate collection types.
	 */
	public String getCollectionType(Reference ref) {
		String type = ref.getCollectionType();
		return (type == null ? "set" : type.toLowerCase());
	}

	public String getCollectionType(Attribute attr) {
		String type = attr.getCollectionType();
		return (type == null ? "set" : type.toLowerCase());
	}

	/**
	 * Get-accessor method name of a property, according to JavaBeans naming
	 * conventions.
	 */
	public String getGetAccessor(TypedElement e, String prefix) {
		String capName = toFirstUpper(e.getName());
		if (prefix != null) {
			capName = toFirstUpper(prefix) + capName;
		}
		// Note that Boolean object type is not named with is prefix (according
		// to java beans spec)
		String result = isBooleanPrimitiveType(e) ? "is" + capName : "get" + ("Class".equals(capName) ? "Class_" : capName);
		return result;
	}

	/**
	 * First character to upper case.
	 */
	public String toFirstUpper(String name) {
		if (name.length() == 0) {
			return name;
		} else {
			return name.substring(0, 1).toUpperCase() + name.substring(1);
		}
	}

	/**
	 * First character to lower case.
	 */
	public String toFirstLower(String name) {
		if (name.length() == 0) {
			return name;
		} else {
			return name.substring(0, 1).toLowerCase() + name.substring(1);
		}
	}

	/**
	 * Gets a substring between the begin and end boundaries
	 * 
	 * @param string
	 *            original string
	 * @param begin
	 *            start boundary
	 * @param end
	 *            end boundary
	 * @return substring between boundaries
	 */
	public String substringBetween(String string, String begin, String end) {
		return substringBetween(string, begin, end, false);
	}

	/**
	 * Gets a substring between the begin and end boundaries
	 * 
	 * @param string
	 *            original string
	 * @param begin
	 *            start boundary
	 * @param end
	 *            end boundary
	 * @param includeBoundaries
	 *            include the boundaries in substring
	 * @return substring between boundaries
	 */
	public String substringBetween(String string, String begin, String end, boolean includeBoundaries) {
		if (string == null || begin == null || end == null) {
			return null;
		}
		int startPos = string.indexOf(begin);
		if (startPos != -1) {
			if (includeBoundaries)
				startPos = startPos - begin.length();
			int endPos = string.lastIndexOf(end);
			if (endPos != -1) {
				if (includeBoundaries)
					endPos = endPos + end.length();
				return string.substring(startPos + begin.length(), endPos);
			}
		}
		return null;
	}

	/**
	 * Gets the substring before a given pattern
	 * 
	 * @param string
	 *            original string
	 * @param pattern
	 *            pattern to check
	 * @return substring before the pattern
	 */
	public String substringBefore(String string, String pattern) {
		if (string == null || pattern == null) {
			return string;
		}
		int pos = string.indexOf(pattern);
		if (pos != -1) {
			return string.substring(0, pos);
		}
		return null;
	}

	private boolean isBooleanPrimitiveType(TypedElement e) {
		if (e.getType() == null) {
			return false;
		}
		return "boolean".equals(getTypeName(e));
	}

	public String getRepositoryBaseName(Repository repository) {
		if (!repository.getName().endsWith("Repository")) {
			throw new SculptorGeneratorException("Expect name of repository argument to end with \"Repository\"");
		}
		String baseName = repository.getName().substring(0, repository.getName().length() - "Repository".length());
		return baseName;
	}

	public List<?> addServiceContextParameter(ServiceOperation operation) {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;
		Parameter ctxParameter = factory.createParameter();
		ctxParameter.setName("ctx");
		ctxParameter.setType(propBase.getServiceContextClass());
		operation.getParameters().add(0, ctxParameter);
		return operation.getParameters();
	}

	public Entity addAuditable(Entity entity) {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;

		boolean useJoda = propBase.getBooleanProperty("generate.auditable.joda");
		String timestampType = useJoda ? "DateTime" : "java.util.Date";

		if (!hasElement("createdDate", entity.getAttributes())) {
			Attribute createdDate = factory.createAttribute();
			createdDate.setName("createdDate");
			createdDate.setType(timestampType);
			createdDate.setNullable(true);
			entity.getAttributes().add(createdDate);
		}

		if (!hasElement("createdBy", entity.getAttributes())) {
			Attribute createdBy = factory.createAttribute();
			createdBy.setName("createdBy");
			createdBy.setType("String");
			createdBy.setLength("50");
			createdBy.setNullable(true);
			entity.getAttributes().add(createdBy);
		}

		if (!hasElement("lastUpdated", entity.getAttributes())) {
			Attribute lastUpdated = factory.createAttribute();
			lastUpdated.setName("lastUpdated");
			lastUpdated.setType(timestampType);
			lastUpdated.setNullable(true);
			entity.getAttributes().add(lastUpdated);
		}

		if (!hasElement("lastUpdatedBy", entity.getAttributes())) {
			Attribute lastUpdatedBy = factory.createAttribute();
			lastUpdatedBy.setName("lastUpdatedBy");
			lastUpdatedBy.setType("String");
			lastUpdatedBy.setLength("50");
			lastUpdatedBy.setNullable(true);
			entity.getAttributes().add(lastUpdatedBy);
		}

		return entity;
	}

	private boolean hasElement(String name, List<? extends NamedElement> namedElements) {
		for (NamedElement each : namedElements) {
			if (name.equals(each.getName())) {
				return true;
			}
		}
		return false;
	}

	public DomainObject addVersionAttribute(DomainObject domainObject) {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;

		Attribute version = factory.createAttribute();
		version.setName("version");
		version.setType("Long");
		version.setNullable(false);
		domainObject.getAttributes().add(version);

		return domainObject;
	}

	public DomainObject addIdAttributeImpl(DomainObject domainObject) {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;

		Attribute id = factory.createAttribute();
		id.setName("id");
		id.setType(propBase.getIdType());
		domainObject.getAttributes().add(0, id);

		return domainObject;
	}

	public DomainObject addUuidAttribute(DomainObject domainObject) {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;

		Attribute uuid = factory.createAttribute();
		uuid.setName("uuid");
		uuid.setType("UUID");
		domainObject.getAttributes().add(uuid);

		return domainObject;
	}

	public DomainObject addRepository(DomainObject domainObject) {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;

		Repository repository = factory.createRepository();
		repository.setName(domainObject.getName() + "Repository");
		repository.setGapClass(propBase.getBooleanProperty("generate.gapClass"));
		domainObject.setRepository(repository);

		return domainObject;
	}

	public Repository addRepositoryScaffoldOperations(Repository repository) {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;

		Set<String> existingOperations = new HashSet<String>();
		for (RepositoryOperation op : repository.getOperations()) {
			existingOperations.add(op.getName());
		}

		for (String operationName : propBase.scaffoldOperations()) {
			if (!existingOperations.contains(operationName)) {
				RepositoryOperation op = factory.createRepositoryOperation();
				op.setName(operationName);
				repository.getOperations().add(op);
			}
		}

		return repository;
	}

	public Module addService(Module module, String serviceName) {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;
		Service service = factory.createService();
		service.setName(serviceName);
		service.setGapClass(propBase.getBooleanProperty("generate.gapClass"));
		module.getServices().add(service);
		return module;
	}

	public Service addServiceScaffoldOperations(Service service, Repository delegateRepository) {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;

		Set<String> existingOperations = new HashSet<String>();
		for (ServiceOperation op : (List<ServiceOperation>) service.getOperations()) {
			existingOperations.add(op.getName());
		}

		for (String operationName : propBase.scaffoldOperations()) {
			if (!existingOperations.contains(operationName)) {
				// note that we add one ServiceOperation for each
				// RepositoryOperation with this name,
				// there may be several with same name
				for (RepositoryOperation repositoryOp : delegateRepository.getOperations()) {
					if (repositoryOp.getName().equals(operationName)) {
						ServiceOperation op = factory.createServiceOperation();
						op.setName(operationName);
						service.getOperations().add(op);
						op.setDelegate(repositoryOp);
					}
				}
			}
		}

		return service;
	}

	public Resource addResourceScaffoldOperations(Resource resource, Service delegateService) {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;

		Set<String> existingOperations = new HashSet<String>();
		for (ResourceOperation op : resource.getOperations()) {
			existingOperations.add(op.getName());
		}

		for (String operationName : propBase.restScaffoldOperations()) {
			if (!existingOperations.contains(operationName)) {
				String serviceOperationName = propBase.restServiceDelegateOperation(operationName);
				ServiceOperation serviceOp;
				if (serviceOperationName == null || delegateService == null) {
					serviceOp = null;
				} else {
					serviceOp = operation(delegateService, serviceOperationName);
				}
				ResourceOperation op = factory.createResourceOperation();
				op.setName(operationName);
				resource.getOperations().add(op);
				op.setDelegate(serviceOp);
			}
		}

		return resource;
	}

	private ServiceOperation operation(Service service, String operationName) {
		for (ServiceOperation serviceOp : (List<ServiceOperation>) service.getOperations()) {
			if (serviceOp.getName().equals(operationName)) {
				return serviceOp;
			}
		}
		return null;
	}

	/**
	 * Fill in parameters and return values for operations that delegate to
	 * Service.
	 */
	public void addDefaultValues(Resource resource) {
		for (ResourceOperation op : resource.getOperations()) {
			addDefaultValues(op);
		}
	}

	/**
	 * Fill in parameters and return values for operations that delegate to
	 * Repository.
	 */
	public void addDefaultValues(Service service) {
		for (ServiceOperation op : (List<ServiceOperation>) service.getOperations()) {
			addDefaultValues(op);
		}
	}

	/**
	 * Copy values from delegate RepositoryOperation to this ServiceOperation
	 */
	private void addDefaultValues(ServiceOperation operation) {
		if (operation.getDelegate() != null) {
			copyFromDelegate(operation, operation.getDelegate(), true);
		} else if (operation.getServiceDelegate() != null) {
			// make sure that the service delegate has been populated first
			addDefaultValues(operation.getServiceDelegate());
			// recursive call
			// (circular dependencies not allowed)
			copyFromDelegate(operation, operation.getServiceDelegate(), true);
		}
	}

	/**
	 * Copy values from delegate ServiceOperation to this ResourceOperation
	 */
	private void addDefaultValues(ResourceOperation operation) {
		if (operation.getDelegate() != null) {
			copyFromDelegate(operation, operation.getDelegate(), false);
		}
	}

	private void copyFromDelegate(Operation operation, Operation delegate, boolean inclServiceContext) {
		if (operation.getParameters().isEmpty()) {
			SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;
			String serviceContextClass = serviceContextClass();
			for (Parameter delegateParam : (List<Parameter>) delegate.getParameters()) {
				if (!inclServiceContext && serviceContextClass.equals(delegateParam.getType())) {
					continue;
				}
				Parameter param = factory.createParameter();
				param.setName(delegateParam.getName());
				param.setDomainObjectType(delegateParam.getDomainObjectType());
				param.setType(delegateParam.getType());
				param.setCollectionType(delegateParam.getCollectionType());
				param.setMapKeyType(delegateParam.getMapKeyType());
				operation.getParameters().add(param);
			}
		}
		if (operation.getType() == null || operation.getType().equals("")) {
			operation.setType(delegate.getType());
		}
		if (operation.getDomainObjectType() == null) {
			operation.setDomainObjectType(delegate.getDomainObjectType());
		}
		if (operation.getCollectionType() == null || operation.getCollectionType().equals("")) {
			operation.setCollectionType(delegate.getCollectionType());
		}

		if (operation.getMapKeyType() == null || operation.getMapKeyType().equals("")) {
			operation.setMapKeyType(delegate.getMapKeyType());
		}
		if (operation.getThrows() == null || operation.getThrows().equals("")) {
			if (operationModule(operation).equals(operationModule(delegate))) {
				operation.setThrows(delegate.getThrows());
			} else {
				// delegation between modules requires fully qualified exception
				// class names
				operation.setThrows(fullyQualifiedThrows(delegate));
			}
		}
	}

	protected String serviceContextClass() {
		String propName = "framework.errorhandling.ServiceContext";
		if (propBase.hasProperty(propName)) {
			return propBase.getProperty(propName);
		} else {
			return "org.sculptor." + propName;
		}
	}

	private Module operationModule(Operation op) {
		if (op instanceof RepositoryOperation) {
			return ((RepositoryOperation) op).getRepository().getAggregateRoot().getModule();
		} else if (op instanceof ServiceOperation) {
			return ((ServiceOperation) op).getService().getModule();
		} else if (op instanceof ResourceOperation) {
			return ((ResourceOperation) op).getResource().getModule();
		} else {
			throw new SculptorGeneratorException("Unsupported operation type: " + op.getClass().getName());
		}
	}

	/**
	 * Throws a {@link SculptorGeneratorException} to stop the generation with an error message.
	 * 
	 * @param msg
	 *            message to log
	 */
	public void error(String msg) {
		throw new SculptorGeneratorException(msg);
	}

	public Long currentTimeMillis() {
		return System.currentTimeMillis();
	}

	public String formatJavaDoc(String doc) {
		if (doc == null || doc.trim().equals("")) {
			return "";
		}
		StringBuffer sb = new StringBuffer();
		sb.append("/**\n");
		String s = doc.trim();
		String[] rows = s.split("\n");
		for (int i = 0; i < rows.length; i++) {
			sb.append(" * ").append(rows[i].trim()).append("\n");
		}
		sb.append(" */");
		return sb.toString();
	}

	public Set<Reference> getAllReferences(Application application) {
		Set<Reference> all = new HashSet<Reference>();
		for (DomainObject d : getAllDomainObjects(application)) {
			for (Reference ref : (List<Reference>) d.getReferences()) {
				if (!all.contains(ref.getOpposite())) {
					all.add(ref);
				}
			}
		}

		return all;
	}

	private List<DomainObject> getAllDomainObjects(Application application) {
		List<DomainObject> all = new ArrayList<DomainObject>();
		List<Module> modules = application.getModules();
		for (Module m : modules) {
			for (DomainObject d : (List<DomainObject>) m.getDomainObjects()) {
				all.add(d);
			}
		}
		List<DomainObject> result = sortByName(all);
		return result;
	}

	public boolean isPrimitiveType(String typeName) {
		return primitiveTypeMapper.isPrimitiveType(typeName);
	}

	public String getObjectTypeName(String typeName) {
		return primitiveTypeMapper.mapPrimitiveType2ObjectTypeName(typeName);
	}

	public sculptormetamodel.Enum modifyEnum(sculptormetamodel.Enum enumObject) {
		modifyEnumImplicitAttribute(enumObject);
		modifyEnumConstructorParameters(enumObject);

		return enumObject;
	}

	private void modifyEnumImplicitAttribute(sculptormetamodel.Enum enumObject) {
		if (!enumObject.getAttributes().isEmpty()) {
			return;
		}
		EnumValue first = (EnumValue) enumObject.getValues().get(0);
		if (first.getParameters().isEmpty()) {
			return;
		}
		EnumConstructorParameter param = (EnumConstructorParameter) first.getParameters().get(0);

		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;
		Attribute value = factory.createAttribute();
		value.setName("value");
		value.setType(resolveEnumImplicitAttributeType(param));
		value.setNaturalKey(true);
		enumObject.getAttributes().add(value);
	}

	private String resolveEnumImplicitAttributeType(EnumConstructorParameter param) {
		if (isEnclosedWithQuotes(param.getValue())) {
			return "String";
		}
		try {
			Integer.parseInt(param.getValue());
			return "int";
		} catch (RuntimeException e) {
			// it wasn't an int
		}
		return "String";
	}

	private void modifyEnumConstructorParameters(sculptormetamodel.Enum enumObject) {
		if (enumObject.getAttributes().isEmpty()) {
			return;
		}
		for (EnumValue value : (List<EnumValue>) enumObject.getValues()) {
			Iterator<EnumConstructorParameter> iter = value.getParameters().iterator();
			for (int i = 0; iter.hasNext(); i++) {
				EnumConstructorParameter param = iter.next();
				Attribute att = (Attribute) enumObject.getAttributes().get(i);
				if (getTypeName(att).equals("String") && !isEnclosedWithQuotes(param.getValue())) {
					param.setValue("\"" + param.getValue() + "\"");
				}
			}
		}
	}

	private boolean isEnclosedWithQuotes(String value) {
		return value.startsWith("\"") && value.endsWith("\"");
	}

	public Application getGlobalApp() {
		return app;
	}

	public void setGlobalApp(Application app) {
		HelperBase.app = app;
	}

	/**
	 * Handles Validation Annotations for DomainObjects.
	 * 
	 * @param domainObject
	 * @return validation annotations
	 */
	public String getValidationAnnotations(DomainObject domainObject) {
		return handleValidationAnnotations(domainObject.getValidate());
	}

	/**
	 * Handles Validation Annotations for Attributes.
	 * 
	 * @param attribute
	 * @return validation annotations
	 */
	public String getValidationAnnotations(Attribute attribute) {
		return handleValidationAnnotations(attribute.getValidate());
	}

	/**
	 * Handles Validation Annotations for References.
	 * 
	 * @param reference
	 * @return validation annotations
	 */
	public String getValidationAnnotations(Reference reference) {
		return handleValidationAnnotations(reference.getValidate());
	}

	/**
	 * Parses the given validation string and tries to map annotations from
	 * properties.
	 * 
	 * @param validate
	 *            String with validation information
	 * @return validation annotations
	 */
	private String handleValidationAnnotations(String validate) {

		if (validate == null)
			return "";

		if (validate.length() > 15) {
			@SuppressWarnings("unused")
			boolean baa = true;
		}

		// parsing the validate string is simple text replacement
		validate = validate.replaceAll("&&", " ");
		validate = validate.replaceAll("'", "\"");
		for (Map.Entry<String, String> entry : propBase.validationAnnotationDefinitions().entrySet()) {
			String firstChar = entry.getKey().substring(0, 1);
			String keyPattern = "[" + firstChar.toUpperCase() + firstChar.toLowerCase() + "]" + entry.getKey().substring(1);

			validate = validate.replaceAll("@" + keyPattern, "@" + entry.getValue());
		}

		return validate.trim();
	}

	/**
	 * Handles all validation annotations with multiple parameters (Range, Size,
	 * ...).
	 * 
	 * @param annotation
	 *            the name of the annotation
	 * @param parameterNames
	 *            the parameter names
	 * @param parameters
	 *            the parameter values
	 * @param validate
	 *            the validate string
	 * @return annotation validation string
	 */
	public String handleParameterizedAnnotation(String annotation, String parameterNames, String parameters, String validate) {

		if (parameters == null)
			return "";

		if (parameterNames == null)
			return "";

		// validate contains range
		if (validate != null && validate.toLowerCase().matches(".*@" + annotation.toLowerCase() + ".*"))
			return "";

		String result = " @" + annotation;

		// if validate contains any given parameter name, add complete
		// annotation
		String[] paramNames = parameterNames.split(",");
		for (String paramName : paramNames) {
			if (parameters.toLowerCase().matches(".*" + paramName + ".*")) {
				result += "(" + parameters + ")";
				return result + " ";
			}
		}

		// setting parameters
		String[] params = parameters.split(",");
		result += "(";
		for (int i = 0; i < params.length; i++) {
			if (paramNames[i] != null) {
				if (i > 0)
					result += ",";
				result += paramNames[i] + "=" + params[i];
			}
		}
		result += ")";

		return result + " ";
	}

	/**
	 * Handles all simple validation annotations (Max, Min, ...).
	 * 
	 * @param annotation
	 *            the name of the annotation
	 * @param value
	 *            the parameter values
	 * @param validate
	 *            the validate string
	 * @return annotation validation string
	 */
	public String handleSimpleAnnotation(String annotation, String value, String validate) {

		if (value == null)
			return "";

		// if validate contains annotation, do nothing
		if (validate != null && validate.toLowerCase().matches(".*@" + annotation.toLowerCase() + ".*"))
			return "";

		String result = " @" + annotation;

		// if validate contains named annotation parameters
		if (value.toLowerCase().matches(".*value.*") || value.toLowerCase().matches(".*message.*")) {
			result += "(" + value + ") ";
			return result + " ";
		}

		// a simple annotation only has parameters value and message
		String[] params = value.split(",");
		if (params.length == 1)
			result += "(" + params[0] + ")";
		if (params.length == 2)
			result += "(value=" + params[0] + ", message=" + params[1] + ")";

		return result + " ";
	}

	/**
	 * Handles all boolean validation annotations (Future, Past, Email, ...).
	 * 
	 * @param annotation
	 *            the name of the annotation
	 * @param value
	 *            annotation is set or not
	 * @param validate
	 *            the validate string
	 * @return annotation validation string
	 */
	public String handleBooleanAnnotation(String annotation, Boolean value, String message, String validate) {

		if (!Boolean.TRUE.equals(value))
			return "";

		// if validate contains annotation, do nothing
		if (validate != null && validate.toLowerCase().matches(".*@" + annotation.toLowerCase() + ".*"))
			return "";

		String result = " @" + annotation;

		// set message if not set
		if (message != null) {
			result += "(" + (message.toLowerCase().matches(".*message.*") ? "" : "message=") + message + ")";
		}

		return result + " ";
	}

	static <T extends NamedElement> List<T> sortByName(List<T> list) {
		List<T> result = new ArrayList<T>(list);
		Collections.sort(result, new NameSorter());
		return result;
	}

	private static class NameSorter implements Comparator<NamedElement> {
		public int compare(NamedElement obj1, NamedElement obj2) {
			if (obj1 == null || obj1.getName() == null) {
				return -1;
			}
			if (obj2 == null || obj2.getName() == null) {
				return 1;
			}
			return obj1.getName().compareTo(obj2.getName());
		}
	}

	public String formatAnnotationParameters(List<Object> list) {
		return formatAnnotationParameters(null, list);
	}

	public String formatAnnotationParameters(String annotation, List<Object> list) {
		Map<String, Object> collected = new LinkedHashMap<String, Object>();
		for (int i = 0; i < list.size(); i += 3) {
			Boolean condition = (Boolean) list.get(i);
			if (condition) {
				String key = (String) list.get(i + 1);
				if (key.equals("")) {
					key = "__" + i;
				}
				Object value = list.get(i + 2);
				collected.put(key, value);
			}
		}

		if (collected.isEmpty()) {
			return "";
		}

		StringBuilder result = new StringBuilder();
		if (annotation != null) {
			result.append(annotation).append("(");
		}
		for (Iterator<Entry<String, Object>> iter = collected.entrySet().iterator(); iter.hasNext();) {
			Entry<String, Object> each = iter.next();
			if (!each.getKey().startsWith("__")) {
				result.append(each.getKey()).append("=");
			}
			result.append(each.getValue());
			if (iter.hasNext()) {
				result.append(", ");
			}
		}
		if (annotation != null) {
			result.append(")");
		}

		return result.toString();
	}

	public String getHintImpl(String hint, String parameter) {
		return getHintImpl(hint, parameter, ",;");
	}

	// need to specify the separator in case the hint value contains a ','
	// TODO: very quick solution
	public String getHintImpl(String hint, String parameter, String separator) {
		if (hint == null) {
			return null;
		}
		if (hint.indexOf(parameter) == -1) {
			return null;
		}
		String[] split = hint.split("[" + separator + "]");
		split = trim(split);
		for (int i = 0; i < split.length; i++) {
			int indexOfEq = split[i].indexOf("=");
			if (indexOfEq == -1) {
				if (split[i].equals(parameter)) {
					return "";
				}
			} else {
				if (split[i].substring(0, indexOfEq).trim().equals(parameter)) {
					return split[i].substring(indexOfEq + 1).trim();
				}
			}
		}

		// not found
		return null;
	}

	public boolean hasHintImpl(String hint, String parameter) {
		return getHintImpl(hint, parameter) != null;
	}

	public void addHint(NamedElement element, String hint) {
		addHint(element, hint, ",");
	}

	public void addHint(NamedElement element, String hint, String separator) {
		String hintKey;
		int indexOfEq = hint.indexOf("=");
		if (indexOfEq == -1) {
			hintKey = hint;
		} else {
			hintKey = hint.substring(0, indexOfEq).trim();
		}

		if (hasHintImpl(element.getHint(), hintKey)) {
			return;
		}
		String fullHintStr = element.getHint();
		if (fullHintStr == null || fullHintStr.equals("")) {
			fullHintStr = hint;
		} else {
			fullHintStr += separator + " " + hint;
		}
		element.setHint(fullHintStr);
	}

	private String[] trim(String[] array) {
		String[] result = new String[array.length];
		for (int i = 0; i < array.length; i++) {
			result[i] = array[i].trim();
		}
		return result;
	}

	public List<Object> filterValues(List<Object> keys, List<Object> values) {
		List<Object> result = new ArrayList<Object>();
		Set<Object> used = new HashSet<Object>();
		for (int i = 0; i < keys.size(); i++) {
			if (!used.contains(keys.get(i))) {
				result.add(values.get(i));
				used.add(keys.get(i));
			}
		}
		return result;
	}

	public String toSeparatedString(List<?> values, String separator) {
		StringBuilder result = new StringBuilder();
		for (Object each : values) {
			if (each == null) {
				continue;
			}
			if (result.length() > 0) {
				result.append(separator);
			}
			result.append(String.valueOf(each));
		}
		return result.toString();
	}

	public boolean isEntityOrPersistentValueObject(DomainObject d) {
		if ((d instanceof BasicType) || (d instanceof sculptormetamodel.Enum)) {
			return false;
		}
		return isPersistent(d);
	}

	protected boolean isPersistent(DomainObject domainObject) {
		if (domainObject instanceof Entity) {
			return true;
		} else if (domainObject instanceof ValueObject) {
			ValueObject vo = (ValueObject) domainObject;
			return vo.isPersistent();
		} else {
			return false;
		}
	}

	public List<Object> addFirst(List<Object> list, Object values) {
		list.add(0, values);
		return list;
	}

	public String replaceParamNamePlaceholders(String str, Operation op) {
		if (str.indexOf("${p") == -1) {
			// nothing to replace
			return str;
		}
		String serviceContextClass = propBase.getServiceContextClass();
		int i = 0;
		String result = str;
		for (Parameter each : (Iterable<Parameter>) op.getParameters()) {
			if (serviceContextClass.equals(getTypeName(each))) {
				continue;
			}
			result = result.replaceAll("\\$\\{p" + i + "}", each.getName());
			i++;
		}
		return result;
	}

	public String replacePlaceholder(String str, String placeholder, String replacement) {
		// Strange, regexp is not cooperating with me for this, so I use
		// substring instead
		int i = str.indexOf(placeholder);
		if (i == -1) {
			return str;
		}
		String result = str.substring(0, i) + replacement + str.substring(i + placeholder.length());
		return result;
	}

	private static final HashMap<String, Integer> counters = new HashMap<String, Integer>();

	public String counterInc(String counter) {
		Integer i = counters.get(counter);
		i = i != null ? i + 1 : 0;
		counters.put(counter, i);
		return i.toString();
	}

	public void counterReset(String counter, Integer initValue) {
		counters.put(counter, initValue);
	}

	public String getBuilderPackage(DomainObject domainObject) {
		return getBuilderPackage(domainObject.getModule());
	}

	public String getBuilderPackage(Module module) {
		return concatPackage(getBasePackage(module), propBase.getBuilderPackage());
	}

	public String getReferencePathFromReturnType(RepositoryOperation op) {
		DomainObject returnType = op.getDomainObjectType();
		if (returnType == null) {
			return null;
		}

		DomainObject aggregatRoot = op.getRepository().getAggregateRoot();
		for (Reference reference : (List<Reference>) aggregatRoot.getReferences()) {
			if (reference.getTo() == returnType) {
				return reference.getName();
			}
		}

		// TODO: look deeper in the reference tree (without cyclic references)
		for (Reference reference : (List<Reference>) aggregatRoot.getReferences()) {
			for (Reference reference2 : (List<Reference>) reference.getTo().getReferences()) {
				if (reference2.getTo() == returnType) {
					return reference.getName() + "." + reference2.getName();
				}
			}
		}

		return null;
	}

	public String toConditionalCriteria(String condition, String root) {
		return new QueryConverter.ConditionalCriteriaStrategy(condition,root).toQueryDsl();
	}
}
