package org.sculptor.dddsample.cargo.serviceimpl;

import org.sculptor.dddsample.cargo.domain.HandlingEvent;

/**
 * This interface provides a way to let other parts of the system know about
 * domain events that have occurred. <p/> All method signatures are expressed in
 * the ubiquitous language. <p/> It may be implemented synchronously or
 * asynchronously, using for example JMS.
 */
public interface DomainEventNotifier {

    /**
     * A cargo has been handled.
     * 
     * @param event
     *            handling event
     */
    void cargoWasHandled(HandlingEvent event);
}
