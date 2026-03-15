class VapoursynthBm3dmetal < Formula
  desc "BM3D denoising filter for VapourSynth, implemented in Metal"
  homepage "https://github.com/Sunflower-Dolls/Vapoursynth-BM3DMETAL"
  url "https://github.com/Sunflower-Dolls/Vapoursynth-BM3DMETAL/archive/refs/tags/R2.tar.gz"
  sha256 "0f18f5f65abefe4fc991b822fdd1737c839ae2aa9727eeff7a583ba8b574bbba"
  license "GPL-3.0-or-later"
  head "https://github.com/Sunflower-Dolls/Vapoursynth-BM3DMETAL.git", branch: "main"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-bm3dmetal-2"
    sha256 cellar: :any, arm64_tahoe:   "3f849d4b7f31ec7b61afe758ece12d3e234021b54bd2566fe328f49c166528fe"
    sha256 cellar: :any, arm64_sequoia: "4d56204a09027ffe8e20ee6bdd98e07a8d42b531d919a353491bc4a97de6c68c"
    sha256 cellar: :any, arm64_sonoma:  "21ea35833443e4c9cef0497a9a3be1d1de4f41d835700e6614c62a14450a45d4"
  end

  depends_on "cmake" => :build
  depends_on "llvm@20" => :build
  depends_on "x265" => :test # for clang++-17
  depends_on :macos
  depends_on macos: :monterey
  depends_on "vapoursynth" # Mac only due to Metal dependency

  def install
    ENV["CXX"] = Formula["llvm@20"].opt_bin/"clang++"
    ENV["CC"] = Formula["llvm@20"].opt_bin/"clang-20"
    ENV["OBJCXX"] = Formula["llvm@20"].opt_bin/"clang++"
    ENV["OBJC"] = Formula["llvm@20"].opt_bin/"clang-20"
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
"-DVAPOURSYNTH_INCLUDE_DIRECTORY=#{Formula["vapoursynth"].opt_include}/vapoursynth"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    (lib/"vapoursynth").install "build/lib/libbm3dmetal.dylib"
  end

  test do
    python = Formula["vapoursynth"].deps
                                   .find { |d| d.name.match?(/^python@\d\.\d+$/) }
                                   .to_formula
                                   .opt_libexec/"bin/python"
    (testpath/"test.py").write <<~PYTHON
      from vapoursynth import core
      import vapoursynth as vs
      import sys
      clip = core.std.BlankClip(length=5, width=1920, height=1080, fpsnum=24, fpsden=1)
      clip = core.resize.Spline36(clip=clip, format=vs.RGBS)
      clip = core.bm3dmetal.BM3D(clip)
      clip.output(sys.stdout)
    PYTHON
    python_call = "#{python} test.py"
    x265_call = "#{Formula["x265"].opt_bin}/x265 - --input-res 1920x1080 --fps 24 --output test.hevc"
    call = "#{python_call} | #{x265_call}"
    system "sh", "-c", "#{python_call} > /dev/null"
    system "sh", "-c", call
    assert_path_exists testpath/"test.hevc"
  end
end
