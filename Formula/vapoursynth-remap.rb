class VapoursynthRemap < Formula
  desc "VapourSynth port of RemapFrames"
  homepage "https://github.com/Irrational-Encoding-Wizardry/Vapoursynth-RemapFrames"
  url "https://github.com/Irrational-Encoding-Wizardry/Vapoursynth-RemapFrames/archive/refs/tags/v1.1.tar.gz"
  sha256 "1de7955c3eca3c502a97a322b309c245d474c154a71bd9a30a7676b531a2416d"
  license "BSD-2-Clause"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
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
    system python, "-c", "from vapoursynth import core; core.remap"
  end
end
