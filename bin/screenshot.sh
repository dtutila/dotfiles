#!/bin/bash
set -euo pipefail

OUTPUT_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
FILENAME="$OUTPUT_DIR/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
mkdir -p "$OUTPUT_DIR"

#grim -g "$(slurp)" - | swappy -f - -o "$FILENAME" && wl-copy <"$FILENAME"
hyprshot -m region -z -r - | \
  satty --filename - \
    --output-filename "$FILENAME" \
    --early-exit \
    --actions-on-enter save-to-clipboard \
    --actions-on-escape save-to-file \
    --save-after-copy \
    --copy-command 'wl-copy'