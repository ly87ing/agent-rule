#!/usr/bin/env bash

set -euo pipefail

# 用法说明保持简短，避免脚本帮助信息过长。
usage() {
  cat <<'EOF'
Usage:
  ./scripts/sync-agent-rules.sh [--mode copy|symlink] [--group all|global] [--target NAME] [--dry-run] [--no-backup]
EOF
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
manifest_path="$repo_root/config/targets.list"

mode="copy"
group_filter="all"
dry_run="false"
backup_enabled="true"
selected_targets=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --mode)
      shift
      mode="${1:-}"
      ;;
    --group)
      shift
      group_filter="${1:-}"
      ;;
    --target)
      shift
      selected_targets+=("${1:-}")
      ;;
    --dry-run)
      dry_run="true"
      ;;
    --no-backup)
      backup_enabled="false"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift || true
done

if [ "$mode" != "copy" ] && [ "$mode" != "symlink" ]; then
  echo "Invalid mode: $mode" >&2
  exit 1
fi

if [ "$group_filter" != "all" ] && [ "$group_filter" != "global" ]; then
  echo "Invalid group: $group_filter" >&2
  exit 1
fi

expand_home() {
  local value="$1"
  printf '%s' "${value//\{\{HOME\}\}/$HOME}"
}

absolute_path() {
  local path="$1"
  local dir base
  dir="$(cd "$(dirname "$path")" && pwd -P)"
  base="$(basename "$path")"
  printf '%s/%s' "$dir" "$base"
}

path_within_repo() {
  local path="$1"
  case "$path" in
    "$repo_root"/*) return 0 ;;
    *) return 1 ;;
  esac
}

validate_source_path() {
  local source_abs="$1"
  if ! path_within_repo "$source_abs"; then
    echo "Refusing to use source outside repository: $source_abs" >&2
    exit 1
  fi
  if [ -L "$source_abs" ]; then
    echo "Refusing to use symlink source file: $source_abs" >&2
    exit 1
  fi
}

validate_target_path() {
  local target="$1"
  case "$target" in
    "$HOME/.codex/AGENTS.md"|\
    "$HOME/.claude/CLAUDE.md"|\
    "$HOME/.config/opencode/AGENTS.md"|\
    "$HOME/.gemini/GEMINI.md"|\
    "$HOME/.codex/modules"|\
    "$HOME/.claude/modules"|\
    "$HOME/.config/opencode/modules"|\
    "$HOME/.gemini/modules")
      return 0
      ;;
    *)
      echo "Refusing to write unmanaged target path: $target" >&2
      exit 1
      ;;
  esac
}

target_selected() {
  local name="$1"
  local group="$2"
  local item

  if [ "$group_filter" != "all" ] && [ "$group_filter" != "$group" ]; then
    return 1
  fi

  if [ "${#selected_targets[@]}" -eq 0 ]; then
    return 0
  fi

  for item in "${selected_targets[@]}"; do
    if [ "$item" = "$name" ]; then
      return 0
    fi
  done

  return 1
}

validate_selected_targets() {
  local requested name group _source_rel _target_pattern found

  if [ "${#selected_targets[@]}" -eq 0 ]; then
    return 0
  fi

  for requested in "${selected_targets[@]}"; do
    found="false"
    while IFS='|' read -r name group _source_rel _target_pattern; do
      [ -z "$name" ] && continue
      case "$name" in
        \#*) continue ;;
      esac
      if [ "$name" != "$requested" ]; then
        continue
      fi
      if [ "$group_filter" != "all" ] && [ "$group_filter" != "$group" ]; then
        continue
      fi
      found="true"
      break
    done < "$manifest_path"

    if [ "$found" != "true" ]; then
      echo "Unknown or filtered target: $requested" >&2
      exit 1
    fi
  done
}

backup_target() {
  local target="$1"
  local timestamp backup_path suffix

  if [ "$backup_enabled" != "true" ]; then
    return 0
  fi

  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    return 0
  fi

  timestamp="$(date +%Y%m%d%H%M%S)"
  backup_path="${target}.bak.${timestamp}"
  suffix=0
  while [ -e "$backup_path" ] || [ -L "$backup_path" ]; do
    suffix=$((suffix + 1))
    backup_path="${target}.bak.${timestamp}.${suffix}"
  done
  echo "backup: $target -> $backup_path"
  if [ "$dry_run" = "false" ]; then
    mv "$target" "$backup_path"
  fi
}

sync_copy() {
  local source_abs="$1"
  local target="$2"

  if [ -d "$source_abs" ]; then
    if [ -d "$target" ] && [ ! -L "$target" ] && diff -r "$source_abs" "$target" >/dev/null 2>&1; then
      echo "unchanged(copy): $target"
      return 0
    fi
    backup_target "$target"
    if [ "$dry_run" = "false" ] && { [ -e "$target" ] || [ -L "$target" ]; }; then
      rm -rf "$target"
    fi
    echo "copy(dir): $source_abs -> $target"
    if [ "$dry_run" = "false" ]; then
      cp -R "$source_abs" "$target"
    fi
  else
    if [ -f "$target" ] && [ ! -L "$target" ] && cmp -s "$source_abs" "$target"; then
      echo "unchanged(copy): $target"
      return 0
    fi
    backup_target "$target"
    if [ "$dry_run" = "false" ] && { [ -e "$target" ] || [ -L "$target" ]; }; then
      rm -f "$target"
    fi
    echo "copy: $source_abs -> $target"
    if [ "$dry_run" = "false" ]; then
      cp "$source_abs" "$target"
    fi
  fi
}

sync_symlink() {
  local source_abs="$1"
  local target="$2"
  local current_link=""

  if [ -L "$target" ]; then
    current_link="$(readlink "$target" || true)"
  fi

  if [ "$current_link" = "$source_abs" ]; then
    echo "unchanged(symlink): $target"
    return 0
  fi

  backup_target "$target"
  if [ "$dry_run" = "false" ] && { [ -e "$target" ] || [ -L "$target" ]; }; then
    rm -rf "$target"
  fi
  echo "symlink: $target -> $source_abs"
  if [ "$dry_run" = "false" ]; then
    ln -s "$source_abs" "$target"
  fi
}

matched_count=0

validate_selected_targets

while IFS='|' read -r name group source_rel target_pattern; do
  [ -z "$name" ] && continue
  case "$name" in
    \#*) continue ;;
  esac

  if ! target_selected "$name" "$group"; then
    continue
  fi

  matched_count=$((matched_count + 1))

  source_abs="$(absolute_path "$repo_root/$source_rel")"
  target_path="$(expand_home "$target_pattern")"
  target_dir="$(dirname "$target_path")"

  if [ ! -e "$source_abs" ]; then
    echo "Missing source file/dir: $source_abs" >&2
    exit 1
  fi

  validate_source_path "$source_abs"
  validate_target_path "$target_path"

  echo "target: $name ($group)"
  echo "source: $source_abs"
  echo "dest  : $target_path"

  if [ "$dry_run" = "false" ]; then
    mkdir -p "$target_dir"
  else
    echo "mkdir -p: $target_dir"
  fi

  if [ "$mode" = "copy" ]; then
    sync_copy "$source_abs" "$target_path"
  else
    sync_symlink "$source_abs" "$target_path"
  fi

  echo
done < "$manifest_path"

if [ "$matched_count" -eq 0 ]; then
  echo "No targets matched the provided filters." >&2
  exit 1
fi

echo "Done. mode=$mode group=$group_filter matched=$matched_count dry_run=$dry_run"
