package org.sculptor.dsl.scoping;

import java.util.List;

import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.impl.AbstractScope;
/**
 * 
 * @author Todd Ferrell
 *
 */
public class Scope extends AbstractScope {
	
	public Scope() {
		this(IScope.NULLSCOPE, true);
	}
	protected Scope(IScope parent, boolean ignoreCase) {
		super(parent, ignoreCase);
		// TODO Auto-generated constructor stub
	}


	private List<IEObjectDescription> elements;


	public IScope getOuterScope() {
		return outer == null ? IScope.NULLSCOPE : outer;
	}

	
	private IScope outer;
	
	public void setOuterScope(IScope outer) {
		this.outer = outer;
	}


	public void setElements(List<IEObjectDescription> elements) {
		this.elements = elements;
	}

	@Override
	protected Iterable<IEObjectDescription> getAllLocalElements() {
		
		return elements;
	}	
}
