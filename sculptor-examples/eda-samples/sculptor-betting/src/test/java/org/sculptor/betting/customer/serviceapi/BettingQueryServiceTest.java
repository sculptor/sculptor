package org.sculptor.betting.customer.serviceapi;

import java.util.List;
import java.util.Set;

import org.joda.time.DateTime;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.sculptor.betting.core.domain.Bet;
import org.sculptor.betting.core.domain.BetPlaced;
import org.sculptor.betting.core.serviceapi.BettingPublisher;
import org.sculptor.betting.customer.domain.CustomerBet;
import org.sculptor.betting.customer.mapper.CustomerBetMapper;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.fail;

/**
 * Spring based test with MongoDB.
 */
@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class BettingQueryServiceTest implements BettingQueryServiceTestBase {

	@Autowired
	private DbManager dbManager;

	@Autowired
	private BettingPublisher bettingPublisher;

	@Autowired
	private BettingQueryService bettingQueryService;

	@BeforeEach
	public void initTestData() {
	}

	@BeforeEach
	public void initDbManagerThreadInstance() throws Exception {
		// to be able to do lazy loading of associations inside test class
		DbManager.setThreadInstance(dbManager);
	}

	@AfterEach
	public void dropDatabase() {
		Set<String> names = dbManager.getDB().getCollectionNames();
		for (String each : names) {
			if (!each.startsWith("system")) {
				dbManager.getDB().getCollection(each).drop();
			}
		}
		// dbManager.getDB().dropDatabase();
	}

	private int countRowsInDBCollection(String name) {
		return (int) dbManager.getDBCollection(name).getCount();
	}

	@Test
	public void testGetHighStakes() throws Exception {
		Bet bet = new Bet("abc", "1234", 20.0);
		BetPlaced betPlaced = new BetPlaced(DateTime.now(), bet);
		bettingPublisher.publishEvent(betPlaced);
		waitForConsume();
		List<CustomerBet> highStakes = bettingQueryService.getHighStakes(15.0);
		assertFalse(highStakes.isEmpty());
	}

	private void waitForConsume() throws InterruptedException {
		for (int i = 0; i < 50; i++) {
			System.out.println("# waiting for message");
			Thread.sleep(100);
			if (countRowsInDBCollection(CustomerBetMapper.getInstance().getDBCollectionName()) > 0) {
				return;
			}
		}
		fail("No rows in CustomerBet");
	}

}
