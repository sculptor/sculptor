package org.sculptor.betting.core.camel;

import org.apache.camel.LoggingLevel;
import org.apache.camel.builder.RouteBuilder;

public class Routes extends RouteBuilder {
	@Override
	public void configure() throws Exception {
		// route from the bet queue to the handleBettingInstruction endpoint,
		// via jms topic. Method invokation of auditService is also done on the
		// way.

		from("direct:bettingInstructions").log(LoggingLevel.INFO, "Processing: ${body}");
		from("jms:topic:bet").log(LoggingLevel.INFO, "Processing: ${body}");

		endpoint("jms:topic:bet");
		endpoint("direct:bettingInstructions");

	}

}