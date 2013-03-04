/*
 * Copyright 2007 The Fornax Project Team, including the original 
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

class CssTmpl {


def static String css(GuiApplication it) {
	'''
	«style(it)»
	'''
}

def static String style(GuiApplication it) {
	'''
	'''
	fileOutput("themes/basic/style.css", 'TO_WEBROOT', '''
	@CHARSET "ISO-8859-1";
	div {

	}

	div#header {
 position: relative;
 top: 1em;
 left: 1em;
 right: 1em;
 width: 90%;
	}


	.menu {
		font-size: 0.91em;
		float: left; width: 15em;
		margin: 0; padding: 0;
		border: 1px dashed silver;
	}

	#main {
		font-size: 100.01%;
		font-family: Helvetica,Arial,sans-serif;
		margin-left: 15em;
		border: 1px dashed silver;
		min-width: 16em;
	}

	#breadCrumb {
		color: #374E7F;
		background-color: #EFEBDE;
		font-weight: bold;
		font-style: italic;
		margin-left: 15em;
		margin-bottom: 1em;
		padding: 0.3em;
		border: 1px dashed silver;
		min-width: 16em;
	}

	#formInputFields {
 float: left;
 width: 350px;
 margin: 0;
 padding: 1em;
 overflow: auto;
	}
	#formReferences {
 margin-left: 380px;
 padding: 1em;
	}
	#formActionButtons {
 clear: both;
	}
	#footer {
	}

	.cleaner {
 clear:both;
 height:1px;
 font-size:1px;
 border:none;
 margin:0; padding:0;
 background:transparent;
	}
	body {
 font-family: Verdana, Helvetica, Arial, sans-serif;
 font-size: 80%;
	}
	h1 {
 background-color: #C6D3EF;
 margin-top: 0px;
	}

	table {
 width: 100%;
 padding: 0;
 font-size: 1em;	
	}
	table.references th {
 background-color: #C6D3EF;
 border-bottom: 1px solid black;
	}
	table.references td {
 border-bottom: 1px solid black;
	}
	table.list th {
 background-color: #C6D3EF;
 border-bottom: 1px solid black;
 text-align: left;
	}
	table.list td {
 border-bottom: 1px solid black;
	}
	.headingCell {
 font-weight: bold;
 white-space: nowrap;
 vertical-align: top;
	}
	.buttonCell {
 text-align: right;	
	}
	.idCell {
 width: 1%;
 white-space: nowrap;
 text-align: left;	
	}
	.actionCell {
 width: 1%;
 white-space: nowrap;
 text-align: right;	
	}
	.actionCell a {
 margin-left: 0.3em;
 margin-right: 0.3em;
	}
	.errors {
 color: red;
 font-size: 1em;
	}

	#formActionButtons {
 text-align: right;	
 width: 95%;
	}
	.headerButtonContainer {
 position: relative;
	}
	.manyToManyContainer {
 position: absolute;
 bottom: 1.5em;
 left: 8em;
 background-color: #C6D3EF;
	}

	.fieldError {
 color: red;
 display: block;
	}
	.errorList {
 border: 1px solid red;
 background-color: #FFF4F4;
 padding: 1.5em;
	}
	.errorList li {
 list-style-type: none;
 color: red;
	}
	'''
	)
	'''
	'''
}
}
