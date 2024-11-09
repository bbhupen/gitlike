#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"


# Function for initializing the gitlike config file
function gitlike_init(){
    if [ -d ".gitlike" ]; then
        echo "gitlike already initiated in the current directory"
        return 1  # Exit the function if the directory exists
    fi
    mkdir .gitlike
    mkdir .gitlike/branches
    mkdir .gitlike/branches/main
    mkdir .gitlike/commits
    touch .gitlike/HEAD
    touch .gitlike/gitlike_config
    echo "Enter the name of the application: example (Some github application)"
    read application_name
    echo "Enter the version: example (v 1.1)"
    read version
    json_object="{
        \"name\": \"$application_name\",
        \"version\": \"$version\"
    }"
    head_hash=$(uuidgen)
    echo $json_object > .gitlike/gitlike_config
    echo $head_hash > .gitlike/HEAD
    mkdir .gitlike/commits/$head_hash


}

# Function for checking the file diff
check_diff() {
    # Run diff and capture the output
    diffs=$(diff -r . ".gitlike/commits/$1")

    # Declare an associative array to store files by directory
    declare -A files_by_dir

    # Process each line of the diff output
    while read -r line; do
        # Check if the line indicates files only in one of the directories
        if [[ "$line" =~ ^Only\ in ]]; then
            # Extract directory and file name
            directory=$(echo "$line" | awk '{print $3}' | sed 's/:$//')
            file=$(echo "$line" | awk '{print $4}')
            
            # Append the file to the directory's file list
            files_by_dir["$directory"]+="$file "
        fi
    done <<< "$diffs"

    # Output the files grouped by directory
    for dir in "${!files_by_dir[@]}"; do
        # echo "Directory: $dir"
        if [ "$2" == "add" ]; then
            if [ "$dir" == "." ]; then
                echo ${files_by_dir[$dir]} | sed "s/.gitlike //g"
                break

                fi
        fi
        echo -e "Untracked Files: ${RED}${files_by_dir[$dir]}${ENDCOLOR}"
        echo
    done
}



# Argument validation check
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <arugment 1>"
    echo "init"
    echo "status"
    exit 1
fi



# The main code
head_hash=$(cat .gitlike/HEAD)
argument1=$1

if [ "$argument1" == "init" ]; then
    gitlike_init
elif [ "$argument1" == "status" ]; then
    diff_res=$(check_diff $head_hash)
    echo ""
    echo $diff_res

elif [ "$argument1" == "add" ]; then
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 add <argument>"
        printf "\t%s\t%s\n" "." " add all files"
        printf "\t%s\t%s\n" "file_name" " add specific file to a commit"
        exit 1  
    
    fi


    argument2=$2
    if [ "$argument2" == "." ]; then
        diff_res=$(check_diff $head_hash "add")
        echo ""
        echo -e "Files added to track: ${GREEN}$diff_res${ENDCOLOR}"
        exit 1
    fi

else
    echo "Usage: $0 <arugment 1>"
    echo "init"
    echo "status"
    exit 1
fi