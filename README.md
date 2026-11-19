# claude-obsidian-memory

See and edit Claude Code's memory in Obsidian, without copying it.

Claude Code saves long-term memory as Markdown files in `~/.claude/projects/<slug>/memory/`. This repo turns that folder into an Obsidian vault with one symlink. Claude keeps writing to the same place; Obsidian shows the notes, the `[[links]]` between them, and the graph view.

## Why

- **One source of truth.** No sync job and no second copy that drifts.
- **Fast.** Nothing runs in the background. Obsidian reads plain files.
- **Smart recall.** Memories are small, one fact each, linked with `[[name]]`, and listed in a short `MEMORY.md` index that Claude loads every session.

## Install (Linux)

```bash
git clone https://github.com/<you>/claude-obsidian-memory
cd claude-obsidian-memory
./scripts/install.sh
obsidian   # or ~/bin/obsidian
```

The script:

1. Downloads the latest official Obsidian AppImage and extracts it to `~/Applications/obsidian` (works without `libfuse2`).
2. Adds a launcher at `~/bin/obsidian` and a desktop entry.
3. Creates the vault `~/Documents/Obsidian/Claude-Memory` with `memory/` linked to your Claude memory folder.

Safe to run again. Settings via environment variables:

| Variable | Default |
| --- | --- |
| `VAULT` | `~/Documents/Obsidian/Claude-Memory` |
| `APP_DIR` | `~/Applications/obsidian` |
| `BIN_DIR` | `~/bin` |
| `CLAUDE_PROJECT_SLUG` | your home path with non-alphanumeric characters replaced by `-` (for example `-home-alice`) |
| `MEMORY_DIR` | `~/.claude/projects/$CLAUDE_PROJECT_SLUG/memory` |

Memory for another project: start Claude Code in that folder once, then run the script with `CLAUDE_PROJECT_SLUG` set to that folder's slug.

macOS and Windows: install Obsidian normally, then link the memory folder into your vault (`ln -s` on macOS, `mklink /D` on Windows).

## Keep memory fast and smart

Copy `templates/CLAUDE.md` into your own `CLAUDE.md`. It gives Claude:

- a routing table, so it asks one tool per question instead of several overlapping ones;
- memory rules: one fact per file, short index, update instead of duplicate.

`templates/memory/` shows the file format with two linked examples.

## Notes

- The launcher runs Obsidian with `--no-sandbox`, because the extracted AppImage cannot use the setuid sandbox. Only open vaults and plugins you trust.
- Do not commit or share your real memory folder. It can hold personal details.

## License

MIT
