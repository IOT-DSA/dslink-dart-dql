#!/usr/bin/env bash
PARTS=$(PATHS=$(grep -r 'library ' lib/ -l | xargs realpath)
for p in ${PATHS}
do
  RP=$(realpath ${p} --relative-to=$PWD/lib)
  echo -n "package:dql/$RP|$p"
  echo -n " "
done)
dartanalyzer --build-summary-output=build/summary.sum --build-summary-only --build-mode ${PARTS}
