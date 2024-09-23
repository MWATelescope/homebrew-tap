class Mwalib < Formula
  desc "MWA library to read raw visibilities, voltages and metadata"
  homepage "https://github.com/MWATelescope/mwalib"
  sha256 "580a01aedfd515dd19e43b416b98d6c3121098460a8d96e8aecba28558854c24"
  url "https://github.com/MWATelescope/mwalib/archive/refs/tags/v1.5.0.tar.gz"
  license "MPL-2.0"

  head "https://github.com/MWATelescope/mwalib.git"

  option "with-python", "Build Python bindings"

  depends_on "gcc" => :test
  depends_on "cfitsio"
  depends_on "rust" => :build
  depends_on "automake" => :build
  if build.with?("python")
    depends_on "maturin" => :build
  end

  def install
    if build.with? "python"
      system \
        "maturin", "build", "--release", "--features=python"
      wheel = Dir.new("target/wheels/").select { |f| f =~ /.*\.whl\z/i }[0]
      system \
        "pip3", "install", "target/wheels/#{wheel}"
    end

    system \
      "cargo", "build", "--release"
    lib.install "target/release/libmwalib.dylib"
    lib.install "target/release/libmwalib.a"
    include.install "include/mwalib.h"
  end

  test do
    assert_predicate lib / "libmwalib.a", :exist?
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
      ENV.cc, "-O3", testpath / "mwalib_test.c", "-o", "mwalib_test", "-I", include, "-L", lib, "-lmwalib"
    system "./mwalib_test"

    if build.with? "python"
      system "python3" "-c" "import mwalib"
    end
  end
end
