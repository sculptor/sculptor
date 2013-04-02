package org.sculptor.framework.domain;

public class LeafProperty<Q> implements Property<Q> {
    private static final long serialVersionUID = 1L;

    private final String name;
    private Class<Q> owningClass;

    public LeafProperty(String name, Class<Q> owningClass) {
        this.name = name;
        this.owningClass = owningClass;
    }

    public LeafProperty(String parentPath, String name, boolean isEmbedded, Class<Q> owningClass) {
        this.name = (parentPath == null ? name : (parentPath + (isEmbedded ? "#" : ".") + name));
        this.owningClass = owningClass;
    }

    public String getName() {
        return name.replaceAll("#", ".");
    }

    public String getEmbeddedName() {
        return name;
    }

    @Override
    public String toString() {
        return getName();
    }

    @Override
    public int hashCode() {
        return owningClass.hashCode() + name.hashCode();
    }

    @Override
    public boolean equals(Object other) {
        if (other == null || ! (other instanceof LeafProperty<?>)) {
            return false;
        }

        String thisString=this.owningClass.getCanonicalName() + name;
        String otherString=((LeafProperty<?>) other).owningClass.getCanonicalName() + ((LeafProperty<?>)other).name;
        return thisString.equals(otherString);
    }
}
