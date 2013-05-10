package org.sculptor.shipping.camel;

import org.apache.camel.LoggingLevel;
import org.apache.camel.builder.RouteBuilder;

public class Routes extends RouteBuilder {
    @Override
    public void configure() throws Exception {
        // route from the shippingChannel queue to two different statistics
        // endpoints,
        // via jms topic. Method invokation of auditService is also done on the
        // way.

        from("direct:shippingChannel").log(LoggingLevel.DEBUG, "Processing: ${body}").to(
                "bean:auditService?method=auditEvent", "jms:topic:shippingEvent");
        from("jms:topic:shippingEvent").to("direct:shippingStatistics").to("direct:shippingStatistics2");

        endpoint("direct:testChannel");

    }

}