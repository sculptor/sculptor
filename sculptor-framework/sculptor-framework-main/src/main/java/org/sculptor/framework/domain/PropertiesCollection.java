package org.sculptor.framework.domain;

import org.sculptor.framework.domain.expression.ComplexExpression;
import org.sculptor.framework.domain.expression.Expression;
import org.sculptor.framework.domain.expression.ExpressionNumeric;

import java.io.Serializable;

public class PropertiesCollection<T> implements Property<T>, Serializable {

    private static final long serialVersionUID = 1L;

    private final String name;

    public PropertiesCollection(String parentPath) {
        this.name = parentPath;
    }

    public PropertiesCollection(String parentPath, String additionalPath) {
        this.name = (parentPath == null ? additionalPath
                : (parentPath + "." + additionalPath));
    }

    public String getName() {
        return name;
    }

    @Override
    public ComplexExpression<T> expr() {
        return null;
    }

    protected String getParentPath() {
        return name;
    }

    @Override
    public String toString() {
        return getName();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((name == null) ? 0 : name.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        PropertiesCollection other = (PropertiesCollection) obj;
        if (name == null) {
            if (other.name != null)
                return false;
        } else if (!name.equals(other.name))
            return false;
        return true;
    }

}
