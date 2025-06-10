package org.sculptor.framework.accessimpl.jpa;

import org.sculptor.framework.accessapi.FindByConditionTupleAccess;

import jakarta.persistence.Tuple;
import jakarta.persistence.TypedQuery;
import java.util.List;

/**
 * Created by tavoda on 10/31/16.
 */
public class JpaFindByConditionTupleAccessImpl<T> extends JpaFindByConditionAccessImplGeneric<T, Tuple>
		implements
			FindByConditionTupleAccess<T> {
	public JpaFindByConditionTupleAccessImpl(Class<T> clazz) {
		super(clazz, Tuple.class);
	}

	public List<Tuple> getResult() {
		return getListResult();
	}
}
