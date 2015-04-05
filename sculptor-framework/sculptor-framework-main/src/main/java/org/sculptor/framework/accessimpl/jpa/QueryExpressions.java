package org.sculptor.framework.accessimpl.jpa;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;


/**
 * Holds the expressions of the query
 *
 * @author Oliver Ringel
 *
 */
public class QueryExpressions<T> {

    private List<String> selections = new ArrayList<String>();
    private List<String> groups = new ArrayList<String>();
    private List<String> orders = new ArrayList<String>();
    private List<QueryPropertyRestriction> restrictions = new ArrayList<QueryPropertyRestriction>();
	private Map<String, Object> parameters = new HashMap<String, Object>();
	private Class<T> type = null;

	public QueryExpressions() {
	}

	public QueryExpressions(Class<T> type) {
		this.type = type;
	}

	public List<String> getSelections() {
		return selections;
	}

	public void setSelections(List<String> expressions) {
		this.selections = expressions;
	}

	public void addSelections(String expressions) {
		String[] exp = expressions.split(",");
		for (int i = 0; i < exp.length; i++) {
			this.selections.add(exp[i].trim());
		}
	}

	public void addSelections(String... expressions) {
		for (int i = 0; i < expressions.length; i++) {
			this.selections.add(expressions[i].trim());
		}
	}

	/**
	 * Tries to select all fields from a class with same name and type declared in entity
	 *
	 * @param selectionType
	 */
	// TODO: support for references and collections
	public void addSelections(Class<?> selectionType) {
		List<Field> fields = JpaHelper.listFields(selectionType);
		for (Field field : fields) {
			if (field.getName().equals("serialVersionUID"))
				continue;
			if (type != null && JpaHelper.findField(type, field.getName()) != null) {
				if (JpaHelper.findField(type, field.getName()).getType().equals(field.getType())) {
					this.selections.add(field.getName());
				}
			}
		}
	}

	public void addSelection(String selection) {
		this.selections.add(selection);
	}

	public boolean hasSelections() {
		if (selections != null && !selections.isEmpty()) {
			return true;
		}
		return false;
	}

    public List<String> getGroups() {
		return groups;
	}

    public void setGroups(List<String> groups) {
		this.groups = groups;
	}

	public void addGroups(String groups) {
		String[] grp = groups.split(",");
		for (int i = 0; i < grp.length; i++) {
			this.groups.add(grp[i].trim());
		}
	}

	public void addGroups(String... groups) {
		for (int i = 0; i < groups.length; i++) {
			this.groups.add(groups[i].trim());
		}
	}

	public void addGroup(String selection) {
		this.groups.add(selection);
	}

	public boolean hasGroups() {
		if (groups != null && !groups.isEmpty()) {
			return true;
		}
		return false;
	}

    public List<String> getOrders() {
		return orders;
	}

    public String getOrdersAsString() {
		return JpaHelper.toSeparatedString(orders, ",");
	}

	public void setOrders(List<String> orders) {
		this.orders = orders;
	}

	public void addOrders(String orders) {
		String[] ord = orders.split(",");
		for (int i = 0; i < ord.length; i++) {
			this.orders.add(ord[i].trim());
		}
	}

	public void addOrders(String... orders) {
		for (int i = 0; i < orders.length; i++) {
			this.orders.add(orders[i].trim());
		}
	}

	public void addOrder(String selection) {
		this.orders.add(selection);
	}

	public boolean hasOrders() {
		if (orders != null && !orders.isEmpty()) {
			return true;
		}
		return false;
	}

    public List<QueryPropertyRestriction> getRestrictions() {
		return restrictions;
	}

	public void setRestrictions(List<QueryPropertyRestriction> restrictions) {
		this.restrictions = restrictions;
	}

	public void addRestrictions(Map<String, Object> restrictions) {
		for (Entry<String, Object> restriction : restrictions.entrySet()) {
			this.restrictions.add(
					new QueryPropertyRestriction(restriction.getKey(), restriction.getValue()));
		}
	}

    public void addRestriction(String property, Object value) {
		this.restrictions.add(
				new QueryPropertyRestriction(property, value));
    }

    public void addRestriction(String property, QueryPropertyRestriction.Operator operator, Object value) {
        this.restrictions.add(
                new QueryPropertyRestriction(property, operator, value));
    }

	public Map<String, Object> getParameters() {
		return parameters;
	}

	public void setParameters(Map<String, Object> parameters) {
		this.parameters = parameters;
	}

    public void addParameter(String parameter, Object value) {
    	parameters.put(parameter, value);
    }
}
