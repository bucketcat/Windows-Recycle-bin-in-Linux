#!/bin/bash

#To Do: Solve single file removal and getopt and test file recovery. Maybe log and save original path rather than \n
# dumping it in home.
trash_directory="$HOME/.TRASH"

showUsage() {

    echo -e "Usage: rm_stow\n"
    echo "Options:"
    echo -e "  -h, --help\tShow this help message and exit"
    echo -e "  -l, --list\tEquivalent to ls -la of ~/.TRASH/"
    echo -e "  -e, --empty\tEquivalent to rm -r ~/.TRASH/*\t\t\tWarning, will erase contents of Recycle bin."
    echo -e "  -d, --dryrun\tCan only be used together with --empty.\tDoes a dryrun of clean, outputting all files to be erased."
    echo -e "  -s, --size\tEquivalent to du --summarize --human-readable *\tWill list filesize of the contents of ~/.TRASH/"
    echo -e "  -r, --recover\tRestore files. Similar to Ctrl + z on windows.\n"
    echo "Examples:"
    echo -e "  rm_stow.sh --recover regrahts.txt"
    echo -e "  rm_stow.sh --empty --dryrun"
    echo -e "                    To delete a file, ONLY include the name of the file and no other arguments or options."
    echo -e "  rm_stow.sh bye.txt"

}

createTrashFolder() {
    #system("mkdir ~/TRASH"); This is required for non-bash languages like C/CPP/Java
    mkdir -p "$trash_directory"

}

stowFile() {
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

options=$(getopt -l "help,list,empty::,size,recover:,dryrun" -o "hle::sr:d" -a -- "$@")
#getopt :: optional param, : required. Empty specific file, empty all, dryrun.
eval set -- "$options"

while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
        showUsage
        echo "Help option selected. Press any button to proceed."
        read -r
        shift
        ;;
    -l | --list)
        echo "List option selected."
        ls -R -a ~/.TRASH/
        shift
        ;;
    -e | --empty)
        echo "Empty option selected."
        case "$#" in
        1)
            echo "No argument provided for --empty."
            rm -r ~/.TRASH/*
            shift

            ;;
        *)
            # Assuming $2 is a file name

            if [[ $* == *"--dryrun"* ]] || [[ $* == *"-dryrun"* ]] || [[ $* == *"-d"* ]]; then
                ls -R -a ~/.TRASH/
                # list all files that empty would delete
                exit 0
            else #does not work due to getopt end of command insertion. Can't be replaced with awk, sed nor regex.
                if [[ "$*" == " -- " ]]; then
                    shift # Skip the -- added by getopt
                fi
                # handleFileDeletion "$@"
                file_to_delete="$*"
                #oh my god, have to do a regex lookbehind to remove the "-- " inserted by getopt in end of command. No clue why end of command is triggered when optional commands are specified...
                echo "$*"

                #result_string=$(echo "$original_string" | sed 's/ -- / /')

                nukeFile "$file_to_delete"
                echo "Debug: File to delete: $file_to_delete"
                echo "Removing file from trash: $file_to_delete"

                echo "File: $file_to_delete removed from trash successfully."
                exit 0

            fi

            ;;

        esac
        ;;
    -s | --size)
        echo "Size selected"
        du --summarize --human-readable ~/.TRASH/
        shift
        ;;
    -r | --recover)
        echo "Recover option selected of file: $2"
        ls "$2" ~/.TRASH/ 2>/dev/null
        shift
        if [ "$#" -eq 1 ]; then
            file_to_recover="$1"
            recovered_file_path="$trash_directory/$file_to_recover"
            if [ -e "$recovered_file_path" ]; then
                echo "Recovering file: $file_to_recover"
                mv "$recovered_file_path"  ~/.
                echo "File recovered successfully."
                exit 0
            else
                echo "Error: File not found in the trash directory!"
                exit 1
            fi
        #suppress warning, might want it
        #error if it doesn't exist
        #do something (actual recovery)
        fi
        shift
        ;;
    --)
        shift
        for file in "$@"; do
            stowFile "$file"
        done
        break
        ;;
    *)

        echo "Error! Unrecognised argument or invalid file!"
        exit 1
        break
        ;;
    esac
done

# Print a message if the script is called without any arguments
if [[ ! $1 =~ ^- ]] && [[ -f $1 ]]; then
    echo "No arguments provided. See --help for usage:"
    #showUsage
    exit 1
fi
