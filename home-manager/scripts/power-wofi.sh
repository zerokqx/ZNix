printf "⏻  Poweroff\n🔄  Reboot\n🌙  Suspend\n❄  Hibernate\n🔒  Lock\n🚪  Logout\n" | wofi --show dmenu --prompt "⚡ Power Menu" -W 50 -H 200 | awk '{print tolower($2)}' | xargs -r systemctl
