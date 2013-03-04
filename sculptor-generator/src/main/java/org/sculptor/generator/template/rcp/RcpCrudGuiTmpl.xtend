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

package org.sculptor.generator.template.rcp

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class RcpCrudGuiTmpl {


def static String richClientApp(GuiApplication it) {
	'''
	
	«RcpCrudGuiInfrastructure::infrastructure(it)»
	«RcpCrudGuiPreferences::preferences(it)»
	«RcpCrudGuiCommonAdapter::commonAdapter(it)»
	«RcpCrudGuiCommonData::commonData(it)»
	«RcpCrudGuiCommonUi::commonUi(it)»
	«RcpCrudGuiNavigationMasterDetail::navigationMasterDetail(it)»
	«RcpCrudGuiCommonHandler::selectInMainHandler(it)»
	«RcpCrudGuiMessageResources::messageResources(it)»
	«RcpCrudGuiRichObject::richObject(it)»
	«RcpCrudGuiRepository::repository(it)»
	«RcpCrudGuiServiceStub::serviceStub(it)»
	«RcpCrudGuiAdapter::adapter(it)»
	«RcpCrudGuiDetailsController::detailsController(it)»
	«RcpCrudGuiDetailsPage::detailsPage(it)»
	«RcpCrudGuiCreateController::createController(it)»
	«RcpCrudGuiCreateWizard::createWizard(it)»
	«RcpCrudGuiCreateWizardPage::createWizardPage(it)»
	«RcpCrudGuiCreateWizardHandler::createWizardHandler(it)»
	«RcpCrudGuiDeleteHandler::deleteHandler(it)»
	«RcpCrudGuiListView::listView(it)»
	«RcpCrudGuiListViewHandler::listViewHandler(it)»
	«RcpCrudGuiAddDialog::addDialog(it)»
	«RcpCrudGuiSpring::spring(it)»
	«RcpCrudGuiPlugin::plugin(it)»
	«RcpCrudGuiManifest::manifest(it)»
	
	«IF isTestToBeGenerated()»
		«RcpCrudGuiRepositoryTest::repositoryTest(it)»
		«RcpCrudGuiCreateControllerTest::createControllerTest(it)»
		«RcpCrudGuiDetailsControllerTest::detailsControllerTest(it)»
		«RcpCrudGuiSpringTest::springTest(it)»
	«ENDIF»
	'''
} 



}
