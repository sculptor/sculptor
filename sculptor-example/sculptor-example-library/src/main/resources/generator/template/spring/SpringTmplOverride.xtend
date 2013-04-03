package generator.template.spring

import org.sculptor.generator.template.spring.SpringTmpl

class SpringTmplOverride extends SpringTmpl {

	def override String header(Object it) {
		System::out.println("header() override");
		super.header(it).replaceAll("UTF-8", "ISO-8859-1")
	}

	def override String headerWithMoreNamespaces(Object it) {
		System::out.println("headerWithMoreNamespaces() override");
		super.headerWithMoreNamespaces(it).replaceAll("UTF-8", "ISO-8859-1")
	}
}