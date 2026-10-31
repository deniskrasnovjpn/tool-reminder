---
name: add
description: Add a tool to the tool-reminder catalog. Use when the user asks to add a tool to the catalog or says yes to "Add X to the catalog?".
argument-hint: "<tool>"
---

# Add a tool to the catalog

**Paths.** The data folder and the scripts folder are named in the `## tool-reminder` block from session start.
Without that block: data folder = output of `bash "${CLAUDE_SKILL_DIR}/../../scripts/datadir.sh"`, scripts =
`${CLAUDE_SKILL_DIR}/../../scripts`. Talk to the user, and write the catalog entry, in the language of the
conversation.

Tool: `$ARGUMENTS` (if empty, ask which tool).

1. **Find the documentation.** Libraries, CLIs and services: Context7 first, then the web. A skill: its
   `SKILL.md`. An MCP server or connector: its instructions and tool descriptions. Look separately for how the
   maker phrases when to use the tool: a skill's `description`, a server's instructions, "When to use" sections.
2. **Pick the slug**: lowercase Latin letters and hyphens, after the tool's name. It must not be in the index yet.
3. **Write out every situation** where the tool is needed: each distinct use case, plus the "not for …" boundary
   where it is easily confused with a neighbour.
4. **Compress it into the index line** `- <slug>: <when it helps>`. The line has one job: deciding whether the
   tool applies to a given task. It names only the purpose and the user's situations that call for the tool, plus
   the "not for …" boundary; commands, flags and how to run it live in the tool file. As long as that decision
   needs, at most 300 characters; short beats padded. Write for the user's own tasks, not for a programmer.
5. **Write `tools/<slug>.md`**:
   ```
   # <slug>
   What: <one line>
   When: <use cases, more detailed than the index line>
   Run: <how to call it: command, phrase, slash command>
   Commands and flags: <what matters for using it>
   Caveats: <limits, common mistakes>
   Source: <documentation URL>
   ```
   Translate the labels (What, When, …) into the language of the entry.
6. **Show** the user the index line and the whole file. Write them only after a yes.
7. **Check and commit.** Append the line to `index.md`, write the file, run `bash "<scripts>/check.sh"` until it
   prints `OK`. If the data folder is a git repository: `git -C "<data>" add index.md tools` and commit with the
   subject `<slug>: add`.

Several tools at once (for example from setup): show all entries together for one confirmation, then commit them
in one commit with the subject `<slug>, <slug>, …: add`.
