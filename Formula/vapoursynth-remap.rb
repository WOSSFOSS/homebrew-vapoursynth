class VapoursynthRemap < Formula
  desc "VapourSynth port of RemapFrames"
  homepage "https://github.com/Irrational-Encoding-Wizardry/Vapoursynth-RemapFrames"
  url "https://github.com/Irrational-Encoding-Wizardry/Vapoursynth-RemapFrames/archive/refs/tags/v1.1.tar.gz"
  sha256 "1de7955c3eca3c502a97a322b309c245d474c154a71bd9a30a7676b531a2416d"
  license "BSD-2-Clause"
  head "https://github.com/Irrational-Encoding-Wizardry/Vapoursynth-RemapFrames.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-remap-1.1"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:   "8646842f81c35ccd29c8fafee26b59073519f87962104035910602b1a3fba2c4"
    sha256 cellar: :any, arm64_sequoia: "109fb33d82532865edc6f5a49006eee66c7db5f01c4157c772e165488579c534"
    sha256 cellar: :any, arm64_sonoma:  "f384cfd73dd04b5ec3e35242581b8d0121cd8ea847176d5aa3e5b3b5c73f5f88"
    sha256               x86_64_linux:  "3b3fb926c29b2001fb70503daee069b41c8e15fb228801beb98ce7ca5ae2db77"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "x265" => :test
  depends_on "vapoursynth"

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
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
      clip = core.remap.RemapFrames(clip)
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
