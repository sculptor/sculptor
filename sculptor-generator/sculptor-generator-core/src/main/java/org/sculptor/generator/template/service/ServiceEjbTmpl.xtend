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

package org.sculptor.generator.template.service

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.common.ExceptionTmpl
import org.sculptor.generator.template.common.PubSubTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Parameter
import sculptormetamodel.Service
import sculptormetamodel.ServiceOperation

class ServiceEjbTmpl {

	@Inject private var ExceptionTmpl exceptionTmpl
	@Inject private var PubSubTmpl pubSubTmpl
	@Inject private var ServiceTmpl serviceTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties

def String service(Service it) {
	'''
	«ejbBeanImplBase(it)»
	«IF gapClass»
		«ejbBeanImplSubclass(it)»
	«ENDIF»
	«IF remoteInterface»
		«ejbRemoteInterface(it)»
	«ENDIF»
	«IF localInterface»
		«ejbLocalInterface(it)»
	«ENDIF»
	«IF isServiceProxyToBeGenerated()»
		«serviceProxy(it)»
	«ENDIF»
	'''
}

/*Used for pure-ejb3, i.e. without spring */
def String ejbBeanImplBase(Service it) {
	fileOutput(javaFileName(it.getServiceimplPackage() + "." + name + getSuffix("Impl") + (if (gapClass) "Base" else "")), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «it.getServiceimplPackage()»;

/// Sculptor code formatter imports ///

	«IF gapClass»
		/**
		 * Generated base class for implementation of «name».
		 * <p>Make sure that subclass defines the following annotations:
		 * <pre>
		@javax.ejb.Stateless(name="«name.toFirstLower()»")
		«ejbInterceptors(it)»
		«IF webService»
		«webServiceAnnotations(it)»
		«ENDIF»
		 * </pre>
		 */
	«ELSE»
		/**
		 * Generated implementation of «name».
		 */
		@javax.ejb.Stateless(name="«name.toFirstLower()»")
		«IF !gapClass && webService»
			«webServiceAnnotations(it)»
		«ENDIF»
		«ejbInterceptors(it)»
	«ENDIF»
	public «IF gapClass»abstract «ENDIF»class «name + getSuffix("Impl")»«IF gapClass»Base«ENDIF» «it.extendsLitteral()» 
			implements «it.getEjbInterfaces()» {
		«serviceTmpl.serialVersionUID(it)»
		public «name + getSuffix("Impl")»«IF gapClass»Base«ENDIF»() {
		}

		«serviceTmpl.delegateRepositories(it) »
		«serviceTmpl.delegateServices(it) »

		«it.operations.filter[op | !op.isImplementedInGapClass()].map[serviceTmpl.implMethod(it)].join()»
	}
	'''
	)
}

/*Used for pure-ejb3, i.e. without spring */
def String ejbBeanImplSubclass(Service it) {
	fileOutput(javaFileName(it.getServiceimplPackage() + "." + name + getSuffix("Impl")), OutputSlot::TO_SRC, '''
	«javaHeader()»
	package «it.getServiceimplPackage()»;

/// Sculptor code formatter imports ///

	/**
	 * Implementation of «name».
	 */
	@javax.ejb.Stateless(name="«name.toFirstLower()»")
	«IF webService»
		«webServiceAnnotations(it)»
	«ENDIF»
	«ejbInterceptors(it)»
	«IF subscribe != null»«pubSubTmpl.subscribeAnnotation(it.subscribe)»«ENDIF»
	public class «name + getSuffix("Impl")» «IF gapClass»extends «name + getSuffix("Impl")»Base«ENDIF» {
		«serviceTmpl.serialVersionUID(it)»
		public «name + getSuffix("Impl")»() {
		}

	«serviceTmpl.otherDependencies(it)»

		«it.operations.filter(op | op.isImplementedInGapClass()) .map[serviceTmpl.implMethod(it)].join()»

	«serviceTmpl.serviceHook(it)»
	}
	'''
	)
}

def String ejbInterceptors(Service it) {
	'''
	@javax.interceptor.Interceptors({«IF isServiceContextToBeGenerated()»«fw("errorhandling.ServiceContextStoreInterceptor")».class, «ENDIF»
		«fw("errorhandling.ErrorHandlingInterceptor")».class})
	'''
}

def String ejbMethod(ServiceOperation it) {
	'''
	public «it.getTypeName()» «it.name»(«it.parameters.map[p | serviceTmpl.paramTypeAndName(p)].join(",")») «exceptionTmpl.throwsDecl(it)» {
		initBeanFactory();
		«IF !it.exceptions().isEmpty »try {«ENDIF»
			«IF it.getTypeName() != "void" »return «ENDIF»service.«name»(«FOR parameter : parameters SEPARATOR ", "»«parameter.name»«ENDFOR»);
		«IF !it.exceptions().isEmpty »
			«FOR exc : it.exceptions()»
			} catch («exc» e) {
				setRollbackOnly();
				throw e;
			«ENDFOR»
			}
		«ENDIF»
	}
	'''
}

def String ejbRemoteInterface(Service it) {
	fileOutput(javaFileName(it.getServiceapiPackage() + "." + name + "Remote"), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «it.getServiceapiPackage()»;

/// Sculptor code formatter imports ///

	/**
	 * Generated EJB remote interface for the Service «name».
	 */
	@javax.ejb.Remote
	public interface «name»Remote extends «name» {
	}
	'''
	)
}

def String ejbLocalInterface(Service it) {
	fileOutput(javaFileName(it.getServiceapiPackage() + "." + name + "Local"), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «it.getServiceapiPackage()»;

/// Sculptor code formatter imports ///

	/**
	 * Generated EJB local interface for the Service «name».
	 */
	@javax.ejb.Local
	public interface «name»Local extends «name» {
	}
	'''
	)
}


def String serviceProxy(Service it) {
	fileOutput(javaFileName(it.getServiceproxyPackage() + "." + name + "Proxy"), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «it.getServiceproxyPackage()»;

/// Sculptor code formatter imports ///

	/**
	 * Generated proxy class that can be used by clients to invoke «name».
	 */
	public class «name»Proxy implements «it.getServiceapiPackage()».«name» {

		private «it.getServiceapiPackage()».«name» service;
		private String jndiName;
		private String earName;

		public «name»Proxy() {
		}

		/**
		 * Dependency injection of the EJB to invoke. If service is not injected
		 * lookup based on jndiName will be used.
		 */
		public void setService(«it.getServiceapiPackage()».«name» service) {
			this.service = service;
		}

		/**
		 * Dependency injection of JNDI name of EJB to invoke.
		 * Only necessary if default naming isn't enough.
		 */
		public void setJndiName(String jndiName) {
			this.jndiName = jndiName;
		}
		
		/**
		 * Dependency injection of earName that is used for default
		 * jndiName. Only necessary if default naming isn't enough.
		 */
		public void setEarName(String earName) {
			this.earName = earName;
		}

		protected «it.getServiceapiPackage()».«name» getService() {
			if (service != null) {
				return service;
			}
			try {
				if (jndiName == null) {
				    jndiName = defaultJndiName();
				}
				javax.naming.InitialContext ctx = «IF remoteInterface»createInitialContext()«ELSE»new javax.naming.InitialContext()«ENDIF»;
				«it.getServiceapiPackage()».«name» ejb = («it.getServiceapiPackage()».«name») ctx.lookup(
				    jndiName);
				«IF remoteInterface»
				// don't cache the remote proxy instance, since it might be stale and the server 
				// of the proxy might have crashed.
				if (!useRemoteLookup()) {
					setService(ejb);
				} 
				«ELSE»
				setService(ejb);
				«ENDIF»
				return ejb;
			} catch (javax.naming.NamingException e) {
				throw new RuntimeException("Failed to lookup " + jndiName + ", due to " + e.getMessage(), e);
			}
		}

		private String defaultJndiName() {
			«val localOrRemote = if (remoteInterface && localInterface) '" + localOrRemote()' else
				(if (remoteInterface) 'remote"' else 'local"')»
			if (earName() == null) {
				// this requires definition of ejb-local-ref (in web.xml)
				return "java:comp/env/ejb/«name.toFirstLower()»/«localOrRemote»;
			} else {
				return earName + "/«name.toFirstLower()»/«localOrRemote»;
			}
		}

	private String earName() {
		if (earName == null) {
			earName = defaultEarName();
		}
		return earName;
	}

		private String defaultEarName() {
			«IF hasProperty("deployment.earname")»
				// this name was defined in deployment.earname property in sculptor-generator.properties
				return "«getProperty("deployment.earname")»";
			«ELSE»
				// you can define deployment.earname in sculptor-generator.properties if you need to define 
				// the name of the ear instead of resolving it from the resourceName like this
				String resourceName = "/" + getClass().getName().replace('.', '/') + ".class";
				java.net.URL resource = getClass().getResource(resourceName);
				String fullPath = resource.toExternalForm();
				String[] parts = fullPath.split("/");
				for (int i = 0; i < parts.length; i++) {
					if (parts[i].endsWith(".ear")) {
						// remove .ear
						String earBaseName = parts[i].substring(0, parts[i].length() - 4);
						return earBaseName;
					}
				}
				// ear not found
				return null;
			«ENDIF»
		}

		«IF remoteInterface»
			«serviceRemoteProxy(it)»
		«ENDIF»

		«it.operations.filter(op | op.isPublicVisibility()).map[proxyMethod(it)].join()»

	}
	'''
	)
}

def String serviceRemoteProxy(Service it) {
	'''
		private boolean remote «IF !localInterface» = true«ENDIF»;

		public boolean isRemote() {
			return remote;
		}

		«IF localInterface»
			/**
			 * When setting this to true remote ejb interface is used. By default local
			 * ejb interface is used.
			 */
			public void setRemote(boolean remote) {
				this.remote = remote;
			}
		«ENDIF»
		
		«IF remoteInterface && localInterface»
			private String localOrRemote() {
				return (remote ? "remote" : "local"); 
			}
		«ENDIF»

		private String providerUrl;

		public String getProviderUrl() {
			return providerUrl;
		}

		/**
		 * InitialContext javax.naming.Context.PROVIDER_URL, for example
		 * jnp://host1:1099,host2:1099
		 */
		public void setProviderUrl(String providerUrl) {
			this.providerUrl = providerUrl;
		}
		
		protected boolean useRemoteLookup() {
			return (remote && (providerUrl != null || partitionName != null));
		}

		«IF applicationServer() == "jboss"»
		«IF hasProperty("deployment.jnpPartitionName")»
			// this value was defined in sculptor-generator.properties deployment.jnpPartitionName
			private String partitionName = «getProperty("deployment.jnpPartitionName")»;
		«ELSE»
			// you can define default partitionName in sculptor-generator.properties deployment.jnpPartitionName
			private String partitionName;
		«ENDIF»

		public String getPartitionName() {
			return partitionName;
		}

		/**
		 * InitialContext JBoss cluster partition parameter, jnp.partitionName. Used
		 * for remote lookup.
		 */
		public void setPartitionName(String partitionName) {
			this.partitionName = partitionName;
		}
		«ENDIF»

		protected InitialContext createInitialContext() throws javax.naming.NamingException {
			if (!useRemoteLookup()) {
				return new InitialContext();
			}
			java.util.Properties p = new java.util.Properties();

			«IF applicationServer() == "jboss"»
				// doc of properties: http://community.jboss.org/wiki/NamingContextFactory
				p.put(javax.naming.Context.INITIAL_CONTEXT_FACTORY, "org.jnp.interfaces.NamingContextFactory");
				p.put(javax.naming.Context.URL_PKG_PREFIXES, "jboss.naming:org.jnp.interfaces");
				if (providerUrl != null) {
					p.put(javax.naming.Context.PROVIDER_URL, sortProviderUrl());
				}
				if (partitionName != null) {
					// JBoss cluster partition parameter
					p.put("jnp.partitionName", partitionName);
				}
			«ELSE»
				if (providerUrl != null) {
					p.put(javax.naming.Context.PROVIDER_URL, providerUrl);
				}
			«ENDIF»

			return new InitialContext(p);
		}

		«IF applicationServer() == "jboss"»
			private static final String JNP = "jnp://";
			private java.util.Random random = new java.util.Random(0);

			/**
			 * Sort with preference of current "localhost", i.e. prefer local calls over
			 * remote. "localhost" is determined from System property
			 * "jboss.bind.address".
			 */
			private String sortProviderUrl() {
				if (providerUrl == null) {
					throw new IllegalArgumentException("providerUrl must be defined");
				}
				String str;
				if (providerUrl.startsWith(JNP)) {
					str = providerUrl.substring(JNP.length());
				} else {
					str = providerUrl;
				}
				String[] split = str.split(",");
				if (split.length <= 1) {
					return providerUrl;
				}
				String bindAddress = System.getProperty("jboss.bind.address", "localhost");
				String primary = null;
				java.util.List<String> rest = new java.util.ArrayList<String>();
				for (String each : split) {
					if (primary == null && each.startsWith(bindAddress + ":")) {
					    primary = each;
					} else {
					    rest.add(each);
					}
				}
				StringBuilder result = new StringBuilder();
				if (providerUrl.startsWith(JNP)) {
					result.append(JNP);
				}
				if (primary != null) {
					result.append(primary);
					if (!rest.isEmpty()) {
					    result.append(",");
					}
				}
				if (rest.size() > 1) {
					java.util.Collections.shuffle(rest, random);
				}
				if (rest.size() == 1) {
					result.append(rest.get(0));
				} else {
					for (java.util.Iterator<String> iter = rest.iterator(); iter.hasNext();) {
					    String each = iter.next();
					    result.append(each);
					    if (iter.hasNext()) {
					        result.append(",");
					    }
					}
				}

				return result.toString();
			}
		«ENDIF»
	'''
}

def String proxyMethod(ServiceOperation it) {
	'''
		public «it.getTypeName()» «name»(«it.parameters.map[serviceTmpl.paramTypeAndName(it)].join(",")») «exceptionTmpl.throwsDecl(it)» {
			«IF it.getTypeName() != "void" »return «ENDIF »getService().«name»(«FOR parameter : parameters SEPARATOR ", "»«parameter.name»«ENDFOR»);
		}
	'''
}

def String webServiceAnnotations(Service it) {
	'''
	@javax.jws.WebService(endpointInterface = "«it.getServiceapiPackage()».«name»Endpoint",
		serviceName = "«name»")
	«IF applicationServer() == "jboss" »
		// http://localhost:8080/«module.application.name.toLowerCase()»/«name»/WebDelegateEndPoint?wsdl
		@org.jboss.ws.api.annotation.WebContext(contextRoot = "/«module.application.name.toLowerCase()»", urlPattern="/«name»/WebDelegateEndPoint")
	«ENDIF»
	'''
}

def String webServiceInterface(Service it) {
	fileOutput(javaFileName(it.getServiceapiPackage() + "." + name + "Endpoint"), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «it.getServiceapiPackage()»;

/// Sculptor code formatter imports ///

	«IF it.formatJavaDoc() == "" »
		/**
		 * Generated interface for the «name» web service endpoint.
		 */
	«ELSE »
		«it.formatJavaDoc()»
	«ENDIF »
	@javax.jws.WebService
	public interface «name»Endpoint extends «name» {

		«it.operations.filter(op | op.isPublicVisibility()).map[webServiceInterfaceMethod(it)].join()»

	}
	'''
	)
}

def String webServiceInterfaceMethod(ServiceOperation it) {
	'''
		«it.formatJavaDoc()»
		«IF it.getTypeName() != "void"»@javax.jws.WebResult «ENDIF »«it.getTypeName()» «name»(«it.parameters.map[p | webServiceParamTypeAndName(p)].join(",")») «
		exceptionTmpl.throwsDecl(it)»;
	'''
}

def String webServiceParamTypeAndName(Parameter it) {
	'''
	«IF it.getTypeName() != serviceContextClass()»@javax.jws.WebParam(name = "«name»") «ENDIF »«IF isGenerateParameterName()» @«fw("annotation.Name")»("«name»")«ENDIF» «it.getTypeName()» «name»
	'''
}

def String webServicePackageInfo(Service it) {
	fileOutput(javaFileName(it.getServiceapiPackage() + ".package-info"), OutputSlot::TO_GEN_SRC, '''
	@javax.xml.bind.annotation.XmlSchema(
		namespace = "http://«FOR e : reversePackageName(it.getServiceapiPackage()) SEPARATOR '.'»«e»«ENDFOR»/",
		elementFormDefault = javax.xml.bind.annotation.XmlNsForm.QUALIFIED)
	package «it.getServiceapiPackage()»;

/// Sculptor code formatter imports ///

	'''
	)
}
}
