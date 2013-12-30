package org.sculptor.simplecqrs.command.serviceapi;

import static org.junit.Assert.assertEquals;

import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.sculptor.simplecqrs.command.mapper.InventoryItemSnapshotMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;

/**
 * Spring based test with MongoDB.
 */
@RunWith(org.springframework.test.context.junit4.SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class InventoryItemSnapshotterTest extends AbstractJUnit4SpringContextTests implements
		InventoryItemSnapshotterTestBase {

	@Autowired
	private DbManager dbManager;

	@Autowired
	private InventoryItemSnapshotter inventoryItemSnapshotter;

	@Autowired
	private InventoryFacade inventoryFacade;

	@Before
	public void initTestData() {
	}

	@Before
	public void initDbManagerThreadInstance() throws Exception {
		// to be able to do lazy loading of associations inside test class
		DbManager.setThreadInstance(dbManager);
	}

	@After
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
	@Override
	public void testReceive() throws Exception {
		String itemId = "7890";
		inventoryFacade.createInventoryItem(itemId, "The Thing");
		inventoryFacade.checkInItemsToInventory(itemId, 10000);

		int expectedSnapshots = 0;
		assertEquals(expectedSnapshots, countSnapshots());

		for (int i = 2; i < 311; i++) {
			inventoryFacade.removeItemsFromInventory(itemId, 10);
			if (i % 100 == 0) {
				expectedSnapshots++;
			}
			assertEquals("Expected " + expectedSnapshots + " snapshots after " + i + " events", expectedSnapshots,
					countSnapshots());
		}

	}

	private int countSnapshots() {
		return countRowsInDBCollection(InventoryItemSnapshotMapper.getInstance().getDBCollectionName());
	}
}
