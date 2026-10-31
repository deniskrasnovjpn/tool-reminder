# tool-reminder rules

Below is the index of the user's tool catalog: lines `- <slug>: <when it helps>`. The details of each tool are in
`<data folder>/tools/<slug>.md` (the data folder is named above). The user knows these tools but forgets them at
the moment they would help. Your job is to remind them in time.

## Check on every reply

The line `tool-reminder: check the task against the catalog.` in a user message starts the check.

1. Match the current task against the index. A candidate is a tool that would move this particular task forward.
2. For each new candidate, read its `tools/<slug>.md`. Keep only the candidates the file confirms.
3. If any are confirmed, put a block of at most three items at the end of the reply, before a closing question if
   there is one. Write it in the language of the conversation; in English it reads:
   ```
   🧰 Might help:
   - <slug> (<how to run it, from the file>) — <reason in 3–5 words>
   ```
   Mark a tool you would run yourself with "I can run it" (in the language of the conversation) and run it only
   after the user says yes.
4. If none are confirmed, end the reply as usual, without the block.
5. A tool already suggested for the current task stays in that earlier reply. For a new task it can be suggested
   again.

## Usefulness questions

This section applies only when the block above says `Usefulness questions: on`, and only to the slugs in the
`Watched` line. Skip it when the trigger line says "no usefulness questions".

1. End a reply whose 🧰 block contains such slugs with AskUserQuestion: one question per such slug,
   "<slug> — was the hint useful?", options "Yes", "No", "Don't ask in this session" (in the language of the
   conversation).
2. Append each answer as a line to `<data folder>/feedback.log`:
   `<YYYY-MM-DDTHH:MM> | <slug> | <yes, no, other or dont-ask> | <Other text or empty> | <the task in 5–10 words>`
3. On "Don't ask in this session", create the empty file `<data folder>/state/noask-<session>`. The session number
   is in the block above.

## Catalog maintenance

The catalog changes only after the user says yes. When the user mentions a tool that is not in the index, or a
tool from the index has stopped working, offer it in one line: "Add X to the catalog?" or "Remove X from the
catalog?" (in the language of the conversation). On yes, follow the skill tool-reminder:add or
tool-reminder:remove. The user can also ask for any catalog action in plain words; follow the matching
tool-reminder skill (setup, index, add, remove, edit, revision, tips).

After an entry is added, removed or edited, check the user settings
(`${CLAUDE_CONFIG_DIR:-~/.claude}/settings.json`) for tips with ids starting `tool-reminder.`; if there are any,
offer in one line to refresh them with tool-reminder:tips.
