package org.sculptor.simplecqrs.command.serviceapi;

import static org.junit.Assert.assertEquals;

import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.sculptor.simplecqrs.command.mapper.InventoryItemMapper;
import org.sculptor.simplecqrs.query.mapper.InventoryItemDetailsMapper;
import org.sculptor.simplecqrs.query.mapper.InventoryItemListMapper;
import org.sculptor.simplecqrs.query.serviceapi.ReadModelFacade;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;

/**
 * Spring based test with MongoDB.
 */
@RunWith(org.springframework.test.context.junit4.SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class InventoryFacadeTest extends AbstractJUnit4SpringContextTests implements InventoryFacadeTestBase {

	@Autowired
	private DbManager dbManager;

	@Autowired
	private InventoryFacade inventoryFacade;

	@Autowired
	private ReadModelFacade readFacade;

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
