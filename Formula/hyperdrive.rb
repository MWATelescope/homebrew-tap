class Hyperdrive < Formula
  desc "Calibration software for the Murchison Widefield Array radio telescope"
  homepage "https://github.com/MWATelescope/mwa_hyperdrive"
  url "https://github.com/MWATelescope/mwa_hyperdrive/archive/refs/tags/v0.8.1.tar.gz"
  sha256 "9bef74b3a7c02df24e8d8ade2e41e8b93e4a0af127f2ae91ad4bff32a05c7ab9"
  license "MPL-2.0"
  head "https://github.com/MWATelescope/mwa_hyperdrive.git", branch: "main"

  bottle do
    root_url "https://github.com/MWATelescope/homebrew-tap/releases/download/v2026.10.12.09.34"
    sha256 cellar: :any, arm64_tahoe:   "204eb61816ffd071c83ff4eef6ff1ad2e1385a119ebf5b78bc0583333a0a2546"
    sha256 cellar: :any, arm64_sequoia: "c659e1511e8ee36bf1d9f68898fe4ce239750a67f6a63270f1142cae57595417"
  end

  depends_on "cmake" => :build # builds the bundled HDF5 (hdf5-static)
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "mwatelescope/tap/cfitsio_reentrant"
  depends_on "mwatelescope/tap/mwa-fee-beam"

  def install
    # rubbl's bundled casacore passes `std::abs<T>` to a template, which newer libc++
    # rejects as ambiguous. Fetch crates into a private CARGO_HOME and patch the
    # extracted source there (keep in sync with birli.rb).
    ENV["CARGO_HOME"] = buildpath/"cargo_home"
    system "cargo", "fetch", "--locked"
    rubbl = Dir[buildpath/"cargo_home/registry/src/*/rubbl_casatables_impl-0.4.35001"]
    inreplace rubbl.map { |dir| "#{dir}/casacore/casa/Arrays/Array2Math.cc" } do |s|
      s.gsub! "std::abs<float>", "[](std::complex<float> v) { return std::abs(v); }"
      s.gsub! "std::abs<double>", "[](std::complex<double> v) { return std::abs(v); }"
    end

    # Homebrew's hdf5 2.x is too new for the hdf5-metno crate, so build HDF5 in.
    system "cargo", "install", "--features", "hdf5-static", *std_cargo_args(root: libexec)
    beam_file = Formula["mwatelescope/tap/mwa-fee-beam"].opt_pkgshare/"mwa_full_embedded_element_pattern.h5"
    (bin/"hyperdrive").write_env_script libexec/"bin/hyperdrive",
                                        MWA_BEAM_FILE: "${MWA_BEAM_FILE:-#{beam_file}}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hyperdrive --version")
    # exercises the FEE beam file found via the wrapper's MWA_BEAM_FILE
    system bin/"hyperdrive", "beam", "fee", "--step", "30", "--output", testpath/"beam.tsv"
    assert_predicate testpath/"beam.tsv", :size?
  end
end
