---
name: remove
description: Remove a tool from the tool-reminder catalog. Use when the user asks to remove a tool from the catalog or says yes to "Remove X from the catalog?".
argument-hint: "<slug>"
---

# Remove a tool from the catalog

**Paths.** The data folder and the scripts folder are named in the `## tool-reminder` block from session start.
Without that block: data folder = output of `bash "${CLAUDE_SKILL_DIR}/../../scripts/datadir.sh"`, scripts =
`${CLAUDE_SKILL_DIR}/../../scripts`. Talk to the user in the language of the conversation.

Slug: `$ARGUMENTS` (if empty or not in the index, show the index and ask which one).

1. Show the index line and say that `tools/<slug>.md` goes with it. Ask for confirmation.
2. On yes: delete the line from `index.md` and the file `tools/<slug>.md`.
3. Run `bash "<scripts>/check.sh"` until it prints `OK`. If the data folder is a git repository:
   `git -C "<data>" add -A index.md tools` and commit with the subject `<slug>: remove`.
