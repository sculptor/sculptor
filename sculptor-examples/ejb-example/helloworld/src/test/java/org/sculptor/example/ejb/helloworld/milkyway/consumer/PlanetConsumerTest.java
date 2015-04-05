package org.sculptor.example.ejb.helloworld.milkyway.consumer;

import static org.junit.Assert.assertEquals;

import javax.annotation.Resource;
import javax.jms.Destination;
import javax.jms.Queue;

import org.junit.Test;
import org.sculptor.example.ejb.helloworld.milkyway.domain.Planet;
import org.sculptor.framework.test.AbstractOpenEJBDbUnitTest;

/**
 * JUnit test with OpenEJB and DbUnit support.
 */
public class PlanetConsumerTest extends AbstractOpenEJBDbUnitTest {

	@Resource(mappedName = "planetConsumer")
	private Queue queue;

	@Test
	public void testConsume() throws Exception {
		int countBefore = countRowsInTable(Planet.class);
		String message = "Jupiter";
		Destination replyTo = sendMessage(queue, message);
		waitForReply(replyTo);
		int countAfter = countRowsInTable(Planet.class);
		assertEquals(countBefore + 1, countAfter);
	}

}
