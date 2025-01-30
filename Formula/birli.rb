class Birli < Formula
  desc "MWA library to read raw visibilities, voltages and metadata"
  homepage "https://github.com/MWATelescope/Birli"
  url "https://github.com/MWATelescope/Birli/archive/refs/tags/v0.15.1.tar.gz"
  sha256 "4b0a14f6bbd12e292d04eaa9791597a6d08f9fa044c9ba6dba8e06f796544bb9"
  license "MPL-2.0"

  head "https://github.com/MWATelescope/Birli.git", branch: "main"

  bottle do
    root_url "https://github.com/MWATelescope/homebrew-tap/releases/download/v2025.01.30.06.40"
    rebuild 1
    sha256 cellar: :any, arm64_sequoia: "2454023843c45d61d4b46ebad5202aea8a8c1dd71ffa845610fd72d93d963bcf"
    sha256 cellar: :any, arm64_sonoma:  "a09a4f53b73ec4bf77e50e4804ab37d8495dd3c551358d0b9e59180394b19619"
    sha256 cellar: :any, ventura:       "d6031dba8b6dc693c356b8522bd8aa34cdf9dd2dd16604152914d0af996b2175"
  end

  depends_on "automake" => :build
  depends_on "rust" => :build
  depends_on "gcc" => :test
  depends_on "aoflagger"
  depends_on "mwatelescope/tap/cfitsio_reentrant"

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

  test do
    system "cargo", "test", "--locked", "--release"
    system "target/release/birli", "--help"
  end
end
