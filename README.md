# agent-rule

集中维护本机多个 AI CLI 的规则文件，并通过一条命令同步到实际生效路径。

## 管理范围

- `Codex`: `~/.codex/AGENTS.md`
- `Claude Code`: `~/.claude/CLAUDE.md`
- `OpenCode`: `~/.config/opencode/AGENTS.md`
- `Gemini CLI`: `~/.gemini/GEMINI.md`

## 目录结构

- `rules/global/main.md`: 所有全局规则共享的单一事实来源
- `config/targets.list`: 同步目标清单
- `scripts/sync-agent-rules.sh`: 一键同步脚本
- `scripts/reset-agent-rules.sh`: 一键重置到仓库基线

## 用法

默认使用复制模式，同步全部目标：

```bash
./scripts/sync-agent-rules.sh
```

明确执行“重置到仓库基线”：

```bash
./scripts/reset-agent-rules.sh
```

预览重置动作但不落盘：

```bash
./scripts/reset-agent-rules.sh --dry-run
```

使用软连接模式：

```bash
./scripts/sync-agent-rules.sh --mode symlink
```

只同步全局规则：

```bash
./scripts/sync-agent-rules.sh --group global
```

预览将执行的动作，但不落盘：

```bash
./scripts/sync-agent-rules.sh --dry-run
```

## 说明

- 默认模式是 `copy`，兼容性最好。
- `reset-agent-rules.sh` 固定使用 `copy + global`，不允许通过参数改成 `symlink` 或只同步部分目标。
- `symlink` 适合个人本机统一维护，但当前仓库只管理全局规则文件，不涉及项目级规则。
- 同步脚本会严格校验目标路径，只允许写入当前管理的 4 个全局规则文件。
- 脚本默认会为被覆盖的目标文件创建时间戳备份。
