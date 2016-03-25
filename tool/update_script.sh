#!/usr/bin/env bash

if [ -f ${HOME}/.dglogik/dev/config ]
then
  source ${HOME}/.dglogik/dev/config
  wget --auth-no-challenge \
    --http-user="${DG_CI_USERNAME}" \
    --http-password="${DG_CI_PASSWORD}" \
    "${DG_CI_URL}/httpAuth/repository/download/DGLux5/.lastSuccessful/dql_script.dart" \
    -O lib/addons/script.dart
else
  echo "Failed: ${HOME}/.dglogik/dev/config not found."
  exit 1
fi
