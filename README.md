Sculptor Xtext2 : A Prototype of Fornax Sculptor using Xtext2 
========================================================
This is a prototype of porting [Fornax Sculptor](https://sites.google.com/site/fornaxsculptor/) to [Xtext2](http://www.eclipse.org/Xtext/).

The project outlines some technical details e.g.

* Using [Eclipe Tycho](http://www.eclipse.org/tycho/) with Maven to build Eclipse plugins
* Creating a local Eclipse p2 repository mirror used in an Eclipse plugin build
* Creating a local Eclipse installation with all Eclipse plugins needed for Sculptor development
* Creating a Maven artifact from Eclipse Plugins
* Running unit tests for the Xtext-generated DSL plugins
* Creating a stand-alone library JAR from an xtext-based generator
* Hosting Eclipse plugins in an Eclipse p2 repository on GitHub  
* Hosting Maven plugins in a Maven repository on GitHub  


Maven Modules
---------------

* `devtools`

  Folder with projects used for local development, e.g. `eclipse-mirror` with the local Eclipse p2 repository mirror.

* `releng`

  Folder with projects used by release engineering, e.g. `sculptor-parent` with the parent POM used by the other modules or `sculptor-distribution` with profiles used for building the Sculptor distribution.

* `sculptor-eclipse`

  The aggregator project holding the Eclipse projects with the Eclipse p2 mirror, the meta model, the DSL model with its UI and unit tests, the feature and the p2 mirror.

* `sculptor-generator`

  The aggregator project holding the implementation of the code generator.

* `sculptor-maven`

  The aggregator project holding the Maven plugin, the Maven archetypes and the Maven repository.


Usage
-----------

Building the project needs the following steps:

* Create the local Eclipse p2 repository mirror (located in "devtools/eclipse-mirror/.p2-mirror/") by activating the Maven profile "mirror" -> **The *initial* mirroring process takes hours!!!**

  <pre>
cd releng/sculptor-distribution
mvn initialize -Pmirror
  </pre>

* Add the local Eclipse p2 repository mirror to the Maven "settings.xml" (located in your home directory folder ".m2/")

  ```xml
<mirrors>
    <mirror>
        <!--This sends request to p2 repositories to local mirror -->
        <id>mirror</id>
        <mirrorOf>p2.eclipse,p2.eclipse.xtext,p2.xtext-utils</mirrorOf>
        <url>file://<location of project>/devtools/eclipse-mirror/.p2-mirror/</url>
        <layout>p2</layout>
        <mirrorOfLayouts>p2</mirrorOfLayouts>
    </mirror>
</mirrors>
  ```

* Create a local Eclipse installation (located in the folder "devtools/eclipse-ide/target/products/org.sculptor.ide/<platform>") by activating the Maven profile "ide"

  <pre>
cd releng/sculptor-distribution
mvn verify -Pide
  </pre>

* Build the whole project

  <pre>
cd releng/sculptor-distribution
mvn install
  </pre>

* Deploy the Eclipse p2 repository with the Sculptor plugins to GitHub as decribed [here](http://stackoverflow.com/questions/14013644/hosting-a-maven-repository-on-github/)

  <pre>
cd releng/sculptor-distribution
mvn deploy -Pdeploy
  </pre>

* (Optionally) Build and test the stand-alone Generator JAR by activating the Maven profile "shade" (the generator isn't useful right now - it reads the model, validates it and prints "org.eclipse.emf.mwe2.runtime.workflow.Workflow - Done.")

  <pre>
cd releng/sculptor-distribution
mvn install -Pshade
cd ../../sculptor-generator/sculptor-core
java -jar target/sculptor-core-3.0.0-SNAPSHOT.jar -model src/test/resources/model-test.btdesign
  </pre>
