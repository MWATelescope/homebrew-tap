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
    root_url "https://github.com/MWATelescope/homebrew-tap/releases/download/v2025.01.30.06.40"
    rebuild 6
    sha256 cellar: :any, arm64_sequoia: "964456c51a8a64907354190b5a4ca142af19d12fb58c9ecc83b30aa33df2a465"
    sha256 cellar: :any, arm64_sonoma:  "6b3ea72095452c2682acaeb2319e568e4a2dd779a242f7fc1bf4fa1d7910d33f"
    sha256 cellar: :any, ventura:       "f5c6fc814cb307f86123b7b37cacd79f1ae65971aa55de1e24f752279bbe475a"
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
