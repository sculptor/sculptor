package org.sculptor.simplecqrs.command.repositoryimpl;

import java.util.ArrayList;
import java.util.List;

import org.sculptor.simplecqrs.command.domain.InventoryItem;
import org.sculptor.simplecqrs.command.domain.InventoryItemEvent;
import org.sculptor.simplecqrs.command.exception.InventoryItemNotFoundException;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for InventoryItem
 */
@Repository("inventoryItemRepository")
public class InventoryItemRepositoryImpl extends InventoryItemRepositoryBase {

	public InventoryItemRepositoryImpl() {
	}

	@Override
	public InventoryItem save(InventoryItem entity) {
		InventoryItem saved = super.save(entity);

		List<InventoryItemEvent> changes = entity.getUncommittedChanges();
		changes = applyVersionToChanges(changes, saved.getVersion());
		for (InventoryItemEvent each : changes) {
			getInventoryItemEventRepository().save(each);
		}
		entity.markChangesAsCommitted();

		return saved;
	}

	private List<InventoryItemEvent> applyVersionToChanges(List<InventoryItemEvent> changes, long version) {
		List<InventoryItemEvent> result = new ArrayList<InventoryItemEvent>();
		long sequence = version * 1000;
		for (InventoryItemEvent each : changes) {
			result.add(each.withAggregateVersion(version).withChangeSequence(sequence));
			sequence++;
		}
		return result;
	}

	@Override
	public InventoryItem findByKey(String itemId) throws InventoryItemNotFoundException {
		InventoryItem result = super.findByKey(itemId);

		loadFromHistory(result);

		return result;
	}

	private void loadFromHistory(InventoryItem entity) {
		List<InventoryItemEvent> history = getInventoryItemEventRepository().findAllForItem(entity.getItemId());
		entity.loadFromHistory(history);
	}

}
