#!/usr/bin/env bash
# requires: swaks

set -e

filename=$(realpath $0)
smtp=127.0.0.1:1025
logfile=/vagrant/access.log
prevlaunch=/vagrant/prevlaunch
x=5
y=3

if [ $(readlink /proc/[0-9]*/fd/* | grep "${filename}" | wc -l) -gt 1 ]
then
    echo 'This process has already started.'
    exit 1
fi

prevdate='.'

if [[ -f "${prevlaunch}" && $(cat "${prevlaunch}") != '' ]]
then
    prevdate=$(sed -E 's/.*\[([^:]*).*].*/\1/' "${prevlaunch}")
fi

sed -n "/${prevdate//\//\\\/}/,$ p" "${logfile}" | prevfile=${prevlaunch} rowx=${x} rowy=${y} awk '{ hos[$1] += 1; req[$7] += 1; ret[$9] += 1; if (NR==1) print "Date first:", $4, $5 } END { print "Date last:", $4, $5|"tee $prevfile"; for (i in hos) printf "IP %s is repeated %s times.\n", i, hos[i]|"sort -nk5|tail -n $rowx"; for (j in req) printf "Location %s is repeated %s times.\n", j, req[j]|"sort -nk5|tail -n $rowy"; for (k in ret) printf "Retcode %s is repeated %s times.\n", k, ret[k]|"sort -nk5|tee" }' | \
swaks --to mail@example.com --server ${smtp} --body -
