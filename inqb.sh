#!/bin/bash
# version 2

grp="$1"
sstring="$2"
debug="$3"

if [[ -n "$debug" ]]; then
    set -x
fi

stype="phrase"

main() {
    reset='\033[0m'
    green='\033[32m'
    blue='\033[34m'
    red='\033[31m'

    echo -e "${green}Group to search: ${grp}${reset}"
    echo -e "${green}Search string: ${sstring}${reset}"

    source_file="source/all-indexes.xml"
    info2="on"

    if [[ ! -f "$source_file" ]]; then
        echo -e "${red}all-indexes.xml not found in 'source' folder! Can't complete search. Will exit in 20 seconds.${reset}"
        sleep 20
        exit 1
    fi

    safestring="${sstring//\?/_}"
    htmlfile="$(pwd)/output/${stype}-${grp}-${safestring}.html"

    timeout_secs=60

    mkdir -p output
    rm -f "$htmlfile"

    # end setup
    searchpresent2

    if command -v google-chrome >/dev/null 2>&1; then
        echo -e "${blue}google-chrome \"$htmlfile\"${reset}"
        google-chrome "$htmlfile" &
    elif command -v chromium-browser >/dev/null 2>&1; then
        echo -e "${blue}chromium-browser \"$htmlfile\"${reset}"
        chromium-browser "$htmlfile" &
    elif command -v microsoft-edge >/dev/null 2>&1; then
        echo -e "${blue}microsoft-edge \"$htmlfile\"${reset}"
        microsoft-edge "$htmlfile" &
    else
        echo "No supported browser found."
    fi

    status=$?
    if [[ $status -eq 1 ]]; then
        read -p "Press Enter to continue..."
    fi

    sleep "$timeout_secs"
}

searchpresent2() {
    echo -e "${blue}xslt3-he -xsl:search-present-target-js.sef.json -s:source/all-indexes.xml -o:${htmlfile} target=\"${grp}\" searchword=\"${sstring}\"${reset}"

    xslt3-he \
        -xsl:search-present-target-js.sef.json \
        -s:source/all-indexes.xml \
        -o:"${htmlfile}" \
        target="${grp}" \
        searchword="${sstring}"
}

main