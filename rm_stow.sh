#!/bin/bash

active=false

showUsage() {


echo "Usage: rm_stow"
echo
echo "Options:"
echo "  -h, --help       Show this help message and exit"
echo "  -l, --list       Equivalent to ls -la of ./TRASH/"
echo "  -e, --empty      Equivalent to rm -r ./TRASH/*    Warning, will erase contents of Recycle bin."
echo "  -d, --dryrun     Can only be used together with --empty. Does a dryrun of clean, outputting all files to be erased."
echo "  -s, --size       Equivalent to du --summarize --human-readable * 	Will list filesize of the contents of ./TRASH/"
echo "  -r, --recover    Restore files. Similar to Ctrl + z on windows."
echo
echo "Example:"
echo "  rm_stow.sh --recover regrahts.txt"
echo "Example2:"
echo "	rm_stow.sh --empty --dryrun"


}

options=$(getopt -l "help,list,empty::,size,recover:, dryrun" -o "hl:e::sr:" -a -- "$@")
#getopt :: optional param, : required. Empty specific file, empty all, dryrun.
eval set -- "$options"

while true; do
	case "$1" in
		-h|--help)
		showUsage()
		echo "Help option selected. Press any button to proceed."
		read -r
		shift
		;;
		-e|--empty)
		echo "Empty option selected."
		case "$2" in
			"")
			echo "No argument provided for --empty."
			#rm -r ./TRASH/
			shift 2
			;;
		*)
			echo "Argument for --empty: $2"
			#check for internal --dryrun flag
			if [[ $* == *"--dryrun"* ]] || if [[ $* == *"-dryrun"* ]] || if [[ $* == *"-d"* ]]; then
					ls -R -a ../TRASH/
					#list all files that empty would delete
		  fi
          shift 2
          ;;
				
	  
	  
	  
	  
	  
	  
	  
	esac
done


