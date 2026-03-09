#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

# reset 明确走 copy 模式，避免误把全局规则替换成软连接。
exec "$repo_root/scripts/sync-agent-rules.sh" --mode copy --group global "$@"
