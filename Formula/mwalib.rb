class Mwalib < Formula
  desc "MWA library to read raw visibilities, voltages and metadata"
  homepage "https://github.com/MWATelescope/mwalib"
  url "https://github.com/MWATelescope/mwalib/releases/download/v0.7.1/mwalib-v0.7.1-macosx.tar.gz"
  sha256 "b8b164b5a0b0f8e2dba9ea49504b2906fa8eadb71cabcc15efd5054dfd604397"
  license "MPL-2.0"

  depends_on "gcc" => :test
  depends_on "cfitsio"

  def install
    lib.install "libmwalib.dylib"
    include.install "mwalib.h"
  end

  test do
    assert_predicate lib / "libmwalib.dylib", :exist?
    assert_predicate include / "mwalib.h", :exist?

    (testpath / "mwalib_test.c").write "
#include <mwalib.h>
int main(int argc, char *argv[]) {
  if (mwalib_get_version_major() >= 0) {
    return 0;
  }
  return 1;
}
"
    system \
      ENV.cc, "-O3", testpath / "mwalib_test.c", "-o", "mwalib_test", \
      "-I", include, "-L", lib, "-lmwalib"
    system "./mwalib_test"
  end
end
