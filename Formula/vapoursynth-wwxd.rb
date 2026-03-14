class VapoursynthWwxd < Formula
  desc "Xvid-like scene change detection for VapourSynth"
  homepage "https://github.com/dubhater/vapoursynth-wwxd"
  url "https://github.com/dubhater/vapoursynth-wwxd/archive/refs/tags/v1.0.tar.gz"
  sha256 "29da62c3cde87bd4ebb7ceaf7ad8344834412fcdddbc9d115ed62f478c42e874"
  license ""
  head "https://github.com/dubhater/vapoursynth-wwxd.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-wwxd-1.0"
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:  "379c537bac0dadbecf3b8657e9c13509982d35887d820910db72f776c20cd47a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8baadb0160a6a95feb27213282503d3587b31f7b901087c582d8ed9e3e1f65f8"
  end

  depends_on "pkgconf" => :build
  depends_on "vapoursynth"

  def install
    install_name = OS.mac? ? "libwwxd.dylib" : "libwwxd.so"

    system ENV.cc, "-o", install_name, "-fPIC", "-shared", "-O2", "-Wall", "-Wextra", "-Wno-unused-parameter",
           *`pkg-config --cflags vapoursynth`.split, "src/wwxd.c", "src/detection.c"
    mkdir "#{lib}/vapoursynth"
    lib.install install_name => "vapoursynth/#{install_name}"
  end

  test do
    python = Formula["vapoursynth"].deps
                                   .find { |d| d.name.match?(/^python@\d\.\d+$/) }
                                   .to_formula
                                   .opt_libexec/"bin/python"
    system python, "-c", "from vapoursynth import core; core.wwxd"
  end
end
