#!/usr/bin/env sh

set -euf -o pipefail

TRANSMISSION_URL="${TRANSMISSION_URL}"
TRANSMISSION_RPC_PATH="${TRANSMISSION_RPC_PATH:-/transmission/rpc}"
SESSION_ID=
IS_VERBOSE=${VERBOSE:-false}
IS_DRY_RUN=${DRY_RUN:-false}
DELETE_DATA=${DELETE_DATA:-true}
SEARCH='
{
    "method":"torrent-get",
    "arguments":{
        "fields":[
            "id",
            "addedDate",
            "name",
            "totalSize",
            "error",
            "errorString",
            "eta",
            "isFinished",
            "isStalled",
            "leftUntilDone",
            "metadataPercentComplete",
            "peersConnected",
            "peersGettingFromUs",
            "peersSendingToUs",
            "percentDone",
            "queuePosition",
            "rateDownload",
            "rateUpload",
            "recheckProgress",
            "seedRatioMode",
            "seedRatioLimit",
            "sizeWhenDone",
            "status",
            "trackers",
            "downloadDir",
            "uploadedEver",
            "uploadRatio",
            "webseedsSendingToUs"
        ]
    }
}
'

function rpc {
    local user
    if [ -n "${TRANSMISSION_USERNAME}" ]; then
        user="--user ${TRANSMISSION_USERNAME}:${TRANSMISSION_PASSWORD}"
    fi
    curl --silent --netrc-optional \
         --request POST \
         --http1.1 \
         ${user} \
         --header "Content-Type: application/json" \
         --header "Accept: application/json" \
         --header "X-Transmission-Session-Id: ${SESSION_ID}" \
         "${TRANSMISSION_URL}${TRANSMISSION_RPC_PATH}" \
         "$@"
}

function remove_by_id {
    id=${1}
    echo removing $id
}

verbose() {
  if [ "$IS_VERBOSE" = true ]; then
    "$@"
    return $?
  else
    "$@" > /dev/null 2>&1
    return $?
  fi
}

do_garbage_collection() {
    SESSION_ID=$(rpc --verbose --data '{"method":"session-get"}' 2>&1 | awk 'BEGIN {IGNORECASE=1;FS=": "}/^< x-transmission-session-id/{print $2}')

    if [ -z "${SESSION_ID}" ]; then
        echo 'Could not get session id. Please verify the url and credentials are correct'
        exit 1
    fi

    torrents=$(rpc --data "${SEARCH}" | jq '.arguments.torrents')

    verbose echo -e "Found the following torrents: ${torrents}\n"

    torrents_to_remove=$(echo "$torrents" | jq '[.[] | select(.isFinished == true)]')
    names_to_remove=$(echo "$torrents_to_remove" | jq -r '.[].name')

    if [ -n "$names_to_remove" ]; then
        verbose echo -e "Found the following torrents to remove: ${torrents_to_remove}\n"

        echo "Found the following finished downloads:"
        echo "$names_to_remove"
        echo

        remove_payload=$(echo "$torrents_to_remove" | jq '[.[] | .id] | {"method":"torrent-remove", "arguments": {"ids": ., "delete-local-data": '"${DELETE_DATA}"'}}')
        verbose echo $remove_payload
        if [ "$IS_DRY_RUN" = false ]; then
            rpc --data "$remove_payload" | jq
        else
            echo "Dry Run. Skipping RPC call to remove items."
        fi
    else
        echo "No finished downloads"
    fi
}

do_garbage_collection
