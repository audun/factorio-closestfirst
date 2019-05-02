#!/bin/bash

MOD=`grep \"name\" info.json | cut -f2 -d: | sed 's/[\", ]//g'`
VERSION=`grep \"version\" info.json | cut -f2 -d: | sed 's/[\", ]//g'`
NAME=${MOD}_$VERSION
ZIP=$NAME.zip

mkdir -p $NAME
cp -prv info.json *.lua locale *.txt *.md thumbnail.png $NAME/
rm -f $ZIP
find $NAME/ -name '*~' -delete
zip -r $ZIP $NAME
cp -v $ZIP ~/Library/Application\ Support/factorio/mods/
cd ~/Library/Application\ Support/factorio/mods/
unzip -o $ZIP
