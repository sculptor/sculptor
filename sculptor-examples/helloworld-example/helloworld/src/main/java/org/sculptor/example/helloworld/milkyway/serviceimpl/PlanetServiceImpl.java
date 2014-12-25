package org.sculptor.example.helloworld.milkyway.serviceimpl;

import org.sculptor.example.helloworld.milkyway.domain.Planet;
import org.sculptor.example.helloworld.milkyway.exception.PlanetNotFoundException;
import org.sculptor.framework.context.ServiceContext;
import org.springframework.stereotype.Service;

/**
 * Implementation of PlanetService.
 */
@Service("planetService")
public class PlanetServiceImpl extends PlanetServiceImplBase {

    public PlanetServiceImpl() {
    }

    public String sayHello(ServiceContext ctx, String planetName)
        throws PlanetNotFoundException {

        Planet planet = getPlanet(ctx, planetName);
        return planet.getMessage();
    }

    public Planet getPlanet(ServiceContext ctx, String planetName)
        throws PlanetNotFoundException {

        Planet planet = findByKey(ctx, planetName);
        return planet;
    }

}
