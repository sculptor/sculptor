/*
	Generates summary documentation of the domain model.
 */

package org.sculptor.generator.template.doc

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class ModelDocCssTmpl {

	@Inject extension Helper helper

def String docCss(Application it) {
	fileOutput("DomainModelDoc.css", OutputSlot::TO_GEN_RESOURCES, '''
	/* main elements */

	body,div,td {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
	color: #000;
	}

	body {
	background-color: #fff;
	background-position: top center;
	background-repeat: no-repeat;
	text-align: center;
	min-width: 800px;
	margin-top: 30px;
	margin-left: 30px;
	margin-right: auto;
	}

	div {
	text-align: left;
	}

	div .toc {
	display:block;
	margin-left:105px;
	}

/* header and footer elements */

	#wrap {
	margin:0 auto;
			position:relative;
			float:center;  	
			top: 0px;
			left:0px;
			width:750px;
			text-align:left;  	

	}
	#main {
			margin:0 auto;
			position:relative;
			float:left;  	
			top: 35px;
			left:0px;
			width:700px;
			height:700px; 
			text-align:left;
	}

	#graph {
			margin:0 auto;
			position:relative;
			float:left;  	
			top: 35px;
			left:0px;
			text-align:left;
	}

	#module_graph {
	margin:0 auto;
			position:relative;
			float:left;  
			top: 35px;
			bottom: 35px;
			left:0px;
			text-align:left;
	}

	#services {
	margin:0 auto;
	position:relative;
			float:left;
			top: 35px;
			width:100%;
	}

	#consumers {
	margin:0 auto;
	position:relative;
			float:left;
			top: 35px;
			width:100%;
	}

	#domainObjects {
	margin:0 auto;
	position:relative;
			float:left;
			top: 35px;
			width:100%;
	}



	.footer {
	background:#fff;
	border:none;
	margin-top:20px;
	border-top:1px solid #999999;
	width:100%;
	}

	.footer td {color:#999999;}

	.footer a:link {color: #7db223;}

	h1,h2,h3 {
	font-family: Helvetica, sans-serif;
	color: #ae8658;
	}

	h1 {
	font-size: 20px;
	line-height: 26px;
	}

	h2 {
	font-size: 18px;
	line-height: 20px;
	}

	h3 {
	font-size: 15px;
	line-height: 21px;
	color:#555;
	}

	h4 {
	font-size: 14px;
	line-height: 20px;
	}

	a {
	text-decoration: underline;
	font-size: 13px;
	}

	a:link {
	color: #ae8658;
	}

	a:hover {
	color: #456314;
	}

	a:active {
	color: #ae8658;
	}

	a:visited {
	color: #ae8658;
	}

/* table elements */

	table {
	background: #EEEEEE;
	margin: 2px 0 0 0;
	border: 1px solid #BBBBBB;
	border-collapse: collapse;
	}

	table table {
	margin: -5px 0;
	border: 0px solid #e0e7d3;
	width: 100%;
	}

	table td,table th {
	padding: 5px;
	border: 1px solid #BBBBBB;
	}

	table th {
	font-size: 11px;
	text-align: left;
	font-weight: bold;
	color: #FFFFFF;
	}

	table thead {
	font-weight: bold;
	font-style: italic;
	background-color: #BBBBBB;
	}

	caption {
	caption-side: top;
	width: auto;
	text-align: left;
	font-size: 12px;
	color: #848f73;
	padding-bottom: 4px;
	}

	table a:link {color: #303030;}

	#menu {
		background: #eee;
			position:relative;
			float:left;  	
			top: 35px;
			left:0px;
			width:300px;
	}

	#menu ul{
	list-style: none;
	margin: 0;
	padding: 0;
	}

	#menu ul li{
	padding: 0px;
	margin-left: 20px;
	}

	#menu a, #menu h2 {
	display: block;
	margin: 0;
	color:#FFFFFF;
	}

	#menu h2 {
	color: #fff;
	background: #648C1D;
	font-weight:bold;
	font-size: 2em;
	}

	#menu a {
	color: #666666;
	background: #efefef;
	text-decoration: none;
	padding: 2px 12px;
	}

	#menu a:hover {
	color: #648C1D;
	background: #fff;
	}

	img {
	border: 0;
	}

	#graph img {
	display: block;
	max-width: 680px;
	max-height: 680px;
	}

	#module_graph img {
	display: block;
	max-width: 680px;
	max-height: 680px;
	}

	#operation {
			margin-left:40px;
	}

	#operation_parameters {
			margin-left:20px;
	}

	#operation_returns {
			margin-left:20px;
	}

	'''
	)
}
}
