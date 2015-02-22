package org.sculptor.example.ejb.helloworld.milkyway.serviceimpl;

import java.util.ArrayList;
import java.util.List;

import javax.ejb.Stateless;
import javax.interceptor.Interceptors;
import javax.jws.WebMethod;
import javax.jws.WebService;

import org.jboss.ws.api.annotation.WebContext;
import org.sculptor.example.ejb.helloworld.milkyway.domain.Planet;
import org.sculptor.example.ejb.helloworld.milkyway.serviceapi.PlanetDto;
import org.sculptor.framework.context.ServiceContextStoreInterceptor;
import org.sculptor.framework.errorhandling.ErrorHandlingInterceptor;

/**
 * Implementation of PlanetWebService.
 */
@Stateless(name = "planetWebService")
@WebService(endpointInterface = "org.sculptor.example.ejb.helloworld.milkyway.serviceapi.PlanetWebServiceEndpoint", serviceName = "PlanetWebService")
// http://localhost:8080/universe/PlanetWebService/WebDelegateEndPoint?wsdl
@WebContext(contextRoot = "/universe", urlPattern = "/PlanetWebService/WebDelegateEndPoint")
@Interceptors({ ServiceContextStoreInterceptor.class, ErrorHandlingInterceptor.class })
public class PlanetWebServiceBean extends PlanetWebServiceBeanBase {
	@SuppressWarnings("unused")
	private static final long serialVersionUID = 1L;

	public PlanetWebServiceBean() {
	}

	@WebMethod
	public List<PlanetDto> getAllPlanets() {
		List<PlanetDto> planets = new ArrayList<PlanetDto>();
		for (Planet planet : getPlanetRepository().findAll()) {
			planets.add(new PlanetDto(planet.getName()));
		}
		return planets;
	}

}
