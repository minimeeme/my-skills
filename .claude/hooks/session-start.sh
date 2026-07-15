#!/bin/bash
# SessionStart hook: load the Minkills skill collection into Claude Code on the web.
#
# Claude Code cloud/web sessions start in a fresh container and clone only the
# repo being worked on, so a local `~/.claude/skills` install does not carry
# over. This hook clones the Minkills repo and copies its skills into
# `~/.claude/skills` so they are available for the session.
#
# It runs only in the remote (web) environment; local sessions are left alone.

set -uo pipefail

# Only run in Claude Code on the web; local machines keep their own setup.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

DEST="${HOME}/.claude/skills"
mkdir -p "$DEST"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if git clone --depth 1 https://github.com/minimeeme/Minkills.git "$TMP/Minkills" >/dev/null 2>&1; then
  # Copy each skill folder; existing folders of the same name are overwritten
  # so re-running the hook always refreshes to the latest Minkills.
  cp -R "$TMP/Minkills/skills/." "$DEST/" 2>/dev/null || true
  echo "[minkills] loaded skills into ~/.claude/skills ($(find "$DEST" -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ') skills total)" 1>&2
else
  echo "[minkills] skipped: could not clone minimeeme/Minkills (private repo may be outside this session's GitHub scope; make it public or add it to scope)" 1>&2
fi

exit 0
