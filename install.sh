#!/bin/bash
# Remy installer — puts the `remy` CLI on your PATH, no admin password needed.
#
# Fetches the macOS binary (a local copy, else `curl` from the public release,
# else `gh` for the private repo), installs it to ~/.local/bin/remy, clears the
# quarantine flag, ensures the dir is on PATH, and verifies `remy --version`.
#
# Usage:
#   curl -fsSL <install.sh url> | bash          # download + install
#   ./install.sh                                # use a local binary if present
#   ./install.sh /path/to/remy-macos            # install a specific file
#   REMY_INSTALL_DIR=/somewhere ./install.sh    # override install location
#   REMY_BINARY_URL=<url> ./install.sh          # override the download URL
set -euo pipefail

ASSET="remy-macos"
BIN_NAME="remy"
INSTALL_DIR="${REMY_INSTALL_DIR:-$HOME/.local/bin}"
BINARY_URL="${REMY_BINARY_URL:-https://github.com/letremycook/releases/releases/latest/download/remy-macos}"
GH_REPO="fulltimecrypto/remy"   # private-repo fallback via gh

say()  { printf '  %s\n' "$*"; }
die()  { printf '\033[31mError:\033[0m %s\n' "$*" >&2; exit 1; }
step() { printf '\033[1m==>\033[0m %s\n' "$*"; }

# ── 1. platform check ────────────────────────────────────────────────────────
[ "$(uname -s)" = "Darwin" ] || die "This installer is for macOS only."
ARCH="$(uname -m)"
[ "$ARCH" = "arm64" ] || die "remy currently ships for Apple Silicon (arm64) only; you're on $ARCH."

# ── 2. locate the binary: explicit arg → local copy → curl → gh ──────────────
SRC="${1:-}"
if [ -z "$SRC" ]; then
  sd="."; [ -f "${0:-}" ] && sd="$(cd "$(dirname "$0")" && pwd)"
  for cand in "$sd/$ASSET" "$sd/$BIN_NAME" "$HOME/Downloads/$ASSET"; do
    [ -f "$cand" ] && { SRC="$cand"; break; }
  done
fi

tmp=""
if [ -z "$SRC" ]; then
  tmp="$(mktemp -d)"
  step "Downloading remy…"
  if curl -fsSL "$BINARY_URL" -o "$tmp/$ASSET" && [ -s "$tmp/$ASSET" ]; then
    SRC="$tmp/$ASSET"
  elif command -v gh >/dev/null 2>&1 && \
       gh release download --repo "$GH_REPO" --pattern "$ASSET" --dir "$tmp" >/dev/null 2>&1; then
    SRC="$tmp/$ASSET"
  fi
fi

[ -n "$SRC" ] && [ -f "$SRC" ] || die \
  "Could not obtain '$ASSET' (tried local copies, $BINARY_URL, and gh). Check your connection or pass a path."

# ── 3. install ───────────────────────────────────────────────────────────────
step "Installing to $INSTALL_DIR/$BIN_NAME"
mkdir -p "$INSTALL_DIR"
dest="$INSTALL_DIR/$BIN_NAME"
cp "$SRC" "$dest"
chmod +x "$dest"
xattr -c "$dest" 2>/dev/null || true   # clear quarantine so Gatekeeper won't block it
[ -n "$tmp" ] && rm -rf "$tmp"
say "installed, made executable, cleared quarantine"

# ── 4. ensure it's on PATH ───────────────────────────────────────────────────
case ":${PATH}:" in
  *":$INSTALL_DIR:"*) say "$INSTALL_DIR is already on your PATH" ;;
  *)
    case "$(basename "${SHELL:-/bin/zsh}")" in
      zsh)  rc="${ZDOTDIR:-$HOME}/.zshrc" ;;
      bash) rc="$HOME/.bash_profile" ;;
      *)    rc="$HOME/.profile" ;;
    esac
    if ! grep -qsF "$INSTALL_DIR" "$rc" 2>/dev/null; then
      printf '\n# added by remy installer\nexport PATH="%s:$PATH"\n' "$INSTALL_DIR" >> "$rc"
      say "added $INSTALL_DIR to PATH in $rc"
    fi
    say "open a new terminal, or run:  export PATH=\"$INSTALL_DIR:\$PATH\""
    ;;
esac

# ── 5. verify ────────────────────────────────────────────────────────────────
step "Verifying"
if ver="$("$dest" --version 2>&1)"; then
  say "$ver"
  printf '\n\033[32m✓ remy installed.\033[0m  Run:  %s --version\n' "$BIN_NAME"
else
  die "installed to $dest but it failed to run: $ver"
fi
