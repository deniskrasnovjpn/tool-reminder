#!/bin/bash
# Checks the catalog limits: at most 30 entries, descriptions up to 300 characters,
# index up to 9,500 characters, every entry has tools/<slug>.md and every file has an entry.
# Prints violations; exits 1 if there are any. Optional argument: the data folder.
[ -n "$1" ] && export TOOL_REMINDER_DIR="$1"
. "$(dirname "$0")/common.sh"
cd "$TR_DIR" || { echo "No data folder: $TR_DIR"; exit 1; }
[ -f index.md ] || { echo "No index.md in $TR_DIR"; exit 1; }
fail=0
n=$(grep -c '^- ' index.md)
[ "$n" -gt 30 ] && { echo "Entries: $n (max 30)"; fail=1; }
size=$(wc -m < index.md)
[ "$size" -gt 9500 ] && { echo "index.md: $size characters (max 9500)"; fail=1; }
while IFS= read -r line; do
  slug=$(printf '%s' "$line" | sed 's/^- \([^:]*\):.*/\1/')
  desc=$(printf '%s' "$line" | sed 's/^- [^:]*: *//')
  len=${#desc}
  [ "$len" -gt 300 ] && { echo "$slug: description $len characters (max 300)"; fail=1; }
  [ -f "tools/$slug.md" ] || { echo "$slug: missing tools/$slug.md"; fail=1; }
done < <(grep '^- ' index.md)
for f in tools/*.md; do
  [ -e "$f" ] || continue
  slug=$(basename "$f" .md)
  grep -q "^- $slug:" index.md || { echo "$f: no line in index.md"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "OK: $n entries, index.md $size characters"
exit "$fail"
