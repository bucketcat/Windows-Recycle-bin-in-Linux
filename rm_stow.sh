#!/bin/bash

active=false

showUsage() {


echo "Usage: rm_stow"
echo
echo "Options:"
echo "  -h, --help       Show this help message and exit"
echo "  -l, --list       Equivalent to ls -la of ./TRASH/"
echo "  -e, --empty      Equivalent to rm -r ./TRASH/*    Warning, will erase contents of Recycle bin."
echo "  -s, --size       Equivalent to du --summarize --human-readable * 	Will list filesize of the contents of ./TRASH/"
echo "  -r, --recover    Restore files. Similar to Ctrl + z on windows."
echo
echo "Example:"
echo "  rm_stow.sh --recover regrahts.txt"


}

options=$(getopt -l "help,list,empty::,size,recover:, dryrun" -o "hl:e::sr:d" -a -- "$@")
#getopt :: optional param, : required. Empty specific file, empty all, dryrun.

while true
do
case