#!/bin/sh
alias mvn-version='mvn org.apache.maven.plugins:maven-help-plugin:3.1.1:evaluate -Dexpression=project.version | grep -v \"^\[\"'
