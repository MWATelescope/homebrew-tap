class MwaFeeBeam < Formula
  desc "MWA full embedded element (FEE) beam model, used by hyperbeam and hyperdrive"
  homepage "https://github.com/MWATelescope/mwa_hyperbeam"
  url "https://ws.mwatelescope.org/static/mwa_full_embedded_element_pattern.h5"
  # upstream URL is unversioned; this is the file's Last-Modified date
  version "2025.08.06"
  sha256 "a7649c6e03b8128a1de4614c2f363af5fa44f3890ae27bf893d56ca337bc48ee"

  def install
    pkgshare.install "mwa_full_embedded_element_pattern.h5"
  end

  def caveats
    <<~EOS
      hyperdrive installed via this tap finds the beam file automatically.
      For other tools (e.g. the hyperbeam Python package), set:
        export MWA_BEAM_FILE=#{opt_pkgshare}/mwa_full_embedded_element_pattern.h5
    EOS
  end

  test do
    assert_path_exists pkgshare/"mwa_full_embedded_element_pattern.h5"
  end
end
