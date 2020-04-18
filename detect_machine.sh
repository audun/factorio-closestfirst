#!/bin/sh

uname_output="$(uname -s)"

case "${uname_output}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine="UNKNOWN:${uname_output}"
esac

echo ${machine}
