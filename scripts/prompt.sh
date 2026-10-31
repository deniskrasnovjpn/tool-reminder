#!/bin/bash
# UserPromptSubmit: a short reminder to check the task against the catalog.
# Silent on slash commands and when the catalog is empty.
. "$(dirname "$0")/common.sh"
tr_has_entries || exit 0
input=$(cat)
printf '%s' "$input" | grep -qE '"prompt" *: *"/' && exit 0

sid=$(tr_session_id "$input")
if ! tr_feedback_on || { [ -n "$sid" ] && [ -e "$TR_DIR/state/noask-$sid" ]; }; then
  echo "tool-reminder: check the task against the catalog; no usefulness questions."
else
  echo "tool-reminder: check the task against the catalog."
fi
exit 0
