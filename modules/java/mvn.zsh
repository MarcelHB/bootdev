#!/bin/sh
# Cleanup of unused JARs:
# 1. Ask all your projects' poms what they use (deps, plugins & deps)
# 2. Copy that stuff into a temporary location
# 3. Clear the maven repo
# 4. Copy the temporary stuff back into the repo

# Limitations apply to what the maven tools report to us, so one may actualy download
# some stuff again.

# In theory, there is:
# $ mvn help:evaluate -Dexpression=settings.localRepository | grep -v '\[INFO\]'
# But that again may download additional stuff.
MAVEN_REPO=$HOME/.m2/repository
PLUGIN_RESOLVER_PLUGIN=maven-dependency-plugin
PLUGIN_RESOLVER_GROUP=org.apache.maven.plugins
PLUGIN_RESOLVER=$PLUGIN_RESOLVER_GROUP:$PLUGIN_RESOLVER_PLUGIN
PLUGIN_RESOLVER_VERSION=3.3.0
PLUGIN_RESOLVER_TASK=$PLUGIN_RESOLVER:$PLUGIN_RESOLVER_VERSION:resolve-plugins

function mvn_cleanup_by_poms() {
  # poms
  echo "Finding poms ..."
  local poms=$(find ./* -name pom.xml)
  local deps
  local plugins
  local jars

  if [[ -z $poms ]]; then
    echo "None, aborting"
    exit 0
  fi

  echo "$poms"

  # dependencies
  echo "Collecting dependencies ..."
  while read -r pom; do
    deps=$deps\\n"$(mvn -B -f "$pom" dependency:list | grep -E "\[INFO\][[:space:]]{4}" | cut --complement -b1-10)"
  done <<< "$poms"

  jars=$(echo "$deps" | awk -F ':' 'NF > 0 { gsub("\.", "/", $1); print $1"/"$2"/"$4 }' | sort | uniq)

  # plugins
  echo "Collecting plugins & deps ..."
  while read -r pom; do
    # plugins first
    plugins=$plugins\\n"$(mvn -B -f "$pom" "$PLUGIN_RESOLVER_TASK" | grep -E "\[INFO\][[:space:]]{4}" | cut --complement -b1-10)"
  done <<< "$poms"

  jars=$jars\\n$(echo "$plugins" | awk -F ':' 'NF > 0 { gsub(/:(runtime|compile|test|provided|system)$/, "", $0); gsub("\.", "/", $1); gsub(" ", "", $1); print $1"/"$2"/"$NF }' | sort | uniq)

  # a bit of self-preservation
  echo "Collecting own tooling ..."
  dependency_plugin_sub_path=$(echo "$PLUGIN_RESOLVER_GROUP" | tr '.' '/')/$PLUGIN_RESOLVER_PLUGIN/$PLUGIN_RESOLVER_VERSION
  dependency_plugin_path=$MAVEN_REPO/$dependency_plugin_sub_path
  self=$(mvn -B -f "$dependency_plugin_path/$PLUGIN_RESOLVER_PLUGIN-$PLUGIN_RESOLVER_VERSION.pom" dependency:list | grep -E "\[INFO\][[:space:]]{4}" | cut --complement -b1-10)

  jars=$jars\\n$(echo "$self" | awk -F ':' 'NF > 0 { gsub(/:(runtime|compile|test|provided|system)( --.*)?$/, "", $0); gsub("\.", "/", $1); gsub(" ", "", $1); print $1"/"$2"/"$NF }')
  jars=$jars\\n$dependency_plugin_sub_path

  jars=$(echo "$jars" | awk 'NF > 0' | sort | uniq)

  echo "Creating temporary copy ..."
  while read -r jar; do
    mkdir -p "${MAVEN_REPO}_temp/$jar"
    cp -a -r "$MAVEN_REPO/$jar/." "${MAVEN_REPO}_temp/$jar"
  done <<< "$jars"

  echo "Switching repos ..."
  mv "$MAVEN_REPO" "${MAVEN_REPO}_delete"
  mv "${MAVEN_REPO}_temp" "$MAVEN_REPO"

  echo "Deleting old repo ..."
  rm -rf "${MAVEN_REPO}_delete"
}

alias mvn-pom-cleanup='mvn_cleanup_by_poms;'

