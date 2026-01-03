#!/usr/bin/env sh
set -e

echo "TEST t0200: rank_nearby (Dalby, Skåne)"

command -v rank_nearby >/dev/null 2>&1 || {
  echo "ERROR: rank_nearby not found on PATH" >&2
  exit 1
}

args="--lat 55.667 --lon 13.350 --zoom 15 --slot 0 --limit 10"

echo "running rank_nearby with $args"
rank_nearby $args
 

echo "OK: rank_nearby Dalby completed"
