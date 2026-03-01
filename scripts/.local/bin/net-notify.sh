#!/bin/bash
nmcli monitor | while read -r line; do
    if echo "$line" | grep -q "connectivity: full"; then
        type=$(nmcli -t -f TYPE,STATE dev | grep "connected" | cut -d: -f1 | head -n1)
        notify-send -u low -a "Network" "Connected 󰌘" "Type: ${type^^}"
    elif echo "$line" | grep -q "connectivity: none"; then
        notify-send -u critical -a "Network" "Disconnected 󰲛" "You offline"
    fi
done
