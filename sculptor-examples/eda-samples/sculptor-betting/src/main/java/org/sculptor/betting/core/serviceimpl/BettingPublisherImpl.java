package org.sculptor.betting.core.serviceimpl;

import org.sculptor.betting.core.domain.BetPlaced;
import org.sculptor.framework.event.annotation.Publish;
import org.springframework.stereotype.Service;

/**
 * Implementation of BettingPublisher.
 */
@Service("bettingPublisher")
public class BettingPublisherImpl extends BettingPublisherImplBase {

	public BettingPublisherImpl() {
	}

	@Publish(topic = "jms:topic:bet")
	public void publishEvent(BetPlaced betEvent) {
		// betEvent will be published
	}

}
