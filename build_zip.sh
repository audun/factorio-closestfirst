#!/bin/bash

VERSION=`grep \"version\" info.json | cut -f2 -d: | sed 's/[\", ]//g'`

mkdir -p ClosestFirst_$VERSION
cp -prv info.json *.lua locale *.txt *.md thumbnail.png ClosestFirst_$VERSION/
rm -f ClosestFirst_$VERSION.zip
zip -r ClosestFirst_$VERSION.zip ClosestFirst_$VERSION
mod_directory="$(./get_factorio_mod_directory.sh)"
cp ClosestFirst_$VERSION.zip "$mod_directory"
