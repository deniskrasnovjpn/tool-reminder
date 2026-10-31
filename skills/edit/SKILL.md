---
name: edit
description: Edit a tool-reminder catalog entry in the user's text editor. Use when the user asks to edit, change or fix a catalog entry.
argument-hint: "<slug>"
---

# Edit a catalog entry

**Paths.** The data folder and the scripts folder are named in the `## tool-reminder` block from session start.
Without that block: data folder = output of `bash "${CLAUDE_SKILL_DIR}/../../scripts/datadir.sh"`, scripts =
`${CLAUDE_SKILL_DIR}/../../scripts`. Talk to the user in the language of the conversation.

Slug: `$ARGUMENTS` (if empty or not in the index, show the index and ask which one).

1. Open both files: `bash "<scripts>/open-editor.sh" "<data>/index.md" "<data>/tools/<slug>.md"`. If the script
   prints "could not open", give the user the paths instead.
2. Tell the user which line of `index.md` belongs to the entry and ask them to say "done" when finished.
3. On "done": with git, read `git -C "<data>" diff -- index.md tools`; without git, read both files. Retell the
   changes in a few lines.
4. Run `bash "<scripts>/check.sh"`. On violations, show them and offer fixes; fix only after a yes.
5. With git, commit with the subject `<slug>: edit` (several entries changed: `<slug>, <slug>, …: edit`).

If the user changes their mind instead, offer to restore the files from git (`git -C "<data>" checkout -- <files>`)
and do it only after a yes.
