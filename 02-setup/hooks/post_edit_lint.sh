#!/usr/bin/env bash
# .claude/hooks/post_edit_lint.sh
#
# PURPOSE: Run ruff (lint + format check) and mypy on every file Claude edits.
# TRIGGER: PostToolUse — fires after Write, Edit, or MultiEdit tool completes.
# EFFECT:  Non-blocking. Failures are shown to Claude as feedback, not hard stops.
#          Claude sees the output and self-corrects on the next turn.
#
# PLAYBOOK NOTE:
#   This hook enforces CLAUDE.md §4 (language, runtime & style) and §7 (quality gates)
#   automatically — not by relying on Claude remembering to run lint.
#   The distinction from CLAUDE.md: "hooks are deterministic and guarantee
#   the action happens" vs instructions which are advisory.
#
#   Exit 1 on PostToolUse is NON-BLOCKING by Claude Code design — Claude sees
#   the lint output and self-corrects on the next turn without being forced to
#   continue (unlike Stop hook exit 2, which blocks task completion).

set -euo pipefail

# Verify required tools are available before any use
if ! command -v jq >/dev/null 2>&1; then
  exit 0  # jq unavailable: skip hook rather than failing noisily
fi

# Parse the tool input JSON from stdin
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only process Python files in radar/ or tests/
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

if [[ ! "$FILE_PATH" =~ \.(py)$ ]]; then
  exit 0
fi

if [[ ! "$FILE_PATH" =~ ^(radar|tests)/ ]]; then
  exit 0
fi

# Confirm file exists (Claude may have written to a path that doesn't resolve)
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

echo "━━━ Quality Gate: $FILE_PATH ━━━"

# Verify uv is available before running linters
if ! command -v uv >/dev/null 2>&1; then
  echo "[warn] uv not found — skipping lint check"
  exit 0
fi

# --- Ruff lint ---
echo "[lint] ruff check $FILE_PATH"
if ! uv run ruff check "$FILE_PATH" 2>&1; then
  echo "[lint] FAILED — ruff found issues. Claude should fix before proceeding."
  # Exit 1 = non-blocking: Claude sees output and can self-correct
  exit 1
fi

# --- Ruff format check ---
echo "[fmt]  ruff format --check $FILE_PATH"
if ! uv run ruff format --check "$FILE_PATH" 2>&1; then
  echo "[fmt] FAILED — formatting issues found. Run: uv run ruff format $FILE_PATH"
  exit 1
fi

# --- mypy ---
echo "[type] mypy $FILE_PATH"
if ! uv run mypy "$FILE_PATH" 2>&1; then
  echo "[type] FAILED — mypy found type errors. Fix before marking task complete."
  exit 1
fi

echo "[✓] All quality gates passed: $FILE_PATH"
exit 0
