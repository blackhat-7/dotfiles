# Toggles the CS2 tweaks. They hurt the local LLMs (llamacpp-tuner): awake idle cores eat
# into the CPU power cap, lavd reschedules the CPU expert pool, and long LLM runs need the
# cap to stay cool. All of it resets on reboot.

usage() { echo "usage: game-mode on|off|status" >&2; exit 2; }

all_cpus=$(cat /sys/devices/system/cpu/online)
e_cores=12-19

# GPU and USB (mouse) interrupts otherwise land on the P-cores CS2 runs on.
irqs() { awk '/amdgpu|xhci_hcd/ {sub(":", "", $1); print $1}' /proc/interrupts; }

set_irqs() {
  for irq in $(irqs); do
    echo "$1" | sudo tee "/proc/irq/$irq/smp_affinity_list" >/dev/null
  done
}

# States 2+ (C2/C3) take up to ~1 ms to wake from, which shows up as frame-time spikes.
set_deep_cstates() {
  for f in /sys/devices/system/cpu/cpu*/cpuidle/state[2-9]/disable; do
    echo "$1" | sudo tee "$f" >/dev/null
  done
}

# RAPL PL1/PL2 in W. Off restores the cap set at boot by cpuPowerLimit (nix/linux);
# on restores the board's stock limits, which only overheated under long LLM runs.
set_power_limit() {
  local rapl=/sys/class/powercap/intel-rapl:0
  echo "${1}000000" | sudo tee "$rapl/constraint_0_power_limit_uw" >/dev/null
  echo "${2}000000" | sudo tee "$rapl/constraint_1_power_limit_uw" >/dev/null
}

# The 7900 XTX's power cap: on raises it to the board maximum, off restores the default.
gpu_hwmon=$(dirname "$(echo /sys/class/drm/card*/device/hwmon/hwmon*/power1_cap_max)")

set_gpu_cap() {
  sudo tee "$gpu_hwmon/power1_cap" >/dev/null <<<"$(cat "$gpu_hwmon/power1_cap_$1")"
}

status() {
  local rapl=/sys/class/powercap/intel-rapl:0
  echo "GPU power cap: $(($(cat "$gpu_hwmon/power1_cap") / 1000000)) W (default $(($(cat "$gpu_hwmon/power1_cap_default") / 1000000)), max $(($(cat "$gpu_hwmon/power1_cap_max") / 1000000)))"
  echo "CPU power limit: $(($(cat "$rapl/constraint_0_power_limit_uw") / 1000000))/$(($(cat "$rapl/constraint_1_power_limit_uw") / 1000000)) W"
  echo "scheduler: $(cat /sys/kernel/sched_ext/root/ops 2>/dev/null || echo default)"
  echo "deep C-states disabled on $(cat /sys/devices/system/cpu/cpu*/cpuidle/state[2-9]/disable | grep -c 1) of $(find /sys/devices/system/cpu/cpu*/cpuidle/ -path '*/state[2-9]/disable' | wc -l)"
  for irq in $(irqs); do
    echo "irq $irq ($(awk -v i="$irq:" '$1 == i {print $NF}' /proc/interrupts)) -> CPUs $(cat "/proc/irq/$irq/smp_affinity_list")"
  done
}

case ${1:-} in
  on)
    sudo -v
    sudo systemctl stop game-mode-scx 2>/dev/null || true
    sudo systemd-run --quiet --unit=game-mode-scx --collect "$SCX_LAVD"
    set_deep_cstates 1
    set_irqs "$e_cores"
    set_power_limit 95 181
    set_gpu_cap max
    status
    ;;
  off)
    sudo -v
    sudo systemctl stop game-mode-scx 2>/dev/null || true
    set_deep_cstates 0
    set_irqs "$all_cpus"
    set_power_limit 75 125
    set_gpu_cap default
    status
    ;;
  status) status ;;
  *) usage ;;
esac
