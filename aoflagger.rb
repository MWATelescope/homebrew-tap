class Aoflagger < Formula
  desc "Find and remove radio-frequency interference (RFI) in radio astronomical observations"
  homepage "https://gitlab.com/aroffringa/aoflagger"

  # Most recent release as of 2021-02-24 does not compile
  # url "https://gitlab.com/aroffringa/aoflagger/-/archive/v3.0.0/aoflagger-v3.0.0.zip"
  # sha256 "76df43c81e5cf736b9a93881afe6d3b043817ea78bdd6c244b74bff8d030a93d"

  url "https://gitlab.com/aroffringa/aoflagger/-/archive/34f64162b91ede94684a892f7a0f48d61309f90d/aoflagger-34f64162b91ede94684a892f7a0f48d61309f90d.zip"
  sha256 "ce1150564c124214e8e0d5f7e26822b95886c158095503b71887d052a6b15907"

  depends_on "ska-sa/tap/casacore"
  depends_on "lua@5.3"
  depends_on "fftw"
  depends_on "boost"
  depends_on "boost-build"
  depends_on "lapack"
  depends_on "cfitsio"
  depends_on "libpng"
  depends_on "python@3.9"
  depends_on "pybind11"

  depends_on "cmake" => :build

  head do
    url "https://gitlab.com/aroffringa/aoflagger.git"
  end

  def install
    build_type = "Release"
    mkdir "build/#{build_type}" do
      cmake_args = std_cmake_args
      cmake_args.delete "-DCMAKE_BUILD_TYPE=None"
      cmake_args << "-DCMAKE_BUILD_TYPE=#{build_type}"
      system "cmake", "../..", *cmake_args
      system "cat", "Makefile"
      system "make", "install"
    end
  end
end
