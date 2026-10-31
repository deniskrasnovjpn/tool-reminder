# tool-reminder

A Claude Code plugin that reminds Claude to suggest tools from your own catalog when they fit the task in front of
you.

You install skills, plugins, MCP servers and command-line tools, and then forget about them at exactly the moment
they would help. tool-reminder keeps a short catalog of those tools and has Claude check every task against it.
When a tool fits, Claude ends its reply with a short note:

```
🧰 Might help:
- fact-checker (ask "fact-check this") — verify the quoted figure first
```

## How it works

- The catalog is a list with one line per tool saying when it helps, and one details file per tool.
- At the start of a session, the plugin loads the catalog and a few rules into Claude's context.
- With every prompt it adds one line asking Claude to check the task against the catalog. Claude reads the details
  file before suggesting anything and suggests at most three tools.
- The catalog changes only when you agree.

## Requirements

- Claude Code running locally: the desktop app, the terminal, or VS Code, on Windows, macOS or Linux. Cloud
  sessions on claude.ai/code are not supported.
- `bash`. On Windows that means Git for Windows (Git Bash).
- `git` is optional. With it, the catalog keeps a history of its edits.

## Install

```
claude plugin marketplace add deniskrasnovjpn/tool-reminder
claude plugin install tool-reminder@tool-reminder
```

Inside a Claude Code session the same works with `/plugin marketplace add deniskrasnovjpn/tool-reminder` and
`/plugin install tool-reminder@tool-reminder`.

## Setup

In the first session after installing, Claude offers to run setup once its first reply is done. You can answer yes,
later (it asks again next session) or never. Setup:

1. creates the data folder (and a git repository in it, if git is installed);
2. imports the catalog of the older `toolbox` version, if it finds one;
3. finds installed tools you haven't used in the last 30 days, judging by your local session transcripts, and
   offers to add them to the catalog.

You can run it again any time with `/tool-reminder:setup`.

## Commands

| Command | What it does |
| --- | --- |
| `/tool-reminder:index` | Opens the catalog index in your default text editor |
| `/tool-reminder:add <tool>` | Researches the tool and drafts a catalog entry for you to approve |
| `/tool-reminder:remove <slug>` | Removes an entry |
| `/tool-reminder:edit <slug>` | Opens an entry in your text editor; say "done" when finished |
| `/tool-reminder:revision` | Compares the catalog with installed tools and the collected feedback |
| `/tool-reminder:tips` | Turns the catalog into spinner tips that replace the built-in ones |
| `/tool-reminder:setup` | Runs setup |

A plain request works too: "add rclone to the catalog".

Entries are written in the language you are talking to Claude in.

## Spinner tips

`/tool-reminder:tips` makes one tip per catalog entry from its command and its index line, such as
`/teach — <the index line of teach>`, and shows you the list. For a tip worded differently from the index line,
add a line `Tip: <text>` to the entry's `tools/<slug>.md`; the command takes that line as it is. Once you approve it, the tips go into `spinnerTipsOverride` in
`~/.claude/settings.json`, and Claude Code shows them while it works, in place of its own tips.

Entries with nothing to type in Claude Code, such as tools that only work in the Claude app, get no tip. Tips you
added yourself stay: the plugin's tips have ids starting with `tool-reminder.`, and running the command again
replaces only those. After you add, remove or edit an entry, Claude offers to refresh the tips.

Changes show up the next time Claude Code starts. To see the built-in tips again next to yours, set
`excludeDefault` to `false` in `spinnerTipsOverride`.

## Settings

| Option | Default | Meaning |
| --- | --- | --- |
| `data_dir` | `~/.claude/tool-reminder` | Where your catalog lives |
| `feedback_questions` | off | Debug feature: after a suggestion, Claude asks whether it was useful and logs the answer |

To change them, run `claude plugin configure tool-reminder@tool-reminder`, or ask Claude to do it.

## Turning it off

```
claude plugin disable tool-reminder@tool-reminder
claude plugin enable tool-reminder@tool-reminder
```

## Your data

```
~/.claude/tool-reminder/
  index.md          one line per tool: "- <slug>: <when it helps>"
  tools/<slug>.md   details: what, when, how to run, caveats, source
  feedback.log      answers to usefulness questions
  state/            small flags
```

The folder is separate from the plugin, so updating or uninstalling the plugin leaves it alone. The catalog holds
at most 30 entries, and each index line is at most 300 characters.

## License

MIT
