#!/bin/bash
# Tells which tools were used in the last 30 days, judging by local session transcripts.
# Input on stdin, one spec per line: skill:<name>, plugin:<name>, mcp:<server>, cli:<name>.
# Output, one line per spec: "<spec><TAB>used <YYYY-MM-DD>" (newest transcript that mentions it) or "<spec><TAB>unused".
. "$(dirname "$0")/common.sh"
DAYS=30
PROJECTS="$TR_CONFIG_DIR/projects"

# Transcripts are deleted after cleanupPeriodDays (default 30); a shorter period shortens the window.
keep=$(grep -ho '"cleanupPeriodDays" *: *[0-9]*' "$TR_CONFIG_DIR/settings.json" 2>/dev/null | grep -o '[0-9]*$' | tail -1)
[ -n "$keep" ] && [ "$keep" -lt "$DAYS" ] &&
  echo "warning: transcripts are kept $keep days, so the window is $keep days, not $DAYS" >&2

files=()
if [ -d "$PROJECTS" ]; then
  while IFS= read -r f; do files+=("$f"); done < <(find "$PROJECTS" -name '*.jsonl' -mtime -"$DAYS" 2>/dev/null)
fi

# Escapes a name for an extended regular expression.
re_escape() { printf '%s' "$1" | sed 's/[][\.*^$+?(){}|/]/\\&/g'; }

specs=() pats=() name_pats=() cli_pats=()
while IFS= read -r spec; do
  spec="${spec%$'\r'}"
  [ -n "$spec" ] || continue
  kind="${spec%%:*}"
  n=$(re_escape "${spec#*:}")
  case "$kind" in
    skill) pat="\"skill\":\"$n\"|<command-name>/?$n</command-name>" ;;
    plugin) pat="\"skill\":\"$n:|<command-name>/?$n:|\"name\":\"mcp__plugin_${n}_" ;;
    mcp) pat="\"name\":\"mcp__${n}__" ;;
    cli) pat="\"command\":\"([^\"\\\\]|\\\\.)*[\" &|;(]$n([ \"]|\\\\n)" ;;
    *) printf '%s\tunknown kind\n' "$spec"; continue ;;
  esac
  specs+=("$spec") pats+=("$pat")
  if [ "$kind" = cli ]; then cli_pats+=("$pat"); else name_pats+=("$pat"); fi
done
[ "${#specs[@]}" -gt 0 ] || exit 0

# "<file><TAB><matched text>" per distinct match. Two passes: grep slows down sharply when the
# backtracking CLI patterns share one alternation with the others.
scan() {
  [ "$#" -gt 0 ] && [ "${#files[@]}" -gt 0 ] || return 0
  local all
  all=$(IFS='|'; printf '%s' "$*")
  grep -oHZE "$all" "${files[@]}" 2>/dev/null | tr '\0' '\t'
}
hits=$({ scan "${name_pats[@]}"; scan "${cli_pats[@]}"; } | sort -u)

for i in "${!specs[@]}"; do
  latest=""
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    d=$(date -r "$f" +%Y-%m-%d 2>/dev/null)
    [[ "$d" > "$latest" ]] && latest="$d"
  # The pattern goes through ENVIRON: awk -v would eat its backslashes.
  done < <(printf '%s\n' "$hits" | RE="${pats[$i]}" awk -F'\t' 'NF>1 && $2 ~ ENVIRON["RE"] {print $1}' | sort -u)
  if [ -n "$latest" ]; then printf '%s\tused %s\n' "${specs[$i]}" "$latest"; else printf '%s\tunused\n' "${specs[$i]}"; fi
done
exit 0
