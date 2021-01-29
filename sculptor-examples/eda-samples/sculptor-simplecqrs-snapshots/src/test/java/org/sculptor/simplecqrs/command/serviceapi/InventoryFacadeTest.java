package org.sculptor.simplecqrs.command.serviceapi;

import java.util.Set;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.sculptor.simplecqrs.command.mapper.InventoryItemMapper;
import org.sculptor.simplecqrs.query.mapper.InventoryItemDetailsMapper;
import org.sculptor.simplecqrs.query.mapper.InventoryItemListMapper;
import org.sculptor.simplecqrs.query.serviceapi.ReadModelFacade;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Spring based test with MongoDB.
 */
@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class InventoryFacadeTest implements InventoryFacadeTestBase {

	@Autowired
	private DbManager dbManager;

	@Autowired
	private InventoryFacade inventoryFacade;

	@Autowired
	private ReadModelFacade readFacade;

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

	private int countRowsInInventoryItemList() {
		return countRowsInDBCollection(InventoryItemListMapper.getInstance().getDBCollectionName());
	}

	private int countRowsInInventoryItemDetails() {
		return countRowsInDBCollection(InventoryItemDetailsMapper.getInstance().getDBCollectionName());
	}

	private int countRowsInInventoryItem() {
		return countRowsInDBCollection(InventoryItemMapper.getInstance().getDBCollectionName());
	}

	@Test
	@Override
	public void testCreateInventoryItem() throws Exception {
		inventoryFacade.createInventoryItem("1234", "The Book");
		assertEquals(1, countRowsInInventoryItem());
		assertEquals(1, countRowsInInventoryItemDetails());
		assertEquals(1, countRowsInInventoryItemList());

		assertEquals(1, readFacade.getInventoryItems().size());
		assertEquals("The Book", readFacade.getInventoryItemDetails("1234").getName());
	}

	@Test
	@Override
	public void testDeactivateInventoryItem() throws Exception {
		inventoryFacade.createInventoryItem("1234", "The Book");
		inventoryFacade.deactivateInventoryItem("1234");

		assertEquals(1, countRowsInInventoryItem());
		assertEquals(0, countRowsInInventoryItemDetails());
		assertEquals(0, countRowsInInventoryItemList());
	}

	@Test
	@Override
	public void testRenameInventoryItem() throws Exception {
		inventoryFacade.createInventoryItem("1234", "The Book");
		inventoryFacade.renameInventoryItem("1234", "The Book!!!");
		assertEquals("The Book!!!", readFacade.getInventoryItemDetails("1234").getName());
	}

	@Override
	@Test
	public void testCheckInItemsToInventory() throws Exception {
		inventoryFacade.createInventoryItem("1234", "The Book");
		inventoryFacade.checkInItemsToInventory("1234", 100);
		assertEquals(100, readFacade.getInventoryItemDetails("1234").getCurrentCount());
	}

	@Test
	@Override
	public void testRemoveItemsFromInventory() throws Exception {
		inventoryFacade.createInventoryItem("1234", "The Book");
		inventoryFacade.checkInItemsToInventory("1234", 100);
		inventoryFacade.removeItemsFromInventory("1234", 10);
		assertEquals(90, readFacade.getInventoryItemDetails("1234").getCurrentCount());
	}
}
