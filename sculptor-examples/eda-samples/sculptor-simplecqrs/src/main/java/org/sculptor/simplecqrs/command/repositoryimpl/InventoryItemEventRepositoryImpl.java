package org.sculptor.simplecqrs.command.repositoryimpl;

import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;
import static org.sculptor.simplecqrs.command.domain.InventoryItemEventProperties.changeSequence;
import static org.sculptor.simplecqrs.command.domain.InventoryItemEventProperties.itemId;

import java.util.List;

import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.simplecqrs.command.domain.InventoryItemEvent;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for InventoryItemEvent
 */
@Repository("inventoryItemEventRepository")
public class InventoryItemEventRepositoryImpl extends InventoryItemEventRepositoryBase {

	public InventoryItemEventRepositoryImpl() {
	}

	@Override
	public List<InventoryItemEvent> findAllForItem(String itemId) {
		List<ConditionalCriteria> criteria = criteriaFor(InventoryItemEvent.class).withProperty(itemId()).eq(itemId)
				.orderBy(changeSequence()).build();
		return findByCondition(criteria);
	}
}
