package org.sculptor.betting.core.serviceimpl;

import org.sculptor.betting.core.domain.Bet;
import org.sculptor.betting.core.domain.BettingInstruction;
import org.sculptor.framework.event.annotation.Publish;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

/**
 * Implementation of BettingService.
 */
@Service("bettingService")
public class BettingServiceImpl extends BettingServiceImplBase {

	private static final Logger LOG = LoggerFactory.getLogger(BettingServiceImpl.class); 

	public BettingServiceImpl() {
	}

	@Publish(eventType = BettingInstruction.class, topic = "bettingInstructionTopic", eventBus = "commandBus")
	public void placeBet(Bet bet) {
		LOG.info("### Placing bet: {}", bet);

		// do some initial validation...

		// new BettingInstruction will be published
	}

}
