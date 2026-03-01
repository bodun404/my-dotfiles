#!/bin/bash
#Check ethernet status
#We seek any interface name that begins with "e" and have "up" status
ETH_STATUS=$(cat /sys/class/net/e*/operstate 2>/dev/null)

if [ "$ETH_STATUS" = "up" ]; then
        #if ethernet connected: icon + ETHERNET
        echo " ETHERNET"
else
        #if ethernet disconected we seek for WIFI name
        WIFI_NAME=$(iwgetid -r)
        if [ -n "$WIFI_NAME" ]; then
                #if wifi connected: icon + WIFI name
                echo " $WIFI_NAME"
        else
                #if nothing is connected
                echo " OFFLINE"
        fi
fi
