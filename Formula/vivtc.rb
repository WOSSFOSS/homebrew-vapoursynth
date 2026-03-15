class Vivtc < Formula
  desc "Field matcher and decimation filter for VapourSynth similar to TIVTC"
  homepage "https://github.com/vapoursynth/vivtc"
  license "LGPL-2.1-or-later"
  head "https://github.com/vapoursynth/vivtc.git", branch: "master"

  stable do
    url "https://github.com/vapoursynth/vivtc/archive/refs/tags/R1.tar.gz"
    sha256 "f2c6619e2486f3bcbefb592c983c2ac62bb2cf261c95eb66a31bc6979340ac40"

    patch do
      url "https://github.com/vapoursynth/vivtc/commit/a54c3c48f7910dcea47282a36fa43cb38feee730.patch?full_index=1"
      sha256 "9915fdd9a3916136cd5d04a6f85bc43308b88f34e6b5e97cf84c0eb737f34579"
    end

    patch do
      url "https://github.com/vapoursynth/vivtc/commit/8716a24fb51b1c98f5c7d36629e94ca880523192.patch?full_index=1"
      sha256 "f5dca045cd9df82d067996acba917884268f8be1bfeb589786028d27dc907bd1"
    end
  end

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vivtc-1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e59df1cc6eaacb9cbd7b861e7c1a5271e47828ab1ecf82b119a3a11f1c7c59cd"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a60d0c63dd47e67c93d7e8943b21105d702f1e491b22b24999496593a3459b0b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "93a27b8e9a70718aeeb615417e16c65688fa486eb289a492b1197db7b0bc1782"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "dde097f56a36799c6d0a0ffd38a1cc758406397c065a6c60999cc470a3fddd7b"
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
              "install_dir : join_paths(vapoursynth_dep.get_pkgconfig_variable('libdir'), 'vapoursynth'),",
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
    (testpath/"test.py").write <<~PYTHON
      from vapoursynth import core
      import vapoursynth as vs
      import sys
      clip = core.std.BlankClip(length=5, width=1920, height=1080, fpsnum=24, fpsden=1)
      clip = core.resize.Point(clip, format=vs.YUV420P8, matrix_s="709") # Needed because vivtc doesn't support RGB input
      clip = core.vivtc.VFM(clip, 1)
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
