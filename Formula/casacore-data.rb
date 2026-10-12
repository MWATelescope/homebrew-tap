# source: https://github.com/casacore/homebrew-tap/blob/e104598bbfe44e17a07d59c8bdb6a3559b527c67/Formula/casacore-data.rb
class ZtarDownloadStrategy < CurlDownloadStrategy
  def stage(&block)
    UnpackStrategy::Tar.new(cached_location).extract(basename:, verbose: verbose?)
    chdir(&block)
  end
end

class CasacoreData < Formula
  desc "Ephemerides and geodetic data for casacore measures (via Astron)"
  homepage "https://github.com/casacore/casacore"
  # ASTRON only keeps recent tarballs, so each one used here is mirrored to a release on this
  # repo (tag measures-<version>). To update, see "casacore-data" in the README.
  url "https://github.com/MWATelescope/homebrew-tap/releases/download/measures-20261011-160001/WSRT_Measures_20261011-160001.ztar",
      using: ZtarDownloadStrategy
  mirror "ftp://anonymous@ftp.astron.nl/outgoing/Measures/WSRT_Measures_20261011-160001.ztar"
  version "20261011-160001"
  sha256 "9d9989917a77eb1f7b67c36314a77b36fa33e28603690c037c734b30dc3970fd"
  head "ftp://ftp.astron.nl/outgoing/Measures/WSRT_Measures.ztar", using: ZtarDownloadStrategy

  bottle do
    root_url "https://github.com/MWATelescope/homebrew-tap/releases/download/v2026.10.12.09.11"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "61c21acab3fea07b54b8909b3dd965790eccde8d02e873897aebececc32fc236"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a4bfa5869aee4a70c24dbb07ecab276c49d4ff39db8dfe1a8a00e6d9ebe7a48e"
  end

  option "with-casapy", "Use Mac CASA.App (aka casapy) data directory if found"

  deprecated_option "use-casapy" => "with-casapy"

  APP_DIR = (Pathname.new "/Applications").freeze
  CASAPY_APP_NAME = "CASA.app".freeze
  CASAPY_APP_DIR = (APP_DIR / CASAPY_APP_NAME).freeze
  CASAPY_DATA = (CASAPY_APP_DIR / "Contents/data").freeze

  def install
    if build.with? "casapy"
      if !Dir.exist? CASAPY_APP_DIR
        odie "--with-casapy was specified, but #{CASAPY_APP_NAME} was not found in #{APP_DIR}"
      elsif !Dir.exist? CASAPY_DATA
        odie "--with-casapy was specified, but data directory not found at #{CASAPY_DATA}"
      end
      prefix.install_symlink CASAPY_DATA
    else
      (prefix / CASAPY_DATA.basename).install Dir["*"]
    end
  end

  def caveats
    data_dir = prefix / CASAPY_DATA.basename
    if File.symlink? data_dir
      "Linked to CASA data directory (#{CASAPY_DATA}) from #{data_dir}"
    else
      "Installed latest Astron WSRT_Measures tarball to #{data_dir}"
    end
  end

  test do
    Dir.exist? (prefix / CASAPY_DATA.basename / "ephemerides")
    Dir.exist? (prefix / CASAPY_DATA.basename / "geodetic")
  end
end
