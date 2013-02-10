Sculptor Xtext2 : A Prototype of Fornax Sculptor using Xtext2 
========================================================
This is a prototype of porting [Fornax Sculptor](https://sites.google.com/site/fornaxsculptor/) to [Xtext2](http://www.eclipse.org/Xtext/).

The project outlines some technical details e.g.

* Using [Eclipe Tycho](http://www.eclipse.org/tycho/) with Maven to build Eclipse plugins
* Creating a local Eclipse P2 repository mirror used in an Eclipse plugin build
* Creating a Maven artifact from Eclipse Plugins
* Creating a stand-alone library JAR from an xtext-based generator
* Hosting Eclipse plugins in an Eclipse P2 repository on GitHub  
* Hosting Maven plugins in a Maven repository on GitHub  


Maven Modules
---------------

* sculptor-parent

  The aggregator project with the parent POM used by the other modules.

* sculptor-eclipse

  The aggregator project holding the Eclipse projects with the Eclipse p2 mirror, the meta model, the DSL model with its UI, the feature and the p2 mirror.

* sculptor-generator

  The implementation of the code generator.

* sculptor-maven

  The aggregator project holding the Maven plugin, the Maven archetypes and the Maven repository.


Usage
-----------

Build the project needs the following steps:

* Create the local Eclipse P2 repository mirror (located in "sculptor-eclipse/eclipse-mirror/.p2-mirror/") by activating the Maven profile "mirror" (*this mirroring takes hours!!!*)

  <pre>
  cd sculptor-parent
  mvn initialize -Pmirror
  </pre>

* Add the local Eclipse P2 repository mirror to the Maven "settings.xml" (located in your home directory folder ".m2/")

  ```xml
  <mirrors>
    <mirror>
      <!--This sends request to p2 repositories to local mirror -->
      <id>mirror</id>
      <mirrorOf>p2.eclipse,p2.eclipse.xtext</mirrorOf>
      <url>file://<location of project>/sculptor-eclipse/eclipse-mirror/.p2-mirror/</url>
      <layout>p2</layout>
      <mirrorOfLayouts>p2</mirrorOfLayouts>
    </mirror>
  </mirrors>
  ```

* Build the whole project

  <pre>
  cd sculptor-parent
  mvn install
  </pre>

* Deploy the Eclipse P2 repository with the Sculptor plugins to GitHub as decribed [here](http://stackoverflow.com/questions/14013644/hosting-a-maven-repository-on-github/)

  <pre>
  cd sculptor-parent
  mvn deploy
  </pre>

* (Optionally) Build and test the stand-alone Generator JAR (the generator isn't useful right now - it reads the model, creates the file "./src-gen/test.txt" with the text "Hello World!" and prints "Code generation finished.")

  <pre>
  cd sculptor-parent
  mvn install -Pshade
  java -jar ../sculptor-generator/target/sculptor-generator-3.0.0-SNAPSHOT.jar ../sculptor-generator/src/test/resources/model-test.btdesign
  </pre>
