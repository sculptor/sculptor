package org.sculptor.simplecqrs.command.serviceimpl;

import org.sculptor.framework.event.Event;
import org.sculptor.simplecqrs.command.domain.InventoryItem;
import org.sculptor.simplecqrs.command.domain.InventoryItemEvent;
import org.sculptor.simplecqrs.command.domain.InventoryItemSnapshot;
import org.sculptor.simplecqrs.command.exception.InventoryItemNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

/**
 * Implementation of InventoryItemSnapshotter.
 */
@Service("inventoryItemSnapshotter")
public class InventoryItemSnapshotterImpl extends InventoryItemSnapshotterImplBase {

	private static final Logger LOG = LoggerFactory.getLogger(InventoryItemSnapshotterImpl.class);

	private static final int VERSION_DELTA = 100;

	public InventoryItemSnapshotterImpl() {
	}

	@Override
	public void receive(Event event) {
		if (!(event instanceof InventoryItemEvent)) {
			return;
		}

		InventoryItemEvent inventoryItemEvent = (InventoryItemEvent) event;
		String itemId = inventoryItemEvent.getItemId();

		InventoryItemSnapshot snapshot = getInventoryItemSnapshotRepository().getLatestSnapshot(itemId);
		long snapshotVersion = snapshot == null ? 1 : snapshot.getVersion();
		long eventVersion = inventoryItemEvent.getAggregateVersion() == null ? 1 : inventoryItemEvent
				.getAggregateVersion();
		if (eventVersion - snapshotVersion >= VERSION_DELTA) {
			takeSnapshot(itemId);
		}
	}

	private void takeSnapshot(String itemId) {
		InventoryItem item;
		try {
			item = getInventoryItemRepository().findByKey(itemId);
		} catch (InventoryItemNotFoundException e) {
			LOG.warn("takeSnapshot failed: " + e.getMessage());
			return;
		}

		InventoryItemSnapshot snapshot = item.createSnapshot();
		getInventoryItemSnapshotRepository().save(snapshot);
	}

}
