#!/usr/bin/env bash

set -e

send-command () {
    echo "$@" > "$QUTE_FIFO"
}

id=$(echo "$QUTE_URL" | sed -E 's!^https://arxiv.org/abs/(.+)$!\1!')

if [[ -z "$id" ]]; then
    send-command "message-error 'Not an arXiv article'"
    exit 1
fi

mkdir -p "$TMPDIR/articles"
article="$TMPDIR/articles/article.pdf"
curl -L "https://arxiv.org/pdf/$id.pdf" > "$article"

output=$(pubs add -X "$id" -d "$article" 2>&1)
escaped=$(echo "$output" | tr '\n' ' ' | sed -E "s/'/'\"'\"'/g")
send-command "message-info '$escaped'"
