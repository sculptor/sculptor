package org.sculptor.simplecqrs.command.serviceapi;

import java.util.Set;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.sculptor.simplecqrs.command.mapper.InventoryItemSnapshotMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Spring based test with MongoDB.
 */
@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class InventoryItemSnapshotterTest implements InventoryItemSnapshotterTestBase {

	@Autowired
	private DbManager dbManager;

	@Autowired
	private InventoryItemSnapshotter inventoryItemSnapshotter;

	@Autowired
	private InventoryFacade inventoryFacade;

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
			assertEquals(expectedSnapshots, countSnapshots()
					, "Expected " + expectedSnapshots + " snapshots after " + i + " events");
		}

	}

	private int countSnapshots() {
		return countRowsInDBCollection(InventoryItemSnapshotMapper.getInstance().getDBCollectionName());
	}
}
