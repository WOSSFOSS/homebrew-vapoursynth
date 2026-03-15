class VapoursynthBilateral < Formula
  desc "Bilateral filter for VapourSynth"
  homepage "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bilateral"
  url "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bilateral/archive/refs/tags/r3.tar.gz"
  sha256 "d652cc9406b03786a8248cb46ceb51db96ab9b57665aa6ca4ff7c83aa108b305"
  license "GPL-3.0-only"
  head "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bilateral.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-bilateral-3"
    sha256 cellar: :any,                 arm64_tahoe:   "11c7b50b2395657a472985bb3e36dbfe96abe4914b99719f8faf6f72536df5af"
    sha256 cellar: :any,                 arm64_sequoia: "6f86cf243ecf63bc4a20d5fd5d75376f75b5c7d4c445c63d9d2075a8520c6b06"
    sha256 cellar: :any,                 arm64_sonoma:  "90aea768ddd68e79b64fc83e1120a62605cb820e8cf5d18e6e4c167d09c1f198"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "05348805648979b832c9bbb1d03cf135c926bd80cd74994c67580a4f5c8f6185"
  end

  depends_on "pkgconf" => :build
  depends_on "x265" => :test
  depends_on "vapoursynth"

  patch do
    url "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bilateral/commit/4fa0c9ee988466faaba3b5a4228d2e57a9e137a5.patch?full_index=1"
    sha256 "cb0276ef4e915d6d17e2ac654089978296689dcfc8fe6e70cbf9c35dcee49041"
  end

  def install
    inreplace "configure",
'SOFLAGS="$SOFLAGS -dynamiclib -Wl,-undefined,suppress -Wl,-read_only_relocs,suppress -Wl,-flat_namespace"',
'SOFLAGS="$SOFLAGS -dynamiclib -Wl,-undefined,suppress -Wl,-read_only_relocs,suppress"'
    chmod "+x", "configure"
    system "./configure", "--install=#{lib}/vapoursynth", "--cxx=#{ENV.cxx}", "--target=64"
    system "make", "install"
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
      clip = core.bilateral.Bilateral(clip)
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
