class CfitsioReentrant < Formula
  desc "C access to FITS data files with optional Fortran wrappers with reentrant"
  homepage "https://heasarc.gsfc.nasa.gov/docs/software/fitsio/fitsio.html"
  url "https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-4.5.0.tar.gz"
  sha256 "e4854fc3365c1462e493aa586bfaa2f3d0bb8c20b75a524955db64c27427ce09"
  license "CFITSIO"
  revision 1

  livecheck do
    url :homepage
    regex(/href=.*?cfitsio[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/mwatelescope/homebrew-tap/releases/download/v2025.01.30.03.55"
    rebuild 2
    sha256 cellar: :any, arm64_sequoia: "835ed44fb32dbd02967698a159377ea53cd2125a7c4666fbf806daf125512c5a"
    sha256 cellar: :any, arm64_sonoma:  "6afb2ac344ad831541beeb2f44f96d56ce394889ad5967733ec52d98837b6610"
    sha256 cellar: :any, ventura:       "9d0f090d15f6597d968c89d21965cdfb584d45744f4c21ada1521f1ddbf476e1"
  end

  depends_on "cmake" => :build
  uses_from_macos "zlib"

  # Fix pkg-config file location, should be removed on next release
  patch do
    url "https://github.com/HEASARC/cfitsio/commit/d2828ae5af42056bb4fde397f3205479d01a4cf1.patch?full_index=1"
    sha256 "690d0bde53fc276f53b9a3f5d678ca1d03280fae7cfa84e7b59b87304fcdcb46"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", "-DUSE_PTHREADS=1", "-D_REENTRANT=1", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    (pkgshare/"testprog").install Dir["testprog*", "utilities/testprog.c"]
  end

  test do
    cp Dir["#{pkgshare}/testprog/testprog*"], testpath
    system ENV.cc, "testprog.c", "-o", "testprog", "-I#{include}",
                   "-L#{lib}", "-lcfitsio"
    system "./testprog > testprog.lis"
    cmp "testprog.lis", "testprog.out"
    cmp "testprog.fit", "testprog.std"
  end
end
