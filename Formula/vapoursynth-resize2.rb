class VapoursynthResize2 < Formula
  desc "Enhanced zimg resizer with custom kernel, blur, and force-resize support"
  homepage "https://github.com/Jaded-Encoding-Thaumaturgy/vapoursynth-resize2"
  url "https://github.com/Jaded-Encoding-Thaumaturgy/vapoursynth-resize2/archive/refs/tags/0.4.0.tar.gz"
  sha256 "2a3629f19c59351544b7a5a8c3f93cc04b60efea45d37347534452e66adfa067"
  license "LGPL-2.1-or-later"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-resize2-0.3.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f77fc991dc929020dc0433c15cf592101b8dc426cc42f2a9d8e3fa878a193f57"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "cf8af7589459d9b22893bb6c0a5c9b533852c803704a904d491f1b9dca37e231"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "6410112b86799fb113539fba1613bd729b14d804aa8853a822c1b9c777cdb0bd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0e1793a621573826fdd08c3da3e825a5164b159eced98ce362d49879329c13b4"
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
              "install_dir : join_paths(vapoursynth_dep.get_variable(pkgconfig: 'libdir'), 'vapoursynth'),",
              "install_dir : '#{lib}/vapoursynth',"

    system "meson", "setup", "build", *std_meson_args, "--wrap-mode=forcefallback"
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
      import vapoursynth as vs
      import sys
      clip = core.std.BlankClip(length=5, width=1920, height=1080, fpsnum=24, fpsden=1)
      clip = core.resize2.Spline36(clip=clip, format=vs.RGBS)
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
