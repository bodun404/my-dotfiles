#!/bin/bash
# Тег дозволяє Dunst замінювати старе сповіщення новим, а не спамити ними
tag="sys_notify"

case $1 in
    vol_up)
        pamixer -i 5
        vol=$(pamixer --get-volume)
        notify-send -h string:x-dunst-stack-tag:$tag -a "Volume" "Volume󰕾 +: $vol%" -h int:value:$vol
        ;;
    vol_down)
        pamixer -d 5
        vol=$(pamixer --get-volume)
        notify-send -h string:x-dunst-stack-tag:$tag -a "Volume" "Volume󰕾 -: $vol%" -h int:value:$vol
        ;;
    vol_mute)
        pamixer -t
        status=$(pamixer --get-mute | grep -q "true" && echo "Mute 󰝟" || echo "Unmute 󰕾")
        notify-send -h string:x-dunst-stack-tag:$tag -a "Audio" "Sound: $status"
        ;;
    mic_mute)
        pamixer --default-source -t
        status=$(pamixer --default-source --get-mute | grep -q "true" && echo "Muted 󰍭" || echo "Live 󰍬")
        notify-send -h string:x-dunst-stack-tag:$tag -a "Microphone" "Mic: $status"
        ;;
    bright_up)
        brightnessctl set +10%
        level=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
        notify-send -h string:x-dunst-stack-tag:$tag -a "Brightness" "Brightness: $level%" -h int:value:$level
        ;;
    bright_down)
        brightnessctl set 10%-
        level=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
        notify-send -h string:x-dunst-stack-tag:$tag -a "Brightness" "Brightness: $level%" -h int:value:$level
        ;;
esac
