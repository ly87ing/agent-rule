#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/reset-agent-rules.sh [--dry-run] [--no-backup]
EOF
}

passthrough=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run|--no-backup)
      passthrough+=("$1")
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --mode|--group|--target)
      echo "reset-agent-rules.sh does not allow overriding mode, group, or target." >&2
      exit 1
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

# reset 明确固定为 copy + global，避免调用方把它变成软连接或局部同步。
exec "$repo_root/scripts/sync-agent-rules.sh" --mode copy --group global "${passthrough[@]}"
