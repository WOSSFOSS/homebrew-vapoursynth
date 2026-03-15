class VsNlmIspc < Formula
  desc "Non-local means denoise filter, drop-in replacement of KNLMeansCL"
  homepage "https://github.com/AmusementClub/vs-nlm-ispc"
  url "https://github.com/AmusementClub/vs-nlm-ispc/archive/refs/tags/v2.tar.gz"
  sha256 "bdb0404a8a6ca736cbd91daf0d5d17f3b9f197a7779e07721bfe24d37fc7b3dc"
  license "GPL-3.0-or-later"
  head "https://github.com/AmusementClub/vs-nlm-ispc.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vs-nlm-ispc-2"
    sha256 cellar: :any,                 arm64_tahoe:   "6fc5a7f04b1190de92f2db8dd2d7bbf34cd9e9467546e77bc6921ebe572b199e"
    sha256 cellar: :any,                 arm64_sequoia: "e41d106da7def19d695d207428f80068b2d5b8d2eb0111c2f8c724d7f6e08094"
    sha256 cellar: :any,                 arm64_sonoma:  "399e7f123d3a3f1f513e1094d0e4bc95784582ef8c8fd22db1730cddd1283529"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c60fd100b08d6844dce8948bc75f41912c1cb0eee44c97f92871f0fc2105f827"
  end

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
