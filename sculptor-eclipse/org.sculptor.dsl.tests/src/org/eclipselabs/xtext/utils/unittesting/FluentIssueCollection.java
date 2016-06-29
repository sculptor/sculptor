package org.eclipselabs.xtext.utils.unittesting;

import static org.eclipselabs.xtext.utils.unittesting.XtextUtils.ancestor;
import static org.eclipselabs.xtext.utils.unittesting.XtextUtils.eString;
import static org.eclipselabs.xtext.utils.unittesting.XtextUtils.egetAndResolve;
import static org.eclipselabs.xtext.utils.unittesting.XtextUtils.getEObject;
import static org.eclipselabs.xtext.utils.unittesting.XtextUtils.name;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.apache.log4j.Logger;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.validation.Issue;

import com.google.common.collect.Iterables;
 
/**
 * Offers a fluent way of asserting Xtext Issues (Validation Warnings and Errors).
 * 
 * @author Markus Voelter - Initial Contribution and API
 *
 */
public class FluentIssueCollection implements Iterable<Issue>{

	private static Logger LOGGER = Logger.getLogger(FluentIssueCollection.class);

	private List<Issue> issues;
	private List<String> messages;
	private Resource resource;
	
	private boolean state;
	private boolean stateIsSet;

	public FluentIssueCollection( Resource res, List<Issue> issues, List<String> messages ) {
		this.resource = res;
		this.issues = issues;
		this.messages = messages;
	}
 
	public FluentIssueCollection(Resource res, List<String> messages) {
		this.issues = new ArrayList<Issue>();
		this.resource = res;
		this.messages = messages;
	}
	
	private void addMessage( String m ) {
		messages.add( m );
	}
	
	public void addIssue( Issue issue ) {
		issues.add( issue );
	}
	
	public FluentIssueCollection forType( Class<? extends EObject> cls ) {
		FluentIssueCollection res = new FluentIssueCollection(resource, messages);
		for (Issue i : issues) {
			URI uri = i.getUriToProblem();
			EObject eObject = resource.getEObject(uri.fragment());
			if ( cls.isInstance(eObject)) {
				res.addIssue(i);
			}
		}
		if (res.getIssueCount() == 0 ) {
			res.addMessage("No issues found for type "+cls.getName());
		}
		return res;
	}

	public FluentIssueCollection get( int index ) {
		FluentIssueCollection res = new FluentIssueCollection(resource, messages);
		if ( index >= getIssueCount() ) {
			res.addMessage( "trying to get element at "+index+", but only have "+getIssueCount()+" elements -> creating empty collection!");
		} else {
			res.addIssue( getIssues().get(index) );
		}
		return res;
	}

	public FluentIssueCollection inLine( int lineNo ) {
		FluentIssueCollection res = new FluentIssueCollection(resource, messages);
		int rc = 0;
		for (Issue i: issues) {
			if ( i.getLineNumber() == lineNo ) {
				res.addIssue( i );
				rc++;
			}
		} 
		if ( rc == 0 ) {
			res.addMessage("no issues found for line number "+lineNo);
		}
		return res;
	}

	public FluentIssueCollection withStringFeatureValue( String featureName, String value ) {
		FluentIssueCollection res = new FluentIssueCollection(resource, messages);
		for (Issue i: issues) {
			EObject eObject = getEObject(i, resource);
			String v = eString(egetAndResolve(eObject, featureName, resource.getResourceSet()));
			if ( v.contains(value)) {
				res.addIssue( i );
			}
		}
		if (res.getIssueCount() == 0 ) {
			res.addMessage("no elements found with feature "+featureName+" valued '"+value+"'");
		}
		return res;
	}
	
	public FluentIssueCollection except(Set<Issue> toBeRemoved) {
		FluentIssueCollection res = new FluentIssueCollection(resource, messages);
		
		if (toBeRemoved!=null) {
			for (Issue i: issues) {
				if ( !toBeRemoved.contains(i) ) {
					res.addIssue( i );
				}
			}
		}
		return res;
	}

	public FluentIssueCollection errorsOnly() {
		Severity severity = Severity.ERROR;
		
		return withSeverity(severity);
	}
	
	public FluentIssueCollection warningsOnly() {
		Severity severity = Severity.WARNING;
		
		return withSeverity(severity);
	}

	public FluentIssueCollection withSeverity(Severity... severities) {
		FluentIssueCollection res = new FluentIssueCollection(resource, messages);
		for (Issue i: issues) {
			if ( Iterables.contains(Arrays.asList(severities), i.getSeverity()) ) {
				res.addIssue( i );
			}
		}
		return res;
	}

	public FluentIssueCollection named( String expectedName ) {
		FluentIssueCollection res = new FluentIssueCollection(resource, messages);
		for (Issue i: issues) {
			EObject eObject = getEObject(i, resource);
			String name = name(eObject);
			if ( name.contains(expectedName)) {
				res.addIssue( i );
			}
		}
		if (res.getIssueCount() == 0 ) {
			res.addMessage("no elements found with name "+expectedName);
		}
		return res;
	}


	
	public FluentIssueCollection forElement( Class<? extends EObject> cls, String name ) {
		FluentIssueCollection res = new FluentIssueCollection(resource, messages);
		for (Issue i : issues) {
			EObject eObject = getEObject(i, resource);
			if ( cls.isInstance(eObject)) {
				if ( name.equalsIgnoreCase(name(eObject)) ) {
					res.addIssue(i);
				}
			}
		}
		if (res.getIssueCount() == 0 ) {
			res.addMessage("no elements of type "+cls.getName()+" named '"+name+"' found");
		}
		return res;
	}

	private int getIssueCount() {
		return issues.size();
	}

	public FluentIssueCollection under( Class<? extends EObject> cls ) {
		return under(cls,null);
	}

	
	public FluentIssueCollection under( Class<? extends EObject> cls, String name ) {
		FluentIssueCollection res = new FluentIssueCollection(resource, messages);
		for (Issue i : issues) {
			URI uri = i.getUriToProblem();
			EObject eObject = resource.getEObject(uri.fragment());
			EObject p = ancestor( eObject, cls );
			if ( p != null ) {
				if ( name != null ) {
					if ( name.equals(name(p))) {
						res.addIssue(i);
					}
				} else {
					res.addIssue(i);
				}
			} 
		}
		if ( res.getIssueCount() == 0 ) {
			res.addMessage("did not find issues under a "+cls.getName()+" named '"+name+"'");
		}
		return res;
	}
	

	public FluentIssueCollection sizeIs(int i) {
		if ( issues.size() == i ) {
			state = true;
		} else {
			addMessage("failed size: expected "+i+", actual "+issues.size());
			state = false;
		}
		return this;
	}
	
	public FluentIssueCollection oneOfThemContains(String substring) {
		boolean found = false;
		for (Issue i: issues) {
			if ( i.getMessage().toLowerCase().contains(substring.toLowerCase()) ) { 
				found = true;
			}
		}
		if ( found ) reportOk(); else {
			addMessage("failed oneOfThemContains: none of the issues contains substring '"+substring+"'");
			reportError();
		}
		return this;
	}
	
	public FluentIssueCollection nOfThemContain(int n, String substring) {
		int count = 0;
		for (Issue i: issues) {
			if ( i.getMessage().toLowerCase().contains(substring.toLowerCase()) ) { 
				count++;
			}
		}
		if ( count == n ) reportOk(); else {
			addMessage("failed nOfThemContain: expected "+n+" with substring '"+substring+"', but '"+count+"' found.");
			reportError();
		}
		return this;
	}	
	
	public FluentIssueCollection allOfThemContain(String substring) {
		for (Issue i: issues) {
			if ( !i.getMessage().toLowerCase().contains(substring.toLowerCase()) ) {
				reportError();
				addMessage("failed allOfThemContain: not all issues contain the substring '"+substring+"'");
			}
		}
		reportOk(); 
		return this;
	}
	
	public FluentIssueCollection theOneAndOnlyContains(String substring) {
		if ( issues.size() > 1 ) {
			reportError();
			addMessage("failed theOneAndOnlyContains: expecting a single issue (theSingleOneReads) but found: "+issues.size());
			for (Issue issue : issues) {
				LOGGER.debug("  line "+issue.getLineNumber()+": "+issue.getMessage()+" / "+issue.getUriToProblem());
			}			
			return this;
		}
		return oneOfThemContains(substring);
	}
	
	/**
	 * Filters all issues with a specific {@link Issue#getCode() issue code}.
	 * 
	 * @param code Issue code
	 * @return A new instance containing the issues with the given code.
	 */
	public FluentIssueCollection withCode( String code ) {
		FluentIssueCollection res = new FluentIssueCollection(resource, messages);
		for (Issue i: issues) {
			if ( i.getCode().equals(code)) {
				res.addIssue( i );
			}
		}
		if (res.getIssueCount() == 0 ) {
			res.addMessage("failed withCode: no issues found with code '"+code+"'");
		}
		return res;
	}
	
	public boolean evaluate() {
		return state;
	}
	
	
	protected void reportOk() {
		if ( stateIsSet ) {
			if ( state ) state = true;
			if ( !state ) state = false;
		} else  {
			state = true;
		}
		stateIsSet = true;
	}

	protected void reportError() {
		if ( stateIsSet ) {
			if ( state ) state = false;
			if ( !state ) state = false;
		} else  {
			state = false;
		}
		stateIsSet = true;
	}

	public List<Issue> getIssues() {
		return issues;
	}
	
	public Resource getResource() {
		return resource;
	}

	public List<String> getMessages() {
		return messages;
	}
	
	public String getMessageString() {
		StringBuffer sb = new StringBuffer();
		for (String m : messages) {
			sb.append("\n  - "+m);
		}
		return sb.toString();
	}

	public void dumpIssues() {
		LOGGER.debug("--- Issues ---");
		for (Issue i: issues) {
			dumpIssue(resource, i);
		}
	}
	
	public String getSummary() {
		if (issues.size() == 0)
			return "No issues";
		
		StringBuffer sb = new StringBuffer();
		sb.append("Issues:");
		for (Issue i : issues) {
			sb.append("\n  - "+ getIssueSummary(resource, i));
		}
		return sb.toString();
	}
	
	public static void dumpIssue(Resource resource, Issue issue) {
		LOGGER.debug( getIssueSummary(resource, issue));
	}
	
	public static String getIssueSummary(Resource resource, Issue issue) {
		boolean validFragment = true;
		if ("//".equals(issue.getUriToProblem().fragment())) {
			validFragment = false;
		}
		
		if (validFragment) {
			EObject eObject =  resource.getEObject(issue.getUriToProblem().fragment());
			EClass cls = eObject.eClass();
			return issue.getSeverity() + " at " + cls.getName()+"( line "+issue.getLineNumber()+"): " +issue.getMessage();
		} else {
			return issue.getSeverity() + "( line "+issue.getLineNumber()+"): " +issue.getMessage();
		}
	}

	public Iterator<Issue> iterator() {
		return issues.iterator();
	}

}