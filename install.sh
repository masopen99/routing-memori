#!/usr/bin/env bash
# routing-memori installer.
# One line:  curl -fsSL https://raw.githubusercontent.com/masopen99/routing-memori/main/install.sh | bash
# Installs Obsidian (if missing) and exposes Claude Code auto-memory as an Obsidian vault.
# Memory files stay where Claude Code writes them; the vault only holds a symlink.
# Everything is inside main() so a partial download never runs half a script.
set -euo pipefail

main() {
  local os; os="$(uname -s)"
  VAULT="${VAULT:-$HOME/Documents/Obsidian/Claude-Memory}"
  BIN_DIR="${BIN_DIR:-$HOME/bin}"
  # Claude Code stores memory per project at ~/.claude/projects/<slug>/memory.
  # The slug is the project path with every non-alphanumeric character replaced by "-".
  SLUG="${CLAUDE_PROJECT_SLUG:-$(printf '%s' "$HOME" | sed 's/[^a-zA-Z0-9]/-/g')}"
  MEMORY_DIR="${MEMORY_DIR:-$HOME/.claude/projects/$SLUG/memory}"

  say "routing-memori"
  case "$os" in
    Linux)
      APP_DIR="${APP_DIR:-$HOME/Applications/obsidian}"
      OBS_CFG="$HOME/.config/obsidian/obsidian.json"
      install_linux
      ;;
    Darwin)
      OBS_CFG="$HOME/Library/Application Support/obsidian/obsidian.json"
      install_macos
      ;;
    *)
      die "Unsupported OS: $os. Install Obsidian yourself and run: ln -s \"$MEMORY_DIR\" \"<vault>/memory\""
      ;;
  esac
  setup_vault
  say "Done."
  say "  Vault : $VAULT"
  say "  Memory: $MEMORY_DIR"
  if [ "$os" = Linux ]; then say "  Open  : $BIN_DIR/obsidian"; else say "  Open  : open -a Obsidian"; fi
}

say() { printf '\033[1;35m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing command: $1"; }

install_linux() {
  need curl
  if [ -x "$APP_DIR/AppRun" ]; then
    say "Obsidian already installed at $APP_DIR"
  elif command -v obsidian >/dev/null 2>&1; then
    say "Obsidian found on PATH: $(command -v obsidian)"
    return
  else
    local arch pattern url tmp
    arch="$(uname -m)"
    case "$arch" in
      x86_64) pattern='/Obsidian-[0-9.]+\.AppImage$' ;;
      aarch64|arm64) pattern='/Obsidian-[0-9.]+-arm64\.AppImage$' ;;
      *) die "Unsupported CPU: $arch" ;;
    esac
    say "Finding latest Obsidian release"
    url="$(curl -fsSL https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
      | grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4 | grep -E -- "$pattern" | head -n 1 || true)"
    [ -n "$url" ] || die "could not find Obsidian AppImage for $arch"
    tmp="$(mktemp -d)"
    say "Downloading $url"
    curl -fL --retry 3 --progress-bar -o "$tmp/Obsidian.AppImage" "$url"
    chmod +x "$tmp/Obsidian.AppImage"
    say "Extracting (no libfuse2 needed)"
    (cd "$tmp" && ./Obsidian.AppImage --appimage-extract >/dev/null)
    mkdir -p "$(dirname "$APP_DIR")"
    mv "$tmp/squashfs-root" "$APP_DIR"
    rm -rf "$tmp"
  fi
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
  case ":$PATH:" in *":$BIN_DIR:"*) ;; *) say "Note: add $BIN_DIR to PATH to run 'obsidian'" ;; esac
}

install_macos() {
  if [ -d /Applications/Obsidian.app ] || [ -d "$HOME/Applications/Obsidian.app" ]; then
    say "Obsidian already installed"
  elif command -v brew >/dev/null 2>&1; then
    say "Installing Obsidian with Homebrew"
    brew install --cask obsidian
  else
    die "Install Obsidian from https://obsidian.md (or install Homebrew), then run this again"
  fi
}

setup_vault() {
  mkdir -p "$MEMORY_DIR" "$VAULT"
  [ -f "$MEMORY_DIR/MEMORY.md" ] || { say "Creating empty MEMORY.md index"; printf '# Memory index\n\n' > "$MEMORY_DIR/MEMORY.md"; }
  if [ -e "$VAULT/memory" ] && [ ! -L "$VAULT/memory" ]; then
    die "$VAULT/memory exists and is not a symlink; move it away first"
  fi
  ln -sfn "$MEMORY_DIR" "$VAULT/memory"
  if [ ! -f "$OBS_CFG" ]; then
    local id
    mkdir -p "$(dirname "$OBS_CFG")"
    id="$(head -c8 /dev/urandom | od -An -tx1 | tr -d ' \n')"
    printf '{"vaults":{"%s":{"path":"%s","ts":%s,"open":true}}}\n' "$id" "$VAULT" "$(date +%s)000" > "$OBS_CFG"
  else
    say "Obsidian already has vaults: use 'Open folder as vault' -> $VAULT"
  fi
}

main "$@"
