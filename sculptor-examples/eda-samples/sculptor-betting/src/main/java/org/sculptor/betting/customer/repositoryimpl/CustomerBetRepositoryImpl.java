package org.sculptor.betting.customer.repositoryimpl;

import static org.sculptor.betting.customer.domain.CustomerBetProperties.amount;

import java.util.List;

import org.sculptor.betting.customer.domain.CustomerBet;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.ConditionalCriteriaBuilder;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for CustomerBet
 */
@Repository("customerBetRepository")
public class CustomerBetRepositoryImpl extends CustomerBetRepositoryBase {

	public CustomerBetRepositoryImpl() {
	}

	public List<CustomerBet> findHighStakesCustomers(Double limit) {
		List<ConditionalCriteria> criteria = ConditionalCriteriaBuilder.criteriaFor(CustomerBet.class)
				.withProperty(amount()).greaterThan(limit).build();
		List<CustomerBet> result = findByCondition(criteria);
		return result;
	}

}
