class VapoursynthFpng < Formula
  desc "Fpng for VapourSynth"
  homepage "https://github.com/Mikewando/vsfpng"
  url "https://github.com/Mikewando/vsfpng/archive/refs/tags/1.0.tar.gz"
  sha256 "f982325f7e0b45dc9d21d54c58981db4e9bc9fea775f4b3158fcf138142327a7"
  license "LGPL-2.1-or-later"
  head "https://github.com/Mikewando/vsfpng.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-fpng-1.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "bb44766db5db9b01f054918add1abeda2c81947c6bd0b353fe6fe00c255fdaf0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e1be95e63390881bf310a9c9ed4c1ecada673b0f98a676bc1955844da5a3ad52"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "99b7c1e97840e58a74a5223d212f04d2bde768d75adb9afebc7ef684d1669107"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a41cfdc636bca24018d3f0cc017ce91e2aee587a90c3a822621b8fece9d53cbb"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "x265" => :test
  depends_on "vapoursynth"

  patch do
    url "https://github.com/Mikewando/vsfpng/commit/d2c59bb4e4949a1b747d21f76494705c315b382a.patch?full_index=1"
    sha256 "1eedd931987830a461ade72b54adb24b1895c5b0300f3676b8e7b6c7a7a2f572"
  end

  def install
    # Upstream build system wants to install directly into vapoursynth's libdir and does not respect
    # prefix, but we want it in a Cellar location instead.
    inreplace "meson.build",
              "install_dir = vapoursynth_dep.get_variable(pkgconfig: 'libdir') / 'vapoursynth'",
              "install_dir = '#{lib}/vapoursynth'"
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
      clip = core.fpng.Write(clip, "test%04d.png")
      with open("/dev/null", "wb") as f:
        clip.output(f)
    PYTHON
    python_call = "#{python} test.py"
    system "sh", "-c", python_call.to_s
    (0..4).each do |i|
      assert_path_exists testpath/"test000#{i}.png"
    end
  end
end
