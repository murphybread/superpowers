#!/usr/bin/env bash
# Responsibility: Installs Murphybread prompt files and bundled skills into the current user's agent directories only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
MANAGED_MARKER="Managed by murphybread/superpowers install.sh"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"

log() {
    printf '[install] %s\n' "$*"
}

ensure_parent_dir() {
    local path="$1"
    mkdir -p "$(dirname "$path")"
}

backup_target() {
    local path="$1"
    local backup_path="${path}.pre-murphybread-install.${TIMESTAMP}.bak"

    if [ ! -e "$path" ] && [ ! -L "$path" ]; then
        return 1
    fi

    mv "$path" "$backup_path"
    log "Backed up ${path} -> ${backup_path}"
    return 0
}

is_managed_file() {
    local path="$1"
    [ -f "$path" ] && grep -Fq "$MANAGED_MARKER" "$path"
}

install_prompt_file() {
    local source_path="$1"
    local destination_path="$2"

    ensure_parent_dir "$destination_path"

    if [ -e "$destination_path" ] && ! is_managed_file "$destination_path"; then
        backup_target "$destination_path" || true
    fi

    cp "$source_path" "$destination_path"
    log "Installed $(basename "$destination_path")"
}

install_skills_symlink() {
    local destination_path="$HOME/.agents/skills/superpowers"
    local expected_target="$REPO_ROOT/skills"

    mkdir -p "$HOME/.agents/skills"

    if [ -L "$destination_path" ]; then
        local current_target
        current_target="$(readlink "$destination_path")"
        if [ "$current_target" = "$expected_target" ]; then
            log "Skills symlink already points to bundled skills"
            return 0
        fi
    fi

    if [ -e "$destination_path" ] || [ -L "$destination_path" ]; then
        backup_target "$destination_path" || true
    fi

    ln -s "$expected_target" "$destination_path"
    log "Linked skills directory"
}

require_file() {
    local path="$1"
    [ -f "$path" ] || {
        printf 'Missing required file: %s\n' "$path" >&2
        exit 1
    }
}

main() {
    require_file "$REPO_ROOT/AGENTS.md"
    require_file "$REPO_ROOT/CLAUDE.md"

    mkdir -p "$HOME/.codex" "$HOME/.claude" "$HOME/.agents/skills"

    install_prompt_file "$REPO_ROOT/AGENTS.md" "$HOME/.codex/AGENTS.md"
    install_prompt_file "$REPO_ROOT/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    install_skills_symlink

    log "Install complete"
    log "Restart Codex and Claude Code to pick up the updated prompts and skills"
}

main "$@"
