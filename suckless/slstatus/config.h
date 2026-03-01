/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 1000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "";

/* maximum output string length */
#define MAXLEN 2048

/*
 * function            description                     argument (example)
 *
 * battery_perc        battery percentage              battery name (BAT0)
 *                                                     NULL on OpenBSD/FreeBSD
 * battery_remaining   battery remaining HH:MM         battery name (BAT0)
 *                                                     NULL on OpenBSD/FreeBSD
 * battery_state       battery charging state          battery name (BAT0)
 *                                                     NULL on OpenBSD/FreeBSD
 * cat                 read arbitrary file             path
 * cpu_freq            cpu frequency in MHz            NULL
 * cpu_perc            cpu usage in percent            NULL
 * datetime            date and time                   format string (%F %T)
 * disk_free           free disk space in GB           mountpoint path (/)
 * disk_perc           disk usage in percent           mountpoint path (/)
 * disk_total          total disk space in GB          mountpoint path (/)
 * disk_used           used disk space in GB           mountpoint path (/)
 * entropy             available entropy               NULL
 * gid                 GID of current user             NULL
 * hostname            hostname                        NULL
 * ipv4                IPv4 address                    interface name (eth0)
 * ipv6                IPv6 address                    interface name (eth0)
 * kernel_release      `uname -r`                      NULL
 * keyboard_indicators caps/num lock indicators        format string (c?n?)
 *                                                     see keyboard_indicators.c
 * keymap              layout (variant) of current     NULL
 *                     keymap
 * load_avg            load average                    NULL
 * netspeed_rx         receive network speed           interface name (wlan0)
 * netspeed_tx         transfer network speed          interface name (wlan0)
 * num_files           number of files in a directory  path
 *                                                     (/home/foo/Inbox/cur)
 * ram_free            free memory in GB               NULL
 * ram_perc            memory usage in percent         NULL
 * ram_total           total memory size in GB         NULL
 * ram_used            used memory in GB               NULL
 * run_command         custom shell command            command (echo foo)
 * swap_free           free swap in GB                 NULL
 * swap_perc           swap usage in percent           NULL
 * swap_total          total swap size in GB           NULL
 * swap_used           used swap in GB                 NULL
 * temp                temperature in degree celsius   sensor file
 *                                                     (/sys/class/thermal/...)
 *                                                     NULL on OpenBSD
 *                                                     thermal zone on FreeBSD
 *                                                     (tz0, tz1, etc.)
 * uid                 UID of current user             NULL
 * up                  interface is running            interface name (eth0)
 * uptime              system uptime                   NULL
 * username            username of current user        NULL
 * vol_perc            OSS/ALSA volume in percent      mixer file (/dev/mixer)
 *                                                     NULL on OpenBSD/FreeBSD
 * wifi_essid          WiFi ESSID                      interface name (wlan0)
 * wifi_perc           WiFi signal in percent          interface name (wlan0)
 */
static const struct arg args[] = {
	/* function format          argument */
	{cpu_perc, "^b#ff5555^^c#282a36^  %s%% ^d^", NULL},
	{run_command, "^b#ff5555^^c#282a36^%sMHz ^d^", "grep 'cpu MHz' /proc/cpuinfo | head  -1 | awk '{print int($4)}'"},
	{temp, "^b#ff5555^^c#282a36^ %s°C ^d^", "/sys/class/hwmon/hwmon5/temp1_input"},
	{run_command, "^b#6272a4^^c#282a36^  %s ^d^", "free -m | awk '/^Mem/ { printf(\"%.2f GiB\", $3/1024) }'"},
	{run_command, "^b#50fa7b^^c#282a36^  %s ^d^", "/usr/local/bin/net-status.sh"},
	{netspeed_rx, "^b#50fa7b^^c#282a36^  %s/s ^d^", "wlp2s0"},
	{ipv4, "^b#50fa7b^^c#282a36^ 󰩠 %s ^d^", "wlp2s0"},
	{run_command, "^b#bd93f9^^c#282a36^  %s ^d^", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{if($3==\"[MUTED]\") print \"MUTE\"; else print int($2*100)\"%\"}'"},
	{run_command, "^b#bd93f9^^c#282a36^ %s ^d^", "brightnessctl -m | cut -d, -f4"},
	{run_command, "^b#bd93f9^^c#282a36^%s ^d^", "bluetoothctl info | grep -q 'Name' && echo ' 󰥰 ' || (bluetoothctl show | grep -q 'Powered: yes' && echo '  ' || echo ' 󰂲 ')"},
	{battery_state, "^b#f1fa8c^^c#282a36^  %s ^d^", "BAT0"},
	{battery_perc,  "^b#f1fa8c^^c#282a36^%s%% ^d^", "BAT0"},
	{run_command, "^b#f1fa8c^^c#282a36^ %sW ^d^", "awk '{print $1*10^-6}' /sys/class/power_supply/BAT0/power_now | cut -c1-4"},
	{battery_remaining, "^b#f1fa8c^^c#282a36^(%s) ^d^", "BAT0"},
	//Pomodoro
	{run_command, "%s", "cat /tmp/slstatus_pomodoro 2>/dev/null"},
	//Caffeine, shows icon or nothing. Logic just line in pomodoro
	{run_command, "%s", "cat /tmp/slstatus_caffeine 2>/dev/null"},
	{keymap, "^b#21222c^^c#f8f8f2^  %s ^d^", NULL},
	{datetime, "^b#21222c^^c#f8f8f2^ %s ^d^", "%H:%M:%S"},
};
