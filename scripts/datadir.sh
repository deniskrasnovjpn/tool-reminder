#!/bin/bash
# Prints the data folder. Optional argument: the data_dir option value, for callers outside hooks.
[ -n "$1" ] && export TOOL_REMINDER_DIR="$1"
. "$(dirname "$0")/common.sh"
printf '%s\n' "$TR_DIR"
