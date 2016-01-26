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
