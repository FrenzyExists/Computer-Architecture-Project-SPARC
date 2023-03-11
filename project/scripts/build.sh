#!/bin/bash

current_dir="$(pwd)"
red="\033[0;31m"
yellow="\033[0;33m"
green="\033[0;32m"
blue="\033[0;34m"
magenta="\033[0;35m"
cyan="\033[0;36m"
black="\033[0;30m"
black_2="\033[0;90m"
reset="\033[0m"
white="\033[0;97m"

version=("0.1" "Let Me Be Sad")

welcome() {
        printf "%b" "
${yellow} _____         _ _            _____           _         _   
${yellow}|  |  |___ ___|_| |___ ___   |  _  |___ ___  |_|___ ___| |_ 
${blue}|  |  | -_|  _| | | . | . |  |   __|  _| . | | | -_|  _|  _|
${magenta} \___/|___|_| |_|_|___|_  |  |__|  |_| |___|_| |___|___|_|  
${magenta}                      |___|                |___|            
${reset}

»»» Team Players:
    » ${yellow}Victor Barriera${reset}
    » ${red}Angel L Garcia${reset}
    » ${blue}Victor Blue${reset}

${blue}version ${yellow}${version[0]}${magenta}: ${green}${version[1]}${reset}

Requires
 » bash v4.3+
 » icarus verilog

Options:
   -h | --help        -> prints this section
        --build-all   -> build all project components
"
    exit 1
}

build_all() {
    if ! test -d "$current_dir/build"; then
        mkdir "$current_dir/build"
    fi

    # TODO: Convert this into a dictionary or an array for the sake of DRYness

    printf "Building ALU"
    iverilog -o "$current_dir/build/alu.vvp" "$current_dir/project/src/project-alu.v" "$current_dir/project/test/project-alu-tester.v"
    printf "done"

    printf "Building Source Operand2 Handler"
    iverilog -o "$current_dir/build/operand.vvp" "$current_dir/project/src/project-operand.v" "$current_dir/project/test/project-operand-tester.v"
    printf "done"

    printf "Building SPARC-focused Instruction Memory"
    iverilog -o "$current_dir/build/register-memory.vvp" "$current_dir/project/src/project-instruction-memory.v" "$current_dir/project/test/project-instruction-memory-tester.v"
    printf "done"
}

execute-all() {
    if ! test -d "$current_dir/build"; then
        printf "build file not found, please run the script with the --build-all flag and then execute\n\n"
        exit
    fi
    printf "Executing ALU\n--------------\n"
    $current_dir/build/alu.vvp

    printf "\n\nExecuting Source Operand2 Handler\n------------------\n"





}


[ -z "$1" ] && welcome

# Compile all verilog files
while test $# -gt 0; do
    case "$1" in
        -h | --help) 
            welcome
        ;;
        --build-all)
            build_all
            exit
        ;;
        --execute-all)
            execute-all
            exit
    esac
done
