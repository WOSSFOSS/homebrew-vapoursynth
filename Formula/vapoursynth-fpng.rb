class VapoursynthFpng < Formula
  desc "Fpng for VapourSynth"
  homepage "https://github.com/Mikewando/vsfpng"
  url "https://github.com/Mikewando/vsfpng/archive/refs/tags/1.0.tar.gz"
  sha256 "f982325f7e0b45dc9d21d54c58981db4e9bc9fea775f4b3158fcf138142327a7"
  license "LGPL-2.1-or-later"
  head "https://github.com/Mikewando/vsfpng.git", branch: "master"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "vapoursynth"

  patch do
    url "https://github.com/Mikewando/vsfpng/commit/d2c59bb4e4949a1b747d21f76494705c315b382a.patch?full_index=1"
    sha256 "1eedd931987830a461ade72b54adb24b1895c5b0300f3676b8e7b6c7a7a2f572"
  end

  def install
    # Upstream build system wants to install directly into vapoursynth's libdir and does not respect
    # prefix, but we want it in a Cellar location instead.
    inreplace "meson.build",
              "install_dir = vapoursynth_dep.get_variable(pkgconfig: 'libdir') / 'vapoursynth'",
              "install_dir = '#{lib}/vapoursynth'"
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    python = Formula["vapoursynth"].deps
                                   .find { |d| d.name.match?(/^python@\d\.\d+$/) }
                                   .to_formula
                                   .opt_libexec/"bin/python"
    system python, "-c", "from vapoursynth import core; core.fpng"
  end
end
