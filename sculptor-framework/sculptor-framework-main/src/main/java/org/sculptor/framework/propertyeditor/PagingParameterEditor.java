package org.sculptor.framework.propertyeditor;

import org.sculptor.framework.domain.PagingParameter;

import java.beans.PropertyEditorSupport;

public class PagingParameterEditor extends PropertyEditorSupport {
	@Override
	public void setAsText(String pagingParameter) throws IllegalArgumentException {
		String[] data = pagingParameter.split(",");
		PagingParameter result;
		if (data.length == 1) {
			result = PagingParameter.pageAccess(Integer.parseInt(data[0]));
		} else if (data.length == 2) {
			result = PagingParameter.pageAccess(Integer.parseInt(data[0]), Integer.parseInt(data[1]));
		} else if (data.length == 3 && data[2].equalsIgnoreCase("true")) {
			result = PagingParameter.pageAccess(Integer.parseInt(data[0]), Integer.parseInt(data[1]), true);
		} else if (data.length == 3 && data[2].equalsIgnoreCase("false")) {
			result = PagingParameter.pageAccess(Integer.parseInt(data[0]), Integer.parseInt(data[1]), false);
		} else if (data.length == 3) {
			result = PagingParameter.pageAccess(Integer.parseInt(data[0]), Integer.parseInt(data[1])
					, Integer.parseInt(data[2]));
		} else if (data.length == 4) {
			result = PagingParameter.pageAccess(Integer.parseInt(data[0]), Integer.parseInt(data[1])
					, Boolean.parseBoolean(data[3]), Integer.parseInt(data[2]));
		} else {
			result = PagingParameter.pageAccess(20, 1, false, 0);
		}

		setValue(result);
	}
}
