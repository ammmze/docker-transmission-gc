FROM alpine:edge

RUN apk add --no-cache transmission-cli curl jq

COPY entrypoint.sh /usr/local/bin/
COPY transmission-gc.sh /usr/local/bin/transmission-gc

ENV TRANSMISSION_URL=http://transmission:9091 \
    TRANSMISSION_USERNAME= \
    TRANSMISSION_PASSWORD= \
    CRON_EXPRESSION='0 * * * *' \
    RUN_ON_START=true \
    VERBOSE=false \
    DELETE_DATA=true

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
