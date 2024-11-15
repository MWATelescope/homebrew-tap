class Casacore < Formula
  desc "Suite of C++ libraries for radio astronomy data processing"
  homepage "https://github.com/casacore/casacore"
  url "https://github.com/casacore/casacore/archive/refs/tags/v3.6.1.tar.gz"
  sha256 "480d3340fa17e9ba67f18efbaff4bbb272a01d1f400d2295c0b6c86eb7abcf82"
  head "https://github.com/casacore/casacore.git"

  option "without-python", "Build without Python bindings"

  depends_on "cmake" => :build
  depends_on "casacore/tap/casacore-data"
  depends_on "cfitsio"
  depends_on "fftw"
  depends_on "gcc" # for gfortran
  depends_on "gsl"
  depends_on "hdf5"
  depends_on "ncurses"
  depends_on "openblas"
  depends_on "readline"
  depends_on "wcslib"

  if build.with?("python")
    # if this line changes https://github.com/Homebrew/homebrew-core/blob/914f3d69b312903688270b42730b37a5f02a241a/Formula/b/boost-python3.rb#L26C14-L26C27
    # then this will break.
    # if you change this line, you should also change the line below:
    # python_exe = which("python3.12")
    depends_on "python@3.12"
    depends_on "numpy"
    depends_on "boost-python3"
  end

  def install
    casacore_data = HOMEBREW_PREFIX / "opt/casacore-data/data"
    opoo "casacore data not found at #{casacore_data}" unless casacore_data.exist?
    # To get a build type besides "release" we need to change from superenv to std env first
    build_type = "release"
    mkdir "build/#{build_type}" do
      cmake_args = std_cmake_args
      cmake_args.delete "-DCMAKE_BUILD_TYPE=None"
      cmake_args << "-DCMAKE_BUILD_TYPE=#{build_type}"
      cmake_args << "-DBUILD_PYTHON=OFF" # avoid any python2
      cmake_args << "-DBUILD_PYTHON3=#{build.with?("python") ? "ON" : "OFF"}"
      cmake_args << "-DUSE_OPENMP=OFF"
      cmake_args << "-DUSE_FFTW3=ON" << "-DFFTW3_ROOT_DIR=#{HOMEBREW_PREFIX}"
      cmake_args << "-DUSE_HDF5=ON" << "-DHDF5_ROOT_DIR=#{HOMEBREW_PREFIX}"
      # cmake_args << "-DBoost_NO_BOOST_CMAKE=ON"
      cmake_args << "-DDATA_DIR=#{casacore_data}"
      if build.with?("python")
        python_exe = which("python3.12")
        cmake_args << "-DPython3_EXECUTABLE=#{python_exe}"
        numpy_include = `#{python_exe} -c "import numpy; print(numpy.get_include())"`.strip
        cmake_args << "-DPython3_NumPy_INCLUDE_DIR=#{numpy_include}"
      end
      system "cmake", "../..", *cmake_args
      system "make", "install"
    end
  end

  test do
    system bin / "findmeastable", "IGRF"
    system bin / "findmeastable", "DE405"
  end
end
