class VapoursynthBm3dmetal < Formula
  desc "BM3D denoising filter for VapourSynth, implemented in Metal"
  homepage "https://github.com/Sunflower-Dolls/Vapoursynth-BM3DMETAL"
  url "https://github.com/Sunflower-Dolls/Vapoursynth-BM3DMETAL/archive/refs/tags/R2.tar.gz"
  sha256 "0f18f5f65abefe4fc991b822fdd1737c839ae2aa9727eeff7a583ba8b574bbba"
  license "GPL-3.0-or-later"
  head "https://github.com/Sunflower-Dolls/Vapoursynth-BM3DMETAL.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "llvm@17" => :build
  depends_on "x265" => :test
  depends_on macos: :ventura
  depends_on "vapoursynth" # Mac only due to Metal dependency

  def install
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
