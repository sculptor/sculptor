package org.sculptor.shipping.core.serviceimpl;

import org.sculptor.framework.event.Event;
import org.springframework.stereotype.Service;

@Service
public class AuditService {

    // public void auditEvent(Message<Event> message) {
    public void auditEvent(Event event) {
        System.out.println("Audit of event: " + event);
    }

    // public void securityAuditEvent(Message<Event> message) {
    public void securityAuditEvent(Event event) {
        System.out.println("Security audit of event: " + event);
    }

}
