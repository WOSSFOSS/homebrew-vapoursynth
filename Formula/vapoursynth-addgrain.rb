class VapoursynthAddgrain < Formula
  desc "AddGrain filter for VapourSynth"
  homepage "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-AddGrain"
  url "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-AddGrain/archive/refs/tags/r10.tar.gz"
  sha256 "0d5f4addca0d852cc973b82e355c3a78dfc9eeedeb68fd2748ed20325dca6d85"
  license "GPL-3.0-or-later"
  head "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-AddGrain.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-addgrain-10"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "0196480692d94d4102ba0dc995ae41a5b6f1576842f5832eb21f1cc7bd99cebc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a28652d6b51db2c446294d4916b8090ea81f2ae28ea513e328bdf09a8a2019dd"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "59a0d14e4583a752ba127fcb076737f51b7117dd3e1ce5404d815d7a4af47ae0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "9640c8f1b2230b3915a7ea9f4cd85f3c6b197e5dda16f9059c1bdf1642da01f6"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "x265" => :test
  depends_on "vapoursynth"

  def install
    # Upstream build system wants to install directly into vapoursynth's libdir and does not respect
    # prefix, but we want it in a Cellar location instead.
    inreplace "meson.build",
              "install_dir = vapoursynth_dep.get_variable(pkgconfig: 'libdir') / 'vapoursynth'",
              "install_dir =  '#{lib}/vapoursynth'"

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
      grained = core.grain.Add(clip)
      info.output(sys.stdin)
    PYTHON
    python_call = "#{python} test.py"
    x265_call = "#{Formula["x265"].opt_bin}/x265 - --input-res 1920x1080 --fps 24 --output test.hevc"
    call = "#{python_call} | #{x265_call}"
    system "sh", "-c", call
    assert_path_exists testpath/"test.hevc"
  end
end
