class VapoursynthDfttest < Formula
  desc "DFTTest filter for VapourSynth"
  homepage "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest"
  url "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest/archive/refs/tags/r7.tar.gz"
  sha256 "1f4def2a2b82c32d3a5e6c5ece31a2ca0e833f02aa352c9bccb57ea18145b920"
  license "GPL-3.0-or-later"
  head "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest.git", branch: "master"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "x265" => :test
  depends_on "fftw"
  depends_on "vapoursynth"

  patch do
    url "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest/commit/89034df3fa630cbc9d73fd3ed9bcc222468f3fee.patch?full_index=1"
    sha256 "3c94534e2e77fda8dcced021044033ac00b467867116427897799b396ac4b97f"
  end

  def install
    # Upstream build system wants to install directly into vapoursynth's libdir and does not respect
    # prefix, but we want it in a Cellar location instead.
    inreplace "meson.build",
              "install_dir: join_paths(vapoursynth_dep.get_pkgconfig_variable('libdir'), 'vapoursynth'),",
              "install_dir: '#{lib}/vapoursynth',"

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
      clip = core.dfttest.DFTTest(clip)
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
