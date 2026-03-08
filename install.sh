#!/usr/bin/env bash
# Responsibility: Installs Murphybread prompt files and bundled skills into the current user's agent directories only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
DEFAULT_INSTALL_DIR="$HOME/.codex/superpowers"
INSTALL_ROOT="${SUPERPOWERS_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"
REPO_URL="${SUPERPOWERS_REPO_URL:-https://github.com/murphybread/superpowers.git}"
REPO_BRANCH="${SUPERPOWERS_REPO_BRANCH:-main}"
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

install_claude_skills() {
    local claude_skills_dir="$HOME/.claude/skills"
    mkdir -p "$claude_skills_dir"

    local skill_path
    for skill_path in "$REPO_ROOT"/skills/*; do
        [ -d "$skill_path" ] || continue

        local skill_name
        skill_name="$(basename "$skill_path")"

        local destination_path="$claude_skills_dir/$skill_name"
        if [ -L "$destination_path" ]; then
            local current_target
            current_target="$(readlink "$destination_path")"
            if [ "$current_target" = "$skill_path" ]; then
                continue
            fi
        fi

        if [ -e "$destination_path" ] || [ -L "$destination_path" ]; then
            backup_target "$destination_path" || true
        fi

        ln -s "$skill_path" "$destination_path"
        log "Linked Claude skill $skill_name"
    done
}

require_file() {
    local path="$1"
    [ -f "$path" ] || {
        printf 'Missing required file: %s\n' "$path" >&2
        exit 1
    }
}

is_repo_install_context() {
    [ -f "$SCRIPT_DIR/AGENTS.md" ] && [ -f "$SCRIPT_DIR/CLAUDE.md" ] && [ -d "$SCRIPT_DIR/skills" ]
}

bootstrap_repo_if_needed() {
    mkdir -p "$(dirname "$INSTALL_ROOT")"

    if [ -d "$INSTALL_ROOT/.git" ]; then
        log "Updating bundled repository from $REPO_URL ($REPO_BRANCH)"
        git -C "$INSTALL_ROOT" pull --ff-only "$REPO_URL" "$REPO_BRANCH"
    else
        if [ -e "$INSTALL_ROOT" ]; then
            printf 'Install directory exists but is not a git repository: %s\n' "$INSTALL_ROOT" >&2
            exit 1
        fi
        log "Cloning bundled repository from $REPO_URL ($REPO_BRANCH)"
        git clone --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_ROOT"
    fi
}

run_local_install() {
    REPO_ROOT="$INSTALL_ROOT" SUPERPOWERS_BOOTSTRAPPED=1 bash "$INSTALL_ROOT/install.sh" "$@"
}

main() {
    if [ "${SUPERPOWERS_BOOTSTRAPPED:-0}" != "1" ] && ! is_repo_install_context; then
        bootstrap_repo_if_needed
        run_local_install "$@"
        return 0
    fi

    if is_repo_install_context; then
        REPO_ROOT="$SCRIPT_DIR"
    else
        REPO_ROOT="$INSTALL_ROOT"
    fi

    require_file "$REPO_ROOT/AGENTS.md"
    require_file "$REPO_ROOT/CLAUDE.md"

    mkdir -p "$HOME/.codex" "$HOME/.claude" "$HOME/.agents/skills"

    install_prompt_file "$REPO_ROOT/AGENTS.md" "$HOME/.codex/AGENTS.md"
    install_prompt_file "$REPO_ROOT/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    install_skills_symlink
    install_claude_skills

    log "Install complete"
    log "Local Claude skills were installed into ~/.claude/skills"
    log "Claude plugin marketplace state under ~/.claude/plugins was not modified"
    log "Restart Codex and Claude Code to pick up the updated prompts and skills"
}

main "$@"
