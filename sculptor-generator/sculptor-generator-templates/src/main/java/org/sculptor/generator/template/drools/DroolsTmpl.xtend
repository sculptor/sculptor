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
package org.sculptor.generator.template.drools

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application

@ChainOverridable
class DroolsTmpl {

	@Inject extension Helper helper
	@Inject extension Properties properties

	def String droolsSupport(Application it) {
		'''
		«droolsChangeSet(it)»
		«droolsRules(it)»
		«droolsDsl(it)»
		'''
	}
	
	def String droolsChangeSet(Application it) {
		fileOutput("CompanyPolicy.xml", OutputSlot.TO_RESOURCES, '''
		<?xml version = '1.0' encoding = 'UTF-8'?>
		<change-set xmlns='http://drools.org/drools-5.0/change-set'
			xmlns:xs='http://www.w3.org/2001/XMLSchema-instance'
			xs:schemaLocation='drools-change-set-5.0.xsd' >
		<add>
			<resource source='classpath:/CompanyPolicy.dslr' type='DSLR'/>
			<resource source='classpath:/CompanyPolicy.dsl' type='DSL'/>
		</add>
		</change-set>
		'''
		)
	}
			
	def String droolsRules(Application it) {
		fileOutput("CompanyPolicy.dslr", OutputSlot.TO_RESOURCES, '''
		package CompanyPolicy

		/* ################################################################################
		   # Declaration
		   ################################################################################ */
		import java.util.Set;
		import java.util.Date;
		import java.util.Calendar;
		import org.apache.commons.logging.Log;

		import «fw("drools.RequestDescription")»;
		import «fw("domain.AuditHandler")»;
		import «fw("domain.FullAuditLog")»;
		import «fw("context.ServiceContext")»;
		import «fw("errorhandling.ApplicationException")»;
		import org.springframework.context.ApplicationContext;

		global ServiceContext serviceContext;
		global ApplicationContext appContext;
		global Log log;
		global Calendar currentDate;
		global Long currentTimestamp;

		/* ################################################################################
		   # Support functions
		   ################################################################################ */
		function Object findService(ApplicationContext appContext, String serviceName) {
		return appContext.getBean(serviceName);
		}

		/* ################################################################################
		   # Auditing rules
		   ################################################################################ */
		RULE "Zobraz poziadavku"
		unique-group "Log"
		priority -100
		WHEN
		Exist request
		THAN
		Log "    serviceName: "+$req.getServiceName()
		Log "    methodName: "+$req.getMethodName()
		END
		'''
		)
	}
	
	def String droolsDsl(Application it) {
		fileOutput("CompanyPolicy.dsl", OutputSlot.TO_RESOURCES, '''
		[condition][]Exist request on=$req : RequestDescription()
		[condition][]- service "{service}"=serviceName=="{service}"
		[condition][]- method "{method}"=methodName=="{method}"
		[condition][]Exist request=$req : RequestDescription()

		[consequence][]Log {message}=log.info({message});
		[consequence][]LogError {message}=log.warn({message});
		[consequence][]LogFatal {message}=log.error({message});
		[consequence][]Audit request {description}=makeAuditRecord(serviceContext, servlet, $req.getServiceName(),  $req.getOperationType(), $req.getMethodName(), {description});
		[consequence][]Audit {audit}=makeAuditRecord(serviceContext, servlet, {audit});

		[keyword][]RULE=rule
		[keyword][]WHEN=when
		[keyword][]THAN=then
		[keyword][]END=end
		[keyword][]unique-group=activation-group
		[keyword][]priority=salience
		'''
		)
	}

}
