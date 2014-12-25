/*
 * (C) Copyright Factory4Solutions a.s. 2009
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
package org.sculptor.framework.drools;

/**
 * This advice should be used to wave Drools to service calls
 *
 * @author Ing. Pavel Tavoda
 */
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;
import org.kie.api.command.Command;
import org.kie.internal.agent.KnowledgeAgent;
import org.kie.internal.agent.KnowledgeAgentFactory;
import org.kie.internal.command.CommandFactory;
import org.kie.internal.io.ResourceChangeScannerConfiguration;
import org.kie.internal.io.ResourceFactory;
import org.kie.internal.runtime.StatelessKnowledgeSession;
import org.sculptor.framework.context.ServiceContext;
import org.sculptor.framework.context.ServiceContextStore;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

public class DroolsAdvice implements MethodInterceptor, ApplicationContextAware {
	private static final Logger log = LoggerFactory.getLogger(DroolsAdvice.class);

	private ApplicationContext appContext;
	private KnowledgeAgent kagent;

	int updateInterval=300; // 5 min
	String ruleSet="/CompanyPolicy.xml";
	boolean catchAllExceptions=false;

	public Object invoke(MethodInvocation procJointpoint) throws Throwable {
		long startTimeExec=System.currentTimeMillis();
		log.info("############# START DROOLS RULES");
		RequestDescription req=new RequestDescription( procJointpoint);
		try {
			Object[] arguments = procJointpoint.getArguments();
			ServiceContext ctx;
			int startArg;
			if (arguments[0] instanceof ServiceContext) {
				ctx=(ServiceContext) arguments[0];
				startArg=1;
			} else {
				ctx=ServiceContextStore.get();
				startArg=0;
			}

			HashMap<String, Object> objects=new HashMap<String, Object>();
			for (int i=startArg; i < arguments.length; i++) {
				objects.put("arg"+i, arguments[i]);
			}
			objects.put("request", req);
			objects.put("service", procJointpoint.getThis());
			objects.put("username", ServiceContextStore.getCurrentUser());

			HashMap<String, Object> globals=new HashMap<String, Object>();
			if (ctx != null) {
				globals.put("serviceContext", ctx);
			}
			globals.put("appContext", appContext);
			globals.put("log", log);

			Calendar curDate = Calendar.getInstance();
			globals.put("currentDate", curDate);
			globals.put("currentTimestamp", curDate.getTimeInMillis());

			applyCompanyPolicy(objects, globals);
		} catch (Throwable th) {
			if (catchAllExceptions) {
				while(th.getCause() != null) {
					th=th.getCause();
				}
				log.warn("Applying company policy finished with error: "+th.getMessage(), th);
			} else {
				throw th;
			}
		} finally {
			log.info("############# END DROOLS RULES ("+(System.currentTimeMillis() - startTimeExec)+" ms)");
		}

		if (req.wasProceed() && req.getLastResult() != null && req.getLastResult() instanceof Throwable) {
			throw (Throwable) req.getLastResult();
		} else if (req.wasProceed()) {
			return req.getLastResult();
		} else {
			return procJointpoint.proceed();
		}
	}

	private void applyCompanyPolicy(HashMap<String, Object> objects, HashMap<String, Object> globals) {
		if (kagent==null) {
			synchronized (DroolsAdvice.class) {
				if (kagent==null) {
					KnowledgeAgent unconfigAgent = KnowledgeAgentFactory.newKnowledgeAgent( "CompanyPolicyAgent" );
					unconfigAgent.applyChangeSet(ResourceFactory.newClassPathResource(getDroolsRuleSet()));

					ResourceChangeScannerConfiguration sconf = ResourceFactory.getResourceChangeScannerService().newResourceChangeScannerConfiguration();
					sconf.setProperty( "drools.resource.scanner.interval", Integer.toString(getUpdateInterval()) );
					ResourceFactory.getResourceChangeScannerService().configure( sconf );
					ResourceFactory.getResourceChangeNotifierService().start();
					ResourceFactory.getResourceChangeScannerService().start();

					kagent = unconfigAgent;
				}
			}
		}

		StatelessKnowledgeSession slSession = kagent.newStatelessKnowledgeSession();
		List<Command<?>> cmds = new ArrayList<Command<?>>();
		if (globals != null && globals.size() > 0) {
			for (Iterator<String> keys=globals.keySet().iterator(); keys.hasNext();) {
				String key=keys.next();
				cmds.add(CommandFactory.newSetGlobal(key, globals.get(key)));
			}
		}

		if (objects != null && objects.size() > 0) {
			for (Iterator<String> keys=objects.keySet().iterator(); keys.hasNext();) {
				String key=keys.next();
				cmds.add( CommandFactory.newInsert(objects.get(key), key) );
			}
		}
		// For stateless sesion is automatic
		// cmds.add(CommandFactory.newFireAllRules());

		slSession.execute( CommandFactory.newBatchExecution( cmds ) );
	}

	public int getUpdateInterval() {
		return updateInterval;
	}

	public void setUpdateInterval(int updateInterval) {
		this.updateInterval = updateInterval;
	}

	public String getDroolsRuleSet() {
		return ruleSet;
	}

	public void setDroolsRuleSet(String ruleSet) {
		this.ruleSet = ruleSet;
	}

	public boolean getCatchAllExceptions() {
		return catchAllExceptions;
	}

	public void setCatchAllExceptions(boolean catchAllExceptions) {
		this.catchAllExceptions = catchAllExceptions;
	}

	/**
	 * Dependency injection, ApplicationContextAware.
	 */
	public void setApplicationContext(ApplicationContext appContext) throws BeansException {
		this.appContext=appContext;
	}
}