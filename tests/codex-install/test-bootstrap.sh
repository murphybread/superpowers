#!/usr/bin/env bash
# Responsibility: Verifies the Murphybread installer can bootstrap by cloning or updating the repo before installing.
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

TMP_HOME="$(mktemp -d)"
TMP_WORK="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME" "$TMP_WORK"' EXIT

SOURCE_REPO="$TMP_WORK/source-repo"
BOOTSTRAP_DIR="$TMP_WORK/bootstrap"

cp -a "$REPO_ROOT" "$SOURCE_REPO"
rm -rf "$SOURCE_REPO/.git"
git -C "$SOURCE_REPO" init >/dev/null 2>&1
git -C "$SOURCE_REPO" config user.name test >/dev/null 2>&1
git -C "$SOURCE_REPO" config user.email test@example.com >/dev/null 2>&1
git -C "$SOURCE_REPO" checkout -b main >/dev/null 2>&1
git -C "$SOURCE_REPO" add -A >/dev/null 2>&1
git -C "$SOURCE_REPO" commit -m "test bootstrap source" >/dev/null 2>&1

mkdir -p "$BOOTSTRAP_DIR"
cp "$REPO_ROOT/install.sh" "$BOOTSTRAP_DIR/install.sh"

HOME="$TMP_HOME" \
SUPERPOWERS_REPO_URL="$SOURCE_REPO" \
SUPERPOWERS_INSTALL_DIR="$TMP_HOME/.codex/superpowers" \
bash "$BOOTSTRAP_DIR/install.sh"

assert_file_exists "$TMP_HOME/.codex/AGENTS.md"
assert_file_exists "$TMP_HOME/.claude/CLAUDE.md"
assert_symlink_target "$TMP_HOME/.agents/skills/superpowers" "$TMP_HOME/.codex/superpowers/skills"
assert_symlink_target "$TMP_HOME/.claude/skills/managing-kanban" "$TMP_HOME/.codex/superpowers/skills/managing-kanban"
assert_symlink_target "$TMP_HOME/.claude/skills/writing-results" "$TMP_HOME/.codex/superpowers/skills/writing-results"

cmp -s "$SOURCE_REPO/AGENTS.md" "$TMP_HOME/.codex/AGENTS.md" || fail "Installed AGENTS.md does not match source repo"
cmp -s "$SOURCE_REPO/CLAUDE.md" "$TMP_HOME/.claude/CLAUDE.md" || fail "Installed CLAUDE.md does not match source repo"

echo "PASS"
