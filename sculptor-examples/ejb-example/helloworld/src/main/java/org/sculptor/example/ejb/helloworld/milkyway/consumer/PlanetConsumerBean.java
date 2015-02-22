package org.sculptor.example.ejb.helloworld.milkyway.consumer;

import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.interceptor.Interceptors;
import javax.jms.MessageListener;

import org.sculptor.example.ejb.helloworld.milkyway.consumer.PlanetConsumerBeanBase;
import org.sculptor.example.ejb.helloworld.milkyway.domain.Planet;
import org.sculptor.framework.context.ServiceContextStoreInterceptor;
import org.sculptor.framework.errorhandling.ApplicationException;
import org.sculptor.framework.errorhandling.ErrorHandlingInterceptor;
import org.sculptor.framework.persistence.JpaFlushEagerInterceptor;

/**
 * EJB MessageDrivenBean implementation of PlanetConsumer.
 * <p>
 * You must define resource mapping ConnectionFactory and invalidMessageQueue,
 * like this in jboss.xml:
 * 
 * <pre>
 *       &lt;message-driven&gt;
 *             &lt;ejb-name&gt;eventConsumer&lt;/ejb-name&gt;
 *             &lt;resource-ref&gt;
 *                 &lt;res-ref-name&gt;jms/QueueFactory&lt;/res-ref-name&gt;
 *                 &lt;jndi-name&gt;ConnectionFactory&lt;/jndi-name&gt;
 *             &lt;/resource-ref&gt;
 *             &lt;resource-ref&gt;
 *                 &lt;res-ref-name&gt;jms/invalidMessageQueue&lt;/res-ref-name&gt;
 *                 &lt;jndi-name&gt;queue/helloworld.invalidMessageQueue&lt;/jndi-name&gt;
 *             &lt;/resource-ref&gt;
 *         &lt;/message-driven&gt;
 * </pre>
 */
@MessageDriven(name = "planetConsumer", messageListenerInterface = MessageListener.class, activationConfig = {
		@ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Queue"),
		@ActivationConfigProperty(propertyName = "destination", propertyValue = "queue/addPlanet") })
@Interceptors({ ServiceContextStoreInterceptor.class, ErrorHandlingInterceptor.class, JpaFlushEagerInterceptor.class })
public class PlanetConsumerBean extends PlanetConsumerBeanBase implements MessageListener {
	@SuppressWarnings("unused")
	private static final long serialVersionUID = 1L;

	public PlanetConsumerBean() {
	}

	public String consume(String textMessage) throws ApplicationException {
		Planet newPlanet = new Planet(textMessage);
		newPlanet.setMessage("Hello from " + textMessage);
		getPlanetRepository().save(newPlanet);
		return null;
	}

}
