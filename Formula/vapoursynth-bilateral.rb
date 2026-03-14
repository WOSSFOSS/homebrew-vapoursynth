class VapoursynthBilateral < Formula
  desc "Bilateral filter for VapourSynth"
  homepage "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bilateral"
  url "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bilateral/archive/refs/tags/r3.tar.gz"
  sha256 "d652cc9406b03786a8248cb46ceb51db96ab9b57665aa6ca4ff7c83aa108b305"
  license "GPL-3.0-only"
  head "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bilateral.git", branch: "master"

  depends_on "pkgconf" => :build
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
    system python, "-c", "from vapoursynth import core; core.bilateral"
  end
end
