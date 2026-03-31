#!/usr/bin/env bash
set -euo pipefail

HOST="${PERF_HOST:-127.0.0.1}"
ENDPOINT="${PERF_PATH:-/concurrency}"

usage() {
  cat <<'EOF'
Usage: performance_test.sh <server> [concurrent_requests]

  server            One of: nginx, apache, swoole, roadmap, franken
  concurrent_requests
                    Optional, default 1000

Ports (match docker-compose defaults; override with env if you remapped):
  nginx     -> NGINX_PORT              (default 8080)
  apache    -> APACHE_PORT             (default 8081)
  swoole    -> OCTANE_SWOOLE_PORT      (default 8001)
  roadmap   -> OCTANE_ROADRUNNER_PORT  (default 8002, RoadRunner)
  franken   -> OCTANE_FRANKENPHP_PORT  (default 8000, FrankenPHP + Octane)

Optional env: PERF_HOST (default 127.0.0.1), PERF_PATH (default /concurrency)

Examples:
  ./performance_test.sh nginx
  ./performance_test.sh franken 500
  OCTANE_SWOOLE_PORT=9001 ./performance_test.sh swoole 2000
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] || [ -z "${1:-}" ]; then
  usage
  [ -n "${1:-}" ] && exit 0
  exit 1
fi

SERVER=$(echo "$1" | tr '[:upper:]' '[:lower:]')
shift

case "$SERVER" in
  nginx)
    PORT="${NGINX_PORT:-8080}"
    LABEL="Nginx + PHP-FPM"
    ;;
  apache)
    PORT="${APACHE_PORT:-8081}"
    LABEL="Apache + mod_php"
    ;;
  swoole)
    PORT="${OCTANE_SWOOLE_PORT:-8001}"
    LABEL="Octane + Swoole"
    ;;
  roadmap|roadrunner)
    PORT="${OCTANE_ROADRUNNER_PORT:-8002}"
    LABEL="Octane + RoadRunner"
    ;;
  franken|frankenphp)
    PORT="${OCTANE_FRANKENPHP_PORT:-8000}"
    LABEL="Octane + FrankenPHP"
    ;;
  *)
    echo "Unknown server: $SERVER" >&2
    echo >&2
    usage >&2
    exit 1
    ;;
esac

CONCURRENT="${1:-1000}"

URL="http://${HOST}:${PORT}${ENDPOINT}"

print_header() {
  echo ""
  echo "=== $1 ($(date '+%Y-%m-%d %H:%M:%S')) ==="
}

print_load() {
  echo "CPU load (load average — runnable / waiting threads per CPU):"
  if [ -r /proc/loadavg ]; then
    read -r l1 l5 l15 rest < /proc/loadavg
    echo "  1 min:  $l1"
    echo "  5 min:  $l5"
    echo "  15 min: $l15"
  elif command -v sysctl >/dev/null 2>&1 && sysctl -n vm.loadavg >/dev/null 2>&1; then
    set -- $(sysctl -n vm.loadavg | tr -d '{}')
    echo "  1 min:  $1"
    echo "  5 min:  $2"
    echo "  15 min: $3"
  elif command -v uptime >/dev/null 2>&1; then
    uptime
  fi
}

print_memory() {
  echo "Memory:"
  if command -v free >/dev/null 2>&1; then
    free -h
  else
    if bytes=$(sysctl -n hw.memsize 2>/dev/null); then
      echo "  Physical RAM (hw.memsize): ${bytes} bytes"
    fi
    echo "  vm_stat (page size is shown in the first line; often 4096 bytes on Apple Silicon / Intel):"
    vm_stat 2>/dev/null | head -20 || true
  fi
}

print_system() {
  print_load
  print_memory
}

print_header "Before load test"
print_system

print_header "Running ${CONCURRENT} concurrent requests"
echo "Target: ${LABEL}"
echo "URL:    ${URL}"
echo ""

TIMEFORMAT=$'Wall-clock time: %R seconds (user %U, sys %S)\n'
export TIMEFORMAT
time (
  for ((i = 1; i <= CONCURRENT; i++)); do
    curl -sS "$URL" -o /dev/null &
  done
  wait
)

print_header "After load test"
print_system
