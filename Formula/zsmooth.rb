class Zsmooth < Formula
  desc "Cross-platform, cross-architecture video smoothing functions for Vapoursynth"
  homepage "https://forum.doom9.org/showthread.php?t=185465"
  url "https://github.com/adworacz/zsmooth/archive/refs/tags/0.15.tar.gz"
  sha256 "d9a8be63ca9e358ea9677b1ccb000dac5350325300e1d58a262f4f1b86e1683e"
  license "MIT"
  head "https://github.com/adworacz/zsmooth.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/zsmooth-0.15"
    sha256 cellar: :any,                 arm64_tahoe:   "01c26c3c0767ca71a067c7abd7f8ce6a233100167b043858c08415ae63b2f95f"
    sha256 cellar: :any,                 arm64_sequoia: "08cd9f26de61738c71a07317716bee1f35e226d5f5dea4f5a0dedd8615a825b7"
    sha256 cellar: :any,                 arm64_sonoma:  "3ca14df121088fc8718d2c9cc3883871fb9b8a0dd51c0c564218ffeb3fa0c964"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "160d3b5c4a27921a168f4a2689d8a6ed5b5ebc640a73a5a7ca31969fce338ff2"
  end

  depends_on "zig" => :build
  depends_on "x265" => :test
  depends_on "vapoursynth"

  def install
    extension_name = shared_library("libzsmooth")
    if OS.mac?
      max_install_size_pre = <<~ZIG
        if (target.result.os.tag == .macos) {
          lib.headerpad_max_install_names = true;
        }
      ZIG
      install_command = "    b.installArtifact(lib);"
      inreplace "build.zig", install_command, max_install_size_pre + install_command
    end
    system "zig", "build", *std_zig_args
    (lib/"vapoursynth").install_symlink lib/extension_name
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
      clip = core.zsmooth.CCD(clip)
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
