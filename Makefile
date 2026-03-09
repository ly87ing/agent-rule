sync:
	./scripts/sync-agent-rules.sh

reset:
	./scripts/reset-agent-rules.sh

sync-symlink:
	./scripts/sync-agent-rules.sh --mode symlink

dry-run:
	./scripts/sync-agent-rules.sh --dry-run
