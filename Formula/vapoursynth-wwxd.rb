class VapoursynthWwxd < Formula
  desc "Xvid-like scene change detection for VapourSynth"
  homepage "https://github.com/dubhater/vapoursynth-wwxd"
  url "https://github.com/dubhater/vapoursynth-wwxd/archive/refs/tags/v1.0.tar.gz"
  sha256 "29da62c3cde87bd4ebb7ceaf7ad8344834412fcdddbc9d115ed62f478c42e874"
  license "GPL-2.0-only"
  head "https://github.com/dubhater/vapoursynth-wwxd.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-wwxd-1.0"
    rebuild 2
    sha256 cellar: :any,                 arm64_tahoe:   "8c6d13c5dfe585dd08fbe73b29d99d841aaa9dc6494b33eb423084afdb37e769"
    sha256 cellar: :any,                 arm64_sequoia: "dbf451e0a78b29a20526909b3eeb1f56ddea7aafc6b0cf31991dc57593cfbc00"
    sha256 cellar: :any,                 arm64_sonoma:  "d5fdc8acbfd32c088a6ebecb7490a3e9080c3df644bebab0fb1248f2dc1412c7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5540a084b7a5448e7bb1fa5cb5611075919d71f2cc3ff506a763093b0e1f6374"
  end

  depends_on "pkgconf" => :build
  depends_on "x265" => :test
  depends_on "vapoursynth"

  def install
    install_name = shared_library("libwwxd")

    system ENV.cc, "-o", install_name, "-fPIC", "-shared", "-O2", "-Wall", "-Wextra", "-Wno-unused-parameter",
           *`pkg-config --cflags vapoursynth`.split, "src/wwxd.c", "src/detection.c"
    mkdir "#{lib}/vapoursynth"
    lib.install install_name => "vapoursynth/#{install_name}"
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
      clip = core.wwxd.WWXD(clip)
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
