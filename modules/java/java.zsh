#!/bin/sh
# extracts the project version from the pom.xml
alias mvn-version='mvn org.apache.maven.plugins:maven-help-plugin:3.1.1:evaluate -Dexpression=project.version | grep -v \"^\[\"'
# creates an HTML report of dep. vulnerabilities in target/
alias mvn-vuln='mvn org.owasp:dependency-check-maven:5.3.0:check'
