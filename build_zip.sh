#!/bin/bash

VERSION=`grep \"version\" info.json | cut -f2 -d: | sed 's/[\", ]//g'`

mkdir -p ClosestFirst_$VERSION
cp -prv info.json *.lua locale *.txt *.md ClosestFirst_$VERSION/
zip -r ClosestFirst_$VERSION.zip ClosestFirst_$VERSION
cp ClosestFirst_$VERSION.zip ~/Library/Application\ Support/factorio/mods/

