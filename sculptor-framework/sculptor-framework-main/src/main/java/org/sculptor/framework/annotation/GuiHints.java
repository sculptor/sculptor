/*
 * (C) Copyright Factory4Solutions a.s. 2009
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sculptor.framework.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Inherited;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation used for marking methods with some details necessary for nice
 * GUI behaviour
 * 
 * @author Ing. Pavel Tavoda
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@Inherited
public @interface GuiHints {
	public VisibleOn visibleOn() default VisibleOn.ON_DETAIL;
	public DetailBehavior detailBehavior() default DetailBehavior.ON_VIEW;
	public String ifStatus() default "";
	public String ifRole() default "";
	public boolean requireConfirmation() default false;

	enum VisibleOn {
		ON_LIST,
		ON_DETAIL,
		ON_TAB,
		ON_LIST_DETAIL,
		HIDDEN
	}

	enum DetailBehavior {
		ON_VIEW, ON_EDIT, ON_NEW, ON_VIEW_EDIT, ON_VIEW_NEW, ON_EDIT_NEW, ON_ALL, ON_VIEW_EDIT_NEW
	}
}