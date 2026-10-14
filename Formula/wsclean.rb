class Wsclean < Formula
  desc "Fast widefield interferometric imager based on w-stacking"
  homepage "https://gitlab.com/aroffringa/wsclean"
  # release tarball includes the git submodules (aocommon, radler, schaapcommon)
  url "https://gitlab.com/aroffringa/wsclean/-/package_files/271776739/download"
  version "3.7"
  sha256 "7b542b21c4224679de3a4235103b5128f5135bf9c31db1aec7cfac69a0abe827"
  license "GPL-3.0-or-later"
  head "https://gitlab.com/aroffringa/wsclean.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "pybind11" => :build
  depends_on "boost"
  depends_on "fftw"
  depends_on "gsl"
  depends_on "hdf5"
  depends_on "mwatelescope/tap/casacore"
  depends_on "mwatelescope/tap/cfitsio_reentrant"
  depends_on "python@3.14" # embedded via pybind11

  def install
    # libc++ does not pull in <semaphore> transitively like libstdc++ does
    inreplace "gridding/msgridder.h", "#include <aocommon/uvector.h>",
              "#include <aocommon/uvector.h>\n\n#include <semaphore>"

    cmake_args = std_cmake_args
    cmake_args.delete "-DCMAKE_BUILD_TYPE=None"
    cmake_args << "-DCMAKE_BUILD_TYPE=Release"
    # bottles must run on any Apple Silicon CPU, not just the CI runner's
    cmake_args << "-DPORTABLE=ON"
    cmake_args << "-DBLA_VENDOR=Apple"
    cmake_args << "-DPython3_EXECUTABLE=#{which("python3.14")}"
    # optional features (wsclean-mp, beams, IDG) stay off even if found on the build machine
    cmake_args << "-DCMAKE_DISABLE_FIND_PACKAGE_MPI=ON"
    cmake_args << "-DCMAKE_DISABLE_FIND_PACKAGE_EveryBeam=ON"
    cmake_args << "-DCMAKE_DISABLE_FIND_PACKAGE_IDGAPI=ON"
    system "cmake", "-S", ".", "-B", "build", *cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wsclean -version")
    assert_match "phase centre", shell_output("#{bin}/chgcentre 2>&1")

    # image a 1 Jy point source at the phase centre of a tiny synthetic measurement set
    casacore_bin = formula_opt_bin("mwatelescope/tap/casacore")
    system casacore_bin/"writems", "msname=t.ms", "ra=00:00:00", "dec=-27.00.00", "nant=4", "nchan=4",
           "ntime=2", "starttime=23Mar2016/12:00:00"
    system casacore_bin/"taql", "update t.ms set UVW=[(ANTENNA2-ANTENNA1)*30.0+ROWNUMBER()%7, " \
                                "(ANTENNA2*ANTENNA2-ANTENNA1)*20.0, 0.0], DATA=1.0+0i, FLAG=False"
    output = shell_output("#{bin}/wsclean -size 64 64 -scale 2amin -niter 10 -name img t.ms")
    assert_match "Initial peak: 1 Jy at 32,32", output
    assert_path_exists testpath/"img-image.fits"
  end
end
