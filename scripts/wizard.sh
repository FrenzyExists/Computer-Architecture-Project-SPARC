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

declare -a menu_stack
stack_size=0

# -> 0.1 Let Me Be Sad:
#    Worked on Phase 1, mostly doing just some base components n stuff'
# -> 0.2 Baby Doll:
#    Completed Phase 2 and did a small improvement on the script
# -> 0.3 Bad Men:
#    Completed Phase 3, made some changes on the menu
version=("0.4" "DaySeeker")

# Directory path for Verilog source files
verilog_dir="src"

# Directory path for test files or testers
tester_dir="testers"

# Directory path for build or output files
build_dir="build"

exec_dir="exec"

synth_dir="synthetized"

# Set description
description="Choose an option:"

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
animation_thingy() {
  for i in {0..1} do :; do for i in {1..19} {18..2}; do
    printf "\e[31;1m%${i}s \r" █
    sleep 0.02
  done; done
}

# Function to push a menu onto the stack
push_menu() {
  menu_stack+=("$1")
  stack_size=${#menu_stack[@]}
}

# Function to pop the top menu from the stack
pop_menu() {
  menu_stack=("${menu_stack[@]:0:${#menu_stack[@]}-1}")
  stack_size=${#menu_stack[@]}
}

# Function to move cursor up
cursor_up() {
  [ $cursor_pos -gt 0 ] && {
    tput cuu1
    ((cursor_pos--))
  }
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

prompter() {
  local filename="$1"
  local filevvp=$(basename "$filename")
  filevvp="${filevvp%.*}.vvp"

  # Common code here
  printf "\r%-25s%+25s" "$filename" ""
  sleep 1
  printf "\rBuild Success! %+25s" ""
  printf "\033[3A" # Clear 3 lines down
  sleep 1
  unset filename
  unset filevvp
  pop_menu
}

process_files() {
  local options=()
  local functions=()
  local directory=$1
  local action=$2

  while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    options+=("$filename")
    functions+=("$action $filename")
  done < <(find "$parent_dir/$directory" -type f -print0)

  select_options options functions
}

# =========================================================================

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

build_file() {
  local filename="$1"
  iverilog -o "$parent_dir/$build_dir/${filename%.*}.vvp" "$parent_dir/$verilog_dir/$filename" 2>/dev/null || printf "        %bUh... this file fucked up%b" "$red" "$reset"
  prompter "$filename"
}

build_all() {
  printf "\n\nBuilding Source Modules:\n---------------------------------------------\n"
  local directory="$parent_dir/$verilog_dir"

  build_files "$directory"
  printf "    DONE （＾ｖ＾）\n\nBuilding Test Modules:\n---------------------------------------------\n"

  directory="$parent_dir/$tester_dir"
  build_files "$directory"

  printf "\nDONE （＾ｖ＾）\n\n"
  pop_menu
}

build_specific() {
  process_files "$verilog_dir" "build_file"
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

  test -d "$build_dir" || mkdir "$build_dir"

  options=("build all modules" "build a particular module")
  functions=("build_all" "build_specific")

  select_options options functions
}

# =========================================================================

execute_file() {
  local filename="$1"
  vvp "$parent_dir/$build_dir/${filename%.*}.vvp" "$parent_dir/$verilog_dir/$filename" | less
  prompter "$filename"
}

execute_specific() {
  process_files "$build_dir" "execute_file"
}

execute_all() {
  printf "Do you want to check if the file is synthesizable? (y/n) " && read -r answer
  test -d "$directory" || (printf "Compile Files first" && return 1)

  printf "\n\nExecuting Test Modules:\n"

  # Nothing matters,
  # as above so bellow...

  local directory="$parent_dir/$build_dir"
  local file_count=$(find "$directory" -maxdepth 1 -type f | wc -l)
  local completed=0
  local progress=""

  # Check if ps2pdf and enscript are installed
  local to_pdf=1
  if ! command -v ps2pdf &>/dev/null || ! command -v enscript &>/dev/null; then
    printf "Warning: ps2pdf or enscript is not installed.\nFiles will be .txt instead.\n"
    to_pdf=0
  fi

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

    if [[ $answer =~ ^[Yy]$ ]]; then
        iverilog -S "$parent_dir/$verilog_dir/$filename"
    fi

    # TODO: Use some flag options so this doesn't break in case enscript is not installed
    if [ to_pdf eq 1 ] ; then
      local outfile="${filename%.*}.pdf"
      vvp "$parent_dir/$build_dir/$vfile" | enscript -o - | ps2pdf - "$parent_dir/$exec_dir/$outfile"
    else
      local outfile="${filename%.*}.txt"
      vvp "$parent_dir/$build_dir/$vfile" > "/$parent_dir/$exec_dir/$outfile"
    fi
    # Print the progress bar at the bottom
    printf "\n%s %d/%d files" "$progress" "$completed" "$file_count"
    sleep 0.4
  done
}

execute() {
  boi="
${red} _ _ _ _        _   _          _____     _ _   _         
${red}| | | |_|___   | |_| |_ ___   | __  |_ _|_| |_| |___ ___ 
${yellow}| | | | |- _|  |  _|   | -_|  | __ -| | | | | . | -_|  _|
${magenta}|_____|_|___|  |_| |_|_|___|  |_____|___|_|_|___|___|_|  ${reset}

${cyan}»» ${description}${reset}

"
  options=("Execute All Modules" "Execute a Specifc Module")
  functions=("execute_all" "execute_specific")
  select_options options functions

}

doctor() {
  clear && printf "%b" "
${red} ____          _              _ _ _ _     
${red}|    \ ___ ___| |_ ___ ___   | | | |_|___ 
${yellow}|  |  | . |  _|  _| . |  _|  | | | | |- _|
${cyan}|____/|___|___|_| |___|_|    |_____|_|___|${reset}


${cyan}»» Checking if verilog is installed...${reset}

"
  animation_thingy
  printf "\r "

   # Check if python is installed
   # Check if cocotb is installed
   # If not pip install it

  if ! command -v iverilog &>/dev/null; then
    printf "Icarus Verilog not found. Attempting to install Icarus Verilog..\n"

    local install_command=""
    local package_manager=""

    if ! where pacman &>/dev/null 2>&1; then # Arch Linux
      install_command="sudo pacman -Sy --quiet && sudo pacman -S --quiet iverilog-git"
      package_manager="pacman"

    elif ! where apt-get &>/dev/null 2>&1; then # Debian
      install_command="sudo apt-get update && sudo apt-get install -y iverilog"
      package_manager="apt-get"

    elif ! where yum &>/dev/null 2>&1; then # Red Hat
      install_command="sudo yum update && sudo yum install -y iverilog"
      package_manager="yum"

    elif [ "$(uname)" == "Darwin" ] && command -v brew &>/dev/null; then
      install_command="brew update && brew install icarus-verilog"
      package_manager="Homebrew"
    fi

    if [ -n "$install_command" ]; then
      printf "Installing Icarus Verilog using $package_manager\n"
      "${install_command}"
    else
      printf "Couldn't find a suitable package manager. Attempting to install from source...\n"
      if ! where git &>/dev/null 2>&1; then
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

        printf "Icarus is succesfully installed!\n"
      else
        printf "Git is not installed, get git, fr\n"
        exit 1
      fi

      printf "Error: Icarus Verilog is not installed and package manager not found\n"
      exit 1
    fi
  else
    printf "\n${red}Icarus Verilog${reset} is already installed!\n"
    sleep 1
  fi
}

fault() {
  printf "Option not implemented, need to work on cocotb files first\n"
}

timing() {
  printf "Option not implemented, need to work on cocotb files first\n"
}

analyze() {
  description="Select the analysis you want!"
    boi="
${magenta}  _  _             _                         _             _         _    
${magenta} | || |__ _ _ _ __| |_ __ ____ _ _ _ ___    /_\  _ _  __ _| |_  _ __(_)___
${yellow} | __ / _\` | '_/ _\` \ V  V / _\` | '_/ -_)  / _ \| ' \/ _\` | | || (_-< (_-<
${blue} |_||_\__,_|_| \__,_|\_/\_/\__,_|_| \___| /_/ \_\_||_\__,_|_|\_, /__/_/__/
${blue}                                                             |__/         
${reset}
  

  ${cyan}»» ${description}${reset}

  "
    options=("Timing Analysis > Measures speed of design" "Fault Analysis > Checks if design suffers any logical glitch")
    functiions=("timing" "fault")
    select_options options functions
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
    » ${red}Angel L Garcia${reset} | ${magenta}Detective Pikachu${reset}
    » ${blue}Victor Hernandez${reset}

${blue}version ${yellow}${version[0]}${magenta}: ${green}${version[1]}${reset}

Requires
 » bash v4.3+
 » icarus verilog
 » enscript (optional, for PDF outputs)
 » ps2pdf (optional, for PDF outputs)
 » python 3.7+
 » cocotb

  ${cyan}»» ${description}${reset}
"

  functions=("analize" "doctor" "execute" "build" "cocotb")
  options=("Analize Hardware Designs" "Call the Doctor" "Execute Compilled Designs" "Compile Hardware Designs" "Run Cocotb Testbench")
  select_options options functions
}

select_options() {
  local -n _options=$1
  local -n _functions=$2

  if [ ${#_options[@]} -ne ${#_functions[@]} ]; then
    echo "Error: The number of options and functions does not match."
    return 1
  fi

  tput civis # Hide the terminal cursor

  if [ "$stack_size" -eq 0 ]; then
    _options+=("Exit")
    _functions+=("Exit")
  else
    _options+=("Go Back")
    _functions+=("GoBack")
  fi

  local options_len=${#_options[@]}
  local cursor_pos=0

  while true; do
    clear
    display_options

    read -s -n 1 key

    if [ "$key" == "" ]; then
      local selected_func=${_functions[$cursor_pos]}
      if [ -n "$selected_func" ]; then
        if [ "$selected_func" == "GoBack" ]; then
          pop_menu
          if [ "$stack_size" -eq 0 ]; then
            welcome
          else
            return 1
          fi
        elif [ "$selected_func" == "Exit" ]; then
          tput cnorm # Restore the terminal cursor
          exit 0
        else
          if [[ $(type -t foo) == function ]] ; then
            printf "Function is not implemented, wait for next update!\n"
            sleep 1
          else
            push_menu "$selected_func"
            func_name=${selected_func%% *}
            func_args=${selected_func#* }
            "$func_name" "$func_args"
          fi
        fi
      fi
    fi

    case "$key" in
    "A") cursor_up ;;
    "B") cursor_down ;;
    *) ;;
    esac
  done
}

# Check if Icarus Verilog is installed
if ! command -v iverilog &>/dev/null 2>&1; then
  printf "\n${red}Icarus Verilog${reset} not found. You should run the script with the doctor to get the prob fixed.\n"
  sleep 1
  exit
else
  welcome
fi
