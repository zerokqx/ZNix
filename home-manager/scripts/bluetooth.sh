printf "  Scan\n  Power On\n  Power Off\n  List Devices\n  Connect\n  Disconnect\n" | wofi --show dmenu --prompt "  Bluetooth Menu" | while read choice; do
  case "$choice" in
  *Scan*) bluetoothctl scan on ;;
  *Power\ On*) bluetoothctl power on ;;
  *Power\ Off*) bluetoothctl power off ;;
  *List*) bluetoothctl devices ;;
  *Connect*) bluetoothctl devices | awk '{print $2 " " $3}' | while read mac name; do echo "  $name [$mac]"; done | wofi --show dmenu --prompt "  Connect to..." | awk -F'[][]' '{print $2}' | xargs -r bluetoothctl connect ;;
  *Disconnect*) bluetoothctl devices | awk '{print $2 " " $3}' | while read mac name; do echo "  $name [$mac]"; done | wofi --show dmenu --prompt "  Disconnect from..." | awk -F'[][]' '{print $2}' | xargs -r bluetoothctl disconnect ;;
  esac
done
