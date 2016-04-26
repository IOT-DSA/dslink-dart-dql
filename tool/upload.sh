#!/usr/bin/env bash
set -e
TMP=$(mktemp -d)
MD=$(realpath "$(dirname $0)/..")
git clone https://github.com/IOT-DSA/dslink-dart-dql.git -b gh-pages "${TMP}"
pub build example/browser
rm -rf ${TMP:?}/*
cp -R build/example/browser/*  "${TMP:?}/"
cd ${TMP} || exit 1
git add .
git commit -m "Update DQL Site"
git push origin gh-pages
cd ${MD} || exit 1
rm -rf ${TMP}
