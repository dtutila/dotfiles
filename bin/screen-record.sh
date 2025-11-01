#!/bin/bash
OUTPUT_DIR="${XDG_VIDEOS_DIR:-$HOME/Videos}"

screenrecording() {
  filename="$OUTPUT_DIR/screenrecording-$(date +'%Y-%m-%d_%H-%M-%S').mp4"
  notify-send "Screen recording starting..." -t 1000
  sleep 1
#  wl-screenrec -f "$filename" --ffmpeg-encoder-options="-c:v libx264 -vaapi_device /dev/dri/renderD128 -hwaccel vaapi " "$@"
# wl-screenrec -f "$filename" --ffmpeg-encoder-options="-c:v h264_amf" "$@"
# wl-screenrec -f "$filename" --ffmpeg-encoder-options="-c:v av1_amf" "$@"
# wl-screenrec -f "$filename" --ffmpeg-encoder-options="-c:v libx264" "$@"
# wl-screenrec -f "$filename" --ffmpeg-encoder-options="-c:v h264_vaapi -profile:v baseline -vaapi_device /dev/dri/renderD128" "$@"

#  wf-recorder -f "$filename" --audio=Combined.monitor -c libx264 -p crf=23 -p preset=medium -p movflags=+faststart "$@"
wf-recorder \
  -g "$(slurp)" \
  -f ~/Videos/record_$(date +%F_%H-%M-%S).mp4 \
  --audio=alsa_output.usb-0b0e_Jabra_Link_380_50C275C5D049-00.analog-stereo.monitor \
  --audio=alsa_input.usb-0b0e_Jabra_Link_380_50C275C5D049-00.mono-fallback
}

if pgrep -x wl-recorder >/dev/null; then
  pkill -x wl-recorder
  notify-send "Screen recording saved to $OUTPUT_DIR" -t 2000
elif [[ "$1" == "output" ]]; then
  screenrecording
else
  screenrecording 
fi
