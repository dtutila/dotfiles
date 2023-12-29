#!/bin/sh
xrandr --output HDMI-0 --right-of DP-4 &
# xrandr --output DP-4 --right-of HDMI-0 &

#lxsession &

nm-applet &

#lxpolkit & # Graphical authentication agent

# background
feh --bg-scale ~/.config/wallpappers/waves-at-dawn.jpg &

# compositor
picom --config ~/.config/picom/picom.conf3 &
#picom &
#picom --experimental-backends --backend glx &
#picom --backend xr_glx_hybrid &
#picom --experimental-backends --backend glx --config ~/.config/picom/picom.conf &
# sxhkd
sxhkd -c ~/.config/qtile/sxhkd/sxhkdrc &

# Notifications
dunst &

playerctld &

flameshot &

pcloud &

blueman-applet &

#1password &
