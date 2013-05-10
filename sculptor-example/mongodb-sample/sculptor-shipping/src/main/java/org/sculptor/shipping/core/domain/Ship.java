package org.sculptor.shipping.core.domain;

import java.util.ArrayList;
import java.util.List;

import org.joda.time.DateTime;
import org.sculptor.framework.event.DynamicMethodDispatcher;

/**
 * 
 * Entity representing Ship. This class is responsible for the domain object
 * related business logic for Ship. Properties and associations are implemented
 * in the generated base class
 * {@link org.sculptor.shipping.core.domain.ShipBase}.
 */
public class Ship extends ShipBase {
    private static final long serialVersionUID = 1L;

    protected Ship() {
    }

    /**
     * Use {@link #createNew(String, String)} for constructing new InventoryItem
     * instances. This constructor is needed for persistence mapper.
     */
    public Ship(ShipId shipId) {
        super(shipId);
    }

    public static Ship createNew(ShipId shipId, String name) {
        Ship result = new Ship(shipId);
        result.applyChange(new ShipCreated(new DateTime(), shipId, name));
        return result;
    }

    public void arrival(Port port) {
        applyChange(new ShipHasArrived(new DateTime(), getShipId(), port));
    }

    public void apply(ShipHasArrived event) {
        setPort(event.getPort());
    }

    public boolean isAtSea() {
        return getPort() == null;
    }

    public void departure(Port port) {
        applyChange(new ShipHasDepartured(new DateTime(), getShipId(), port));
    }

    public void apply(ShipHasDepartured event) {
        setPort(null);
    }

    public void load(Cargo cargo) {
        applyChange(new CargoLoaded(new DateTime(), getShipId(), cargo));
    }

    public void apply(CargoLoaded event) {
        addCargo(event.getCargo());
    }

    public void unload(Cargo cargo) {
        applyChange(new CargoUnloaded(new DateTime(), getShipId(), cargo));
    }

    public void apply(CargoUnloaded event) {
        removeCargo(event.getCargo());
    }

    public void apply(ShipCreated event) {
        setName(event.getName());
    }

    public void apply(Object other) {
        // ignore
    }

    private final List<ShipEvent> changes = new ArrayList<ShipEvent>();

    public List<ShipEvent> getUncommittedChanges() {
        return changes;
    }

    public void markChangesAsCommitted() {
        changes.clear();
    }

    private void applyChange(ShipEvent event, boolean isNew) {
        DynamicMethodDispatcher.dispatch(this, event, "apply");
        if (isNew) {
            changes.add(event);
        } else {
            setVersion(event.getAggregateVersion());
        }
    }

    private void applyChange(ShipEvent event) {
        applyChange(event, true);
    }

    public void loadFromHistory(List<ShipEvent> history) {
        for (ShipEvent each : history) {
            applyChange(each, false);
        }
    }

}
