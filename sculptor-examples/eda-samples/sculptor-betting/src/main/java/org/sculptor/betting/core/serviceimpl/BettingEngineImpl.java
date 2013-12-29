package org.sculptor.betting.core.serviceimpl;

import org.sculptor.betting.core.domain.BetPlaced;
import org.sculptor.betting.core.domain.BettingInstruction;
import org.sculptor.betting.core.domain.BettingInstructionRepository;
import org.sculptor.framework.event.DynamicMethodDispatcher;
import org.sculptor.framework.event.Event;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * Implementation of BettingEngine.
 */
@Service("bettingEngine")
public class BettingEngineImpl extends BettingEngineImplBase {

	private static final Logger LOG = LoggerFactory.getLogger(BettingEngineImpl.class); 

	@Autowired
	private BettingInstructionRepository instructionRepository;

	public void receive(Event event) {
		DynamicMethodDispatcher.dispatch(this, event, "handle");
	}

	public void handle(BettingInstruction betInstruction) {
		LOG.info("### Handling bet: {}", betInstruction);

		instructionRepository.save(betInstruction);

		BetPlaced betPlaced = new BetPlaced(betInstruction.getOccurred(), betInstruction.getBet());
		getBettingPublisher().publishEvent(betPlaced);
	}

}
