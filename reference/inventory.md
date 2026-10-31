# Inventory of forgotten tools

Shared by the skills tool-reminder:setup and tool-reminder:revision. The result is a list of installed tools that
are not in the catalog and were not used in the last 30 days.

1. **Collect installed tools**, each as a spec:
   - skills: the skill list of this session and the folders in `~/.claude/skills/` → `skill:<name>` (plugin skills
     keep their prefix, `skill:<plugin>:<name>`);
   - plugins: `claude plugin list` → `plugin:<name>`;
   - MCP servers and connectors: the MCP tools of this session and `claude mcp list` → `mcp:<server>`, where
     `<server>` is the middle part of the tool names `mcp__<server>__<tool>`; for claude.ai connectors that part is
     an id, so use the tool descriptions to name the connector to the user;
   - CLIs: the commands that installed skills and `tools/*.md` rely on, present on this machine
     (`command -v <name>`) → `cli:<name>`.
   Leave out tool-reminder itself, Claude Code's built-in tools, and every tool whose slug is in the index.
2. **Filter by use**: pipe the specs, one per line, into `bash "<scripts>/usage.sh"`. Keep the lines marked
   `unused`. If the script warns on stderr that transcripts are kept fewer than 30 days, tell the user the window
   is shorter.
3. **The list** is complete when every installed tool from step 1 is either left out with its reason or has a
   `usage.sh` verdict.
