#!/bin/bash

#--- Settings ---
TERM="alacritty --class floating_sys"

#Files for slstatus(placed in RAM /tmp)
CAFFEINE_FILE="/tmp/slstatus_caffeine"
POMO_FILE="/tmp/slstatus_pomodoro"
POMO_PID="/tmp/pomodoro_pid"

DMENU_CMD="dmenu -b -i -nb #1a1b26 -nf #a9b1d6 -sb #50fa7b -sf #1a1b26"

#main function of menu
run_menu() {
    # -b : menu placed on bottom
    # -i : disable registry check
    # -p : prompt
    $DMENU_CMD -p "$1"
}

#Function for notification
notify() {
    notify-send -a "SystemControl" "$1" "$2"
}

#--- Pomodoro Timer Logic Function ---
start_timer() {
    target_min=$1
    end_msg=$2
    
    #Killing old timer
    if [ -f "$POMO_PID" ]; then
        kill "$(cat "$POMO_PID")" 2>/dev/null
    fi

    #Notification about timer start
    notify "Pomodoro" "⏳Begin: ${target_min} min"

    #Timer start
    #Ми передаємо код в одинарних лапках (bash його не чіпає),
    #а змінні передаємо в кінці після --. Це гарантує відсутність помилок синтаксису.
    nohup bash -c '
        minutes=$1
        msg=$2
        pid_file=$3
        status_file=$4
        
        echo $$ > "$pid_file"
        seconds=$((minutes * 60))
        
        while [ $seconds -gt 0 ]; do
            m=$((seconds / 60))
            s=$((seconds % 60))
            # Записуємо у файл
            printf "  %d:%02d " $m $s > "$status_file"
            sleep 1
            ((seconds--))
        done
        
        #Clear and finish
        rm -f "$status_file" "$pid_file"
        notify-send -u critical "Pomodoro" "$msg"
    ' -- "$target_min" "$end_msg" "$POMO_PID" "$POMO_FILE" >/dev/null 2>&1 &
}
#--- SubMenu ---

menu_dunst() {
    is_paused=$(dunstctl is-paused)
    if [ "$is_paused" == "true" ]; then status="[ON]"; else status="[OFF]"; fi

    opts="🚫 DND $status\n📜 History\n🧹 Close All\n Back"
    
    selected=$(echo -e "$opts" | run_menu "Notify:")

    case "$selected" in
        *"DND"*)      dunstctl set-paused toggle ;;
        *"History"*)  dunstctl history-pop ;;
        *"Close"*)    dunstctl close-all ;;
        *"Back"*)     exec "$0" ;;
    esac
}

menu_power() {
    opts=" Game(AC)\n Save(BAT)\n⚡ Auto\nℹ️ Stat(SYS)\ni Stat(BAT)\n Back"
    
    selected=$(echo -e "$opts" | run_menu "Power:")

    case "$selected" in
        *"Game"*) pkexec tlp ac && notify "Power" " Game Mode (AC Force)" ;;
        *"Save"*) pkexec tlp bat && notify "Power" " Battery Saver (BAT Force)" ;;
        *"Auto"*) pkexec tlp start && notify "Power" "⚡ TLP Auto Mode" ;;
        *"Stat(SYS)"*) $TERM -e bash -c "sudo tlp-stat -s; echo; read -p 'Press Enter to close...'" ;;
        *"Stat(BAT)"*) $TERM -e bash -c "sudo tlp-stat -b; echo; read -p 'Press Enter to close'" ;; 
	*"Back"*) exec "$0" ;;
    esac
}

menu_pomodoro() {
    opts=" 25m(Work)\n🧠 50m(Deep)\n☕ 5m(Short)\n 15m(Long)\n󱫪 Stop\n Back"
    selected=$(echo -e "$opts" | run_menu "Pomodoro:")

    case "$selected" in
	*"15m"*)  start_timer 15 " Back to work!" ;;
        *"25m"*)  start_timer 25 " Time for a break!" ;;
        *"50m"*)  start_timer 50 "🧠Deep work done!" ;;
        *"5m"*)   start_timer 5 "☕Break over!" ;;
        *"Stop"*)
	 [ -f "$POMO_PID" ] && kill "$(cat "$POMO_PID")" && rm "$POMO_FILE" "$POMO_PID"
	 notify "Pomodoro" "󱫪 Stopped."
	 ;;
        *"Back"*) exec "$0" ;;
    esac
}

toggle_caffeine() {
#Check for status-file 
	if [ -f "$CAFFEINE_FILE" ]; then
		xset s on +dpms
		rm "$CAFFEINE_FILE"
		notify "󰒲 Caffone" "OFF(Normal sleep)"
	else
		xset s off -dpms
		echo " 󰒳 " > "$CAFFEINE_FILE"
		notify "󰒳 Caffeine" "ON(No sleep)"
	fi
}

menu_nightlight() {
    #Check status
    if pgrep -x "gammastep" > /dev/null; then status="[ON]"; else status="[OFF]"; fi

    #Options
    opts="🕒 Auto Mode (Sunset/Sunrise)\n🔥 Very Warm (2500K)\n☀️ Warm (3500K)\n⛅ Neutral (4500K)\n💡 Bright (5500K)\n🌑 Turn OFF\n Back"
    
    selected=$(echo -e "$opts" | run_menu "Night Light $status:")

    #Kyiv/Fastiv coordinates
    LAT="50.08"
    LON="29.91"

    case "$selected" in
        *"Auto"*)
            pkill -x gammastep
            #Standart: day cold night warm
            gammastep -l $LAT:$LON &
            notify "Night Light" "🕒 Auto Mode (Schedule)"
            ;;
        *"2500K"*)
            pkill -x gammastep
            # -t DAY:NIGHT (same) -r (now)
            gammastep -l $LAT:$LON -t 2500:2500 -r &
            notify "Night Light" "🔥 Set to 2500K"
            ;;
        *"3500K"*)
            pkill -x gammastep
            gammastep -l $LAT:$LON -t 3500:3500 -r &
            notify "Night Light" "☀️ Set to 3500K"
            ;;
        *"4500K"*)
            pkill -x gammastep
            gammastep -l $LAT:$LON -t 4500:4500 -r &
            notify "Night Light" "⛅ Set to 4500K"
            ;;
        *"5500K"*)
            pkill -x gammastep
            gammastep -l $LAT:$LON -t 5500:5500 -r &
            notify "Night Light" "💡 Set to 5500K"
            ;;
        *"OFF"*)
            pkill -x gammastep
            # -x force restart to X11 colors
            gammastep -x 
            notify "Night Light" "🌑 OFF (Reset)"
            ;;
        *"Back"*)
            exec "$0"
            ;;
    esac
}

menu_sys_power() {
    opts=" Lock Screen\n󰤄 Suspend\n🚪 Logout (DWM)\n🔁 Reboot\n Shutdown\n UEFI Firmware\n Back"
    selected=$(echo -e "$opts" | run_menu "System Power:")

    case "$selected" in
        *"Lock"*)     $LOCKER ;;
        *"Suspend"*)  $LOCKER && systemctl suspend ;; # Блокуємо перед сном
        *"Logout"*)   pkill dwm || pkill -u $USER dwm ;; # Вбиваємо dwm для виходу
        *"Reboot"*)   systemctl reboot ;;
        *"Shutdown"*) systemctl poweroff ;;
        *"UEFI"*)     systemctl reboot --firmware-setup ;;
        *"Back"*)     exec "$0" ;;
    esac
}
#--- Main menu ---


options="🛑 Menu\n🎧 Audio\n🌐 Net\n Bluetooth\n Pomodoro\n🔋 Power\n Calendar\n🔔 Notify\n☕ Caffeine\n🗑️ Trash\n✈️ Airplane\n🌙 Night"

choice=$(echo -e "$options" | run_menu "System:")

case "$choice" in
    *"Menu"*)     menu_sys_power ;;
    *"Audio"*)    $TERM -t 'sys-pulsemixer' -e pulsemixer ;;
    *"Net"*)      $TERM -t 'sys-nmtui' -e nmtui ;;
    *"Bluetooth"*) $TERM -e bluetuith ;;
    *"Pomodoro"*) menu_pomodoro ;;
    *"Power"*)    menu_power ;;
    *"Calendar"*) $TERM -e bash -c "cal; echo; read -p 'Press Enter to close...'" ;;
    *"Notify"*)   menu_dunst ;;
    *"Caffeine"*) toggle_caffeine ;;
    *"Trash"*)    trash-empty && notify "Trash" "🗑️ Emptied" ;;
    *"Airplane"*) rfkill toggle all && notify "System" "✈️ Airplane toggled" ;;
    *"Night"*)    menu_nightlight ;;
esac
