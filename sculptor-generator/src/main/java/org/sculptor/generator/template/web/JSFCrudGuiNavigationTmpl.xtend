/*
 * Copyright 2008 The Fornax Project Team, including the original 
 * author or authors.
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

package org.sculptor.generator.template.web

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class JSFCrudGuiNavigationTmpl {


def static String navigation(GuiApplication it) {
	'''
	«template(it)»
	«header(it)»
	«footer(it)»

	«IF isDynamicMenu()»
	«menuIncDynamic(it)»
	«menuBean(it)»
	«ELSE»
	«menuInc(it)»
	«ENDIF»	

	«indexWelcome(it)»
	'''
}

def static String template(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/common/template.xhtml", 'TO_WEBROOT', '''
	«JSFCrudGuiFlowJsf::docType(it)»
	<html «JSFCrudGuiFlowJsf::faceletsXmlns(it)»>
	<head>
		<title><h:outputFormat value="#{msg['navigation.title']}">
					<f:param value="#{msg['model.application.name']}" />
				</h:outputFormat></title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<t:stylesheet path="/themes/basic/style.css" />
	</head>
	<body>
		<div id="header">
			<ui:include src="header.html" />
		</div>
		<div class="menu">
			<ui:include src="/WEB-INF/generated/common/menu.html" />
		</div>
		<div id="breadCrumb">
			«breadCrumb(it)»
		</div> 
		<div id="main">
			<ui:insert name="content" />
		</div>
		<div id="footer">
			<ui:include src="footer.html" />
		</div>
	</body>
	</html>
	'''
	)
	'''
	'''
}

def static String header(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/common/header.html", 'TO_WEBROOT', '''
	<div></div>
	'''
	)
	'''
	'''
}

def static String breadCrumb(GuiApplication it) {
	'''
	<c:forEach var="item" items="${a:breadCrumb(flowExecutionContext,msg)}" varStatus="status" begin="0" step="1">
		<c:if test="${status.last}">
			<span class="lastItem">#{item.crudOperation} #{item.domainObjectName}</span>
		</c:if>
		<c:if test="${not status.last}">#{item.crudOperation} #{item.domainObjectName} #{" &gt; "}</c:if>
	</c:forEach>
	'''
}

def static String menuBean(GuiApplication it) {
	'''
	'''
	fileOutput(javaFileName(this.basePackage + "." + name.toFirstUpper() + "DynamicMenu") , '''
	«javaHeader()»
	package «this.basePackage»;

	import java.io.Serializable;
	import java.util.ArrayList;
	import java.util.List;

	import javax.faces.context.FacesContext;

	import org.apache.myfaces.custom.navmenu.NavigationMenuItem;
	import org.springframework.context.MessageSource;


	public class «name.toFirstUpper()»DynamicMenu implements Serializable {
	private static final long serialVersionUID = 1L;

	private final String MSG__NAV_LIST="navigation.list";
	private final String MSG__NAV_CREATE="navigation.create";
	
	protected MessageSource messages;
	
	protected NavigationMenuItem[] navItems;

	public «name.toFirstUpper()»DynamicMenu() {
	}

	protected void init(){
	«val menuTasks  = it.menuTasksGroupedByTarget()»
		List<NavigationMenuItem> navigationsMenuItems = new ArrayList<NavigationMenuItem>();
		
		«it.menuTasks .forEach[menuDynamic(it)]»
		
		navItems=navigationsMenuItems.toArray(new NavigationMenuItem[0]);
	}
		
	«val menuTasks  = it.menuTasksGroupedByTarget()»
		«it.menuTasks .forEach[menuCreateMethods(it)]»
	
	
	protected String createJsCookmenuJavaScriptLink(String link) {
		return "eval:window.location.href=\"" + getContext() + link+"\"";
	}
	
	protected String getContext() {
		return FacesContext.getCurrentInstance().getExternalContext()
				.getRequestContextPath();
	}
	
	protected NavigationMenuItem createMenuItem(String label, String action,
			String icon, boolean split) {
		NavigationMenuItem menuItem = new NavigationMenuItem(label, action,
				icon, split);
		menuItem.setTarget(null);
		return menuItem;
	}
/*
	private void printMap(Map map) {
		Iterator iterator = map.entrySet().iterator();
		while (iterator.hasNext()) {
			Map.Entry entry = (Map.Entry) iterator.next();
			System.out.println("[" + entry.getKey() + "]=[" + entry.getValue()
					+ "]");
		}
	}
	*/
		public NavigationMenuItem[] getNavItems() {
			if(this.navItems==null){
				 init();
				/* 
				ExternalContext externalContext = FacesContext.getCurrentInstance()
					.getExternalContext();
					 
				printMap(externalContext.getApplicationMap());
			printMap(externalContext.getInitParameterMap());
			printMap(externalContext.getRequestMap());
			printMap(externalContext.getSessionMap());
			printMap(externalContext.getRequestParameterMap());
				*/ 
			}
			return navItems;
		}

		public void setNavItems(NavigationMenuItem[] navItems) {
			this.navItems = navItems;
		}

		public void setMessages(MessageSource messages) {
			this.messages = messages;
		}   

		public String getMessage(String messageKey, Object[] messageParameter) {

			//TODO maybe we need locale from FacesContext
			String message = this.messages.getMessage(messageKey, messageParameter, null);
		return message;
		}

		public String getMessage(String messageKey, Object messageParameter) {

			//TODO maybe we need locale from FacesContext
			String message = this.messages.getMessage(messageKey,
				new Object[] { messageParameter }, null);
		return message;
		}
		
		protected String getCreateActionImageUrl(){
			return "/img/create.png"; 
		}
		
		protected String getListActionImageUrl(){
			return "/img/list.png"; 
		}
		
		protected String getItemImageUrl(){
			return "/img/item.png"; 
		}
	
	}
	'''
	)
	'''
	'''
}

def static String menuDynamic(UserTaskGroup it) {
	'''
	«IF !this.userTasks.typeSelect(CreateTask).isEmpty || !this.userTasks.typeSelect(ListTask).isEmpty»
		navigationsMenuItems.add(create«for.name.toFirstUpper()»MenuItem());
	«ENDIF»
	'''
}

def static String menuCreateMethods(UserTaskGroup it) {
	'''
	«IF !this.userTasks.typeSelect(CreateTask).isEmpty || !this.userTasks.typeSelect(ListTask).isEmpty»
	
	protected NavigationMenuItem create«for.name.toFirstUpper()»MenuItem() {
	
	«IF !this.userTasks.typeSelect(CreateTask).isEmpty && !this.userTasks.typeSelect(ListTask).isEmpty»
		NavigationMenuItem[] «for.name.toFirstLower()»ChildrenMenuItems = new NavigationMenuItem[2];
		«for.name.toFirstLower()»ChildrenMenuItems[0]=«menuItemDynamic(it) FOR this.userTasks.typeSelect(ListTask).first()»;
		«for.name.toFirstLower()»ChildrenMenuItems[1]=«menuItemDynamic(it) FOR this.userTasks.typeSelect(CreateTask).first()»;
	«ELSEIF !this.userTasks.typeSelect(CreateTask).isEmpty»
		NavigationMenuItem[] «for.name.toFirstLower()»ChildrenMenuItems = new NavigationMenuItem[1];
		«for.name.toFirstLower()»ChildrenMenuItems[0]=«menuItemDynamic(it) FOR this.userTasks.typeSelect(CreateTask).first()»;
	«ELSEIF !this.userTasks.typeSelect(ListTask).isEmpty»
		NavigationMenuItem[] «for.name.toFirstLower()»ChildrenMenuItems = new NavigationMenuItem[1];
		«for.name.toFirstLower()»ChildrenMenuItems[0]=«menuItemDynamic(it) FOR this.userTasks.typeSelect(ListTask).first()»;
	«ENDIF»
	
		NavigationMenuItem «for.name.toFirstLower()»MenuItem = createMenuItem(
					getMessage("model.DomainObject.«for.name»",null), «for.name.toFirstLower()»ChildrenMenuItems[0].getAction(), getItemImageUrl(), false);
		«for.name.toFirstLower()»MenuItem.setNavigationMenuItems(«for.name.toFirstLower()»ChildrenMenuItems);
		
		return «for.name.toFirstLower()»MenuItem;
	}
	
	«ENDIF»
	'''
}

def static String menuItemDynamic(ListTask it) {
	'''

/*	
		createMenuItem(getMessage(MSG__NAV_LIST,getMessage("model.DomainObject.«for.name».plural",null)),"flowId:«name»-flow", "iconUrl", false)
 */
		createMenuItem(getMessage(MSG__NAV_LIST,getMessage("model.DomainObject.«for.name».plural",null)),createJsCookmenuJavaScriptLink("/«springServletMapping()»/«module.name»/«name»"), getListActionImageUrl(), false)
	'''
}

def static String menuItemDynamic(CreateTask it) {
	'''
/*	
		createMenuItem(getMessage(MSG__NAV_CREATE,getMessage("model.DomainObject.«for.name»",null)),"flowId:«name»-flow", "iconUrl", false)
 */
		createMenuItem(getMessage(MSG__NAV_CREATE,getMessage("model.DomainObject.«for.name»",null)),createJsCookmenuJavaScriptLink("/«springServletMapping()»/«module.name»/«name»"), getCreateActionImageUrl(), false)
	'''
} 



def static String menuIncDynamic(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/generated/common/menu.html", 'TO_GEN_WEBROOT', '''
	<h:form «JSFCrudGuiFlowJsf::faceletsXmlns(it)»>
		<input type="hidden" name="jscook_action"/>
		<t:jscookMenu layout="vbr" theme="ThemeOffice">
			<t:navigationMenuItems value="#{dynamicMenu.navItems}" />
		</t:jscookMenu>	
	</h:form>
	'''
	)
	'''
	'''
}

def static String menuInc(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/generated/common/menu.html", 'TO_GEN_WEBROOT', '''
/*
	<h:form «JSFCrudGuiFlowJsf::faceletsXmlns(it)»>
 */
		<table «JSFCrudGuiFlowJsf::faceletsXmlns(it)»>
			<tr>
			«val menuTasks  = it.menuTasksGroupedByTarget()»
				«it.menuTasks .forEach[menu(it)]»
				<td>#{" "}</td>
			</tr>
		</table>
/*
	</h:form>
 */
	'''
	)
	'''
	'''
}
	
/*Kind of abstract method, not used, concrete implementations 
	for subclasses of UserTask are defined */
def static String menu(UserTask it) {
	'''
	'''
}


def static String menu(UserTaskGroup it) {
	'''
	<td class="contentCell">
	«IF !this.userTasks.typeSelect(CreateTask).isEmpty»
	«menuItem(it) FOR this.userTasks.typeSelect(CreateTask).first()»
	«ELSE»<br />
	«ENDIF»
	«IF !this.userTasks.typeSelect(ListTask).isEmpty»
	«menuItem(it) FOR this.userTasks.typeSelect(ListTask).first()»
	«ELSE»<br />
	«ENDIF»
	</td>
	'''
}

def static String menuItem(ListTask it) {
	'''
	<a href="#{facesContext.externalContext.context.contextPath}/«springServletMapping()»/«module.name»/«name»">
	<h:outputFormat value="#{msg['navigation.list']}">
	<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name».plural']}" />
	</h:outputFormat>
	</a><br/>
/*
	<h:commandLink action="flowId:«name»-flow">
		<h:outputFormat value="#{msg['navigation.list']}">
			<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name».plural']}" />
		</h:outputFormat>
	</h:commandLink><br />
 */ 
	'''
}

def static String menuItem(CreateTask it) {
	'''
	<a href="#{facesContext.externalContext.context.contextPath}/«springServletMapping()»/«module.name»/«name»">
	<h:outputFormat value="#{msg['navigation.create']}">
	<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name»']}" />
	</h:outputFormat>
	</a><br/>
/*	
	<h:commandLink action="flowId:«name»-flow">
		<h:outputFormat value="#{msg['navigation.create']}">
			<f:param value="#{msg«resolveModuleName()»['model.DomainObject.«for.name»']}" />
		</h:outputFormat>
	</h:commandLink><br />
 */
	'''
} 

def static String footer(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/common/footer.html", 'TO_WEBROOT', '''
	<div></div>
	'''
	)
	'''
	'''
}

def static String indexWelcome(GuiApplication it) {
	'''
	'''
	fileOutput("index.xhtml", 'TO_WEBROOT', '''
	«JSFCrudGuiFlowJsf::docType(it)»
	<html «JSFCrudGuiFlowJsf::faceletsXmlns(it)»>
	<body>
		<ui:composition template="WEB-INF/common/template.xhtml">
			<ui:define name="content">
				<h1><h:outputFormat value="#{msg['welcome.header']}">
						<f:param value="#{msg['model.application.name']}" />
					</h:outputFormat></h1>
			</ui:define>
		</ui:composition>
	</body>
	</html>	
	'''
	)
	'''
	
	'''
	fileOutput("index.jsp", 'TO_WEBROOT', '''
	<% response.sendRedirect(request.getContextPath() + "/«springServletMapping()»/index.xhtml"); %>
	'''
	)
	'''
	'''
}
}
