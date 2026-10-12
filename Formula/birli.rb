class Birli < Formula
  desc "Preprocess MWA raw visibilities: RFI flagging, averaging, and conversion"
  homepage "https://github.com/MWATelescope/Birli"
  url "https://github.com/MWATelescope/Birli/archive/refs/tags/v0.20.0.tar.gz"
  sha256 "fbcca61824d0063ac88cf932454ac6db072af309ed69f002336f835a96751c28"
  license "MPL-2.0"
  revision 1
  head "https://github.com/MWATelescope/Birli.git", branch: "main"

  bottle do
    root_url "https://github.com/MWATelescope/homebrew-tap/releases/download/v2026.10.12.10.45"
    sha256 cellar: :any, arm64_tahoe:   "0487b1f2d281fdcf6a3791b0073a8fa5c197097b687c4f2d90f69044c147c8cd"
    sha256 cellar: :any, arm64_sequoia: "8ced7fd6c90e005d7637ea1c2a2015be5e26cad46557bcc69ae629ec4ee3e713"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "mwatelescope/tap/aoflagger"
  depends_on "mwatelescope/tap/cfitsio_reentrant"

  def install
    # rubbl's bundled casacore passes `std::abs<T>` to a template, which newer libc++
    # rejects as ambiguous. Fetch crates into a private CARGO_HOME and patch the
    # extracted source there (keep in sync with hyperdrive.rb).
    ENV["CARGO_HOME"] = buildpath/"cargo_home"
    system "cargo", "fetch", "--locked"
    rubbl = Dir[buildpath/"cargo_home/registry/src/*/rubbl_casatables_impl-0.4.35001"]
    inreplace rubbl.map { |dir| "#{dir}/casacore/casa/Arrays/Array2Math.cc" } do |s|
      s.gsub! "std::abs<float>", "[](std::complex<float> v) { return std::abs(v); }"
      s.gsub! "std::abs<double>", "[](std::complex<double> v) { return std::abs(v); }"
    end

    ENV["AOFLAGGER_INCLUDE_DIR"] = formula_opt_include("aoflagger").to_s
    ENV["AOFLAGGER_LIB"] = formula_opt_lib("aoflagger").to_s
    system "cargo", "install", "--features", "aoflagger", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/birli --version")
    assert_match "aoflagger", shell_output("#{bin}/birli --help")
  end
end
