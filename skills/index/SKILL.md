---
name: index
description: Open the tool-reminder catalog index in the user's text editor. Use when the user asks to see, open or list the catalog.
---

# Open the catalog index

**Paths.** The data folder and the scripts folder are named in the `## tool-reminder` block from session start.
Without that block: data folder = output of `bash "${CLAUDE_SKILL_DIR}/../../scripts/datadir.sh"`, scripts =
`${CLAUDE_SKILL_DIR}/../../scripts`. Talk to the user in the language of the conversation.

1. If `<data>/index.md` does not exist, say that tool-reminder is not set up and offer the skill
   tool-reminder:setup.
2. Run `bash "<scripts>/open-editor.sh" "<data>/index.md"`. If it prints "could not open", show the index in the
   reply instead.
3. Tell the user, in one line, to say "done" if they edit the file.
4. On "done", continue with steps 3–5 of the skill tool-reminder:edit for the changed entries.
