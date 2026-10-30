# Toggles the CS2 latency tweaks. They hurt the local LLMs (llamacpp-tuner):
# awake idle cores eat into the 75 W CPU cap, and lavd reschedules the CPU expert pool.
# All of it resets on reboot.

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

status() {
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
    status
    ;;
  off)
    sudo -v
    sudo systemctl stop game-mode-scx 2>/dev/null || true
    set_deep_cstates 0
    set_irqs "$all_cpus"
    status
    ;;
  status) status ;;
  *) usage ;;
esac
