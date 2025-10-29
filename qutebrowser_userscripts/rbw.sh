#! /usr/bin/env nix
#! nix shell nixpkgs#choose-gui --command sh

function fakekey {
    echo "$1" | sed -E 's/(.)/\1\n/g' | while read key; do
        if [ "x$key" = 'x' ]; then
            continue
        fi
        echo "fake-key \\$key" >> "$QUTE_FIFO"
    done
}

set -e
entry=$(rbw list | choose)
fakekey "$(rbw get "$entry")"
