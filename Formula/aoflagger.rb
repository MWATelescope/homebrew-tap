class Aoflagger < Formula
  desc "Find and remove radio-frequency interference in radio astronomical observations"
  homepage "https://gitlab.com/aroffringa/aoflagger"
  url "https://gitlab.com/aroffringa/aoflagger/-/package_files/264635245/download"
  version "3.5.0"
  sha256 "4caf3e9ab0b998c59061836745778e9ea65e020700750d899da66a2ece092367"
  license "GPL-3.0-only"

  bottle do
    root_url "https://github.com/MWATelescope/homebrew-tap/releases/download/v2026.10.12.09.54"
    sha256 arm64_tahoe:   "d7dfcafae9dc474effd576e3e638ed1bb2326ada29e763348045162cfd15fc0f"
    sha256 arm64_sequoia: "0c7abc9d54da23fc7ba7fa297567c5ee3906e70a5ab67c7207a09c24344b11d3"
  end

  depends_on "boost" => :build # header-only use
  depends_on "boost-build" => :build
  depends_on "cmake" => :build
  depends_on "pybind11" => :build

  depends_on "fftw"
  depends_on "gsl"
  depends_on "hdf5"
  depends_on "libpng"
  depends_on "libsigc++@2"
  depends_on "lua@5.4"
  depends_on "mwatelescope/tap/casacore"
  depends_on "mwatelescope/tap/cfitsio_reentrant"
  depends_on "openblas" # BLAS and LAPACK
  depends_on "python@3.14"
  depends_on "gtkmm4" => :optional # --with-gtkmm4 builds the rfigui and aoqplot GUIs

  def install
    cmake_args = std_cmake_args
    cmake_args.delete "-DCMAKE_BUILD_TYPE=None"
    cmake_args << "-DCMAKE_BUILD_TYPE=Release"
    # bottles must run on any Apple Silicon CPU, not just the CI runner's
    cmake_args << "-DPORTABLE=ON"
    cmake_args << "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    cmake_args << "-DENABLE_GUI=#{build.with?("gtkmm4") ? "ON" : "OFF"}"
    cmake_args << "-DENABLE_TESTS=OFF"
    cmake_args << "-DPython_EXECUTABLE=#{which("python3.14")}"
    system "cmake", "-S", ".", "-B", "build", *cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_path_exists include/"aoflagger.h"
    assert_match version.major_minor.to_s, shell_output("#{bin}/aoflagger --version")
  end
end
