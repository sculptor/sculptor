package org.sculptor.example.ejb.helloworld.milkyway.serviceimpl;

import javax.ejb.Stateless;
import javax.interceptor.Interceptors;

import org.sculptor.example.ejb.helloworld.milkyway.serviceapi.InternalPlanetServiceLocal;
import org.sculptor.example.ejb.helloworld.milkyway.serviceimpl.InternalPlanetServiceBeanBase;
import org.sculptor.framework.context.ServiceContext;
import org.sculptor.framework.context.ServiceContextStoreInterceptor;
import org.sculptor.framework.errorhandling.ErrorHandlingInterceptor;
import org.sculptor.framework.persistence.JpaFlushEagerInterceptor;

/**
 * Implementation of InternalPlanetService.
 */
@Stateless(name = "internalPlanetService")
@Interceptors({ ServiceContextStoreInterceptor.class, ErrorHandlingInterceptor.class })
public class InternalPlanetServiceBean extends InternalPlanetServiceBeanBase implements InternalPlanetServiceLocal {
	@SuppressWarnings("unused")
	private static final long serialVersionUID = 1L;

	public InternalPlanetServiceBean() {
	}

	@Interceptors({ JpaFlushEagerInterceptor.class })
	public String sayHello(ServiceContext ctx) {
		return "Hello";
	}

}
