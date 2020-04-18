#!/bin/sh

machine="$(./detect_machine.sh)"

case "${machine}" in
    Linux)     directory="$HOME";;
    Darwin)    directory="~/Library/Application\ Support";;
esac

echo "$directory/.factorio/mods/"
