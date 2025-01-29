class Birli < Formula
  desc "MWA library to read raw visibilities, voltages and metadata"
  homepage "https://github.com/MWATelescope/Birli"
  url "https://github.com/MWATelescope/Birli/archive/refs/tags/v0.15.1.tar.gz"
  sha256 "4b0a14f6bbd12e292d04eaa9791597a6d08f9fa044c9ba6dba8e06f796544bb9"
  license "MPL-2.0"

  head "https://github.com/MWATelescope/Birli.git"

  depends_on "automake" => :build
  depends_on "rust" => :build
  depends_on "gcc" => :test
  depends_on "aoflagger"
  depends_on "cfitsio_reentrant"

  def install
    with_env(
      "AOFLAGGER_INCLUDE_DIR"      => ENV["AOFLAGGER_INCLUDE_DIR"] || (HOMEBREW_PREFIX / "include"),
      "DYLD_FALLBACK_LIBRARY_PATH" => ENV["DYLD_FALLBACK_LIBRARY_PATH"] || (HOMEBREW_PREFIX / "lib"),
      "RUSTFLAGS"                  => ENV["RUSTFLAGS"] || "-C target-cpu=native",
    ) do
      system "cargo", "install", "--path=.", "--locked"
    end
    bin.install "target/release/birli"
  end
end
