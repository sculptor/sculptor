package org.sculptor.shipping.statistics.serviceimpl;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

import org.sculptor.framework.event.DynamicMethodDispatcher;
import org.sculptor.framework.event.Event;
import org.sculptor.framework.event.EventBus;
import org.sculptor.framework.event.EventSubscriber;
import org.sculptor.shipping.core.domain.ShipHasArrived;
import org.sculptor.shipping.core.domain.ShipHasDepartured;
import org.sculptor.shipping.core.domain.UnLocode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

/**
 * Implementation of Statistics.
 */
@Service("statistics")
public class StatisticsImpl extends StatisticsImplBase {

	private static final Logger LOG = LoggerFactory.getLogger(StatisticsImpl.class);

	private final ConcurrentHashMap<UnLocode, AtomicInteger> shipsInPort = new ConcurrentHashMap<UnLocode, AtomicInteger>();

	@Autowired
	@Qualifier("eventBus")
	private EventBus eventBus;

	public StatisticsImpl() {
	}

	public void somewhere() {
		eventBus.subscribe("shippingChannel", new EventSubscriber() {
			@Override
			public void receive(Event event) {
				System.out.println("Received: " + event);
			}
		});
	}

	@Override
	public void receive(Event event) {
		DynamicMethodDispatcher.dispatch(this, event, "consume");
	}

	@Override
	public void consume(ShipHasArrived event) {
		UnLocode key = event.getPort().getUnlocode();
		int currentValue = addShipInPort(key, 1);
		LOG.info("### Ship {} arrived. Now there are {} ships in {}", event.getShip().getIdentifier(), currentValue,
				event.getPort().getUnlocode().getIdentifier());
	}

	@Override
	public void consume(ShipHasDepartured event) {
		UnLocode key = event.getPort().getUnlocode();
		int currentValue = addShipInPort(key, -1);
		LOG.info("### Ship {} departure. Now there are {} ships in {}", event.getShip().getIdentifier(), currentValue,
				event.getPort().getUnlocode().getIdentifier());

	}

	private int addShipInPort(UnLocode key, int value) {
		int currentValue;
		AtomicInteger counter = shipsInPort.get(key);
		if (counter == null) {
			counter = new AtomicInteger(value);
			currentValue = counter.get();
			AtomicInteger previous = shipsInPort.putIfAbsent(key, counter);
			if (previous != null) {
				currentValue = previous.addAndGet(value);
			}
		} else {
			currentValue = counter.addAndGet(value);
		}
		return currentValue;
	}

	@Override
	public void consume(Object any) {
		LOG.info("Ignored event: {}", any);
	}

	@Override
	public int getShipsInPort(UnLocode port) {
		AtomicInteger counter = shipsInPort.get(port);
		if (counter == null) {
			return 0;
		} else {
			return counter.get();
		}
	}

	@Override
	public void reset() {
		shipsInPort.clear();
	}

}
