#!/bin/bash

VERSION=`grep \"version\" info.json | cut -f2 -d: | sed 's/[\", ]//g'`
NAME=ClosestFirst_$VERSION
ZIP=$NAME.zip

mkdir -p $NAME
cp -prv info.json *.lua locale *.txt *.md thumbnail.png $NAME/
rm -f $ZIP
zip -r $ZIP $NAME
cp $ZIP ~/Library/Application\ Support/factorio/mods/
cd ~/Library/Application\ Support/factorio/mods/
unzip -o $ZIP
