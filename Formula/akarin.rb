class Akarin < Formula
  desc "Enhanced LLVM-based std.Expr, Select, PropExpr, Text, Tmpl, DLISR, DLVFX, CAMBI"
  homepage "https://github.com/AkarinVS/vapoursynth-plugin"
  url "https://github.com/AkarinVS/vapoursynth-plugin/archive/refs/tags/v0.96f.tar.gz"
  sha256 "2cb51062642e160dea322c5e1fa027b0c0ed8938c9225a9f09cbef40f33dbec3"
  license "LGPL-3.0-only"
  head "https://github.com/AkarinVS/vapoursynth-plugin.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/akarin-0.96"
    rebuild 1
    sha256 cellar: :any,                 arm64_sonoma: "924ab0e97428b3db85ca02e1c1f56ffbba597c45e84661cb5631e5a363e03714"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "104376abc4fc1bfc6e0375fe1910b09d7540363bd37eab08fe2743ca55ed216a"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "x265" => :test
  depends_on "llvm@15"
  depends_on "vapoursynth"
  depends_on "zstd"

  uses_from_macos "ncurses"

  on_linux do
    depends_on "zlib-ng-compat"
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
      text = core.akarin.Text(clip, "Akarin Frame#: {N}")
      text.output(sys.stdout)
    PYTHON
    python_call = "#{python} test.py"
    x265_call = "#{Formula["x265"].opt_bin}/x265 - --input-res 1920x1080 --fps 24 --output test.hevc"
    call = "#{python_call} | #{x265_call}"
    system "sh", "-c", "#{python_call} > /dev/null"
    system "sh", "-c", call
    assert_path_exists testpath/"test.hevc"
  end
end
