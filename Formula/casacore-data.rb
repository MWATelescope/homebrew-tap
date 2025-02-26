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
  # curl ftp://anonymous@ftp.astron.nl/outgoing/Measures/
  url "ftp://anonymous@ftp.astron.nl/outgoing/Measures/WSRT_Measures_20250128-160001.ztar", using: ZtarDownloadStrategy
  version "20250128-160001"
  # curl -s 'ftp://anonymous@ftp.astron.nl/outgoing/Measures/WSRT_Measures_20250128-160001.ztar' | sha256 -
  sha256 "5835e3f5458d8f88fd057044a891d26a5cbfdec9a865967b1189d4fd52140c80"
  head "ftp://ftp.astron.nl/outgoing/Measures/WSRT_Measures.ztar", using: ZtarDownloadStrategy

  bottle do
    root_url "https://github.com/MWATelescope/homebrew-tap/releases/download/v2025.01.30.06.40"
    rebuild 6
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "fe5eb8972c59c9b5205f290711ea2a16fbbcfd3b5661d46d2f37762842eeb81a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "de762746fba9a462cc741123a94591c4f57a6f4c8606b0b2ffd2edf3f72b1d86"
    sha256 cellar: :any_skip_relocation, ventura:       "aab5fd008285d8c841ccf80066f40f84173b845ff8c5c34e2a4beb27d26fd158"
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
