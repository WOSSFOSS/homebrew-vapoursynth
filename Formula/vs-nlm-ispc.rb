class VsNlmIspc < Formula
  desc "Non-local means denoise filter, drop-in replacement of KNLMeansCL"
  homepage "https://github.com/AmusementClub/vs-nlm-ispc"
  url "https://github.com/AmusementClub/vs-nlm-ispc/archive/refs/tags/v2.tar.gz"
  sha256 "bdb0404a8a6ca736cbd91daf0d5d17f3b9f197a7779e07721bfe24d37fc7b3dc"
  license "GPL-3.0-or-later"
  head "https://github.com/AmusementClub/vs-nlm-ispc.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "ispc" => :build
  depends_on "pkgconf" => :build
  depends_on "x265" => :test
  depends_on "vapoursynth"

  def install
    inreplace "CMakeLists.txt", "install(TARGETS vsnlm_ispc LIBRARY DESTINATION ${install_dir})",
"install(TARGETS vsnlm_ispc LIBRARY DESTINATION \"#{lib}/vapoursynth\")"
    ENV["ISPC"] = Formula["ispc"].opt_bin/"ispc"
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args,
"-DVS_INCLUDE_DIR=#{Formula["vapoursynth"].opt_include}/vapoursynth"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    python = Formula["vapoursynth"].deps
                                   .find { |d| d.name.match?(/^python@\d\.\d+$/) }
                                   .to_formula
                                   .opt_libexec/"bin/python"
    (testpath/"test.py").write <<~PYTHON
      from vapoursynth import core
      import sys
      clip = core.std.BlankClip(length=5, width=1920, height=1080, fpsnum=24, fpsden=1)
      clip = core.nlm_ispc.NLMeans(clip)
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
