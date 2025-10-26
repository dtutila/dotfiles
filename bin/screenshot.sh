#!/bin/bash
OUTPUT_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures/Screenshots}"
FILENAME="$OUTPUT_DIR/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
grim -g "$(slurp)" - | swappy -f - -o "$FILENAME" && wl-copy <"$FILENAME"
