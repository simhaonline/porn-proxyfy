#!/usr/bin/env bash
#
# porn-proxyfy
#
# Hide your traffic through TURN servers from biggest porn providers
#
# Made with some THC by DgSe95
#
# Version: 1.0

# Options
set +o xtrace

# Header
echo -e "\n`basename $0 | sed -e 's/.sh//'`\n"
echo -e "Hide your traffic through TURN servers from biggest porn providers"
echo -e "Made with some THC by DgSe95"

# Usage
if [[ $1 == '-h' || $1 == '--help' ]]; then
    echo -e "Usage: `basename $0` [--log] <filename>"
    exit 0
elif [[ $1 == '--log' ]]; then
    shift
    LOG_FILE=$1
fi

# Config
DUMPED_CONFIG_URL="https://stripchat.com/api/front/v2/config"
DUMPED_USERNAME="`curl -sSL $DUMPED_CONFIG_URL | jq -jc .config.features.webRTCOriginTurnServersConfig.iceServersTemplate.iceServers[0].username`"
DUMPED_PASSWORD="`curl -sSL $DUMPED_CONFIG_URL | jq -jc .config.features.webRTCOriginTurnServersConfig.iceServersTemplate.iceServers[0].credential`"
DUMPED_SERVERS=(`curl -sSL $DUMPED_CONFIG_URL | jq -rc .config.features.webRTCTurnServersConfig.servers[]`)
DUMPED_SERVERS_TEMPLATE="`curl -sSL $DUMPED_CONFIG_URL | jq -jc .config.features.webRTCTurnServersConfig.iceServersTemplate.iceServers[0].url | sed -e 's/turn://' | sed -e 's/?transport=udp//'`"

# generate a random number from 0 to ($1-1)
# GLOBALS: _RANDOM.
# Taken from: https://www.shell-tips.com/bash/arrays/
rand() {
    local max=$((32768 / $1 * $1))
    if (( $max > 0 )); then
        while (( (_RANDOM=$RANDOM) >= max )); do :; done
        _RANDOM=$(( _RANDOM % $1 ))
    else
        return 1
    fi
}

# shuffle an array using the rand function
# GLOBALS: _array, _RANDOM
# Taken from: https://www.shell-tips.com/bash/arrays/
shuffle() {
    local i tmp size
    size=${#_array[*]}
    for ((i=size-1; i>0; i--)); do
        if ! rand $((i+1)); then exit 1; fi
        tmp=${_array[i]} _array[i]=${_array[$_RANDOM]} _array[$_RANDOM]=$tmp
    done
}

# Randomize server array
_array=("${DUMPED_SERVERS[@]}"); shuffle ; DUMPED_SERVERS=("${_array[@]}")

# Randomize test
# echo ${DUMPED_SERVERS[0]}

# Servers
RANDOM_SERVER="`echo $DUMPED_SERVERS_TEMPLATE | sed -e 's/{server}/'${DUMPED_SERVERS[0]}'/'`"
# echo $RANDOM_SERVER

# Run with both server types (http + socks5)
echo -e "\nRunning TURN socks/http proxy on [${RANDOM_SERVER}]...\n\nPress [Ctrl + C] to exit.\n"
if [[ ! -z $LOG_FILE ]]; then
    # with logs
    ./turner/turner -server $RANDOM_SERVER -u $DUMPED_USERNAME -p $DUMPED_PASSWORD -socks5 -http | tee $LOG_FILE
else
    # without logs
    ./turner/turner -server $RANDOM_SERVER -u $DUMPED_USERNAME -p $DUMPED_PASSWORD -socks5 -http
fi
