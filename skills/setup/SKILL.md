---
name: setup
description: Set up tool-reminder - create the data folder, import an old toolbox catalog, suggest forgotten tools. Use when the user agrees to set up tool-reminder or asks to run its setup again.
---

# tool-reminder setup

**Paths.** The data folder and the scripts folder are named in the `## tool-reminder` block from session start.
Without that block: data folder = output of `bash "${CLAUDE_SKILL_DIR}/../../scripts/datadir.sh"`, scripts =
`${CLAUDE_SKILL_DIR}/../../scripts`. Talk to the user in the language of the conversation. Anything outside the
data folder changes only after a yes.

If `<data>/index.md` already exists, setup ran before: go straight to step 3.

## 1. Old toolbox

The old catalog is present when `~/.claude/toolbox/index.md` and `~/.claude/toolbox/rules.md` both exist. If it is
absent, go to step 2. If present, tell the user what will move into the data folder: `index.md`, `tools/`,
`feedback.log` and, if it is a git repository, its history. Ask for a yes.

On yes:
- with git in the old folder: `git clone --no-hardlinks ~/.claude/toolbox "<data>"`, then
  `git -C "<data>" remote remove origin`; remove the engine files the plugin now carries
  (`git -C "<data>" rm -r -q --ignore-unmatch hooks rules.md skill`) and commit `migrate: from toolbox`;
- without git: copy `index.md` and `tools/` into `<data>`;
- in both cases copy `feedback.log` (it is not tracked) and run `bash "<scripts>/check.sh"`.

Then clean up the old setup, one confirmation per item, showing each item first:
1. In `~/.claude/settings.json`, the hook entries whose command contains `/.claude/toolbox/hooks/`. Remove only
   those entries, keep the file valid JSON, and keep every other hook.
2. `~/.claude/skills/toolbox`: remove the link or folder itself, never what it points to.
3. Mentions of toolbox in `~/.claude/CLAUDE.md`, the memory files of this project, and any instruction files the
   user names: propose edits that point to tool-reminder.
4. Last, ask whether to delete `~/.claude/toolbox` or keep it. Delete only on an explicit yes.

## 2. Data folder

Skip what the import already created. Create `<data>/tools/` and `<data>/state/`, an empty `<data>/index.md`, and
`<data>/.gitignore` with the lines `feedback.log` and `state/`. If `git` is available and `<data>/.git` is
missing: `git -C "<data>" init -q` and commit `init`. Without git, tell the user in one line that with git the
catalog would keep a history of its edits.

## 3. Forgotten tools

1. Build the list with `${CLAUDE_SKILL_DIR}/../../reference/inventory.md`.
2. Offer the unused tools with AskUserQuestion, multiSelect, grouped by kind (skills, plugins, MCP, CLI), each
   option labelled with the tool name and a short description of what it does.
3. For the chosen tools follow the skill tool-reminder:add; show all entries together for one confirmation.
4. Nothing unused, or nothing chosen: say so in one line.

## 4. Finish

Tell the user briefly, in a few lines:
- the commands: `/tool-reminder:index`, `:add`, `:remove`, `:edit`, `:revision`, `:setup`; plain requests work too;
- usefulness questions (a debug feature) are off; they are switched on with the plugin option `feedback_questions`
  (`claude plugin configure tool-reminder`), which you can do for them on request;
- the whole plugin is switched off with `claude plugin disable tool-reminder`.
