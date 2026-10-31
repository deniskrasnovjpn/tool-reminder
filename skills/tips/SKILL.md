---
name: tips
description: Turn the tool-reminder catalog into Claude Code spinner tips that replace the built-in ones. Use when the user asks for tips from the catalog or to refresh them.
---

# Spinner tips from the catalog

**Paths.** The data folder and the scripts folder are named in the `## tool-reminder` block from session start.
Without that block: data folder = output of `bash "${CLAUDE_SKILL_DIR}/../../scripts/datadir.sh"`. Settings file:
`${CLAUDE_CONFIG_DIR:-~/.claude}/settings.json`, the user settings; Claude Code reads tip objects and
`excludeDefault` only from user, managed and `--settings` settings. Talk to the user, and write the tips, in the
language of the conversation.

A tip from the catalog is the object `{ "id": "tool-reminder.<slug>", "text": "<tip>" }` in
`spinnerTipsOverride.tips`. The id prefix marks the tips this skill owns; every other entry in that list is the
user's own.

1. **Read** `<data>/index.md` and every `<data>/tools/<slug>.md`.
2. **Write one tip per entry**, shaped `<launch> — <what it does>`:
   - _launch_ is what the user types, taken from the entry's run line: a slash command or a key combination,
     bare, without placeholder arguments (`/teach`, `/doctor prompt-audit`). A skill without a command of its
     own launches by its bare name, `/<skill>`: Claude Code runs a plugin skill by its bare name unless another
     command already has it.
   - _what it does_ is the entry's use, compressed from its "when" line into a statement.
   - Length: 33 to 148 characters, the range of the built-in tips (Claude Code 2.1.316); aim for 60 to 130.
   - Skip an entry that has nothing to type in Claude Code: no command and no key combination, or a tool that
     works only elsewhere (for example only in the Claude app). Note each skipped slug and the reason.
3. **Show** the tips as a numbered list with their length in characters, then the skipped slugs, then the change
   to settings: the catalog tips replaced, the user's own tips kept, the built-in tips turned off (Claude Code's
   plugin suggestions among them). Point out any of the user's own entries that launch the same command as a new
   tip and offer to remove them. Write only after a yes; on corrections, show the list again.
4. **Write** `spinnerTipsOverride` in the settings file, touching nothing else in the file:
   - remove the entries whose `id` starts with `tool-reminder.`, and the user's entries they agreed to remove;
   - insert the new tip objects at the start of `tips`, in index order; every other entry stays as it is;
   - set `excludeDefault` to `true`; `label` and `tipsFile` stay as they are.
5. **Verify**: the settings file parses as JSON (`jq empty <file>`, or `node -e` with `JSON.parse`), and `tips`
   holds exactly the new catalog tips plus the user's kept entries. Tell the user the tips appear at the next
   start of Claude Code, and that setting `excludeDefault` to `false` brings the built-in tips back alongside
   them.
