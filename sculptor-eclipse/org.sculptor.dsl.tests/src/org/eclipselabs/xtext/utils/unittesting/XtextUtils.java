package org.eclipselabs.xtext.utils.unittesting;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.validation.Issue;

/**
 * <p>Utilities for XText supporting the IssueCollection</p>
 * <p>TODO: This class should be available in a more generic package</p>
 * 
 * @author Markus Voelter - Initial Contribution and API
 *
 */
public class XtextUtils {
	
	/**
	 * Returns the ancestor of type ancestorClass of the ctx element 
	 */
	public static <C extends EObject> C ancestor(EObject ctx, Class<C> ancestorClass) {
		return EcoreUtil2.getContainerOfType(ctx, ancestorClass);
	}	

	/**
	 * like above, but using the EClass instead of the Java class object
	 */
	public static EObject ancestor(EObject ctx, EClass ancClass) {
		EObject anc = ctx.eContainer();
		while ( true ) {
			if ( anc == null ) return null;
			if ( ancClass.isInstance(anc)) return anc;
			anc = anc.eContainer();
		}
	}	
	
	public static List<EObject> ancestors(EObject ctx, EClass ancClass) {
		List<EObject> res = new ArrayList<EObject>();
		EObject anc = ctx.eContainer();
		while ( true ) {
			if ( anc == null ) return res;
			if ( ancClass.isInstance(anc)) res.add( anc );
			anc = anc.eContainer();
		}
	}	

	/** 
	 * compares two objects and takes into account nulls
	 */
	public static boolean nullTolerantEquals(Object o1, Object o2) {
		if ( o1 == null ) {
			if ( o2 == null ) {
				return true;
			} else {
				return false;
			}
		} else {
			if ( o2 == null ) {
				return false;
			} else {
				return o1.equals(o2);
			}
		}
	}	
	
	/**
	 * uses reflection to return the value of the name attribute
	 * if it exists, null otherwise
	 */
	public static String name( EObject object ) {
		EStructuralFeature namefeature = object.eClass().getEStructuralFeature("name");
		if ( namefeature == null ) {
			return null;
		} else {
			return (String) object.eGet(namefeature);
		}
	}

	/**
	 * outputs a more or less useful string representation
	 * for an EObject
	 */
	public static String eString( EObject eObject )  {
		if ( eObject instanceof EClass ) {
			return ((EClass) eObject).getName();
		} else {
			String res;
			String name = name(eObject);
			if ( name != null ) {
				res = eObject.eClass().getName()+"/"+name;
			} else {
				res = eObject.eClass().getName();
			}
			if ( eObject.eIsProxy() ) {
				res += "[proxy]";
			}
			return res;
		}
	}	

	public static Object eget( EObject eObject, String featureName) {
		Object val = eObject.eGet(eObject.eClass().getEStructuralFeature(featureName));
		return val;
	}

	public static EObject egetAndResolve( EObject eObject, String featureName, ResourceSet rs ) {
		EObject val = (EObject) eget( eObject, featureName );
		return resolveProxy((EObject) val, rs);
	}

	public static EObject getEObject( Issue issue, Resource r ) {
		URI uri = issue.getUriToProblem();
		EObject eObject = r.getEObject(uri.fragment());
		return eObject;
	}
	
	public static EObject resolveProxy( EObject eObject, ResourceSet rs ) {
		if ( eObject.eIsProxy()) {
			eObject = EcoreUtil.resolve(eObject, rs);
		}
		return eObject;
	}
	
}