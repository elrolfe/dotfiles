#!/bin/sh

usage() { echo "Usage: $(basename $0) [FLAGS] [DIR [DIR ...]]" && grep "[[:space:]].)\ #" $0 | sed 's/#//' | sed -r 's/([a-z])\)/-\1/'; }

OUTPUT=1
while getopts "vsh" arg; do
    case $arg in
        v) # Verbose output
            if [ ! $OUTPUT -eq 1 ]; then
                usage
                exit 1
            fi
            OUTPUT=2
            ;;

        s) # No output
            if [ ! $OUTPUT -eq 1 ]; then
                usage
                exit 1
            fi
            OUTPUT=0
            ;;

        h) # Display help
            usage
            exit 0
            ;;

        *)
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

if [ $# -eq 0 ]; then
    DIRS=$(basename -a $(ls -d ~/.dotfiles/*/))
else
    DIRS=$@
fi

for d in $DIRS; do
    if [ $OUTPUT -gt 0 ]; then
        echo "Setting $d configuration files"
    fi

    FILES=$(ls ~/.dotfiles/${d}/*)
    for f in $FILES; do
        eval LOCATION=$(grep "#:LOCATION" $f | sed 's/#:LOCATION //')
        LOCATION_DIR=$(dirname $LOCATION)

        # Make sure the necessary directory exists
        if [ $OUTPUT -eq 2 ]; then
            MKDIR_FLAG="-pv"
        else
            MKDIR_FLAG="-p"
        fi
        mkdir $MKDIR_FLAG $LOCATION_DIR

        if [ -f $LOCATION ]; then # Backup the original file
            if [ $OUTPUT -eq 2 ]; then
                echo "    Backing up $LOCATION to $LOCATION.bak"
            fi
            mv $LOCATION $LOCATION.bak
        fi

        if [ ! -h $LOCATION ]; then # Create a symbolic link to the configuration file
            ln -s $f $LOCATION
            if [ $OUTPUT -eq 2 ]; then
                echo "Created link to $(basename $f) at $LOCATION"
            fi
        elif [ $OUTPUT -eq 2 ]; then
            echo "Link already exists at $LOCATION, leaving it unchanged"
        fi
    done
done
