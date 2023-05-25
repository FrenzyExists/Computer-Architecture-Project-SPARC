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

# Parent directory where the rest of files are
parent_dir=$(dirname "$(dirname "$(realpath "$0")")")

NEWEST_TAG=$(git describe --abbrev=0 --tags 2>/dev/null || echo "No tags found")

if [ "$NEWEST_TAG" != "$SCRIPT_VERSION" ]; then
    git tag -a "${version[0]}" -m "version ${version[1]}" 2>/dev/null
fi

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
            printf "    %s\n" "${options[$i]}"
        fi
    done
}

help() {
    printf "NO BITCHES\n"
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

    # TODO: Fix display bug
    build_file() {
        local filename="$1"
        local filevvp=$(basename "$filename")
        filevvp="${filevvp%.*}.vvp"
        # printf "\n\n\rBuilding %-25s     %-25s" "$parent_dir/$verilog_dir/$filename" "$parent_dir/$build_dir/$filevvp"
        iverilog -o "$parent_dir/$build_dir/$filevvp" "$parent_dir/$verilog_dir/$filename" 2>/dev/null || printf "        %bUh... this file fucked up%b" "$red" "$reset"
        unset filename
        unset filevvp
    }


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
        tput civis # Hide the terminal cursor

        build_files "$directory"

        printf "    DONE （＾ｖ＾）\n\nBuilding Test Modules:\n---------------------------------------------\n"

        directory="$parent_dir/$tester_dir"
        build_files "$directory"

        tput cnorm # Restore the terminal cursor
        printf "\nDONE （＾ｖ＾）\n\n"
    }

    build_specific() {
        local options=()
        while IFS= read -r -d '' options; do
            filename=$(basename "$options")
            options+=("$filename")
        done < <(find "$parent_dir/$verilog_dir" -type f -print0)
        
        options+=("finish")
        # Get length of options array
        options_len=${#options[@]}

        # Set initial cursor position to first option
        cursor_pos=0
        tput civis # Hide the terminal cursor
        while true; do
            # Clear screen and display options
            # clear
            tput cuu ${#options[@]}
            display_options

            # Move the cursor back to the first line of options
            # tput cuu ${#options[@]}-20
            read -s -n 1 key    # Wait for user input

            if [ "$key" == "" ]; then
            filename=${options[$cursor_pos]}
            if [ "$filename" == "finish" ]; then
                printf "    %s\n" "DONE （＾ｖ＾）"
                sleep 1.5
                break
            fi
            build_file "$filename"


            # printf "\n    %-24s%s\n" "Building" "${filenames[$cursor_pos]}"
            # filename=${filenames[$cursor_pos]}
            # local vfile="${filename%.*}.vvp"
            # iverilog -o "$parent_dir/$build_dir/$vfile" "$directory/$filename" 2>/dev/null || printf "           %bUh this file fucked up%b" "$red" "$reset"
            # tput cnorm # Restore the terminal cursor
            
            #     exit
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

    options=("build all modules" "build a particular module" "return to monke")

    # Get length of options array
    options_len=${#options[@]}

    # Set initial cursor position to first option
    cursor_pos=0

    # Loop to display options and get user input
    while true; do
        # Clear screen and display options
        clear
        display_options

        # Wait for user input
        read -s -n 1 key

        # Check if user pressed enter
        if [ "$key" == "" ]; then
            case "${options[$cursor_pos]}" in
            # Change stuff here too when changing options
            "build all modules")
                build_all
                ;;
            "build a particular module")
                build_specific
                ;;
            "return to monke")
                printf "%b" "
${brown}      .-\"-.${reset}
${brown}    _/${cream}.-.-.${brown}\\_ ${reset}
${brown}   /|${cream}( ${red}✖ ✖${cream} )${brown}|\\ ${reset}
${brown}  | /${cream}/  \033[1mω  \\\\${brown}\ | ${reset}
${brown} / / ${cream}\'---'/ ${brown}\\ \\ ${reset}
${brown} \\ \\_/\`\"\"\"\`\\_/ / ${reset}
${brown}  \\           / ${reset}
"
                sleep 1.5
                return
                ;;
            esac
            break
        fi
        # Check which key was pressed
        case "$key" in
        "A") cursor_up ;;
        "B") cursor_down ;;
        *) ;;
        esac
    done
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
    options=("help" "build" "list components" "LET ME OUT!!!")

    # Get length of options array
    options_len=${#options[@]}

    # Set initial cursor position to first option
    cursor_pos=0

    # Loop to display options and get user input
    while true; do
        # Clear screen and display options
        clear
        display_options

        # Wait for user input
        read -s -n 1 key

        # Check if user pressed enter
        if [ "$key" == "" ]; then
            case "${options[$cursor_pos]}" in
            # Change stuff here too when changing options
            "build")
                build
                welcome
                ;;
            "help")
                help
                ;;
            "LET ME OUT!!!")
                exit
                ;;

            *)
                printf "    » Options is still in construction. Pwease wait till pwogwamer stops pwocwastinating :3\n"
            ;;
            esac
            break
        fi

        # Check which key was pressed
        case "$key" in
        "A") cursor_up ;;
        "B") cursor_down ;;
        *) ;;
        esac
    done
}


welcome