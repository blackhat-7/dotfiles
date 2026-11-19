# Toggles the CS2 tweaks. They hurt the local LLMs (llamacpp-tuner): they keep idle cores
# awake and lavd reschedules the CPU expert pool. All of it resets on reboot.

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

# The 7900 XTX's power cap: on raises it to the board maximum, off restores the default.
gpu_hwmon=$(dirname "$(echo /sys/class/drm/card*/device/hwmon/hwmon*/power1_cap_max)")
gpu_pm=$gpu_hwmon/device/power

# The idle GPU sleeps (runtime suspend) and its power files then fail with EBUSY.
# Keep it awake until the script exits; the driver keeps the cap across sleep.
wake_gpu() {
  echo on | sudo tee "$gpu_pm/control" >/dev/null
  trap 'echo auto | sudo tee "$gpu_pm/control" >/dev/null' EXIT
}

set_gpu_cap() {
  sudo tee "$gpu_hwmon/power1_cap" >/dev/null <<<"$(cat "$gpu_hwmon/power1_cap_$1")"
}

status() {
  if [[ $(cat "$gpu_pm/runtime_status") == suspended ]]; then
    echo "GPU power cap: unknown (GPU asleep)"
  else
    echo "GPU power cap: $(($(cat "$gpu_hwmon/power1_cap") / 1000000)) W (default $(($(cat "$gpu_hwmon/power1_cap_default") / 1000000)), max $(($(cat "$gpu_hwmon/power1_cap_max") / 1000000)))"
  fi
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
    wake_gpu
    set_gpu_cap max
    status
    ;;
  off)
    sudo -v
    sudo systemctl stop game-mode-scx 2>/dev/null || true
    set_deep_cstates 0
    set_irqs "$all_cpus"
    wake_gpu
    set_gpu_cap default
    status
    ;;
  status) status ;;
  *) usage ;;
esac
