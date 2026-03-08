class VapoursynthPlacebo < Formula
  desc "Libplacebo-based debanding, scaling and color mapping plugin for VapourSynth"
  homepage "https://github.com/sgt0/vs-placebo"
  url "https://github.com/sgt0/vs-placebo.git",
      tag:      "v3.3.1",
      revision: "b6ca788bec16646456a88addd18b1f7c7fa07511"
  license "LGPL-2.1-only"
  head "https://github.com/sgt0/vs-placebo.git", branch: "master"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "dovi_tool"
  depends_on "libplacebo"
  depends_on "vapoursynth"

  def install
    # Upstream build system wants to install directly into vapoursynth's libdir and does not respect
    # prefix, but we want it in a Cellar location instead.
    inreplace "meson.build",
              "install_dir : join_paths(vapoursynth_dep.get_variable(pkgconfig: 'libdir'), 'vapoursynth'),",
              "install_dir : '#{lib}/vapoursynth',"

    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    python = Formula["vapoursynth"].deps
                                   .find { |d| d.name.match?(/^python@\d\.\d+$/) }
                                   .to_formula
                                   .opt_libexec/"bin/python"
    system python, "-c", "from vapoursynth import core; core.placebo"
  end
end
