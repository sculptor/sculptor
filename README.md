# [![Sculptor](https://raw.github.com/sculptor/sculptor.github.io/master/images/sculptor-banner.png)](http://sculptorgenerator.org)  [![Build Status](https://travis-ci.org/sculptor/sculptor.png?branch=develop)](https://travis-ci.org/sculptor/sculptor) #


[Sculptor](http://sculptorgenerator.org) is an open source productivity tool that applies the concepts from [Domain-Driven Design](http://domaindrivendesign.org/books/) and [Domain Specific Languages](http://en.wikipedia.org/wiki/Domain-specific_language).

You express your design intent in a textual specification (within an Eclipse editor), from which Sculptor generates (with a Maven plugin) high quality
Java code and configuration. You can use the concepts from Domain-Driven Design (DDD) in the textual Domain Specific Language (DSL).
E.g. Service, Module, Entity, Value Object, Repository.

The generated code is based on well-known frameworks, such as [JPA](http://java.sun.com/javaee/technologies/persistence.jsp),
[Hibernate](http://www.hibernate.org/), [Spring Framework](http://www.springframework.org/) or [Java EE](http://java.sun.com/javaee/).
Sculptor takes care of the technical details, the tedious repetitive work, and let you focus on delivering more business value - and have more fun.


## System Requirements

To use Sculptor you need local installations of the following tools:

* [Java JDK](http://www.oracle.com/technetwork/java/javase/downloads/) (1.6 or newer)
* [Maven](http://maven.apache.org/download.html) (3.0.5 or newer)
* [Eclipse](http://eclipse.org/downloads/) (4.2 or newer) with [Xtext](http://www.eclipse.org/Xtext/download.html) (2.5.0 or newer)
* (optional) [GraphViz](http://www.graphviz.org/) (2.2.8 or newer)

The installation and configuration of these tools is described in [Sculptors installation guide](http://sculptorgenerator.org/documentation/installation).


## Installation

Sculptor consists of an Eclipse plugin (the DSL editor) and a Maven plugin (the code generator) with its Maven archetypes:

* Sculptors Eclipse plugin has to be installed with the Eclipse Update Manager `Help > Install New Software...` from [http://sculptorgenerator.org/updates/](http://sculptorgenerator.org/updates/)
* Sculptors Maven plugin and its Maven archetypes are retrieved by Maven from one of the following Maven repositories
 * Releases: [Maven Central](http://search.maven.org)
 * Development Snapshots: [https://oss.sonatype.org/content/repositories/snapshots/](https://oss.sonatype.org/content/repositories/snapshots/)

The installation and configuration of these tools is described in [Sculptors installation guide](http://sculptorgenerator.org/documentation/installation).


## Getting started

To start with a hands-on example on using Sculptor use the
[Hello Word Tutorial](http://sculptorgenerator.org/documentation/hello-world-tutorial). There're other tutorials to continue with, e.g.
the [DDD Sample](http://sculptorgenerator.org/documentation/ddd-sample),
the [Archetype Tutorial](http://sculptorgenerator.org/documentation/archetype-tutorial)
or the [Advanced Tutorial](http://sculptorgenerator.org/documentation/advanced-tutorial).

You can learn more about the capabilities of Sculptor by reading the [blog posts](http://sculptorgenerator.org/archive), e.g. 
[Improving Developer Productivity with Sculptor](http://sculptorgenerator.org/2010/06/10/improving-developer-productivity-with-sculptor).


## Contributing

Here are some ways for you to contribute:

* Get involved with the community on the [Sculptor forum](https://groups.google.com/group/sculptorgenerator).
  Please help out on the forum by responding to questions and joining the debate.
* Create [GitHub tickets](https://github.com/sculptor/sculptor/issues) for bugs or new features and comment on the ones that you are interested in.
* GitHub is for social coding: if you want to write code, we encourage contributions [through pull requests](https://help.github.com/articles/creating-a-pull-request)
  from [forks of this repository](https://help.github.com/articles/fork-a-repo).
  If you want to contribute code this way, please reference a GitHub ticket as well covering the specific issue you are addressing.
  See [Sculptors documentation](http://sculptorgenerator.org/documentation/development-environment) for details on how to set up the development
  environment and build the project.
* If you want to help us with [documentation and tutorials](http://sculptorgenerator.org/documentation/), we encourage contributions
  [through pull requests](https://help.github.com/articles/creating-a-pull-request) from forks of the corresponding repository
  [https://github.com/sculptor/sculptor.github.io](https://github.com/sculptor/sculptor.github.io).
  See the repositories README for details on how to set up the development environment.


## License

Sculptor is released under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

