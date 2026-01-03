#!/usr/bin/env sh
set -e

echo "TEST t0100: geomap pipeline (n=5)"

# Required env
[ -n "${OVE_BASE_DIR:-}" ] || {
  echo "ERROR: OVE_BASE_DIR is not set" >&2
  exit 1
}

OUT_DIR="$OVE_BASE_DIR/stage/lists/geomap"

# Basic sanity: command must exist
command -v run_geomap_pipeline >/dev/null 2>&1 || {
  echo "ERROR: run_geomap_pipeline not found on PATH" >&2
  exit 1
}

# Run pipeline
run_geomap_pipeline --n 5 --out-dir "$OUT_DIR"

# Expected outputs (default zoom=15, slot=0)
HOTMAP="$OUT_DIR/hotmap_zoom15_slot0.geojson"
TOPSITES="$OUT_DIR/top_sites_zoom15_slot0.csv"

# Verify outputs exist and are non-empty
[ -s "$HOTMAP" ] || {
  echo "ERROR: Missing or empty output: $HOTMAP" >&2
  exit 2
}

[ -s "$TOPSITES" ] || {
  echo "ERROR: Missing or empty output: $TOPSITES" >&2
  exit 2
}

# Verify generated contents is not empty 
ls -lh "$HOTMAP" "$TOPSITES" || true
LINES="$(wc -l < "$TOPSITES" | tr -d ' ')"
[ "$LINES" -ge 2 ] || { echo "ERROR: CSV has too few rows ($LINES): $TOPSITES" >&2; exit 3; }

echo "OK: geomap pipeline completed (n=5)"
echo "     outputs:"
echo "       $(basename "$HOTMAP")"
echo "       $(basename "$TOPSITES")"
