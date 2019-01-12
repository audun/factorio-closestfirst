#!/bin/bash

VERSION=0.1.3

mkdir -f ClosestFirst_$VERSION
cp -prv info.json *.lua locale *.txt *.md ClosestFirst_$VERSION/
zip -r ClosestFirst_$VERSION.zip ClosestFirst_$VERSION
cp ClosestFirst_$VERSION.zip ~/Library/Application\ Support/factorio/mods/

