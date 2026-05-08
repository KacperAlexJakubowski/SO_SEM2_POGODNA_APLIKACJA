#!/bin/bash
# Author           : Kacper Jakubowski ( s208525@pg.edu.pl )
# Created On       : 08.05.2026
# Last Modified On : 08.05.2026 
# Version          : 1.0
#
# Description      :
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)
# 
# Generative AI statement (keep ONE line below, delete the others):
# * I did NOT use GenAI tools while developing this code.

VERSION="1.0"
CONFIG_FILE="./config.config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Nie znaleziono pliku konfiugracyjnego niezbędnego do prawidłowego działania aplikacji." >&2
    exit 1
fi
source "$CONFIG_FILE"

UPDATE_WEATHER=false
while getopts ":hvlu" opt; do
    case ${opt} in
        h )
            echo "Krótka pomoc"
            exit 0
            ;;
        v )
            echo "Version: $VERSION"
            exit 0
            ;;
        l )
            read -p "Nazwa nowej lokalizacji: " LOC
            CONFIG_LOCATION=${LOC// /+}
            sed -i "s#^CONFIG_LOCATION=.*#CONFIG_LOCATION=\"$LOC\"#" "$CONFIG_FILE"
            echo "Zapisano nową lokalizację."
            ;;
        u )
            UPDATE_WEATHER=true
            ;;
        \? )
            echo "Nieprawidłowa opcja: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

if [ "$UPDATE_WEATHER" = true ]; then
    curl "wttr.in/${CONFIG_LOCATION}"
fi
