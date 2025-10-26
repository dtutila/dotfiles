#!/bin/bash

sleep 1 && swayidle -w \
  timeout 240 '1password --lock' \
  timeout 300 'swaylock -f -c 000000' \
  timeout 600 'sleep 1 &&  hyprctl dispatch dpms off' \
  resume 'hyprctl dispatch dpms on' \
  before-sleep 'sleep 1 && swaylock -f -c 000000 && 1password --lock' &
