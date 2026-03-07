class Knlmeanscl < Formula
  desc "Optimized OpenCL implementation of the Non-local means de-noising algorithm"
  homepage "https://github.com/Khanattila/KNLMeansCL"
  license "GPL-3.0-only"
  head "https://github.com/Khanattila/KNLMeansCL.git", branch: "master"

  depends_on "boost" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "opencl-headers" => :build
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
    system python, "-c", "from vapoursynth import core; core.knlm"
  end
end
