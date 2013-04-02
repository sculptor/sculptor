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

import org.aopalliance.intercept.MethodInvocation;


/**
 * Class used for sending information about request to Drools engine
 *
 * @author Ing. Pavel Tavoda
 */
public class RequestDescription {
	private final String serviceName;
	private final String methodName;

	private MethodInvocation joinPoint;
	private Object lastResult=null;
	private boolean wasProceed=false;

	public RequestDescription(MethodInvocation procJoinPoint) {
		// String serviceName, String methodName) {
		String serviceClassName=procJoinPoint.getThis().getClass().getSimpleName();
		if (serviceClassName.endsWith("Impl")) {
			serviceClassName=serviceClassName.substring(0, serviceClassName.length()-4);
		}

		this.serviceName = serviceClassName;
		this.methodName = procJoinPoint.getMethod().getName();
		this.joinPoint=procJoinPoint;
	}

	public String getMethodName() {
		return methodName;
	}

	public String getServiceName() {
		return serviceName;
	}

	public Object proceed() throws Throwable {
		wasProceed=true;
		lastResult=joinPoint.proceed();
		return lastResult;
	}

	public void setSyntheticResult(Object result) {
		wasProceed=true;
		lastResult=result;
	}

	public void setSyntheticException(Throwable exception) {
		wasProceed=true;
		lastResult=exception;
	}

	public Object getLastResult() {
		return lastResult;
	}

	public boolean wasProceed() {
		return wasProceed;
	}
}
