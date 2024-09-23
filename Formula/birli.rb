class Birli < Formula
  desc "MWA library to read raw visibilities, voltages and metadata"
  homepage "https://github.com/MWATelescope/Birli"
  sha256 "058a7a12b9f46718a5c83ba9158486cad8f30aab9135f4bd6303b5f82a7a655f"
  url "https://github.com/MWATelescope/Birli/archive/refs/tags/v0.13.0.tar.gz"
  license "MPL-2.0"

  head "https://github.com/MWATelescope/Birli.git"

  depends_on "gcc" => :test
  depends_on "cfitsio"
  depends_on "aoflagger"
  depends_on "rust" => :build
  depends_on "automake" => :build

  def install
    ENV['AOFLAGGER_INCLUDE_DIR'] = HOMEBREW_PREFIX / "include"
    system \
      "cargo", "install", "--path=.", "--locked"

    bin.install "target/release/birli"
  end
end
