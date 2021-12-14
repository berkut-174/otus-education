#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 [OPTIONS] {FILENAME}"
    echo "OPTIONS"
    echo -e "\t -h\t\t- Help. This screen"
    exit 1
}

if [ "$#" -lt 1 ]
then
    usage
fi

# get args
while getopts ":h" option
do
    case "${option}" in
        h)
            usage
            ;;
        \?)
            echo "Invalid option -$OPTARG"
            usage
            ;;
        :)
            echo "Option -$OPTARG has no argument"
            usage
            ;;
    esac
done

# get resolved path
name=$(realpath "$1")

if [ ! -e "${name}" ]
then
    echo "File '${name}' not found."
    usage
fi

while IFS= read -r process
do
    # test access
    test -r "${process}/cwd" || continue
    # print head
    if [ -z "${head}" ]
    then
        printf "COMMAND|PID|USER|FD|TYPE|DEVICE|SIZE/OFF|NODE|NAME\n"
        head=1
    fi
    # get descriptor
    fd=$(ls -l "${process}/fd" | awk -v name="${name}" '$11 ~ name { print $9 }')
    # output
    if [[ -n "${fd}" || "$(readlink ${process}/cwd)" == "${name}" ]]
    then
        comm=$(cat "${process}/comm")
        pid=$(basename "${process}")
        uid=$(awk '/Uid/ {print $2}' "${process}/status")
        user=$(getent passwd "${uid}" | cut -d: -f1)
        fd=${fd:-cwd}
        type=$(stat -c %F "${name}")
        device=$(stat -c %d "${name}")
        size=$(stat -c %s "${name}")
        node=$(stat -c %i "${name}")
        printf "${comm}|${pid}|${user}|${fd}|${type}|${device}|${size}|${node}|$1\n"
    fi
done <<< $(ls -d /proc/[0-9]*) | column -t -s '|'
