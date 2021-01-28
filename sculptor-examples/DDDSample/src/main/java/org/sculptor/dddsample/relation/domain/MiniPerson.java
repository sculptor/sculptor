package org.sculptor.dddsample.relation.domain;

import org.hibernate.annotations.Type;
import org.joda.time.DateTime;
import org.sculptor.framework.domain.AbstractDomainObject;
import org.sculptor.framework.domain.Identifiable;
import org.sculptor.framework.domain.JodaAuditListener;
import org.sculptor.framework.domain.JodaAuditable;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import java.util.*;

public class MiniPerson {
	private Long id;
	private String first;
	private String secondName;
	private DateTime createdDate;

	public MiniPerson(Long id, String first, String second, DateTime created) {
		this.id = id;
		this.first = first;
		this.secondName = second;
		this.createdDate = created;
	}

	public Long getId() {
		return id;
	}

	public String getFirst() {
		return first;
	}

	public String getSecondName() {
		return secondName;
	}

	public DateTime getCreatedDate() {
		return createdDate;
	}

	@Override
	public String toString() {
		return "MiniPerson{" +
				"id=" + id +
				", first='" + first + '\'' +
				", secondName='" + secondName + '\'' +
				", createdDate=" + createdDate +
				'}';
	}
}
