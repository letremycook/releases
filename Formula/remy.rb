class Remy < Formula
  desc "CLI for autonomous AI development"
  homepage "https://github.com/letremycook/releases"
  version "2026.07.01"

  # Apple Silicon only for now — errors cleanly on Intel.
  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/letremycook/releases/releases/download/2026.07.01/remy-macos-arm64.tar.gz"
  sha256 "b411a0739aa2ce2416e6c2bac900d6179af9a9843ea188c08bf35a662f8b34ac"

  def install
    bin.install "remy"
  end

  test do
    assert_match "remy, version", shell_output("#{bin}/remy --version")
  end
end
