#!/usr/bin/env bash

set -e

cd $(realpath $(dirname $0))/../..

if [ ! -d .arc/libdglogik ]
then
  git submodule update --recursive --init
fi

export DART_LINT_MODE=true
export DART_STRONG_MODE=false
export DART_IGNORE_FILES=(
    lib/addons/script.dart
)

dart .arc/libdglogik/lint/dart_linter.dart "${@}" || true
