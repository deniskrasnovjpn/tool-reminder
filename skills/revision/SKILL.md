---
name: revision
description: Review the tool-reminder catalog against installed tools and collected feedback. Use when the user asks for a catalog revision or review, or the session-start block suggests one.
---

# Catalog revision

**Paths.** The data folder and the scripts folder are named in the `## tool-reminder` block from session start.
Without that block: data folder = output of `bash "${CLAUDE_SKILL_DIR}/../../scripts/datadir.sh"`, scripts =
`${CLAUDE_SKILL_DIR}/../../scripts`. Talk to the user in the language of the conversation.

1. **Inventory**: follow `${CLAUDE_SKILL_DIR}/../../reference/inventory.md`.
2. **Compare with the index**, three lists:
   - installed, not in the catalog, unused for 30 days (from step 1);
   - in the catalog, not found among the installed tools;
   - violations reported by `bash "<scripts>/check.sh"`.
3. **Feedback**: the lines of `<data>/feedback.log` after the last line starting with `---`. Group them by slug.
   For slugs with "no" and "other" answers, propose a concrete edit of the index line or of `tools/<slug>.md`. If
   the answers point to a general failure (hints out of place, too frequent, missed), propose an edit of the
   rules and tell the user it belongs in the plugin's `rules/rules.md`, not in the catalog. Skip this step when
   there is no feedback.
4. **Apply** each proposal only after a yes: adding through tool-reminder:add, removing through
   tool-reminder:remove, edits in place followed by `check.sh` and, with git, a commit `<slug>: edit`.
5. If step 3 had feedback, append to `feedback.log` the line `--- reviewed <YYYY-MM-DDTHH:MM>`.
