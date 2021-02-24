class Aoflagger < Formula
  desc "Find and remove radio-frequency interference (RFI) in radio astronomical observations"
  homepage "https://gitlab.com/aroffringa/aoflagger"

  url "https://gitlab.com/aroffringa/aoflagger.git", :using => :git, :tag => "v3.0.0"

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
    url "https://gitlab.com/aroffringa/aoflagger.git", :using => :git
  end

  stable do
    patch :DATA
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

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 957cb76..0916bb7 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -77,8 +77,6 @@ endif("${isSystemDir}" STREQUAL "-1")
 
 set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror=vla -DNDEBUG -funroll-loops -O3 -std=c++11")
 
-string(APPEND CMAKE_SHARED_LINKER_FLAGS " -Wl,--no-undefined")
-
 include(CheckCXXCompilerFlag)
 include(CheckSymbolExists) 
 include(CheckCXXSymbolExists)
