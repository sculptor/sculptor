package org.sculptor.simplecqrs.query.serviceimpl;

import org.sculptor.framework.event.DynamicMethodDispatcher;
import org.sculptor.framework.event.Event;
import org.sculptor.simplecqrs.command.domain.InventoryItemCreated;
import org.sculptor.simplecqrs.command.domain.InventoryItemDeactivated;
import org.sculptor.simplecqrs.command.domain.InventoryItemEvent;
import org.sculptor.simplecqrs.command.domain.InventoryItemRenamed;
import org.sculptor.simplecqrs.query.domain.InventoryItemList;
import org.sculptor.simplecqrs.query.exception.InventoryItemListNotFoundException;
import org.springframework.stereotype.Service;

/**
 * Implementation of InventoryListView.
 */
@Service("inventoryListView")
public class InventoryListViewImpl extends InventoryListViewImplBase {

	public InventoryListViewImpl() {
	}

	@Override
	public void receive(Event event) {
		DynamicMethodDispatcher.dispatch(this, event, "handle");
	}

	public void handle(InventoryItemCreated event) {
		getInventoryItemListRepository().save(new InventoryItemList(event.getItemId(), event.getName()));
	}

	public void handle(InventoryItemRenamed event) {
		InventoryItemList item = tryGetItem(event.getItemId());
		item.setName(event.getNewName());
		getInventoryItemListRepository().save(item);
	}

	public void handle(InventoryItemDeactivated event) {
		InventoryItemList item = tryGetItem(event.getItemId());
		getInventoryItemListRepository().delete(item);
	}

	public void handle(InventoryItemEvent other) {
		// not interested
	}

	private InventoryItemList tryGetItem(String itemId) {
		try {
			return getInventoryItemListRepository().findByKey(itemId);
		} catch (InventoryItemListNotFoundException e) {
			throw new IllegalStateException("Unknown item: " + itemId);
		}
	}
}
