class VapoursynthFillborders < Formula
  desc "Fills the borders of a clip"
  homepage "https://github.com/dubhater/vapoursynth-fillborders"
  url "https://github.com/dubhater/vapoursynth-fillborders/archive/refs/tags/v2.tar.gz"
  sha256 "935eb2a243f2a83ef0f1fe0ddc8cb1e16c81e99ccf5b690d089487a46a9c1c4d"
  license "WTFPL"
  head "https://github.com/dubhater/vapoursynth-fillborders.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-fillborders-2"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "792341e4f6ef7316110754e3186867a7f5c7025bb75e1204c20209e4e742b321"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5f2ecd378b141c1813d0beb84b935a4eabd2db0bbb938940944068e47a393de2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "b6338bfc63fbfda2bd90b3a57130fcf141e188b6f463e88052aba786d23ac88c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c8b6fe422b4b994e7e80b1338f07da706e92b5d58680cb0e79ba88abbd86311d"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "x265" => :test
  depends_on "vapoursynth"

  def install
    system "meson", "setup", "build", *std_meson_args, "--libdir=#{lib}/vapoursynth"
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
      clip = core.fb.FillBorders(clip, 2, 2, 2, 2)
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
