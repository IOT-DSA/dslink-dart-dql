#!/usr/bin/env bash
set -e
TMP=$(mktemp -d)
MD=$(realpath "$(dirname $0)/..")
git clone git@github.com:IOT-DSA/dslink-dart-dql.git -b gh-pages "${TMP}"
pub build
rm -rf ${TMP:?}/*
cp -R build/web/*  "${TMP:?}/"
cd ${TMP} || exit 1
git add .
git commit -m "Update DQL Site" || true
git push origin gh-pages || true
cd ${MD} || exit 1
rm -rf ${TMP}
