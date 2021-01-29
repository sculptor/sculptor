package org.sculptor.betting.core.serviceapi;

import java.util.Set;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.sculptor.betting.core.domain.Bet;
import org.sculptor.betting.core.mapper.BettingInstructionMapper;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Spring based test with MongoDB.
 */
@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class BettingServiceTest implements BettingServiceTestBase {

	@Autowired
	private DbManager dbManager;

	@Autowired
	private BettingService bettingService;

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
	public void testPlaceBet() throws Exception {
		Bet bet = new Bet("abc", "1234", 10.0);
		bettingService.placeBet(bet);
		assertEquals(1, countRowsInDBCollection(BettingInstructionMapper.getInstance().getDBCollectionName()));
	}

}
