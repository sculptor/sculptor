package org.sculptor.simplecqrs.command.repositoryimpl;

import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;
import static org.sculptor.simplecqrs.command.domain.InventoryItemSnapshotProperties.itemId;
import static org.sculptor.simplecqrs.command.domain.InventoryItemSnapshotProperties.version;

import java.util.List;

import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.domain.PagedResult;
import org.sculptor.framework.domain.PagingParameter;
import org.sculptor.simplecqrs.command.domain.InventoryItemSnapshot;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for InventoryItemSnapshot
 */
@Repository("inventoryItemSnapshotRepository")
public class InventoryItemSnapshotRepositoryImpl extends InventoryItemSnapshotRepositoryBase {

	public InventoryItemSnapshotRepositoryImpl() {
	}

	@Override
	public InventoryItemSnapshot getLatestSnapshot(String itemId) {
		List<ConditionalCriteria> criteria = criteriaFor(InventoryItemSnapshot.class).withProperty(itemId()).eq(itemId)
				.orderBy(version()).descending().build();
		PagingParameter pagingParameter = PagingParameter.rowAccess(0, 1);
		PagedResult<InventoryItemSnapshot> result = findByCondition(criteria, pagingParameter);
		if (result.getValues().isEmpty()) {
			return null;
		} else {
			return result.getValues().get(0);
		}
	}
}
