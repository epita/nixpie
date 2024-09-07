#!/usr/bin/env bash

if [ "$1" == "--escape-sequence" ]; then
    exec > >(sed $'s/\e/\\\\E/g')
fi

colorfmt() {
    sed -e "
    s/%hlbr/$(tput bold)$(tput setaf 1)/g;
    s/%hlr/$(tput setaf 1)/g;
    s/%hlbg/$(tput bold)$(tput setaf 2)/g;
    s/%hlg/$(tput setaf 2)/g;
    s/%hlbb/$(tput bold)$(tput setaf 4)/g;
    s/%blb/$(tput setaf 4)/g;
    s/%hlby/$(tput bold)$(tput setaf 3)/g;
    s/%hly/$(tput setaf 3)/g;
    s/%hlbm/$(tput bold)$(tput setaf 5)/g;
    s/%hlm/$(tput setaf 5)/g;
    s/%hlbw/$(tput bold)$(tput setaf 8)/g;
    s/%hlw/$(tput setaf 7)/g;
    s/%hl0/$(tput sgr0 || echo $'\e[0m')/g;
    " <<<"${1}"
}

center_text() {
    local text="$1"
    local width=80
    printf "%*s\n" $(((${#text} + width) / 2)) "$text"
}

# Write the content to the output file

cat <<EOF
         ########################################           
         #         EPITA $(colorfmt "%hlbbACU 2024%hl0") - TTY         #
         ########################################           

# Assignment

This computer is set in text only mode. Your graphic session has been disabled
for the purpose of this practical.

The learning goals are:

- Learn how to use the shell through a game.
- Navigate shell commands using only the keyboard.
- Keyboard is configured with the QWERTY layout.

We hope you will enjoy this initiative and have some fun.

-- 
ACU 2024 Team

# Login

To continue, please log below with your regular login and password. The
password will not be displayed on the screen: that is normal.

# Build
EOF
