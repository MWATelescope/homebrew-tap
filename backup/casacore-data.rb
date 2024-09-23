class ZtarDownloadStrategy < CurlDownloadStrategy
  def stage(&block)
    UnpackStrategy::Tar.new(cached_location).extract(basename: basename, verbose: verbose?)
    chdir(&block)
  end
end

class CasacoreData < Formula
  desc "Ephemerides and geodetic data for casacore measures (via Astron)"
  homepage "https://github.com/casacore/casacore"
  url "https://github.com/d3v-null/WSRT-Measures-Mirror/releases/download/v2024.09.23/WSRT_Measures.zip"
  sha256 "f0286670bdea35f538e10ffd6c0e411ca1611edd567eb40a9a35ab165640a8e8"
  # url "file:///dev/null"
  # sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "app"

  head do
    url "ftp://ftp.astron.nl/outgoing/Measures/WSRT_Measures.ztar", using: ZtarDownloadStrategy
  end

  option "with-casapy", "Use Mac CASA.App (aka casapy) data directory if found"
  deprecated_option "use-casapy" => "with-casapy"

  APP_DIR = (Pathname.new "/Applications").freeze
  CASAPY_APP_NAME = "CASA.app".freeze
  CASAPY_APP_DIR = (APP_DIR / CASAPY_APP_NAME).freeze
  CASAPY_DATA = (CASAPY_APP_DIR / "Contents/data").freeze

  def install
    if build.with? "casapy"
      ohai "--with-casapy was specified"
      if !Dir.exist? CASAPY_APP_DIR
        odie "#{CASAPY_APP_NAME} was not found in #{APP_DIR}"
      elsif !Dir.exist? CASAPY_DATA
        odie "data directory not found at #{CASAPY_DATA}"
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
