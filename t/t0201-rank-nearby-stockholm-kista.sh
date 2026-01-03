#!/usr/bin/env sh
set -e

echo "TEST t0201: rank_nearby (Stockholm – Kista)"

command -v rank_nearby >/dev/null 2>&1 || {
  echo "ERROR: rank_nearby not found on PATH" >&2
  exit 1
}

rank_nearby \
  --lat 59.403 \
  --lon 17.944 \
  --zoom 15 \
  --slot 0 \
  --limit 10

echo "OK: rank_nearby Kista completed"
