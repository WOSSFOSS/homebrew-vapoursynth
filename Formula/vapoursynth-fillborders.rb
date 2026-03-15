class VapoursynthFillborders < Formula
  desc "Fills the borders of a clip"
  homepage "https://github.com/dubhater/vapoursynth-fillborders"
  url "https://github.com/dubhater/vapoursynth-fillborders/archive/refs/tags/v2.tar.gz"
  sha256 "935eb2a243f2a83ef0f1fe0ddc8cb1e16c81e99ccf5b690d089487a46a9c1c4d"
  license "WTFPL"
  head "https://github.com/dubhater/vapoursynth-fillborders.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-fillborders-2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "77e2ab2bfa4611bee03ed2fad12608150785b9995263489147321f65f9cf8eb2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f4b20ce2abcadce231ca60fbd5e7a07080ef384dfd770114c804c90dcb3bd0a7"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2da5af497ce4c0100c9d0c416f4acc3369feda1140900560c6f8e9d952cf81ec"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ee57a13454ea9f9f363d8a2e385fbfe1517f75ee9367bb90e464b70a759d4bcb"
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
