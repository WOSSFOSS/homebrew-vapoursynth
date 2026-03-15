class VapoursynthDfttest < Formula
  desc "DFTTest filter for VapourSynth"
  homepage "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest"
  url "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest/archive/refs/tags/r7.tar.gz"
  sha256 "1f4def2a2b82c32d3a5e6c5ece31a2ca0e833f02aa352c9bccb57ea18145b920"
  license "GPL-3.0-or-later"
  head "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-dfttest-7"
    sha256 cellar: :any, arm64_tahoe:   "c16fb0e062ebbb4984bff69c1f1c567b9e6f1057ca7047e82dfaf0da391b129c"
    sha256 cellar: :any, arm64_sequoia: "4688edc369238b3e06eee30bc062824ed65ec2a853b8f3a1d864b7e86a7cf8f0"
    sha256 cellar: :any, arm64_sonoma:  "ae15ef819634b6991afa22d751b6a5fece5a0310a75659a919185762bd5af353"
    sha256               x86_64_linux:  "010966feaeae9ca9ee34d6cfa4be9f042ceb0731e67e968b7a860dc7ba23ea91"
  end

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
