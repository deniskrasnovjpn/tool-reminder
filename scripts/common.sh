#!/bin/bash
# Shared helpers, sourced by the other scripts.
# Data folder: $TOOL_REMINDER_DIR, else the plugin option data_dir, else <Claude config dir>/tool-reminder.
export LC_ALL=C.UTF-8

TR_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

tr_data_dir() {
  local d="${TOOL_REMINDER_DIR:-${CLAUDE_PLUGIN_OPTION_DATA_DIR:-}}"
  # An unset option can arrive as an unsubstituted placeholder.
  case "$d" in '' | '${'*) d="$TR_CONFIG_DIR/tool-reminder" ;; esac
  case "$d" in '~' | '~/'*) d="$HOME${d#\~}" ;; esac
  printf '%s\n' "${d%/}"
}

TR_DIR="$(tr_data_dir)"

tr_feedback_on() {
  case "${CLAUDE_PLUGIN_OPTION_FEEDBACK_QUESTIONS:-false}" in
    true | 1 | yes) return 0 ;;
  esac
  return 1
}

tr_has_git() {
  command -v git >/dev/null 2>&1 && [ -d "$TR_DIR/.git" ]
}

tr_has_entries() {
  grep -q '^- ' "$TR_DIR/index.md" 2>/dev/null
}

# First 8 characters of session_id from the hook's JSON input.
tr_session_id() {
  local sid
  sid=$(printf '%s' "$1" | grep -o '"session_id" *: *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  printf '%s' "${sid:0:8}"
}
