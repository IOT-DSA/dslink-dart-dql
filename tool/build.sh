#!/usr/bin/env bash

if [ -f ${HOME}/.dglogik/jenkins_info ]
then
  mv lib/script.dart lib/script.dart.bak
  wget --auth-no-challenge \
    --http-user="${JENKINS_USERNAME}" \
    --http-password="${JENKINS_PASSWORD}" \
    'http://git.dglogik.com/httpAuth/repository/download/DGLux5/.lastSuccessful/dql_script.dart' \
    -O lib/script.dart
fi

rm -rf build
mkdir -p build/bin
dart2js -o build/bin/run.dart bin/run.dart --output-type=dart --categories=Server
rm -rf build/bin/*.deps

if [ -f ${HOME}/.dglogik/jenkins_info ]
then
  mv lib/script.dart.bak lib/script.dart
fi
cp dslink.json build/
cd build
zip -r ../../../files/dslink-dart-dql.zip .
cd ..
