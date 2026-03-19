#!/usr/bin/env bash
# Copy nicketuttarwar.com and uttarwarart.com from the parent of this repo into
# subfolders here, excluding paths per each project's .gitignore (plus shared
# defaults). Never copies nested .git/ or common temp/build artifacts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# This repo root (directory containing this script)
DEST_ROOT="${DEST_ROOT:-$SCRIPT_DIR}"
# Sibling projects live next to this folder (one level up)
PARENT="$(dirname "$DEST_ROOT")"

DRY_RUN=0
DELETE=0
while [[ "${1:-}" == -* ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1 ;;
    --delete) DELETE=1 ;;
    -h|--help)
      echo "Usage: $(basename "$0") [-n|--dry-run] [--delete]"
      echo "  Copies ../nicketuttarwar.com and ../uttarwarart.com into:"
      echo "    $DEST_ROOT/nicketuttarwar.com/"
      echo "    $DEST_ROOT/uttarwarart.com/"
      echo "  --delete  remove files under those subfolders that no longer exist upstream"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

RSYNC=(rsync -a)
if [[ "$DRY_RUN" -eq 1 ]]; then
  RSYNC+=(--dry-run)
fi

# Shared excludes when a tree has no .gitignore (nicketuttarwar.com) and
# baseline junk/temp patterns aligned with typical web + Python projects.
DEFAULT_EXCLUDES="$(cat <<'EOF'
.git/
__pycache__/
*.py[cod]
*$py.class
.pytest_cache/
.mypy_cache/
.ruff_cache/
*.log
*.tmp
.DS_Store
Thumbs.db
.idea/
*.swp
*.swo
*~
node_modules/
dist/
build/
coverage/
.nyc_output/
.env
.env.local
.env.*.local
EOF
)"

build_exclude_file() {
  local src_root="$1"
  local out="$2"
  {
    printf '%s\n' "$DEFAULT_EXCLUDES"
    if [[ -f "$src_root/.gitignore" ]]; then
      # Drop comments and blank lines; keep gitignore-style patterns for rsync
      grep -v '^[[:space:]]*#' "$src_root/.gitignore" | grep -v '^[[:space:]]*$' || true
    fi
  } >"$out"
}

sync_one() {
  local name="$1"
  local src="$PARENT/$name"
  local dest="$DEST_ROOT/$name"

  if [[ ! -d "$src" ]]; then
    echo "error: source not found: $src" >&2
    exit 1
  fi

  local excl
  excl="$(mktemp "${TMPDIR:-/tmp}/sync-sites-excludes.XXXXXX")"
  build_exclude_file "$src" "$excl"

  mkdir -p "$dest"
  echo "Syncing $name  ($src -> $dest)"
  local -a args=("${RSYNC[@]}")
  if [[ "$DELETE" -eq 1 ]]; then
    args+=(--delete)
  fi
  args+=(--exclude-from="$excl" "$src/" "$dest/")
  "${args[@]}"
  rm -f "$excl"
}

sync_one "nicketuttarwar.com"
sync_one "uttarwarart.com"
echo "Done."
