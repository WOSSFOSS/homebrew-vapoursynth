class VapoursynthFillborders < Formula
  desc "Fills the borders of a clip"
  homepage "https://github.com/dubhater/vapoursynth-fillborders"
  url "https://github.com/dubhater/vapoursynth-fillborders/archive/refs/tags/v2.tar.gz"
  sha256 "935eb2a243f2a83ef0f1fe0ddc8cb1e16c81e99ccf5b690d089487a46a9c1c4d"
  license ""

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
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
    system python, "-c", "from vapoursynth import core; core.fb"
  end
end
