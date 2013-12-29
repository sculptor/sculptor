package org.sculptor.betting.customer.consumer;

import org.sculptor.betting.core.domain.Bet;
import org.sculptor.betting.core.domain.BetPlaced;
import org.sculptor.betting.customer.domain.Customer;
import org.sculptor.betting.customer.domain.CustomerBet;
import org.sculptor.betting.customer.exception.CustomerNotFoundException;
import org.sculptor.framework.event.DynamicMethodDispatcher;
import org.sculptor.framework.event.Event;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * Implementation of BettingConsumer.
 */
@Component("bettingConsumer")
public class BettingConsumerImpl extends BettingConsumerImplBase {

	private static final Logger LOG = LoggerFactory.getLogger(BettingConsumerImpl.class); 

	public BettingConsumerImpl() {
	}

	public void receive(Event event) {
		DynamicMethodDispatcher.dispatch(this, event, "handle");
	}

	public void handle(BetPlaced betPlaced) {
		LOG.info("### Consuming betPlaced: {}", betPlaced);
		Bet bet = betPlaced.getBet();
		String customerId = bet.getCustomerId();
		String customerName = null;
		try {
			Customer customer = getCustomerRepository().findByKey(customerId);
			customerName = customer.getCustomerName();
		} catch (CustomerNotFoundException e) {
			// ok
		}
		CustomerBet customerBet = new CustomerBet(customerId, customerName, bet.getAmount());
		getCustomerBetRepository().save(customerBet);
	}

}
