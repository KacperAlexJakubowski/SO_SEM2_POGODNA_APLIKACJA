#!/bin/bash
# Author           : Kacper Jakubowski ( s208525@pg.edu.pl )
# Created On       : 08.05.2026
# Last Modified On : 22.05.2026 
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
CONFIG_FILE="../settings.config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Nie znaleziono pliku konfiugracyjnego niezbędnego do prawidłowego działania aplikacji." >&2
    exit 1
fi
source "$CONFIG_FILE"

LOC=""
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
            echo "Zapisano nową lokalizację"
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
    WEATHER_TEMP="../temp/weather.json"
    BACKGROUNDS="../backgrounds/"
    OUTPUT="../output/output.jpg"

    # fetch weather in JSON format
    curl "wttr.in/${CONFIG_LOCATION}?format=j1" > "${WEATHER_TEMP}"

    # data fetch from json
    if [ ! -f "${WEATHER_TEMP}" ]; then
        echo "Nie udało się pobrać informacji o aktualnej pogodzie w ${CONFIG_LOCATION}"
        exit 1
    fi

    echo "Pomyślnie pobrano informacje o pogodzie"

    TEMPERATURE=$(jq -r ".current_condition[0].temp_C" "${WEATHER_TEMP}")
    FEEL_TEMPERATURE=$(jq -r ".current_condition[0].FeelsLikeC" "${WEATHER_TEMP}")
    HUMIDITY=$(jq -r ".current_condition[0].humidity" "${WEATHER_TEMP}")
    OBSV_TIME=$(jq -r ".current_condition[0].observation_time" "${WEATHER_TEMP}")
    CODE=$(jq -r ".current_condition[0].weatherCode" "${WEATHER_TEMP}")
    DSC=$(jq -r ".current_condition[0].weatherDesc[0].value" "${WEATHER_TEMP}")
    ICON=$(jq -r ".current_condition[0].weatherIconUrl[0].value" "${WEATHER_TEMP}")
    WIND_SPEED=$(jq -r ".current_condition[0].windspeedKmph" "${WEATHER_TEMP}")
    COUNTRY=$(jq -r ".nearest_area[0].country[0].value" "${WEATHER_TEMP}")

    # # data fetch test
    # echo "${TEMPERATURE}"
    # echo "${FEEL_TEMPERATURE}"
    # echo "${HUMIDITY}"
    # echo "${OBSV_TIME}"
    # echo "${CODE}"
    # echo "${DSC}"
    # echo "${ICON}"
    # echo "${WIND_SPEED}"
    # echo "${COUNTRY}"

    BACKGROUND="${BACKGROUNDS}/${CODE}.jpg"

    

elif [[ -z "$LOC" ]]; then
    echo "Nie wybrano żadnej opcji"
    exit 1
fi