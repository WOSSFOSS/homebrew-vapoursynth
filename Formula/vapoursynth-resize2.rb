class VapoursynthResize2 < Formula
  desc "Enhanced zimg resizer with custom kernel, blur, and force-resize support"
  homepage "https://github.com/Jaded-Encoding-Thaumaturgy/vapoursynth-resize2"
  url "https://github.com/Jaded-Encoding-Thaumaturgy/vapoursynth-resize2/archive/refs/tags/0.4.2.tar.gz"
  sha256 "40d0feb0845b97eefb7eb1b20784bf641a72b15d5191dd19b26077344b44ea23"
  license "LGPL-2.1-or-later"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-resize2-0.4.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f6046a0e628e12b4bb5e3dd482bbbf1514d92addcbad3b7024036c5a49162d4f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "02cd570b289248a51ae7ac697a0a0bf22ceb2a977d52547942cfe90983fd6288"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "38375462b85f089c9d900c6635e4fe427d146a6af48360f776d43c4d4496f3e7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a09fb247797794c561af51143e94a0a772ac9383af99557b5ebb50ded797ca2a"
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
