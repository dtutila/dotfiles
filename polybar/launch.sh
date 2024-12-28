#!/bin/sh

DIR="$HOME/.config/polybar"
# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch the bar
#polybar -q main -c "$DIR"/config.ini &
polybar  -q minimal-hdmi -c "$DIR"/minimal.ini &
polybar  -q minimal-dp -c "$DIR"/dp.ini &