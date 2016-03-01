#!/usr/bin/env bash
python tool/diagram/diagram.py > tmp.html
webkit2png -F --selector=".railroad-diagram" -o tool/diagram tmp.html
rm tmp.html
mv tool/diagram-full.png tool/diagram.png
