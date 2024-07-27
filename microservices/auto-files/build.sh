#!/bin/bash

echo "cleaning all distributions before build new dist"
rm Dockerfile
../gradlew clean
if [ $? -ne 0 ]; then
  echo "Failed cleaning workspace"
  exit -1
fi

echo "making a new distributions jar file"
../gradlew build
if [ $? -ne 0 ]; then
  echo "Failed building workspace"
  exit -1
fi

builddir="build/libs"
echo "the jar distribution dir is $builddir"

# Verify if the build dir exist
if [ ! -d "$builddir" ]; then
    echo "The '$builddir' directory doesn't exist!!!"
    exit 1
fi

for entry in "$builddir"/*
do
  file=$(grep -n "plain" "$entry")
  if [ $? -ne 0 ]; then
      filename=$entry
  fi
done

echo "Getting latest version for distribution file: $filename"
export DISTNAME=$filename
cat DockerfileTemplate | envsubst > Dockerfile
