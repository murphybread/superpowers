#!/usr/bin/env bash
# Responsibility: Verifies the Murphybread installer backs up unmanaged files and links bundled skills only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

assert_file_exists() {
    local path="$1"
    [ -f "$path" ] || fail "Expected file to exist: $path"
}

assert_symlink_target() {
    local path="$1"
    local expected="$2"
    [ -L "$path" ] || fail "Expected symlink: $path"
    local actual
    actual="$(readlink "$path")"
    [ "$actual" = "$expected" ] || fail "Expected $path -> $expected but got $actual"
}

assert_glob_count() {
    local pattern="$1"
    local expected="$2"
    local count
    count=$(find "$(dirname "$pattern")" -maxdepth 1 -name "$(basename "$pattern")" | wc -l | tr -d ' ')
    [ "$count" = "$expected" ] || fail "Expected $expected match(es) for $pattern but found $count"
}

TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

mkdir -p "$TMP_HOME/.codex" "$TMP_HOME/.claude" "$TMP_HOME/.agents/skills/superpowers"
printf 'legacy codex prompt\n' > "$TMP_HOME/.codex/AGENTS.md"
printf 'legacy claude prompt\n' > "$TMP_HOME/.claude/CLAUDE.md"
printf 'legacy skill placeholder\n' > "$TMP_HOME/.agents/skills/superpowers/README.txt"

HOME="$TMP_HOME" bash "$REPO_ROOT/install.sh"

assert_file_exists "$TMP_HOME/.codex/AGENTS.md"
assert_file_exists "$TMP_HOME/.claude/CLAUDE.md"
assert_symlink_target "$TMP_HOME/.agents/skills/superpowers" "$REPO_ROOT/skills"
assert_symlink_target "$TMP_HOME/.claude/skills/managing-kanban" "$REPO_ROOT/skills/managing-kanban"
assert_symlink_target "$TMP_HOME/.claude/skills/writing-results" "$REPO_ROOT/skills/writing-results"

cmp -s "$REPO_ROOT/AGENTS.md" "$TMP_HOME/.codex/AGENTS.md" || fail "Installed AGENTS.md does not match repository copy"
cmp -s "$REPO_ROOT/CLAUDE.md" "$TMP_HOME/.claude/CLAUDE.md" || fail "Installed CLAUDE.md does not match repository copy"

assert_glob_count "$TMP_HOME/.codex/AGENTS.md.pre-murphybread-install.*.bak" "1"
assert_glob_count "$TMP_HOME/.claude/CLAUDE.md.pre-murphybread-install.*.bak" "1"
assert_glob_count "$TMP_HOME/.agents/skills/superpowers.pre-murphybread-install.*.bak" "1"

HOME="$TMP_HOME" bash "$REPO_ROOT/install.sh"

assert_glob_count "$TMP_HOME/.codex/AGENTS.md.pre-murphybread-install.*.bak" "1"
assert_glob_count "$TMP_HOME/.claude/CLAUDE.md.pre-murphybread-install.*.bak" "1"

echo "PASS"
