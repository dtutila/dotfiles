#!/usr/bin/env bash

# Power menu options
lock="  Lock"
logout="󰍃  Logout"
shutdown="  Shutdown"
reboot="  Reboot"
suspend="󰤄  Suspend"

# Show menu
chosen=$(echo -e "$lock\n$logout\n$suspend\n$reboot\n$shutdown" | rofi -dmenu -i -p "Power" -theme-str 'window {width: 300px;}')

case "$chosen" in
    "$lock")
        loginctl lock-session
        ;;
    "$logout")
        hyprctl dispatch exit
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
esac
