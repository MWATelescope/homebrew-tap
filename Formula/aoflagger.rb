class Aoflagger < Formula
  desc "Find and remove radio-frequency interference in radio astronomical observations"
  homepage "https://gitlab.com/aroffringa/aoflagger"
  license "GPL-3.0-only"

  stable do
    url "https://gitlab.com/aroffringa/aoflagger.git", tag: "v3.1.0", revision: "18b70b9836552d7a632c457ffd8822e57a3ebe7b"
  end

  head do
    url "https://gitlab.com/aroffringa/aoflagger.git"
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "boost-build"
  depends_on "casacore"
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
      system "cmake", "../..", *cmake_args
      system "make", "install"
    end
  end

  test do
    File.exist? include / "aoflagger.h"
  end
end
