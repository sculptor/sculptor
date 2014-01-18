package org.sculptor.simplecqrs.command.serviceimpl;

import org.sculptor.simplecqrs.command.domain.InventoryItem;
import org.sculptor.simplecqrs.command.exception.InventoryItemNotFoundException;
import org.springframework.stereotype.Service;

/**
 * Implementation of InventoryFacade.
 */
@Service("inventoryFacade")
public class InventoryFacadeImpl extends InventoryFacadeImplBase {

	public InventoryFacadeImpl() {
	}

	@Override
	public void createInventoryItem(String itemId, String name) {
		InventoryItem item = InventoryItem.createNew(itemId, name);
		getInventoryItemRepository().save(item);
	}

	@Override
	public void deactivateInventoryItem(String itemId) {
		InventoryItem item = tryGetItem(itemId);
		item.deactivate();
		getInventoryItemRepository().save(item);
	}

	@Override
	public void renameInventoryItem(String itemId, String newName) {
		InventoryItem item = tryGetItem(itemId);
		item.rename(newName);
		getInventoryItemRepository().save(item);
	}

	@Override
	public void checkInItemsToInventory(String itemId, int count) {
		InventoryItem item = tryGetItem(itemId);
		item.checkIn(count);
		getInventoryItemRepository().save(item);
	}

	@Override
	public void removeItemsFromInventory(String itemId, int count) {
		InventoryItem item = tryGetItem(itemId);
		item.remove(count);
		getInventoryItemRepository().save(item);
	}

	private InventoryItem tryGetItem(String itemId) {
		try {
			return getInventoryItemRepository().findByKey(itemId);
		} catch (InventoryItemNotFoundException e) {
			throw new IllegalStateException("Unknown item: " + itemId);
		}
	}
}
