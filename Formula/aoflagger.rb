class Aoflagger < Formula
  desc "Find and remove radio-frequency interference in radio astronomical observations"
  homepage "https://gitlab.com/aroffringa/aoflagger"
  url "https://gitlab.com/aroffringa/aoflagger/-/package_files/96704214/download"
  version "3.4.0"
  sha256 "9560b7381b68f37d842599f222a8aa2a5d3d3d501d1277471e1a0ba3d7b2aeba"
  license "GPL-3.0-only"

  bottle do
    root_url "https://github.com/MWATelescope/homebrew-tap/releases/download/v2025.01.30.06.40"
    rebuild 1
    sha256 arm64_sequoia: "c5647904c8feff543584ae1ce7dde91aa996426c7d931fa67e9bf36c9b82839f"
    sha256 arm64_sonoma:  "707f69f08caf600f6f62f21a3dc219dba061c3f50354b88f67f5aa2f076449c5"
    sha256 ventura:       "cddb746fd547739c0bfafd30966357a9f3b53ac35ee1ed0410a13f9e91563a39"
  end

  option "with-python", "Build Python bindings"
  option "with-hdf5", "Build with hdf5"

  depends_on "boost-build" => :build
  depends_on "cmake" => :build
  depends_on "pybind11" => :build if build.with?("python")

  depends_on "boost"
  depends_on "fftw"
  depends_on "lapack"
  depends_on "libpng"
  depends_on "lua@5.4"
  depends_on "mwatelescope/tap/casacore"
  depends_on "mwatelescope/tap/cfitsio_reentrant"
  depends_on "hdf5" => :optional

  def install
    build_type = "Release"
    mkdir "build/#{build_type}" do
      cmake_args = std_cmake_args
      cmake_args.delete "-DCMAKE_BUILD_TYPE=None"
      cmake_args << "-DCMAKE_BUILD_TYPE=#{build_type}"
      cmake_args << "-DPORTABLE=False"
      cmake_args << "-DUSE_HDF5=ON" << "-DHDF5_ROOT_DIR=#{HOMEBREW_PREFIX}" if build.with?("hdf5")
      system "cmake", "../..", *cmake_args
      system "make", "install"
    end
  end

  test do
    File.exist? include / "aoflagger.h"
  end
end
