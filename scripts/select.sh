#!/bin/bash

# Define options
options=("Option 1" "Option 2" "Option 3")

# Set description
description="Please select an option:"

# Get length of options array
options_len=${#options[@]}

# Set initial cursor position to first option
cursor_pos=0

# Function to move cursor up
function cursor_up {
  if [ $cursor_pos -gt 0 ]; then
    tput cuu1
    ((cursor_pos--))
    # play -n synth 0.1 sin 880 >/dev/null 2>&1
  fi
}

# Function to move cursor down
function cursor_down {
  if [ $cursor_pos -lt $(($options_len - 1)) ]; then
    tput cud1
    ((cursor_pos++))
  fi
}

# Function to display options and highlight current option
function display_options {
    
  printf "%s\n\n" "$description"

  for i in "${!options[@]}"; do
    if [ "$i" -eq $cursor_pos ]; then
      printf "\e[7m%s\e[27m\n" "${options[$i]}"
    else
      printf "%s\n" "${options[$i]}"
    fi
  done
}

# Loop to display options and get user input
while true; do
  # Clear screen and display options
  clear
  display_options

  # Wait for user input
  read -s -n 1 key

  # Check if user pressed enter
  if [ "$key" == "" ]; then
    # Clear screen and display selected option
    # clear
    printf "\nSelected: %s\n" "${options[$cursor_pos]}"
    break
  fi

  # Check which key was pressed
  case "$key" in
    "A") cursor_up ;;
    "B") cursor_down ;;
    *) ;;
  esac
done
