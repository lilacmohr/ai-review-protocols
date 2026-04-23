#!/usr/bin/env bash
# .claude/hooks/session_start.sh
#
# PURPOSE: Load project context at session start so Claude begins every session
#          with current state rather than relying on memory from prior sessions.
# TRIGGER: SessionStart — fires on startup, resume, or /clear.
# EFFECT:  Injects additionalContext into Claude's initial context window.
#
# PLAYBOOK NOTE:
#   Claude has no memory between sessions. SessionStart is the mechanism for
#   giving every new session a consistent baseline — current branch, recent
#   changes, open issues, and the current task type (for TDD guard).
#
#   At team scale: imagine 10 engineers each starting a Claude Code session
#   on different branches. Without SessionStart context injection, each agent
#   starts cold. With it, each agent starts with: "You're on branch feat/pre-filter,
#   3 files changed since last commit, current task is [IMPL] #43."
#   That's the difference between a confused first turn and an immediately
#   productive one.

set -euo pipefail

# ── Git context ───────────────────────────────────────────────────────────────
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
RECENT_CHANGES=$(git diff --name-only HEAD 2>/dev/null | head -10 | tr '\n' ', ' | sed 's/,$//')
LAST_COMMIT=$(git log -1 --format="%h %s" 2>/dev/null || echo "no commits yet")
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

# ── Current task type (for pre_tool_guard TDD enforcement) ────────────────────
# Agents should set this via: echo "IMPL" > .claude/.current_task_type
# or: echo "TEST" > .claude/.current_task_type
# at the start of a session when working on a specific issue type.
TASK_TYPE_FILE=".claude/.current_task_type"
TASK_TYPE="unknown"
CURRENT_ISSUE="unknown"

if [[ -f "$TASK_TYPE_FILE" ]]; then
  TASK_TYPE=$(cat "$TASK_TYPE_FILE" | tr -d '[:space:]')
fi

ISSUE_FILE=".claude/.current_issue"
if [[ -f "$ISSUE_FILE" ]]; then
  CURRENT_ISSUE=$(cat "$ISSUE_FILE" | tr -d '[:space:]')
fi

# ── Test suite status (fast check — unit tests only) ─────────────────────────
TEST_STATUS="unknown"
if [[ -f "pyproject.toml" ]] && find tests/unit -name "*.py" 2>/dev/null | grep -q .; then
  if command -v uv >/dev/null 2>&1; then
    if uv run pytest tests/unit -q --tb=no --no-header 2>/dev/null; then
      TEST_STATUS="✓ unit tests passing"
    else
      TEST_STATUS="✗ unit tests FAILING — check before writing new code"
    fi
  else
    TEST_STATUS="uv not found — cannot check test status"
  fi
else
  TEST_STATUS="no unit tests yet"
fi

# ── Output additionalContext for Claude ───────────────────────────────────────
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo 'project')")
CONTEXT="=== Session Context (${PROJECT_NAME}) ===
Branch: ${BRANCH}
Last commit: ${LAST_COMMIT}
Uncommitted files: ${UNCOMMITTED}
Recently changed: ${RECENT_CHANGES:-none}
Unit test status: ${TEST_STATUS}
Current task type: ${TASK_TYPE}
Current issue: ${CURRENT_ISSUE}

Reminders:
- Read CLAUDE.md before writing any code
- TDD protocol: [TEST] issues before [IMPL] issues
- Quality gate: make check must pass before git commit
- Raise DECISION NEEDED before adding dependencies or changing public interfaces
=== End Session Context ==="

jq -n --arg ctx "$CONTEXT" '{"additionalContext": $ctx}'

exit 0
