# Remy releases

Binary releases of [Remy](https://github.com/fulltimecrypto/remy), the autonomous AI development tool.

This repo only contains compiled binaries and Scoop manifests. No source.

## Install

### Windows — direct download
```powershell
gh auth login                # one-time, only while this repo is private
gh release download 2026.05.03 -R letremycook/releases -p remy.exe -D $HOME\bin
# add $HOME\bin to PATH (one-time)
```

### Windows — Scoop
Once this repo is public:
```powershell
scoop install https://github.com/letremycook/releases/releases/latest/download/remy.json
scoop update remy            # picks up future releases via the manifest's autoupdate block
```

While the repo is private, Scoop's plain HTTP downloader doesn't carry GitHub auth — use the direct-download path above instead.

### macOS
Not yet published. macOS binaries must be built on a Mac (Nuitka has no cross-compilation). Coming once we either build it on a Mac host or wire up a `macos-latest` GitHub Actions runner.

## First-run notes
- Unsigned binary — Windows SmartScreen will warn ("More info" → "Run anyway"). macOS will need `xattr -d com.apple.quarantine` once the Mac binary lands.
- All persistent state goes to `~/.remy/` (override with `$REMY_HOME`). The binary itself is fully relocatable; uninstall = delete the file.
