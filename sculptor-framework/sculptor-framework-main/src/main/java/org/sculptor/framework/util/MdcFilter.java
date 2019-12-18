package org.sculptor.framework.util;

import org.slf4j.MDC;
import org.springframework.security.core.context.SecurityContextHolder;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

public class MdcFilter implements Filter {

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response,
						 FilterChain chain) throws IOException, ServletException {
		try {
			String userId = "NO_USER";
			if (SecurityContextHolder.getContext() != null
					&& SecurityContextHolder.getContext().getAuthentication() != null
					&& SecurityContextHolder.getContext().getAuthentication().getPrincipal() != null) {
				userId = SecurityContextHolder.getContext().getAuthentication().getPrincipal().toString();
			}
			String sessionId = "NO_SESSION";
			String url = "NO_URL";
			if (request instanceof HttpServletRequest) {
				HttpServletRequest httpRequest = (HttpServletRequest) request;
				sessionId = httpRequest.getSession().getId();
				url = httpRequest.getRequestURI();
			}

			MDC.put("user", userId);
			MDC.put("remoteAddress", request.getRemoteAddr());
			MDC.put("sessionId", sessionId);

			MDC.put("requestId", Long.toString(System.nanoTime()));
			MDC.put("serverName", request.getServerName());
			MDC.put("url", url);

			chain.doFilter(request, response);
		} finally {
			MDC.clear();
		}

	}

	@Override
	public void destroy() {
	}
}
