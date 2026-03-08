class VapoursynthPlacebo < Formula
  desc "Libplacebo-based debanding, scaling and color mapping plugin for VapourSynth"
  homepage "https://github.com/sgt0/vs-placebo"
  url "https://github.com/sgt0/vs-placebo.git",
      tag:      "v3.3.1",
      revision: "b6ca788bec16646456a88addd18b1f7c7fa07511"
  license "LGPL-2.1-only"
  head "https://github.com/sgt0/vs-placebo.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-placebo-3.3.1"
    sha256 cellar: :any, arm64_tahoe:   "d8e3ddf1987bfac801610f01147c93fcf4125c5d1d2c9ff48168ad77a4a7830d"
    sha256 cellar: :any, arm64_sequoia: "cb77bb162a5fd0672de0498fd9a5bd86e3d0c20cfbbf5f2038306d63d872eec5"
    sha256 cellar: :any, arm64_sonoma:  "1ca7feca10130c4e0f1aca1819b9abe29267e8c2b6118f343cef2ad429ffe76a"
    sha256               x86_64_linux:  "05c179379a43d4ffd1772fdda49337ba6b6ce88263612aeca6084845249916da"
  end

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
