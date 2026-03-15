class VapoursynthZip < Formula
  desc "VapourSynth Zig Image Processing Plugin"
  homepage "https://github.com/dnjulek/vapoursynth-zip"
  url "https://github.com/dnjulek/vapoursynth-zip/archive/refs/tags/R13.tar.gz"
  sha256 "d8916f1d04fae4123a48c53e37b15ca015cb4a8a4f6e43e75c870ac2524dd0e0"
  license "MIT"
  head "https://github.com/dnjulek/vapoursynth-zip.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/vapoursynth-zip-13"
    sha256 cellar: :any,                 arm64_tahoe:   "c97ff244ff096b9a9cd1a513d83f42d2fe99bed060b5689f4ec1cac22e3e94d5"
    sha256 cellar: :any,                 arm64_sequoia: "a41ee1e1d8e2cb27ec7e9ea6770fa9ea5de9ba6b80ccc90b68619458b8dc7158"
    sha256 cellar: :any,                 arm64_sonoma:  "f589de1b2c35da49fefeeff766dc46769204418bc78eb4ec59fd1bd49fda5d2c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "2104cacda12aee1fb83f8e8d52ec1a216286772dedc370a647cf462cca9749fc"
  end

  depends_on "zig" => :build
  depends_on "x265" => :test
  depends_on "vapoursynth"

  def install
    extension_name = shared_library("libvszip")
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
      clip = core.vszip.Deband(clip)
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
