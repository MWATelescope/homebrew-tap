class Erfa < Formula
  desc "Essential Routines for Fundamental Astronomy"
  homepage "https://github.com/liberfa/erfa"
  url "https://github.com/liberfa/erfa/releases/download/v2.0.0/erfa-2.0.0.tar.gz"
  sha256 "75cb0a2cc1561d24203d9d0e67c21f105e45a70181d57f158e64a46a50ccd515"
  license "MPL-2.0"

  depends_on "gcc" => :test
  depends_on "autoconf"
  depends_on "automake"
  depends_on "libtool"

  def install
    system "./bootstrap.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    assert_predicate lib / "liberfa.dylib", :exist?
    assert_predicate include / "erfa.h", :exist?

    (testpath / "erfa_test.c").write "
#include <erfa.h>
int main(int argc, char *argv[]) {
  if (eraEpj(2.0, 1.0) == 0) {
    return 1;
  }
  return 0;
}
"
    system \
      ENV.cc, "-O3", testpath / "erfa_test.c", "-o", "erfa_test", "-I", include, "-L", lib, "-lerfa"
    system "./erfa_test"
  end
end
