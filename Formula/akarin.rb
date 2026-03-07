class Akarin < Formula
  desc "Enhanced LLVM-based std.Expr, Select, PropExpr, Text, Tmpl, DLISR, DLVFX, CAMBI"
  homepage "https://github.com/AkarinVS/vapoursynth-plugin"
  url "https://github.com/AkarinVS/vapoursynth-plugin/archive/refs/tags/v0.96f.tar.gz"
  sha256 "2cb51062642e160dea322c5e1fa027b0c0ed8938c9225a9f09cbef40f33dbec3"
  license "LGPL-3.0-only"
  head "https://github.com/AkarinVS/vapoursynth-plugin.git", branch: "master"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "llvm@15"
  depends_on "vapoursynth"
  depends_on "zlib-ng-compat"
  depends_on "zstd"

  uses_from_macos "ncurses"

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
    system python, "-c", "from vapoursynth import core; core.akarin"
  end
end
