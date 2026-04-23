#!/usr/bin/env bash
# .claude/hooks/pre_tool_guard.sh
#
# PURPOSE: Block operations that violate project conventions before they execute.
#          Catches issues at the prevention layer, not the correction layer.
# TRIGGER: PreToolUse — fires before Bash or Write/Edit tool executes.
# EFFECT:  BLOCKING for denied operations (exit 1 with hookSpecificOutput).
#          Transparent for allowed operations (exit 0).
#
# GUARDS:
#   1. Blocks direct `git commit` — commits must go through `make check` first
#   2. Blocks destructive filesystem operations
#   3. Blocks installing unapproved packages
#   4. Warns about writing to test files during [IMPL] tasks (TDD discipline)
#
# PLAYBOOK NOTE:
#   PreToolUse is the only hook that can PREVENT an action rather than
#   react to it. Use it sparingly — only for violations that are hard to
#   undo or that represent fundamental process breaks (not style issues).
#   Style issues belong in post_edit_lint.sh, not here.
#
#   The TDD guard (#2) is the most important for this project. It enforces
#   the [TEST] → [IMPL] pairing at the tool level: an agent working on an
#   [IMPL] issue cannot accidentally modify the test file it's supposed to
#   be making green.

set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

deny() {
  local reason="$1"
  jq -n \
    --arg reason "$reason" \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": $reason
      }
    }'
  exit 0
}

# ── Guard 1: Block direct git commit ─────────────────────────────────────────
# Commits must only happen after `make check` passes.
# Claude should use: make check && git commit -m "..."
if [[ "$TOOL_NAME" == "Bash" ]]; then
  if echo "$COMMAND" | grep -qE '^\s*git commit'; then
    deny "Direct git commit blocked. Run 'make check' first, then commit: make check && git commit -m 'message'. This ensures lint + typecheck + tests all pass before any commit."
  fi
fi

# ── Guard 2: Block rm -rf ─────────────────────────────────────────────────────
if [[ "$TOOL_NAME" == "Bash" ]]; then
  if echo "$COMMAND" | grep -qE 'rm\s+-rf?\s+/|rm\s+-rf?\s+~'; then
    deny "Destructive rm command blocked. Only relative-path deletions are permitted."
  fi
fi

# ── Guard 3: Block unapproved pip/uv add ─────────────────────────────────────
# New dependencies require a DECISION NEEDED (see CLAUDE.md §3 and §9).
APPROVED_PACKAGES="feedparser|trafilatura|openai|structlog|click|httpx|google-auth|google-api-python-client|pydantic|pytest|ruff|mypy|uv"
if [[ "$TOOL_NAME" == "Bash" ]]; then
  if echo "$COMMAND" | grep -qE '(pip install|uv add)\s+'; then
    # Check all packages in the command (handles multi-package installs)
    INSTALL_ARGS=$(echo "$COMMAND" | sed -E 's/(pip install|uv add)\s+//')
    UNAPPROVED=""
    for PKG in $INSTALL_ARGS; do
      # Skip flags and options
      [[ "$PKG" == -* ]] && continue
      # Strip version specifiers (e.g. requests==2.28.0 → requests)
      PKG_NAME=$(echo "$PKG" | sed -E 's/[><=!].*//')
      if ! echo "$PKG_NAME" | grep -qiE "^(${APPROVED_PACKAGES})$"; then
        UNAPPROVED="$PKG_NAME"
        break
      fi
    done
    if [[ -n "$UNAPPROVED" ]]; then
      deny "Package '$UNAPPROVED' is not in the approved dependency list (CLAUDE.md \u00a79). Raise a DECISION NEEDED comment on the current GitHub issue before adding new dependencies."
    fi
  fi
fi

# ── Guard 4: Warn on test file modification during IMPL tasks ─────────────────
# This is advisory (non-blocking exit 0) but injects a warning into Claude's context.
# Full block would be too restrictive (e.g., fixing a fixture is legitimate).
if [[ "$TOOL_NAME" =~ ^(Write|Edit|MultiEdit)$ ]]; then
  if [[ "$FILE_PATH" =~ ^tests/.*\.py$ ]]; then
    # Check if there's an active [IMPL] task signal (set by session start or user prompt)
    # We use a lightweight marker file convention: .claude/.current_task_type
    TASK_TYPE_FILE=".claude/.current_task_type"
    if [[ -f "$TASK_TYPE_FILE" ]]; then
      TASK_TYPE=$(cat "$TASK_TYPE_FILE")
      if [[ "$TASK_TYPE" == "IMPL" ]]; then
        # Non-blocking: inject context warning, don't deny
        jq -n \
          --arg ctx "WARNING: You are modifying a test file during an [IMPL] task. Per TDD protocol (CLAUDE.md \u00a76): implementation tasks make tests green, they do not modify tests. If a test is wrong, raise a DECISION NEEDED comment on the GitHub issue rather than changing the test." \
          '{
            "hookSpecificOutput": {
              "hookEventName": "PreToolUse",
              "permissionDecision": "allow",
              "additionalContext": $ctx
            }
          }'
        exit 0
      fi
    fi
  fi
fi

# All other operations: allow
exit 0
