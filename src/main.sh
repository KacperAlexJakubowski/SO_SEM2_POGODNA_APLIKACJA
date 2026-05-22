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
BACKGROUNDS="../backgrounds/full_hd/"
OUTPUT="../output/wallpaper.png"

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

    # fetch weather in JSON format
    curl -s "wttr.in/${CONFIG_LOCATION}?format=j1" -o "${WEATHER_TEMP}"

    # data fetch from json
    if [ ! -f "${WEATHER_TEMP}" ]; then
        echo "Nie udało się pobrać informacji o aktualnej pogodzie w ${CONFIG_LOCATION}"
        exit 1
    fi

    echo "Pomyślnie pobrano informacje o pogodzie"

    TEMPERATURE=$(jq -r ".current_condition[0].temp_C" "${WEATHER_TEMP}")
    FEEL_TEMPERATURE=$(jq -r ".current_condition[0].FeelsLikeC" "${WEATHER_TEMP}")
    HUMIDITY=$(jq -r ".current_condition[0].humidity" "${WEATHER_TEMP}")
    OBSRV_TIME=$(jq -r ".current_condition[0].observation_time" "${WEATHER_TEMP}")
    CODE=$(jq -r ".current_condition[0].weatherCode" "${WEATHER_TEMP}")
    DSC=$(jq -r ".current_condition[0].weatherDesc[0].value" "${WEATHER_TEMP}")
    ICON_URL=$(jq -r ".current_condition[0].weatherIconUrl[0].value" "${WEATHER_TEMP}")
    WIND_SPEED=$(jq -r ".current_condition[0].windspeedKmph" "${WEATHER_TEMP}")
    COUNTRY=$(jq -r ".nearest_area[0].country[0].value" "${WEATHER_TEMP}")

    # # data fetch test
    # echo "${TEMPERATURE}"
    # echo "${FEEL_TEMPERATURE}"
    # echo "${HUMIDITY}"
    # echo "${OBSRV_TIME}"
    # echo "${CODE}"
    # echo "${DSC}"
    # echo "${ICON_URL}"
    # echo "${WIND_SPEED}"
    # echo "${COUNTRY}"
    
    # background based on returned code
    BACKGROUND="${BACKGROUNDS}/${CODE}.jpg"
    # widget icon
    curl -s "${ICON_URL}" -o "../temp/weather_icon.png"
    # widget canvas using ImageMagick
    convert -size 350x550 xc:"rgba(40, 40, 40, 0.6)" ../temp/weather_canvas.png

    # data on canvas placement - widget creation
    # # city # observation time # temperature # feels like temperature # weather description # separator
    # humidity, wind speed # icon placement
    convert ../temp/weather_canvas.png \
        -gravity North \
        \
        -font DejaVu-Sans-Bold -pointsize 26 -fill "white" \
        -annotate +0+40 "${CONFIG_LOCATION}" \
        \
        -font DejaVu-Sans -pointsize 15 -fill "#A0A0A0" \
        -annotate +0+80 "Last Update: ${OBSRV_TIME}" \
        \
        -font DejaVu-Sans-Bold -pointsize 48 -fill "white" \
        -annotate +0+250 "${TEMPERATURE}°C" \
        \
        -font DejaVu-Sans -pointsize 16 -fill "#D0D0D0" \
        -annotate +0+310 "Feels Like: ${FEEL_TEMPERATURE}°C" \
        \
        -font DejaVu-Sans -pointsize 18 -fill "white" \
        -annotate +0+355 "${DSC}" \
        \
        -font DejaVu-Sans -pointsize 12 -fill "#D0D0D0" \
        -annotate +0+390 "_________________________" \
        \
        -font DejaVu-Sans -pointsize 15 -fill "#E0E0E0" \
        -annotate +0+430 "Humidity: ${HUMIDITY}% | Wind: ${WIND_SPEED} km/h" \
        \
        ../temp/weather_icon.png -geometry +0+120 -composite \
        \
        ../temp/widget.png

        # widget on background placement
        convert "${BACKGROUND}" ../temp/widget.png \
            -gravity North \
            -geometry +0+108 \
            -composite \
            "${OUTPUT}"

        # to test
        # # wallpaper setting
        # WALLPAPER_FULL_PATH="TODO"
        # # for light mode
        # gsettings set org.gnome.desktop.background picture-uri "${WALLPAPER_FULL_PATH}"
        # # for dark mode
        # gsettings set org.gnome.desktop.background picture-uri-dark "${WALLPAPER_FULL_PATH}"


elif [[ -z "$LOC" ]]; then
    echo "Nie wybrano żadnej opcji"
    exit 1
fi