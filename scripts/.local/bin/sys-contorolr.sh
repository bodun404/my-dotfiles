#!/bin/bash

# --- Налаштування ---
TERM="alacritty --class floating_sys"
CAFFEINE_FILE="/tmp/slstatus_caffeine"
POMO_FILE="/tmp/slstatus_pomodoro"
POMO_PID="/tmp/pomodoro_pid"

# Команда Rofi
ROFI_CMD="rofi -dmenu -i"

# --- Основні функції ---

notify() {
    notify-send -a "SystemControl" "$1" "$2"
}

start_timer() {
    target_min=$1
    end_msg=$2
    [ -f "$POMO_PID" ] && kill "$(cat "$POMO_PID")" 2>/dev/null
    notify "Pomodoro" "⏳ Початок: ${target_min} хв"
    nohup bash -c '
        minutes=$1; msg=$2; pid_file=$3; status_file=$4
        echo $$ > "$pid_file"
        seconds=$((minutes * 60))
        while [ $seconds -gt 0 ]; do
            m=$((seconds / 60)); s=$((seconds % 60))
            printf "  %d:%02d " $m $s > "$status_file"
            sleep 1; ((seconds--))
        done
        rm -f "$status_file" "$pid_file"
        notify-send -u critical "Pomodoro" "$msg"
    ' -- "$target_min" "$end_msg" "$POMO_PID" "$POMO_FILE" >/dev/null 2>&1 &
}

# --- Підменю ---

menu_sys_power() {
    opts=" Lock\n󰤄 Suspend\n🚪 Logout\n🔁 Reboot\n Shutdown\n Назад"
    selected=$(echo -e "$opts" | $ROFI_CMD -p "Система")
    case "$selected" in
        *"Lock"*)     slock ;; 
        *"Suspend"*)  systemctl suspend ;;
        *"Logout"*)   pkill dwm ;;
        *"Reboot"*)   systemctl reboot ;;
        *"Shutdown"*) systemctl poweroff ;;
        *"Назад"*)    main_menu ;;
    esac
}

menu_power() {
    opts=" Game(AC)\n Save(BAT)\n⚡ Auto\nℹ️ Stat(SYS)\ni Stat(BAT)\n Назад"
    selected=$(echo -e "$opts" | $ROFI_CMD -p "Живлення")
    case "$selected" in
        *"Game"*) pkexec tlp ac && notify "Power" " Game Mode" ;;
        *"Save"*) pkexec tlp bat && notify "Power" " Battery Saver" ;;
        *"Auto"*) pkexec tlp start && notify "Power" "⚡ TLP Auto" ;;
        *"Stat(SYS)"*) $TERM -e bash -c "sudo tlp-stat -s; read -p 'Enter...'" ;;
        *"Назад"*)   main_menu ;;
    esac
}

menu_pomodoro() {
    opts=" 25m(Work)\n🧠 50m(Deep)\n☕ 5m(Short)\n 15m(Long)\n󱫪 Stop\n Назад"
    selected=$(echo -e "$opts" | $ROFI_CMD -p "Pomodoro")
    case "$selected" in
        *"15m"*)  start_timer 15 " Повертайся до роботи!" ;;
        *"25m"*)  start_timer 25 " Час відпочити!" ;;
        *"50m"*)  start_timer 50 "🧠 Глибока праця завершена!" ;;
        *"5m"*)   start_timer 5 "☕ Перерва закінчилася!" ;;
        *"Stop"*) [ -f "$POMO_PID" ] && kill "$(cat "$POMO_PID")" && rm "$POMO_FILE" "$POMO_PID"
                  notify "Pomodoro" "󱫪 Зупинено." ;;
        *"Назад"*) main_menu ;;
    esac
}

toggle_caffeine() {
    if [ -f "$CAFFEINE_FILE" ]; then
        xset s on +dpms; rm "$CAFFEINE_FILE"
        notify "󰒲 Caffeine" "OFF"
    else
        xset s off -dpms; echo " 󰒳 " > "$CAFFEINE_FILE"
        notify "󰒳 Caffeine" "ON"
    fi
}

# --- Головне меню ---

main_menu() {
    options="🛑 System\n🎧 Audio\n🌐 Net\n Bluetooth\n Pomodoro\n🔋 Power\n Calendar\n☕ Caffeine\n🗑️ Trash\n✈️ Airplane"
    choice=$(echo -e "$options" | $ROFI_CMD -p "Керування")

    case "$choice" in
        *"System"*)    menu_sys_power ;;
        *"Audio"*)     $TERM -t 'sys-pulsemixer' -e pulsemixer ;;
        *"Net"*)       $TERM -t 'sys-nmtui' -e nmtui ;;
        *"Bluetooth"*) $TERM -e bluetuith ;;
        *"Pomodoro"*)  menu_pomodoro ;;
        *"Power"*)     menu_power ;;
        *"Calendar"*)  $TERM -e bash -c "cal; echo; read -p 'Enter...'" ;;
        *"Caffeine"*)  toggle_caffeine ;;
        *"Trash"*)     trash-empty && notify "Trash" "🗑️ Очищено" ;;
        *"Airplane"*)  rfkill toggle all && notify "System" "✈️ Airplane toggled" ;;
    esac
}

main_menu
