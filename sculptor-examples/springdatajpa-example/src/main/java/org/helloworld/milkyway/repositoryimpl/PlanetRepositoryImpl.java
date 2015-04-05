package org.helloworld.milkyway.repositoryimpl;

import javax.sql.DataSource;

import org.helloworld.milkyway.domain.PlanetRepositoryCustom;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

/**
 * Repository custom implementation for Planet
 */
public class PlanetRepositoryImpl implements PlanetRepositoryCustom {

	@Autowired
	private DataSource dataSource;

	public String getLongestName() {
		return new JdbcTemplate(dataSource).queryForObject(
				"select name from PLANET where LENGTH(name) = (select MAX(LENGTH(name)) from PLANET)", String.class);
	}

}
