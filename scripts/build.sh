#!/bin/bash

current_dir="$(pwd)"
red="\033[0;31m"
yellow="\033[0;33m"
green="\033[0;32m"
blue="\033[0;34m"
magenta="\033[0;35m"
cyan="\033[0;36m"
reset="\033[0m"

version=("0.2" "Baby Doll")
prev_versions="""
-> 0.1 Let Me Be Sad:
    Worked on Phase 1, mostly doing just some base components n stuff
"""

verilog_dir="src"
tester_dir="testers"
build_dir="build"

# #################################
files=("alu" "operand-handler" "condition-handler" "reset-handler" "npc-pc-handler")
files_no_tester=("instruction-memory")
files_with_precharge=("data-memory")
dependencies=("muxes")
# #################################

undone_stuff=("pipeline-registers" "register-file" "data-memory" "instruction-memory" "control-unit" "hazard-unit" )

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
    » ${blue}Victor Hernandez${reset}

${blue}version ${yellow}${version[0]}${magenta}: ${green}${version[1]}${reset}

Requires
 » bash v4.3+
 » icarus verilog

Options:
   -h | --help            -> prints this section
        --build-all       -> build all project components
        --list-components -> Lists all project components
"
}

build_all() {

    printf "${cyan}%s\n" " _           _ _     _                       _       _           "
    printf "${cyan}%s\n" "| |__  _   _(_) | __| |  _ __ ___   ___   __| |_   _| | ___  ___ "
    printf "${yellow}%s\n" "| '_ \| | | | | |/ _\` | | '_ \` _ \ / _ \ / _\` | | | | |/ _ \/ __|"
    printf "${magenta}%s\n" "| |_) | |_| | | | (_| | | | | | | | (_) | (_| | |_| | |  __/\__ \\"
    printf "${magenta}%s\n${reset}" "|_.__/ \__,_|_|_|\__,_| |_| |_| |_|\___/ \__,_|\__,_|_|\___||___/"
                                                                 

    if ! test -d "$build_dir"; then
        mkdir "$build_dir"
    fi

    for file in "${files[@]}"; do
        printf "Building %s\n" "$file"
        iverilog -o "$build_dir/$file.vvp" "$verilog_dir/$file.v" "$tester_dir/${file}-tester.v"
        printf "\nDone :3\n"
    done

    printf "Building files that do not include/need tester files...\n"

    for file in "${files_no_tester[@]}"; do
        printf "Building %s\n" "$file"
        iverilog -o "$build_dir/$file.vvp" "$verilog_dir/$file.v"
        printf "\nDone :3\n"
    done

    printf "Building files that require precharge files...\n"

    for file in "${files_with_precharge[@]}"; do
        printf "Building %s\n" "$file"
        iverilog -o "$build_dir/$file.vvp" "$verilog_dir/$file.v" "$verilog_dir/${file}-precharge.v"
        printf "\nDone :3\n"
    done
}


list_modules() {
    printf "${cyan}%s\n" "  _    _    _   _             __  __         _      _        "
    printf "${cyan}%s\n" " | |  (_)__| |_(_)_ _  __ _  |  \/  |___  __| |_  _| |___ ___"
    printf "${yellow}%s\n" " | |__| (_-<  _| | ' \/ _\` | | |\/| / _ \/ _\` | || | / -_|_-<"
    printf "${magenta}%s\n" " |____|_/__/\__|_|_||_\__, | |_|  |_\___/\__,_|\_,_|_\___/__/"
    printf "${magenta}%s\n${reset}" "                      |___/                                    "

    printf "Completed Modules:\n"
    for file in "${files[@]}"; do
        printf "  --> %s\n" "$file"
    done

    printf -- '-%.0s' {1..32} 
    printf -- "\nMissing Modules\n"

    for file in "${undone_stuff[@]}"; do
        printf "  --> %s\n" "$file"
    done
}

execute-all() {
    if ! test -d "$current_dir/build"; then
        printf "build file not found, please run the script with the --build-all flag and then execute\n\n"
        exit
    fi

    # local verilog_file="$1"
    local vvp_file="${verilog_file%.v}.vvp"
    local valid_files=("file1.v" "file2.v" "file3.v")  # Add your valid Verilog file names here

    # Verify if the specified Verilog file is in the valid files array
    if [[ " ${valid_files[@]} " =~ " $verilog_file " ]]; then
        if [ -f "$vvp_file" ]; then
            vvp "$vvp_file"
        else
            echo "Error: Could not find VVP file for $verilog_file"
        fi
    else
        echo "Error: Invalid Verilog file specified"
    fi

    # printf "Executing ALU\n--------------\n"
    # "$current_dir"/build/alu.vvp

    # printf "\n\nExecuting Source Operand2 Handler\n------------------\n"


}

analize_plz() {
    printf "Boob Beep Bop. Booting up...\nIt's time for...\n"
    printf "%b\n" "
  _  _             _                         _             _         _    
 | || |__ _ _ _ __| |_ __ ____ _ _ _ ___    /_\  _ _  __ _| |_  _ __(_)___
 | __ / _\` | '_/ _\` \ V  V / _\` | '_/ -_)  / _ \| ' \/ _\` | | || (_-< (_-<
 |_||_\__,_|_| \__,_|\_/\_/\__,_|_| \___| /_/ \_\_||_\__,_|_|\_, /__/_/__/
                                                             |__/         
    "

    printf "%b\n" "There's atm 3 kinds of analysis done in this project for funsies
    - Timing Analysis ==> Measures speed of design
    - Power Analysis  ==> Measures power consumption of design
    - Fault Analysis  ==> Makes sure shit doesn't fuck up
    "
    # sleep 1sec

    printf "Select the analysis you want!\n"

}

doctor() {
    if ! test -v iverilog ; then
        echo "Icarus Verilog not found. Installing..."
        printf "Attempting to install Icarus...\n"

        # For Debian-based Systems
        if  where apt-get &>/dev/null 2>&1; then
            printf "Installing Icarus Verilog using apt-get"
            sudo apt-get update
            sudo apt-get install -y iverilog

        # For Red Hat Systems
        elif where yum &>/dev/null 2>&1; then
            printf "Installing Icarus Verilog using yum\n"
            sudo yum update
            sudo yum install -y iverilog

        # Check if the system is a macOS
        elif [ "$(uname)" == "Darwin" ]; then
            printf "Installing Icarus Verilog using Homebrew\n"
            brew update
            brew install icarus-verilog


        else
            printf "Couldn't find any package manager on this system. Attempting to use the git version...\n"

            if  where git &>/dev/null 2>&1; then
                temp_dir=$(mktemp -d)
                conf_file="autoconf.sh"
                conf_folder="configure"

                trap 'rm -rf $temp_dir' EXIT

                printf "Clonning...\n"
                git clone https://github.com/steveicarus/iverilog.git "$temp_dir"
                cd "$temp_dir" || exit 
                bash "$conf_file"
                cd "$conf_folder" || exit
                make &

                printf "Icarus got installed! Noice\n"
            else
                printf "Git is not installed, get git, fr\n"
                exit 1
            fi

            printf "Error: Icarus Verilog is not installed and package manager not found\n"
            exit 1
        fi
    fi
}


# Check if Icarus Verilog is installed
[ -z "$1" ] && welcome

if ! command -v iverilog &>/dev/null 2>&1; then
    printf "\nIcarus Verilog not found. You should run the script with the --doctor flag to get the prob fixed.\n"
fi

# Compile all verilog files
while test $# -gt 0; do
    case "$1" in
        -h | --help) 
            welcome
            exit 1
        ;;
        --build-all)
            build_all
            exit
        ;;
        --execute-all)
            execute-all
            exit
        ;;
        --list|-l)
            list_modules
            exit
        ;;
        --diagnose|-doctor|-d)
            doctor
            exit
        ;;
        --analyze-wiz|--a-wiz|-a)
            analize_plz
            exit
        ;;
    esac
done
