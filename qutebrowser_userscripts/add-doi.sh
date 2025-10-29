#!/usr/bin/env bash

set -e

send-command () {
    echo "$@" > "$QUTE_FIFO"
}

output=$(pubs add -D "$(pbpaste)" -d ~/Downloads/a.pdf 2>&1)
escaped=$(echo "$output" | tr '\n' ' ' | sed -E "s/'/'\"'\"'/g")
send-command "message-info '$escaped'"
