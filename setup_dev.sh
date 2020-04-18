#!/bin/bash

VERSION=`grep \"version\" info.json | cut -f2 -d: | sed 's/[\", ]//g'`
NAME=ClosestFirst_$VERSION
ZIP=$NAME.zip

mkdir -p $NAME
cp -prv info.json *.lua locale *.txt *.md thumbnail.png $NAME/
rm -f $ZIP
zip -r $ZIP $NAME
mod_directory="$(./get_factorio_mod_directory.sh)"
cp $ZIP "$mod_directory"
cd "$mod_directory"
unzip -o $ZIP
