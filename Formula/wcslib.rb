# source: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/w/wcslib.rb
class Wcslib < Formula
  desc "Library and utilities for the FITS World Coordinate System"
  homepage "https://www.atnf.csiro.au/computing/software/wcs/"
  url "https://www.atnf.csiro.au/computing/software/wcs/wcslib-8.4.tar.bz2"
  sha256 "960b844426d14a8b53cdeed78258aa9288cded99a7732c0667c64fa6a50126dc"
  license "GPL-3.0-or-later"

  livecheck do
    url :homepage
    regex(/href=.*?wcslib[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/MWATelescope/homebrew-tap/releases/download/v2025.01.30.06.40"
    rebuild 1
    sha256 cellar: :any, arm64_sequoia: "a7b0a39634f7c1e13231adc1f2e9582c71aa5524176aff90e2a60b3f9569328d"
    sha256 cellar: :any, arm64_sonoma:  "41974cc1e040299d957c83c03f91cc629c6ffa218e8bf16af98f706b991218cd"
    sha256 cellar: :any, ventura:       "b419a545e84f1cf1570e81c18ed88c0a110f127bb60541591e97fba58648c1d3"
  end

  depends_on "mwatelescope/tap/cfitsio_reentrant"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-cfitsiolib=#{Formula["cfitsio_reentrant"].opt_lib}",
                          "--with-cfitsioinc=#{Formula["cfitsio_reentrant"].opt_include}",
                          "--without-pgplot",
                          "--disable-fortran"
    system "make", "install"
  end

  test do
    piped = "SIMPLE  =" + (" "*20) + "T / comment" + (" "*40) + "END" + (" "*2797)
    pipe_output("#{bin}/fitshdr", piped, 0)
  end
end
