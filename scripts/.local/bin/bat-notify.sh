#!/bin/bash

# Налаштування рівнів
critical_level=5
low_level=20
full_level=85 # ThinkPad часто обмежує заряд для збереження ресурсу акумулятора

# Початкові стани
prev_status=$(cat /sys/class/power_supply/BAT0/status)
prev_capacity=$(cat /sys/class/power_supply/BAT0/capacity)

while true; do
    status=$(cat /sys/class/power_supply/BAT0/status)
    capacity=$(cat /sys/class/power_supply/BAT0/capacity)

    # 1. Сповіщення про підключення/відключення мережі (AC Adapter)
    # Перевіряємо статус мережевого адаптера (1 - підключено, 0 - ні)
	ac_online=$(cat /sys/class/power_supply/AC/online)

	if [[ "$ac_online" -eq 1 && "$prev_ac" -eq 0 ]]; then
    		notify-send -u low -a "Power" -i "battery-charging" " AC Connected" "Battery: $capacity%"
   		 prev_ac=1
	elif [[ "$ac_online" -eq 0 && "$prev_ac" -eq 1 ]]; then
   		 notify-send -u normal -a "Power" -i "battery-caution" "󱧥 AC Disconnected" "Battery: $capacity%"
	 prev_ac=0
	fi
    # 2. Динамічні сповіщення при розряді (кожні 10%)
    if [[ "$status" == "Discharging" && "$capacity" != "$prev_capacity" ]]; then
        if [[ $((capacity % 10)) -eq 0 ]]; then
            notify-send -u normal -a "Power" " Charge level" "Remains $capacity%"
        fi
    fi

    #3. Critical level of charge
    if [[ "$status" == "Discharging" && "$capacity" -le "$critical_level" && "$capacity" != "$prev_capacity" ]]; then
        notify-send -u critical -a "Power" " Critical charge" "Remains only $capacity%!"
    fi

    prev_capacity=$capacity
    sleep 5 #Оптимальний інтервал для ThinkPad, щоб не навантажувати CPU
done
