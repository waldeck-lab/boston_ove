#!/usr/bin/env sh
# stage_lib.sh — reusable helpers for OVE pipeline scripts (POSIX sh)

fail() { echo "ERROR: $*" >&2; exit 1; }
warn() { echo "WARN:  $*" >&2; }

say() { echo "$*" >&2; }

debug_on() {
  # Enable with: STAGE_DEBUG=1 ./script.sh
  if [ "${STAGE_DEBUG:-0}" = "1" ]; then
    set -x
  fi
}

run() {
  # run "description" cmd arg...
  desc="$1"; shift
  set +e
  "$@"
  rc=$?
  set -e
  if [ $rc -ne 0 ]; then
    fail "$desc (exit $rc): $*"
  fi
}

require_env_dir() {
  # require_env_dir VAR
  var="$1"
  eval val=\${$var:-}
  [ -n "$val" ] || fail "$var is not set."
  [ -d "$val" ] || fail "$var is not a directory: $val"
}

require_file_readable() {
  # require_file_readable PATH [label]
  p="$1"; label="${2:-file}"
  [ -f "$p" ] || fail "$label not found: $p"
  [ -r "$p" ] || fail "$label not readable: $p"
}

require_file_nonempty() {
  # require_file_nonempty PATH [label]
  p="$1"; label="${2:-file}"
  [ -s "$p" ] || fail "$label missing or empty: $p"
}

ensure_dir() {
  # ensure_dir PATH
  d="$1"
  mkdir -p "$d" || fail "Could not create directory: $d"
}

clean_glob() {
  # clean_glob DIR PATTERN
  d="$1"; pat="$2"
  # shellcheck disable=SC2086
  rm -f "$d"/$pat 2>/dev/null || true
}


count_files() {
  # count_files DIR GLOB
  d="$1"; g="$2"
  find "$d" -maxdepth 1 -type f -name "$g" 2>/dev/null | wc -l | tr -d ' '
}


python_run() {
  script="$1"; shift
  require_file_readable "$script" "script"
  if [ -x "$script" ]; then
    run "Running $script" "$script" "$@"
  else
    command -v python3 >/dev/null 2>&1 || fail "python3 not found in PATH (script not executable): $script"
    run "Running python3 $script" python3 "$script" "$@"
  fi
}

require_at_least_one_file() {
  # require_at_least_one_file DIR GLOB [label]
  d="$1"; g="$2"; label="${3:-files}"
  [ -d "$d" ] || fail "Directory not found: $d"
  n="$(count_files "$d" "$g")"
  [ "$n" -gt 0 ] || fail "No $label found in: $d (pattern: $g)"
}

require_no_empty_files() {
  # require_no_empty_files DIR GLOB [label]
  d="$1"; g="$2"; label="${3:-files}"
  # find -size 0 is POSIX enough on GNU/BSD; if you hit portability issues we can adjust.
  empty="$(find "$d" -maxdepth 1 -type f -name "$g" -size 0 2>/dev/null | wc -l | tr -d ' ')"
  [ "$empty" -eq 0 ] || fail "One or more $label are empty in: $d (pattern: $g)"
}

publish_csv_dir() {
  # publish_csv_dir SRC_DIR DST_DIR [remove_glob]
  # Copies *.csv from SRC_DIR into a staging dir under DST_DIR, then moves into place.
  src="$1"; dst="$2"; rmglob="${3:-*.csv}"

  [ -d "$src" ] || fail "Source dir not found: $src"
  ensure_dir "$dst"

  require_at_least_one_file "$src" "*.csv" "CSV files"
  require_no_empty_files "$src" "*.csv" "CSV files"

  stage="$dst/.publish.$$"
  ensure_dir "$stage"

  # Copy with null-separated filenames to survive spaces
  find "$src" -maxdepth 1 -type f -name '*.csv' -print0 \
    | xargs -0 -I {} cp "{}" "$stage/" || fail "Failed copying CSVs into staging: $stage"

  # Remove old outputs (scope controlled by remove_glob)
  # shellcheck disable=SC2086
  rm -f "$dst"/$rmglob 2>/dev/null || true

  # Move new outputs in
  mv "$stage"/*.csv "$dst/" || fail "Failed moving published CSVs into: $dst"

  # Cleanup
  rmdir "$stage" 2>/dev/null || true
}
