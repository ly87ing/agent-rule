#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
manifest_path="$repo_root/config/targets.list"

expand_home() {
  local value="$1"
  printf '%s' "${value//\{\{HOME\}\}/$HOME}"
}

bak_files=()

while IFS='|' read -r name group source_rel target_pattern; do
  [ -z "$name" ] && continue
  case "$name" in
    \#*) continue ;;
  esac

  target_path="$(expand_home "$target_pattern")"
  
  # Find backup files using shopt -s nullglob inside a subshell or looping securely
  # In standard bash, if no matches, the literal string is returned.
  # We test if the file exists to handle the unexpanded literal string.
  for f in "${target_path}.bak."*; do
    if [ -e "$f" ] || [ -L "$f" ]; then
      bak_files+=("$f")
    fi
  done
done < "$manifest_path"

if [ ${#bak_files[@]} -eq 0 ]; then
  echo "No backup files found."
  exit 0
fi

echo "Found the following backup files:"
for f in "${bak_files[@]}"; do
  echo "  $f"
done

echo ""
read -r -p "Do you want to delete these backup files? [y/N] " response

case "$response" in
  [yY][eE][sS]|[yY]) 
    for f in "${bak_files[@]}"; do
      echo "Deleting $f..."
      rm -rf "$f"
    done
    echo "Done."
    ;;
  *)
    echo "Cleanup aborted."
    exit 0
    ;;
esac
