#!/usr/bin/env bash
#
# porn-proxyfy
#
# Hide your traffic through TURN servers from biggest porn providers
#
# Made with some THC by DgSe95
#
# Version: 1.2

# Options
set +o xtrace

# Header
echo -e "\n`basename $0 | sed -e 's/.sh//'`\n"
echo -e "Hide your traffic through TURN servers from biggest porn providers"
echo -e "Made with some THC by DgSe95"

# Usage / arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo -e "\nUsage: `basename $0` [options]\n"
            echo -e "   -l --log    <filename>   - Send output to log file"
            echo -e "   -p --provider   <name>   - Select service provider [stripchat,lovense]\n"
            exit 0
        ;;
        -l|--log) LOG_FILE="$2"; shift ;;
        -p|--provider) PROVIDER="$2"; shift ;;
        *) echo -e "\nUnknown given parameter: ${1}\n"; exit 1 ;;
    esac
    shift
done

# Provider display
if [[ ! -z $PROVIDER ]]; then
    echo -e "\nSelected provider: ${PROVIDER}"
fi

# guess what is it :P
d82() {
    STEP1=$(tr 'A-Za-z0-9' 'N-ZA-Mn-za-m5-90-4' <<< $@)
    STEP2=$(echo -n $STEP1 | base64 -d)
    echo -n $STEP2
}

# Config
SC_CONFIG_URL=`d82 nUE5pUZ1Yl4mqUWcpTAbLKDhL74gY7SjnF4zpz4hqP47Zv4wo70znJpX`
SC_USERNAME=`curl -sSL $SC_CONFIG_URL | jq -jc .config.features.webRTCTurnServersConfig.iceServersTemplate.iceServers[0].username`
SC_PASSWORD=`curl -sSL $SC_CONFIG_URL | jq -jc .config.features.webRTCTurnServersConfig.iceServersTemplate.iceServers[0].credential`
SC_SERVERS=(`curl -sSL $SC_CONFIG_URL | jq -rc .config.features.webRTCTurnServersConfig.servers[]`)
SC_SERVERS_TOTAL=`curl -sSL $SC_CONFIG_URL | jq -rc .config.features.webRTCTurnServersConfig.servers[] | wc -l`
SC_SERVERS_TEMPLATE=`curl -sSL $SC_CONFIG_URL | jq -jc .config.features.webRTCTurnServersConfig.iceServersTemplate.iceServers[0].url | sed -e 's/turn://' | sed -e 's/?transport=udp//'`
LV_SERVER=`d82 p8E6ov0fo8MyoaAyYzAioGbmAQp9Pt==`
LV_USERNAME=`d82 ETShLJEgnJ9X`
LV_PASSWORD=`d82 ETShLJEgnJ9lZQR9Pt==`

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
_array=("${SC_SERVERS[@]}"); shuffle ; SC_SERVERS=("${_array[@]}")

# Randomize test
# echo ${SC_SERVERS[0]}

# Servers
RANDOM_SERVER="`echo $SC_SERVERS_TEMPLATE | sed -e 's/{server}/'${SC_SERVERS[0]}'/'`"
# echo $RANDOM_SERVER

# Run with both server types (http + socks5)
if [[ -z $PROVIDER ]]; then
    # TODO: Merge all servers together

    echo -e "\nServers found: ${SC_SERVERS_TOTAL}\nRunning TURN socks/http proxy on [${RANDOM_SERVER}]...\n\nPress [Ctrl + C] to exit.\n"
    if [[ ! -z $LOG_FILE ]]; then
        # with logs
        ./turner/turner -server $RANDOM_SERVER -u $SC_USERNAME -p $SC_PASSWORD -socks5 -http | tee $LOG_FILE
    else
        # without logs
        ./turner/turner -server $RANDOM_SERVER -u $SC_USERNAME -p $SC_PASSWORD -socks5 -http
    fi
else
    case $PROVIDER in
        stripchat)
            echo -e "\nServers found: ${SC_SERVERS_TOTAL}\nRunning TURN socks/http proxy on [${RANDOM_SERVER}]...\n\nPress [Ctrl + C] to exit.\n"
            if [[ ! -z $LOG_FILE ]]; then
                # with logs
                ./turner/turner -server $RANDOM_SERVER -u $SC_USERNAME -p $SC_PASSWORD -socks5 -http | tee $LOG_FILE
            else
                # without logs
                ./turner/turner -server $RANDOM_SERVER -u $SC_USERNAME -p $SC_PASSWORD -socks5 -http
            fi
        ;;
        lovense)
            echo -e "\nServers found: 1\nRunning TURN socks/http proxy on [$LV_SERVER]...\n\nPress [Ctrl + C] to exit.\n"
            if [[ ! -z $LOG_FILE ]]; then
                # with logs
                ./turner/turner -server $LV_SERVER -u $LV_USERNAME -p $LV_PASSWORD -socks5 -http | tee $LOG_FILE
            else
                # without logs
                ./turner/turner -server $LV_SERVER -u $LV_USERNAME -p $LV_PASSWORD -socks5 -http
            fi
        ;;
        *) echo -e "\nUnknown given provider: ${PROVIDER}\n"; exit 1 ;;
    esac
fi
