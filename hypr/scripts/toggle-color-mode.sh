#!/usr/bin/env bash
set -euo pipefail

monitor="DP-1"
mode="${1:-toggle}"
config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.conf"

refresh_wallpaper_engine() {
  if systemctl --user list-unit-files | rg -q "^wallpaperengine@\.service"; then
    systemctl --user restart "wallpaperengine@${monitor}.service" || true
  fi
  pkill -x swww-daemon || true
  pkill -x hyprpaper || true
}

set_mode_in_config() {
  local cm="$1"
  local sdrbrightness="$2"
  local sdrsaturation="$3"

  python - "$config" "$monitor" "$cm" "$sdrbrightness" "$sdrsaturation" <<'PY'
import pathlib
import re
import sys

config_path = pathlib.Path(sys.argv[1])
monitor = sys.argv[2]
cm = sys.argv[3]
sdrbrightness = sys.argv[4]
sdrsaturation = sys.argv[5]

lines = config_path.read_text().splitlines()
out = []
i = 0
updated = False

while i < len(lines):
    line = lines[i]
    if re.match(r"^\s*monitorv2\s*\{\s*$", line):
        block = [line]
        i += 1
        while i < len(lines):
            block.append(lines[i])
            if re.match(r"^\s*\}\s*$", lines[i]):
                break
            i += 1

        block_text = "\n".join(block)
        if re.search(rf"^\s*output\s*=\s*{re.escape(monitor)}\s*$", block_text, re.M):
            for j, bline in enumerate(block):
                if re.match(r"^\s*cm\s*=", bline):
                    block[j] = re.sub(r"=.*$", f"={cm}", bline)
                elif re.match(r"^\s*sdrbrightness\s*=", bline):
                    block[j] = re.sub(r"=.*$", f"={sdrbrightness}", bline)
                elif re.match(r"^\s*sdrsaturation\s*=", bline):
                    block[j] = re.sub(r"=.*$", f"={sdrsaturation}", bline)
            updated = True

        out.extend(block)
    else:
        out.append(line)
    i += 1

if not updated:
    raise SystemExit(f"Could not find monitorv2 block for {monitor} in {config_path}")

config_path.write_text("\n".join(out) + "\n")
PY
}

apply_mode() {
  case "$1" in
    srgb)
      set_mode_in_config srgb 1.0 1.0
      hyprctl reload >/dev/null
      refresh_wallpaper_engine
      notify-send "Display mode" "Coding mode (sRGB)"
      ;;
    hdr)
      set_mode_in_config hdr 1.1 1.0
      hyprctl reload >/dev/null
      refresh_wallpaper_engine
      notify-send "Display mode" "Media mode (HDR)"
      ;;
    *)
      echo "Unknown mode: $1" >&2
      exit 1
      ;;
  esac
}

current="$({ hyprctl monitors all || true; } | awk -v monitor="$monitor" '
  $1 == "Monitor" && $2 == monitor { in_monitor = 1; next }
  $1 == "Monitor" && $2 != monitor { in_monitor = 0 }
  in_monitor && $1 == "colorManagementPreset:" { print $2; exit }
')"

case "$mode" in
  toggle)
    if [[ "$current" == "hdr" ]]; then
      apply_mode srgb
    else
      apply_mode hdr
    fi
    ;;
  srgb|coding)
    apply_mode srgb
    ;;
  hdr|media)
    apply_mode hdr
    ;;
  *)
    echo "Usage: $0 [toggle|srgb|hdr]" >&2
    exit 1
    ;;
esac
