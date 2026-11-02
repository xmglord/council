#!/usr/bin/env bash
# Symlink the council skill and agents into the user-level Claude Code config.
# Idempotent; never overwrites a real file or directory.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

link() {
    local src="$1" dst="$2"
    if [[ -L "$dst" ]]; then
        ln -sfn "$src" "$dst"
    elif [[ -e "$dst" ]]; then
        echo "skip: $dst exists and is not a symlink" >&2
        return
    else
        ln -s "$src" "$dst"
    fi
    echo "linked: $dst -> $src"
}

mkdir -p "$claude_dir/skills" "$claude_dir/agents"
# Remove links to agents that no longer exist in the repo.
for dst in "$claude_dir"/agents/council-*.md; do
    if [[ -L "$dst" && ! -e "$dst" ]]; then
        rm "$dst"
        echo "removed dangling: $dst"
    fi
done
link "$repo/skills/council" "$claude_dir/skills/council"
for agent in "$repo"/agents/council-*.md; do
    link "$agent" "$claude_dir/agents/$(basename "$agent")"
done
