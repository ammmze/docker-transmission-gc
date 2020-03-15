#!/usr/bin/env sh

if [ "${RUN_ON_START}" = true ]; then
    transmission-gc || exit 1
fi

echo "${CRON_EXPRESSION} transmission-gc" > /etc/crontabs/root
exec crond -f -d 8 > /proc/1/fd/1 2> /proc/1/fd/2
