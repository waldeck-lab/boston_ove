#!/usr/bin/env sh
set -e

echo "TEST t001: cleanup derived geomap artifacts"

# Required env
[ -n "${OVE_BASE_DIR:-}" ] || {
  echo "ERROR: OVE_BASE_DIR is not set" >&2
  exit 1
}

OUT_DIR="$OVE_BASE_DIR/stage/lists/geomap"

# Basic sanity: command must exist
command -v clean_derived >/dev/null 2>&1 || {
  echo "ERROR: clean_derived not found on PATH" >&2
  exit 1
}

# Run cleanup
# year 0 is baseline. Use --year -1 to wipe exports for all years.
clean_derived --all --slot 0 --year -1

# Verify typical generated outputs are removed (year-aware filenames)
HOTMAP15="$OUT_DIR/hotmap_zoom15_year0_slot0.geojson"
TOPSITES15="$OUT_DIR/top_sites_zoom15_year0_slot0.csv"

if [ -e "$HOTMAP15" ]; then
  echo "ERROR: cleanup did not remove: $HOTMAP15" >&2
  exit 2
fi

if [ -e "$TOPSITES15" ]; then
  echo "ERROR: cleanup did not remove: $TOPSITES15" >&2
  exit 2
fi

# Also ensure old legacy filenames are gone if they exist
LEGACY_HOTMAP="$OUT_DIR/hotmap_zoom15_slot0.geojson"
LEGACY_TOPSITES="$OUT_DIR/top_sites_zoom15_slot0.csv"

if [ -e "$LEGACY_HOTMAP" ]; then
  echo "ERROR: cleanup did not remove legacy: $LEGACY_HOTMAP" >&2
  exit 3
fi

if [ -e "$LEGACY_TOPSITES" ]; then
  echo "ERROR: cleanup did not remove legacy: $LEGACY_TOPSITES" >&2
  exit 3
fi

echo "OK: cleanup derived completed"
echo "     removed year0 exports for zoom15 slot0 (and legacy names if present)"
