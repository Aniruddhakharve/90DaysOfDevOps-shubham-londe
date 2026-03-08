#!/bin/bash
set -euo pipefail

print_system() {
  echo "===== System Info ====="
  hostname
  cat /etc/os-release | grep PRETTY_NAME
}

print_uptime() {
  echo "===== Uptime ====="
  uptime
}

print_disk() {
  echo "===== Disk Usage (Top 5) ====="
  du -h / 2>/dev/null | sort -rh | head -5
}

print_memory() {
  echo "===== Memory Usage ====="
  free -h
}

print_cpu() {
  echo "===== Top 5 CPU Processes ====="
  ps aux --sort=-%cpu | head -6
}

main() {
  print_system
  echo
  print_uptime
  echo
  print_memory
  echo
  print_cpu
  echo
  print_disk

}

main
