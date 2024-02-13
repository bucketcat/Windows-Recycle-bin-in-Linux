#!/bin/bash

#To Do:  Maybe log and save original path rather than dumping it in home.
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
    
    echo -e "\e[1;31mWarning!\e[0m To delete a specific file from trash, only include the file name as a single parameter. This assumes that it exists in \e[1;36m~/.TRASH/\e[0m."
    echo -e "Otherwise, it will move it to \e[1;36m~/.TRASH/\e[0m."
    echo -e "\e[1;31mWarning:\e[0m There is no prompt for this and this is a \e[1;31mdestructive action!\e[0m"


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

        echo "Recover option selected for file: $2"
        ls "$trash_directory/$2" 2>/dev/null
        recovered_file_path="$trash_directory/$2"
        echo "Checking existence of: $recovered_file_path"
        if [ -e "$recovered_file_path" ]; then
            echo "Recovering file: $2"
            echo "Destination path: $HOME/"
            mv -v "$recovered_file_path" "$HOME/"
            echo "File recovered successfully."
            exit 0
        else
            echo "Error: File not found in the trash directory!"
            exit 1

        #suppress warning, might want it
        #error if it doesn't exist
        #do something (actual recovery)
        fi
        shift
        ;;
    --)
        shift
        for file in "$@"; do
            file_in_trash="$trash_directory/$file"
            if [ -e "$file_in_trash" ]; then
                # File exists in trash, delete it
                echo "Deleting file from trash: $file"
                rm "$file_in_trash"
                echo "File deleted from trash successfully."
            else
                # File doesn't exist in trash, move it to the trash
                if [ -e "$file" ]; then
                    echo "Moving file to trash: $file"
                    mv "$file" "$trash_directory/"
                    echo "$file moved to trash successfully."
                fi
            fi
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
