#!/bin/sh
# extracts the project version from the pom.xml
alias mvn-version='mvn org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=project.version | grep -v \"^\[\"'
# creates an HTML report of dep. vulnerabilities in target/
alias mvn-vuln='mvn org.owasp:dependency-check-maven:8.0.0:check'

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
