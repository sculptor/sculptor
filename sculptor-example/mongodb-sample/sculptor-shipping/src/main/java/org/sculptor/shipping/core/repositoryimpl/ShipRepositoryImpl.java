package org.sculptor.shipping.core.repositoryimpl;

import java.util.ArrayList;
import java.util.List;

import org.sculptor.shipping.core.domain.Ship;
import org.sculptor.shipping.core.domain.ShipEvent;
import org.sculptor.shipping.core.domain.ShipId;
import org.sculptor.shipping.core.exception.ShipNotFoundException;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for Ship
 */
@Repository("shipRepository")
public class ShipRepositoryImpl extends ShipRepositoryBase {
    public ShipRepositoryImpl() {
    }

    @Override
    public Ship save(Ship entity) {
        Ship saved = super.save(entity);

        List<ShipEvent> changes = entity.getUncommittedChanges();
        changes = applyVersionToChanges(changes, saved.getVersion());
        for (ShipEvent each : changes) {
            getShipEventRepository().save(each);
        }
        entity.markChangesAsCommitted();

        return saved;
    }

    private List<ShipEvent> applyVersionToChanges(List<ShipEvent> changes,
            long version) {
        List<ShipEvent> result = new ArrayList<ShipEvent>();
        long sequence = version * 1000;
        for (ShipEvent each : changes) {
            result.add(each.withAggregateVersion(version).withChangeSequence(
                    sequence));
            sequence++;
        }
        return result;
    }

    @Override
    public Ship findByKey(ShipId shipId) throws ShipNotFoundException {
        Ship result = super.findByKey(shipId);

        loadFromHistory(result);

        return result;
    }

    private void loadFromHistory(Ship entity) {
        List<ShipEvent> history = getShipEventRepository().findAllForShip(
                entity.getShipId());
        entity.loadFromHistory(history);
    }

}
