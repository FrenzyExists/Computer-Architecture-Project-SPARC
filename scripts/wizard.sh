#!/usr/bin/env bash

red="\033[0;31m"
yellow="\033[0;33m"

brown="\033[0;93m"
cream="\033[0;255;228;196m"

green="\033[0;32m"
blue="\033[0;34m"
magenta="\033[0;35m"
cyan="\033[0;36m"
reset="\033[0m"

# -> 0.1 Let Me Be Sad:
#    Worked on Phase 1, mostly doing just some base components n stuff'
# -> 0.2 Baby Doll:
#    Completed Phase 2 and did a small improvement on the script
version=("0.3" "Bad Men")

# Directory path for Verilog source files
verilog_dir="src"

# Directory path for test files or testers
tester_dir="testers"

# Directory path for build or output files
build_dir="build"

# Set description
description="Choose an option:"

declare -a menu_stack

# Parent directory where the rest of files are
parent_dir=$(dirname "$(dirname "$(realpath "$0")")")

NEWEST_TAG=$(git describe --abbrev=0 --tags 2>/dev/null || echo "No tags found")

if [ "$NEWEST_TAG" != "$SCRIPT_VERSION" ]; then
    git tag -a "${version[0]}" -m "version ${version[1]}" 2>/dev/null
fi

# Found this on a random site. Not sure if its scottish or polish
# All I know is that I got a brain aunerisim trying to figure out wtf
# it says without a translator :P
# Yes I am mentally disabled, I have return to  M O N K E
animation_thingy(){
    while :;do for i in {1..20} {19..2};do printf "\e[31;1m%${i}s \r" █;sleep 0.02;done;done
}

# Function to push a menu onto the stack
push_menu() {
    menu_stack+=("$1")
}

# Function to pop the top menu from the stack
pop_menu() {
    menu_stack=("${menu_stack[@]:0:${#menu_stack[@]}-1}")
}

# Function to move cursor up
cursor_up() {
    if [ $cursor_pos -gt 0 ]; then
        tput cuu1
        ((cursor_pos--))
    fi
}

# Function to move cursor down
cursor_down() {
    if [ $cursor_pos -lt $(($options_len - 1)) ]; then
        tput cud1
        ((cursor_pos++))
    fi
}

# Function to display options and highlight current option
display_options() {
    printf "%b%s\n" "$boi"

    for i in "${!options[@]}"; do
        if [ "$i" -eq $cursor_pos ]; then
            printf "${yellow}>>> %s${reset}\n" "${options[$i]}"
        else
            printf "    %s%+25s\n" "${options[$i]}" ""
        fi
    done
}

# Basic Menu Selection and the Butter of the Bread
# TODO: Implement the EXIT and GO BACK options in a dynamic way based on the stack size
select_options() {
    local -n _options=$1
    local -n _functions=$2

    if [ ${#_options[@]} -ne ${#_functions[@]} ]; then
        echo "Error: The number of options and functions does not match."
        return 1
    fi

    tput civis # Hide the terminal cursor

    local options_len=${#_options[@]}
    local cursor_pos=0

    while true; do
        clear
        display_options
        
        read -s -n 1 key

        # Check if user pressed enter
        if [ "$key" == "" ]; then
            local selected_func=${_functions[$cursor_pos]}
            if [ -n "$selected_func" ]; then
                "$selected_func"
            fi
            break
        fi
        
        # Check which key was pressed
        case "$key" in
        "A") cursor_up ;;
        "B") cursor_down ;;
        *) ;;
        esac
    done
    tput cnorm # Restore the terminal cursor
}

analize_plz() {
    clear
    printf "Boob Beep Bop. Booting up...\nIt's time for...\n"
    printf "%b\n" "
${magenta}  _  _             _                         _             _         _    
${magenta} | || |__ _ _ _ __| |_ __ ____ _ _ _ ___    /_\  _ _  __ _| |_  _ __(_)___
${yellow} | __ / _\` | '_/ _\` \ V  V / _\` | '_/ -_)  / _ \| ' \/ _\` | | || (_-< (_-<
${blue} |_||_\__,_|_| \__,_|\_/\_/\__,_|_| \___| /_/ \_\_||_\__,_|_|\_, /__/_/__/
${blue}                                                             |__/         
${reset}"

    printf "%b\n" "There's atm 3 kinds of analysis done in this project for funsies
    - Timing Analysis ==> Measures speed of design
    - Power Analysis  ==> Measures power consumption of design
    - Fault Analysis  ==> Makes sure shit doesn't fuck up
    "

    printf "Select the analysis you want!\n"
}

# TODO: Fix display bug (DONE)
build_file() {
    local filename="$1"
    local filevvp=$(basename "$filename")
    filevvp="${filevvp%.*}.vvp"
    iverilog -o "$parent_dir/$build_dir/$filevvp" "$parent_dir/$verilog_dir/$filename" 2>/dev/null || printf "        %bUh... this file fucked up%b" "$red" "$reset"
    printf "\rBuilding %-25s%+25s" "$filename" ""
    sleep 1
    printf "\rBuild Success! %+25s" ""
    printf "\033[3A"  # Clear 3 lines down
    unset filename
    unset filevvp
}

# TODO: Separate the animation form the actual process so I can use it with other stuff
build_files() {
    local directory="$1"
    local file_count=$(find "$directory" -maxdepth 1 -type f | wc -l)
    local completed=0
    local progress=""

    for file in "$directory"/*; do
        local filename=$(basename "$file")
        local vfile="${filename%.*}.vvp"
        printf "\rBuilding %-25s" "$filename"
        ((completed++))

        # Update the progress bar
        progress=""
        for ((i = 0; i < completed * 20 / file_count; i++)); do
            progress+="▰"
        done
        for ((i = completed * 20 / file_count; i < 20; i++)); do
            progress+="▱"
        done

        # Do the thing
        iverilog -o "$parent_dir/$build_dir/$vfile" "$file" 2>/dev/null || printf "           %bUh this file fucked up%b" "$red" "$reset"

        # Print the progress bar at the bottom
        printf "\n%s %d/%d files" "$progress" "$completed" "$file_count"
        sleep 0.4
    done
}

build_all() {
    printf "\n\nBuilding Source Modules:\n---------------------------------------------\n"
    local directory="$parent_dir/$verilog_dir"

    build_files "$directory"
    printf "    DONE （＾ｖ＾）\n\nBuilding Test Modules:\n---------------------------------------------\n"

    directory="$parent_dir/$tester_dir"
    build_files "$directory"

    printf "\nDONE （＾ｖ＾）\n\n"
}

build_specific() {
    local options=()
    while IFS= read -r -d '' file; do
        filename=$(basename "$file")
        options+=("$filename")
    done < <(find "$parent_dir/$verilog_dir" -type f -print0)
    
    # Add "finish" option at the end
    options+=("finish")
    
    options_len=${#options[@]} # Get length of options array

    cursor_pos=0

    while true; do
        # Clear screen and display options
        tput cuu ${#options[@]}
        display_options

        read -s -n 1 key

        if [ "$key" == "" ]; then
            filename=${options[$cursor_pos]}
            if [ "$filename" == "finish" ]; then
                printf "\r%-25s%+25s\n" "DONE （＾ｖ＾）" ""
                sleep 1.5
                break
            fi
            build_file "$filename"
        fi
        tput cuu ${#options[@]}
        # Check which key was pressed
        case "$key" in
            "A") cursor_up ;;
            "B") cursor_down ;;
            *) ;;
        esac
    done
}

build() {
    boi="
${yellow} _           _ _     _                       _       _           
${yellow}| |__  _   _(_) | __| |  _ __ ___   ___   __| |_   _| | ___  ___ 
${blue}| '_ \| | | | | |/ _\` | | '_ \` _ \ / _ \ / _\` | | | | |/ _ \/ __|
${red}| |_) | |_| | | | (_| | | | | | | | (_) | (_| | |_| | |  __/\__ \\
${red}|_.__/ \__,_|_|_|\__,_| |_| |_| |_|\___/ \__,_|\__,_|_|\___||___/
${reset}

  ${cyan}»» ${description}${reset}
"

    if ! test -d "$build_dir"; then
        mkdir "$build_dir"
    fi

    options=("build all modules" "build a particular module" "Return")
    functions=("build_all" "build_specific" "return")

    select_options options functions
}

execute() {
    boi="
${red} _ _ _ _        _   _          _____     _ _   _         
${red}| | | |_|___   | |_| |_ ___   | __  |_ _|_| |_| |___ ___ 
${yellow}| | | | |- _|  |  _|   | -_|  | __ -| | | | | . | -_|  _|
${magenta}|_____|_|___|  |_| |_|_|___|  |_____|___|_|_|___|___|_|  ${reset}

${cyan}»» ${description}${reset}

"
    options=("Execute All modules" "Execute a Particular Module" "Exit")
    functions=("execute_all" "execute_specific" "return")

    select_options options functions
}


execute_all() {
    if ! test -d "$current_dir/build"; then
        printf "build file not found, please run the script with the --build-all flag and then execute\n\n"
        exit
    fi
    # TODO Read the Boring-ass documentation to figure out a way to perform
    # Simulations on modules without testers

    # local verilog_file="$1"
    local vvp_file="${verilog_file%.v}.vvp"
    local valid_files=("file1.v" "file2.v" "file3.v")  # Add your valid Verilog file names here

    # Verify if the specified Verilog file is in the valid files array
    if [[ " ${valid_files[@]} " =~ " $verilog_file " ]]; then
        if [ -f "$vvp_file" ]; then
            vvp "$vvp_file" 
        else
            printf "Error: Could not find VVP file for %s\n" "$verilog_file"
        fi
    else
        echo "Error: Invalid Verilog file specified"
    fi

    # printf "Executing ALU\n--------------\n"
    # "$current_dir"/build/alu.vvp

    # printf "\n\nExecuting Source Operand2 Handler\n------------------\n"
}


execute_target() {
    local verilog_file="$1"
    local vvp_file="${verilog_file%.v}.vvp"

    if [ -f "$vvp_file" ]; then
        vvp "$vvp_file"
    else
        echo "Error: Could not find VVP file for $verilog_file"
    fi
}

doctor() {
    clear
    printf "%b" "
${red} ____          _              _ _ _ _     
${red}|    \ ___ ___| |_ ___ ___   | | | |_|___ 
${yellow}|  |  | . |  _|  _| . |  _|  | | | | |- _|
${cyan}|____/|___|___|_| |___|_|    |_____|_|___|${reset}


${cyan}»» ${description}${reset}

"
    if ! command -v iverilog &> /dev/null; then
        echo "Icarus Verilog not found. Installing..."
        printf "Attempting to install Icarus...\n"

        if ! where pacman &>/dev/null 2>&1; then
            printf "Installing Icarus Verilog using pacman (Arch Linux)\n"
            sudo pacman -Sy --quiet
            sudo pacman -S --quiet iverilog-git

        # For Debian-based Systems
        elif ! where apt-get &>/dev/null 2>&1; then
            printf "Installing Icarus Verilog using apt-get\n"
            sudo apt-get update
            sudo apt-get install -y iverilog

        # For Red Hat Systems
        elif ! where yum &>/dev/null 2>&1; then
            printf "Installing Icarus Verilog using yum\n"
            sudo yum update
            sudo yum install -y iverilog

        # Check if the system is a macOS
        elif [ "$(uname)" == "Darwin" ]; then
            if ! where brew &>/dev/null 2>&1 ; then 
                printf "Installing Icarus Verilog using Homebrew\n"
                brew update
                brew install icarus-verilog
            else
                printf "Brew is not installed! Get brew!\n"
            fi
        else
            printf "Couldn't find any package manager on this system. Attempting to use the git version...\n"

            if  ! where git &>/dev/null 2>&1; then
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
    else
        sleep 1
        printf "\n${red}Icarus Verilog${reset} is already installed!\n"
    fi

}


welcome() {
    boi="
${yellow} _____         _ _            _____           _         _   
${yellow}|  |  |___ ___|_| |___ ___   |  _  |___ ___  |_|___ ___| |_ 
${blue}|  |  | -_|  _| | | . | . |  |   __|  _| . | | | -_|  _|  _|
${magenta} \___/|___|_| |_|_|___|_  |  |__|  |_| |___|_| |___|___|_|  
${magenta}                      |___|                |___|            
${reset}

»»» Team Players:
    » ${yellow}Victor Barriera${reset}
    » ${red}Angel L Garcia${reset}| ${magenta}Detective Pikachu${reset}
    » ${blue}Victor Hernandez${reset}

${blue}version ${yellow}${version[0]}${magenta}: ${green}${version[1]}${reset}

Requires
 » bash v4.3+
 » icarus verilog

  ${cyan}»» ${description}${reset}
"
    tput civis # Hide the terminal cursor

    functions=("analize" "doctor" "execute" "build" "return")
    options=("Analize Hardware Designs" "Call the Doctor" "Execute Compilled Designs" "Compile Hardware Designs" "Exit")

    select_options options functions
}


# Check if Icarus Verilog is installed
if ! command -v iverilog &>/dev/null 2>&1; then
    printf "\n${red}Icarus Verilog${reset} not found. You should run the script with the doctor to get the prob fixed.\n"
    sleep 1
    exit
else
    welcome
fi