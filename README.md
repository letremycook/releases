As long as the repo is private, download and install needs to happen via gh: 
Quick install for letremycook (and other devs while the repo is private):
  '''
    gh auth login
    gh release download 2026.05.03 -R letremycook/releases -p remy.exe -D $HOME\bin
    remy --version    # → remy, version 0.1.0
  '''
  (add $HOME\bin to PATH once)

As soon as the repo is public, we can use scoop, which will autoamtically run updates of the software upon user request and manage the package for us. This works for now only on Windows, because you can't cross-compile with nuitika. 
  Scoop install (the future end-user path, once letremycook/releases flips public):
  scoop install https://github.com/letremycook/releases/releases/latest/download/remy.json
  scoop update remy
  The manifest's checkver: github + autoupdate block means once it's installed, every new release tag on the repo gets picked up by scoop update without any manifest edits. So the only ongoing work per release is bumping version + hash in remy.json (or having release.py regenerate it before upload — happy to wire that in if you want).

#### IMPORTANT: Nuitika can't cross-complie, i.e. someone of you guys has to do the compiling on the mac and check if everything runs fine. Without cross-compilation, you need a native system to compile.
