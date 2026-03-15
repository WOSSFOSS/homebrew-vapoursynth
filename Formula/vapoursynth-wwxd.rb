class VapoursynthWwxd < Formula
  desc "Xvid-like scene change detection for VapourSynth"
  homepage "https://github.com/dubhater/vapoursynth-wwxd"
  url "https://github.com/dubhater/vapoursynth-wwxd/archive/refs/tags/v1.0.tar.gz"
  sha256 "29da62c3cde87bd4ebb7ceaf7ad8344834412fcdddbc9d115ed62f478c42e874"
  license "GPL-2.0-only"
  head "https://github.com/dubhater/vapoursynth-wwxd.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-wwxd-1.0"
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:   "204e6d0625ac63991fee56563e7169146648abe6dbd0647aa8dec8615ea67406"
    sha256 cellar: :any,                 arm64_sequoia: "8e3c9c4490959b0bed570ff2ee2322285115683ee546970c009831294d13fbed"
    sha256 cellar: :any,                 arm64_sonoma:  "4232519be71468c73d793758d0b87a1f0ae6328415a88bc99333f1dbada834ac"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d1c907548fdba61938eaeca6fd94f12e0ca80b4c034afa355e4b3749dca72dcb"
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
