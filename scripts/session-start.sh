#!/bin/bash
# SessionStart (startup|clear|compact): puts the rules and the catalog index into Claude's context,
# or a one-time setup offer while the plugin is not set up yet.
. "$(dirname "$0")/common.sh"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
sid=$(tr_session_id "$(cat)")

[ ! -f "$TR_DIR/index.md" ] && [ -e "$TR_DIR/state/setup-never" ] && exit 0

echo "## tool-reminder"
echo "Data folder: $TR_DIR"
echo "Plugin scripts: $ROOT/scripts"

if [ ! -f "$TR_DIR/index.md" ]; then
  cat <<EOF
tool-reminder is installed but not set up yet: there is no catalog in the data folder.
In your first reply of this session, after you have answered the user's request, add one line in the
language of the conversation offering setup, with three answers: yes, later, never.
- yes: run the skill tool-reminder:setup.
- later: do nothing; the offer comes back next session.
- never: create the empty file "$TR_DIR/state/setup-never" (with its folder).
Make the offer once per session and do not repeat it after an answer.
EOF
  exit 0
fi

# Manual edits not yet committed (after the index or edit skill without "done").
if tr_has_git; then
  dirty=$(git -C "$TR_DIR" status --porcelain -- index.md tools 2>/dev/null)
  if [ -n "$dirty" ]; then
    echo "The catalog has uncommitted manual edits:"
    printf '%s\n' "$dirty" | sed 's/^/    /'
    echo "In your first reply, offer in one line to check and commit them: show what changed (git diff),"
    echo "run check.sh, then commit with the subject '<slug>[, <slug>...]: edit'."
  fi
fi

tr_has_entries || exit 0

echo "Session: ${sid:-unknown}"
if tr_feedback_on; then echo "Usefulness questions: on"; else echo "Usefulness questions: off"; fi
echo
cat "$ROOT/rules/rules.md"
echo
echo "## Index"
grep '^- ' "$TR_DIR/index.md"
echo

tr_feedback_on || exit 0

# Watched: slugs with fewer than 5 answers since their last commit "<slug>[, <slug>...]: ...".
# Without git every answer counts.
watched=$(
  { tr_has_git && git -C "$TR_DIR" log --format='C %cd %s' --date=format:%Y-%m-%dT%H:%M 2>/dev/null
    [ -f "$TR_DIR/feedback.log" ] && grep -v '^---' "$TR_DIR/feedback.log" |
      awk -F' *\\| *' 'NF>=3 && $3!="не спрашивать" && $3!="dont-ask" {print "F", $1, $2}'
    sed -n 's/^- \([^:]*\):.*/S \1/p' "$TR_DIR/index.md"
  } | awk '
    $1=="C" {
      subj = $0; sub(/^C [^ ]+ /, "", subj)
      if (index(subj, ":") == 0) next
      n_s = split(substr(subj, 1, index(subj, ":") - 1), slugs, /, */)
      for (k = 1; k <= n_s; k++) if (!(slugs[k] in edit)) edit[slugs[k]] = $2
      next
    }
    $1=="F" { n++; ft[n]=$2; fs[n]=$3; next }
    $1=="S" { order[++m]=$2 }
    END {
      for (i=1; i<=n; i++) if (!(fs[i] in edit) || ft[i] >= edit[fs[i]]) cnt[fs[i]]++
      out=""; for (j=1; j<=m; j++) { s=order[j]; if (cnt[s] < 5) out = out (out=="" ? "" : ", ") s }
      print out
    }')
[ -n "$watched" ] && echo "Watched: $watched"

# Answers since the last "--- reviewed" mark.
if [ -f "$TR_DIR/feedback.log" ]; then
  pending=$(awk '/^---/ {c=0; next} NF {c++} END {print c+0}' "$TR_DIR/feedback.log")
  [ "$pending" -ge 10 ] && echo "Unreviewed answers: $pending. Suggest the skill tool-reminder:revision to the user."
fi
exit 0
