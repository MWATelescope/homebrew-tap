class Aoflagger < Formula
  desc "Find and remove radio-frequency interference in radio astronomical observations"
  homepage "https://gitlab.com/aroffringa/aoflagger"
  license "GPL-3.0-only"

  stable do
    url "https://gitlab.com/aroffringa/aoflagger/-/package_files/96704214/download"
    sha256 "9560b7381b68f37d842599f222a8aa2a5d3d3d501d1277471e1a0ba3d7b2aeba"
    version "v3.4.0"
  end

  head do
    url "https://gitlab.com/aroffringa/aoflagger.git"
  end

  option "with-python", "Build Python bindings"

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "boost-build"
  depends_on "casacore/tap/casacore" => :recommended
  depends_on "cfitsio"
  depends_on "fftw"
  depends_on "lapack"
  depends_on "libpng"
  depends_on "lua@5.3"
  depends_on "pybind11"
  depends_on "python@3.9"

  def install
    build_type = "Release"
    mkdir "build/#{build_type}" do
      cmake_args = std_cmake_args
      cmake_args.delete "-DCMAKE_BUILD_TYPE=None"
      cmake_args << "-DCMAKE_BUILD_TYPE=#{build_type}"
      cmake_args << "-DPORTABLE=False" # optimize build for local machine
      system "cmake", "../..", *cmake_args, *std_cmake_args
      system "make", "install"
    end
  end

  test do
    File.exist? include / "aoflagger.h"
  end
end
