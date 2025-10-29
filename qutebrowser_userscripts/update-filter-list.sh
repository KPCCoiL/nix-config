#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq

filters="$QUTE_CONFIG_DIR/filters.txt"
additional_filters="$QUTE_CONFIG_DIR/additional-filters.txt"

curl 'https://raw.githubusercontent.com/brave/adblock-resources/master/filter_lists/list_catalog.json' \
    | jq '.[0].sources | .[] | .url' \
    > "$filters"

combined="$(cat "$filters" "$additional_filters" | jq -sc '.')"
echo "set content.blocking.adblock.lists '$combined'" >> "$QUTE_FIFO"
echo "adblock-update" >> "$QUTE_FIFO"
