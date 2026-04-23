#!/usr/bin/env bash
# .claude/hooks/stop_run_tests.sh
#
# PURPOSE: Run the full test suite when Claude signals it has finished a task.
#          If tests fail, Claude is forced to continue working rather than
#          marking the task complete.
# TRIGGER: Stop — fires when Claude finishes responding.
# EFFECT:  BLOCKING. Exit 2 forces Claude to continue. Exit 0 allows stop.
#
# PLAYBOOK NOTE:
#   This is the enforcement layer for the TDD contract in CLAUDE.md §6.
#   "All tests must pass before a task is considered complete" is a rule.
#   This hook makes it a guarantee.
#
#   This hook runs the FULL test suite (unit + integration), unlike session_start.sh
#   which runs unit tests only for a fast startup check. The Stop hook is a
#   completion gate — it must catch all failures, not just fast ones.
#
#   CUSTOMIZE: Replace 'tests' below with your actual test directory name if different.
#   The 'timeout 120' guard prevents a hanging test from blocking the agent forever.

set -euo pipefail

INPUT=$(cat)

# CRITICAL: Prevent infinite loop.
# If Stop hook already fired this turn, allow Claude to stop.
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [[ "$STOP_HOOK_ACTIVE" == "true" ]]; then
  exit 0
fi

# Only run tests if we're in the project root (guard against wrong-dir invocations)
if [[ ! -f "pyproject.toml" ]]; then
  exit 0
fi

# Only run tests if there are Python files in the working tree
# CUSTOMIZE: adjust the directories below to match your project source layout
if ! find tests -name "*.py" -maxdepth 4 2>/dev/null | grep -q .; then
  exit 0
fi

echo "━━━ Stop Gate: Running test suite ━━━"
echo "[test] uv run pytest tests/ -x -q --tb=short"

if timeout 120 uv run pytest tests/ -x -q --tb=short 2>&1; then
  echo "[✓] All tests pass. Task complete."
  exit 0
else
  echo ""
  echo "[✗] Tests failed. Task is NOT complete."
  echo "    Fix the failing tests before finishing."
  echo "    (Claude will continue working.)"
  # Exit 2 = blocking: Claude is forced to continue rather than stop
  exit 2
fi
