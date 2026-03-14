class VapoursynthRemap < Formula
  desc "VapourSynth port of RemapFrames"
  homepage "https://github.com/Irrational-Encoding-Wizardry/Vapoursynth-RemapFrames"
  url "https://github.com/Irrational-Encoding-Wizardry/Vapoursynth-RemapFrames/archive/refs/tags/v1.1.tar.gz"
  sha256 "1de7955c3eca3c502a97a322b309c245d474c154a71bd9a30a7676b531a2416d"
  license "BSD-2-Clause"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-remap-1.1"
    sha256 cellar: :any, arm64_tahoe:   "93e3a03e60bed0b0dfe080b468afabd2b08bf29780bb74d3ff4e36780f60634b"
    sha256 cellar: :any, arm64_sequoia: "94d25e151fd1d923f5c2c3a6f75c02dcfa6b38f7c1af7a03b96c1574b4e2dee5"
    sha256 cellar: :any, arm64_sonoma:  "4561ec1165ab4ad5f623d5f5cabf8ace122d159be4023e6e31ab2166e537fc47"
    sha256               x86_64_linux:  "e1a87924468d70ee060cdcf4a24377d6f95a67226a323c85673e0df733fe122b"
  end

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
