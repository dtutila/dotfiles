#!/bin/bash
set -euo pipefail

OUTPUT_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
FILENAME="$OUTPUT_DIR/screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
mkdir -p "$OUTPUT_DIR"

hyprshot -m region -z -r - | \
  swappy --file - --output-file "$FILENAME" \
  && wl-copy <"$FILENAME"
