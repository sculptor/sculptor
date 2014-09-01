#!/bin/bash

if [ -z $1 ] || [ -z $2 ]; then
   echo -e "Usage: $0 RELEASE_VERSION DEVLOPMENT_VERSION"
   echo -e "\tRELEASE_VERSION - release version, for example '3.0.0'"
   echo -e "\tDEVELOPMENT_VERSION - next development version (the SNAPSHOT suffix will be added), for example '3.0.1'"
   exit 1
fi

mvn jgitflow:release-start -P!all -DreleaseVersion=$1 -DdevelopmentVersion=$2-SNAPSHOT
if [ $? -ne 0 ]; then
	exit 1
fi

mvn tycho-versions:set-version -P!all -DnewVersion=$1
git commit -a -m "updates POMs and MANIFST.MFs for release of version $1"

mvn jgitflow:release-finish -DdevelopmentVersion=$2-SNAPSHOT
if [ $? -ne 0 ]; then
	exit 1
fi

mvn tycho-versions:set-version -P!all -DnewVersion=$1
mvn tycho-versions:set-version -P!all -DnewVersion=$2-SNAPSHOT
git commit -a -m "updates POMs and MANIFST.MFs for development of version $2-SNAPSHOT"
