---
name: routing-memori
description: Keep Claude Code memory fast and smart, and route each question to exactly one tool. Use when saving or recalling a fact across sessions, when the user says "ingat ini", "remember this", "lupakan", "forget", "rapikan memori", "clean up memory", or asks which memory or code tool to use. Also use before running several overlapping tools (Obsidian, OpenViking, graphify, code-review-graph, serena, codebase-memory-mcp, semble) for one question.
---

# routing-memori

One source of truth for memory, one tool per question type. Memory lives as Markdown files in the Claude Code memory folder (`~/.claude/projects/<slug>/memory/`). Obsidian, if installed with routing-memori, only shows the same files through a symlink. Never keep a second copy anywhere.

## 1. Route the question

Pick one row. Run only that tool. Fall back to Grep or Read only when the chosen tool does not cover the question. Skip rows for tools that are not installed.

| Need | Tool |
| --- | --- |
| Save a fact for later sessions | Write a memory file (section 2) |
| Recall a known topic or name | Read `MEMORY.md`, then open the one matching file |
| Recall something vague across many notes | Semantic index of the vault, for example OpenViking `find` (read-only) |
| Code relationships: callers, call paths, architecture | Code graph MCP, for example `codebase-memory-mcp` |
| Precise symbol edit or rename | `serena` |
| Review a diff, branch or PR | `code-review-graph` |
| Search a remote repo by URL | `semble` |
| Literal text: strings, env names, config keys, logs | Grep |

Do not ask two tools the same question. If two `CLAUDE.md` rules disagree about which tool goes first, follow this table and tell the user about the conflict.

## 2. Save a memory

1. Read `MEMORY.md`. If a file already covers the fact, update that file. Do not create a near-duplicate.
2. Otherwise write one new file with one fact:

```markdown
---
name: <short-kebab-case-slug>
description: <one line, used to decide relevance later>
metadata:
  type: user | feedback | project | reference
---

<the fact>
**Why:** <reason>            (feedback and project only)
**How to apply:** <action>   (feedback and project only)
Related: [[other-memory-slug]]
```

3. Add one line to `MEMORY.md`: `- [Title](file.md) — short hook`. Keep the index short; it loads every session.
4. Write relative dates as absolute dates (`2026-12-01`, not "next Friday").

Types:
- `user`: who the user is and what they prefer.
- `feedback`: how the user wants you to work, including corrections and approaches they confirmed.
- `project`: goals, deadlines and constraints that the code and git history do not show.
- `reference`: where things live: URLs, dashboards, paths.

Do not save: secrets, things the repo or git history already records, or details that only matter for the current conversation.

## 3. Recall a memory

- Start from `MEMORY.md` and read only the files that match. Do not read the whole folder.
- Treat recalled memories as background that was true when written. Before acting on a file path, function name or flag from memory, check that it still exists.
- If a memory is wrong or out of date, fix or delete it at once.

## 4. Clean up memory ("rapikan memori")

1. List the folder and `MEMORY.md`. Find files missing from the index, index lines without a file, duplicates and stale facts.
2. Merge duplicates into one file and fix `[[links]]` that pointed to the removed file.
3. Show the user the planned deletions and wait for approval before deleting anything.
4. Report what changed: merged, updated, deleted and kept.

## 5. Obsidian

- The vault is usually `~/Documents/Obsidian/Claude-Memory`, where `memory/` is a symlink to the memory folder.
- Edits the user makes in Obsidian are real memory edits. Read the file again before you overwrite it.
- Install or repair the vault with: `curl -fsSL https://raw.githubusercontent.com/masopen99/routing-memori/main/install.sh | bash`
