#!/bin/bash


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
function check_diff(){
    diff -r . .gitlike/commits/$1
}



# Argument validation check
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <arugment 1>"
    echo "init"
    echo "status"
    exit 1
fi



# The main code
argument1=$1

if [ "$argument1" == "init" ]; then
    gitlike_init
elif [ "$argument1" == "status" ]; then
    head_hash=$(cat .gitlike/HEAD)
    diff_res=$(check_diff $head_hash)
    echo ""
    echo $diff_res
else
    echo "Usage: $0 <arugment 1>"
    echo "init"
    echo "status"
    exit 1
fi