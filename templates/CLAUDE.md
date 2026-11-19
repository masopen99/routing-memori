## Tool routing (memory and code)

Use one tool per question type. Do not run two tools for the same question. Pick from this table first; fall back to Grep/Read only when the chosen tool does not cover it. Delete rows for tools you do not have.

| Need | Tool |
| --- | --- |
| Remember a fact across sessions | Claude auto-memory files (`~/.claude/projects/<slug>/memory/`) |
| Recall: exact name or known topic | Read `MEMORY.md` index, then the one memory file |
| Recall: fuzzy, across many notes | Semantic index of the vault (for example OpenViking `find`) |
| Code relationships: callers, call paths, architecture | Code graph MCP (for example `codebase-memory-mcp`) |
| Precise symbol edit or rename | `serena` |
| Review a diff or PR | `code-review-graph` |
| Literal text: strings, env names, config keys, logs | Grep |

Memory rules:
- One source of truth: the Markdown memory files. Obsidian only views and edits the same files through a symlink. A semantic index is read-only; do not store memories in it.
- Keep `MEMORY.md` short: one line per memory. Keep each memory file to one fact with `[[links]]` to related memories.
- Update or delete stale memories instead of adding near-duplicates.
