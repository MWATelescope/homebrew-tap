# source: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/w/wcslib.rb
class Wcslib < Formula
  desc "Library and utilities for the FITS World Coordinate System"
  homepage "https://www.atnf.csiro.au/computing/software/wcs/"
  url "https://www.atnf.csiro.au/computing/software/wcs/wcslib-releases/wcslib-8.10.tar.bz2"
  sha256 "b394d3306da9a52410f056136911496e599b5c48f1cff2f221563697077bbd8d"
  license "GPL-3.0-or-later"

  livecheck do
    url :homepage
    regex(/href=.*?wcslib[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/MWATelescope/homebrew-tap/releases/download/v2026.10.12.09.34"
    sha256 cellar: :any, arm64_tahoe:   "2896a57eaf7758f30a476e4f017735c304136fde72419b1b58c34acf29695862"
    sha256 cellar: :any, arm64_sequoia: "55bf837070ac360cbe8db8d68642b1a3720ba54d1cbb903af190be3e6db153e9"
  end

  depends_on "mwatelescope/tap/cfitsio_reentrant"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-cfitsiolib=#{formula_opt_lib("cfitsio_reentrant")}",
                          "--with-cfitsioinc=#{formula_opt_include("cfitsio_reentrant")}",
                          "--without-pgplot",
                          "--disable-fortran"
    system "make", "install"
  end

  test do
    piped = "SIMPLE  =" + (" "*20) + "T / comment" + (" "*40) + "END" + (" "*2797)
    pipe_output("#{bin}/fitshdr", piped, 0)
  end
end
