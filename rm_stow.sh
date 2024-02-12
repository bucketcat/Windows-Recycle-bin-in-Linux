#!/bin/bash


#To Do: Add single file deletion from ~/TRASH if user combined remove + filename


showUsage() {


    echo -e "Usage: rm_stow\n"
    echo "Options:"
    echo -e "  -h, --help\tShow this help message and exit"
    echo -e "  -l, --list\tEquivalent to ls -la of ./.TRASH/"
    echo -e "  -e, --empty\tEquivalent to rm -r ./.TRASH/*\t\t\tWarning, will erase contents of Recycle bin."
    echo -e "  -d, --dryrun\tCan only be used together with --empty.\tDoes a dryrun of clean, outputting all files to be erased."
    echo -e "  -s, --size\tEquivalent to du --summarize --human-readable *\tWill list filesize of the contents of ./.TRASH/"
    echo -e "  -r, --recover\tRestore files. Similar to Ctrl + z on windows.\n"
    echo "Examples:"
    echo -e "  rm_stow.sh --recover regrahts.txt"
    echo -e "  rm_stow.sh --empty --dryrun"
    echo -e "                    To delete a file, ONLY include the name of the file and no other arguments or options."
    echo -e "  rm_stow.sh bye.txt"



}

options=$(getopt -l "help,list,empty::,size,recover:, dryrun" -o "hl:e::sr:" -a -- "$@")
#getopt :: optional param, : required. Empty specific file, empty all, dryrun.
eval set -- "$options"

while true; do
	case "$1" in
		-h|--help)
			showUsage
			echo "Help option selected. Press any button to proceed."
			read -r
			shift
			;;
		-l|--list)
			echo "List option selected."
			ls -R -a ../.TRASH/
			shift
			;;
		-e|--empty)
			echo "Empty option selected."
			case "$2" in
				"")
					echo "No argument provided for --empty."
					rm -r ./.TRASH/
					shift 2
					;;
				*)
					echo "Argument for --empty: $2"
					#check for internal --dryrun flag
					if [[ $* == *"--dryrun"* ]] || [[ $* == *"-dryrun"* ]] || [[ $* == *"-d"* ]]; then
						ls -R -a ../.TRASH/
						#list all files that empty would delete
					fi
					shift 2
					;;
			esac
			;;
		-s|--size)
			echo "Size selected"
			du --summarize --human-readable ~/.TRASH/
			shift
		;;
		-r|--recover)
			echo "Recover option selected of file: $2"
			ls  $2 ../.TRASH/ 2> /dev/null
			#suppress warning, might want it
			#error if it doesn't exist
			#do something (actual recovery)
			shift 2
			;;
		--)
			shift
			break
			;;
		*)            
			if [[ ! $1 == -* ]]; then
                stowFile "$1"
			else	
				echo "Error! Unrecognised argument or invalid file!"
				exit 1
			fi	
			break
			;;				  
	esac
done

stowFile(){
	if [ "$#" -eq 1 ] && ! [[ "$1" =~ ^- ]]; then
  # Check if there are no options provided and a single argument is given
		createTrashFolder
  # If only one argument is provided (file), move it to the trash
		file_to_delete="$1"
		echo "Moving file to trash: $file_to_delete"
  # Perform the actual move to trash here (you might need to adjust this)
		mv "$file_to_delete" ~/.TRASH/
		echo "File moved to trash successfully."
		exit 0
fi
}
createTrashFolder(){
	#system("mkdir ~/TRASH"); This is required for non-bash languages like C/CPP/Java
	mkdir ~/.TRASH 2> /dev/null #better than -p imo
}

# Print a message if the script is called without any arguments
if [ $# -eq 0 ]; then
    echo "No arguments provided. Please see usage below:"
    showUsage
    exit 1
fi

