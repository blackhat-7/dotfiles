# Snapshot of everything that has caused CS2 FPS drops or lag on this PC.
# Run it while CS2 is running, ideally mid-match.

ok() { printf '  \e[32mOK\e[0m   %s\n' "$*"; }
warn() { printf '  \e[33mWARN\e[0m %s\n' "$*"; }
info() { printf '       %s\n' "$*"; }
section() { printf '\n\e[1m%s\e[0m\n' "$*"; }

section "CS2"
pid=$(pgrep -x cs2 || true)
if [[ -z $pid ]]; then
  warn "cs2 is not running; game checks are skipped"
else
  # The 13600K's P-cores are CPUs 0-11; E-cores (12-19) are much slower.
  aff=$(taskset -cp "$pid" | awk '{print $NF}')
  if [[ $aff == 0-11 ]]; then ok "affinity P-cores ($aff)"; else warn "affinity $aff (P-cores are 0-11: taskset -acp 0-11 $pid)"; fi
  info "cs2 CPU $(ps -o pcpu= -p "$pid")%, RSS $(($(ps -o rss= -p "$pid") / 1024)) MiB"
  if pgrep -x gamemoded >/dev/null; then ok "gamemode running"; else info "gamemode not running"; fi
fi

videos=(~/.local/share/Steam/userdata/*/730/local/cfg/cs2_video.txt)
video=${videos[0]}
if [[ -f $video ]]; then
  val() { awk -v k="\"setting.$1\"" '$1 == k { gsub(/"/, "", $2); print $2 }' "$video"; }
  if [[ $(val mat_vsync) == 0 ]]; then ok "in-game vsync off"; else warn "in-game vsync on"; fi
fi

section "Hyprland"
if command -v hyprctl >/dev/null; then
  opt() { hyprctl getoption "$1" -j | jq -r '.int // .bool // .str'; }
  # Direct scanout turns CS2 black and white on this setup, so it must stay off.
  if [[ $(opt render:direct_scanout) == 0 ]]; then ok "direct_scanout off"; else warn "render:direct_scanout on: CS2 goes black and white"; fi
  if [[ $(opt general:allow_tearing) == true ]]; then ok "allow_tearing on"; else info "general:allow_tearing off"; fi
  hyprctl monitors -j | jq -r '.[] | "       \(.name) \(.width)x\(.height)@\(.refreshRate|floor) vrr=\(.vrr)"'
  hyprctl clients -j | jq -r '.[] | select(.class == "cs2") | "       cs2 window fullscreen=\(.fullscreen) size=\(.size|join("x"))"'
fi

section "CPU"
info "governor $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor), EPP $(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)"
read -r lo hi < <(awk '/MHz/ {print int($4)}' /proc/cpuinfo | sort -n | sed -n '1p;$p' | paste -sd' ')
info "clocks ${lo}-${hi} MHz"
temp=$(sensors -j 2>/dev/null | jq -r '[.[] | ."Package id 0"?.temp1_input // empty] | first // empty')
if [[ -n $temp ]]; then
  if ((${temp%.*} < 90)); then ok "package ${temp%.*}C"; else warn "package ${temp%.*}C (throttles near 100)"; fi
fi

section "GPU"
for dev in /sys/class/drm/card*/device; do
  [[ -f $dev/gpu_busy_percent ]] || continue
  info "$(basename "$(dirname "$dev")"): busy $(cat "$dev/gpu_busy_percent")%, sclk $(awk '/\*/ {print $2}' "$dev/pp_dpm_sclk"), mclk $(awk '/\*/ {print $2}' "$dev/pp_dpm_mclk"), level $(cat "$dev/power_dpm_force_performance_level")"
done
sensors -j 2>/dev/null | jq -r 'to_entries[] | select(.key | startswith("amdgpu")) | .value
  | "       edge \(.edge.temp1_input // 0 | floor)C, junction \(.junction.temp2_input // 0 | floor)C, mem \(.mem.temp3_input // 0 | floor)C, power \(.PPT.power1_average // 0 | floor)W"'

section "Background load (3 s sample)"
top -b -n2 -d3 -o %CPU -w 200 | awk '/^top -/ {n++} n == 2 && $1 ~ /^[0-9]+$/ && $9 + 0 >= 10 && $12 != "cs2" {printf "       %5s%%  %s (pid %s)\n", $9, $12, $1}' | head -8
mem=$(awk '/MemAvailable/ {print int($2 / 1048576)}' /proc/meminfo)
if ((mem >= 8)); then ok "${mem} GiB RAM available"; else warn "only ${mem} GiB RAM available"; fi

section "Network"
gw=$(ip route show default | awk '{print $3; exit}')
for host in "$gw" 1.1.1.1; do
  [[ -n $host ]] || continue
  ping -c 20 -i 0.2 -q "$host" | awk -v h="$host" '/loss/ {loss = $6} /rtt/ {split($4, r, "/"); printf "       %-12s loss %s, avg %s ms, max %s ms\n", h, loss, r[2], r[3]}'
done
# Wi-Fi scans stall the rtw88 card for ~100 ms each (see the DMS patch in nix/home/programs).
scans=$(journalctl --since -5min -u wpa_supplicant --no-pager -q 2>/dev/null | grep -c 'Reject scan trigger' || true)
if ((scans == 0)); then ok "no Wi-Fi scan storm in the last 5 min"; else warn "$scans rejected Wi-Fi scans in 5 min: something keeps scanning (try: dms restart)"; fi
