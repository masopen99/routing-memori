#!/usr/bin/env bash
# Install Obsidian (Linux AppImage) and expose Claude Code auto-memory as an Obsidian vault.
# Memory files stay where Claude Code writes them; the vault only holds a symlink.
set -euo pipefail

VAULT="${VAULT:-$HOME/Documents/Obsidian/Claude-Memory}"
APP_DIR="${APP_DIR:-$HOME/Applications/obsidian}"
BIN_DIR="${BIN_DIR:-$HOME/bin}"

# Claude Code stores memory per project at ~/.claude/projects/<slug>/memory.
# Default slug is the home directory with every non-alphanumeric character replaced by "-".
SLUG="${CLAUDE_PROJECT_SLUG:-$(printf '%s' "$HOME" | sed 's/[^a-zA-Z0-9]/-/g')}"
MEMORY_DIR="${MEMORY_DIR:-$HOME/.claude/projects/$SLUG/memory}"

say() { printf '==> %s\n' "$*"; }

install_obsidian() {
  if [ -x "$APP_DIR/AppRun" ]; then
    say "Obsidian already installed at $APP_DIR"
    return
  fi
  say "Finding latest Obsidian release"
  url=$(curl -fsSL https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
    | grep -o '"browser_download_url": *"[^"]*AppImage"' | grep -v arm64 | head -1 | cut -d'"' -f4)
  [ -n "$url" ] || { echo "Could not find AppImage URL" >&2; exit 1; }
  tmp=$(mktemp -d)
  say "Downloading $url"
  curl -fL --retry 3 -o "$tmp/Obsidian.AppImage" "$url"
  chmod +x "$tmp/Obsidian.AppImage"
  # Extract so it runs without libfuse2.
  (cd "$tmp" && ./Obsidian.AppImage --appimage-extract >/dev/null)
  mkdir -p "$(dirname "$APP_DIR")"
  mv "$tmp/squashfs-root" "$APP_DIR"
  rm -rf "$tmp"
}

install_launcher() {
  mkdir -p "$BIN_DIR" "$HOME/.local/share/applications"
  cat > "$BIN_DIR/obsidian" <<LAUNCH
#!/bin/sh
exec "$APP_DIR/AppRun" --no-sandbox "\$@"
LAUNCH
  chmod +x "$BIN_DIR/obsidian"
  cat > "$HOME/.local/share/applications/obsidian.desktop" <<DESK
[Desktop Entry]
Name=Obsidian
Exec=$BIN_DIR/obsidian %u
Icon=$APP_DIR/obsidian.png
Type=Application
Categories=Office;
MimeType=x-scheme-handler/obsidian;
StartupWMClass=obsidian
DESK
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
}

setup_vault() {
  mkdir -p "$MEMORY_DIR" "$VAULT"
  if [ ! -f "$MEMORY_DIR/MEMORY.md" ]; then
    say "Seeding empty MEMORY.md index"
    printf '# Memory index\n\n' > "$MEMORY_DIR/MEMORY.md"
  fi
  ln -sfn "$MEMORY_DIR" "$VAULT/memory"
  cfg="$HOME/.config/obsidian/obsidian.json"
  if [ ! -f "$cfg" ]; then
    mkdir -p "$(dirname "$cfg")"
    id=$(head -c8 /dev/urandom | od -An -tx1 | tr -d ' \n')
    printf '{"vaults":{"%s":{"path":"%s","ts":%s,"open":true}}}\n' "$id" "$VAULT" "$(date +%s)000" > "$cfg"
  else
    say "Obsidian config exists; open $VAULT with 'Open folder as vault'"
  fi
}

install_obsidian
install_launcher
setup_vault
say "Done. Vault: $VAULT -> memory: $MEMORY_DIR"
say "Run: $BIN_DIR/obsidian"
