class Birli < Formula
  desc "Preprocess MWA raw visibilities: RFI flagging, averaging, and conversion"
  homepage "https://github.com/MWATelescope/Birli"
  url "https://github.com/MWATelescope/Birli/archive/refs/tags/v0.20.0.tar.gz"
  sha256 "fbcca61824d0063ac88cf932454ac6db072af309ed69f002336f835a96751c28"
  license "MPL-2.0"
  head "https://github.com/MWATelescope/Birli.git", branch: "main"

  bottle do
    root_url "https://github.com/MWATelescope/homebrew-tap/releases/download/v2026.10.12.09.54"
    sha256 cellar: :any, arm64_tahoe:   "be7db859815f78eff31214cf3d12f9d75c0a8d83dffb2ed2097c9a05488ccdde"
    sha256 cellar: :any, arm64_sequoia: "961d5ecba153b59077d63725d27b88ca4b2336d7cf1c3bafd43a85157951b282"
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
