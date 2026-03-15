class Awsmfunc < Formula
  include Language::Python::Virtualenv

  desc "Awesome VapourSynth functions"
  homepage "https://github.com/OpusGang/awsmfunc"
  url "https://github.com/OpusGang/awsmfunc/archive/refs/tags/1.3.5.tar.gz"
  sha256 "ce6cfe7c366171ced3b6d5f6675444d267909ce54da3e43b5a337d21f8f6cd96"
  license "MIT"
  head "https://github.com/OpusGang/awsmfunc.git", branch: "master"

  depends_on "x265" => :test
  depends_on "numpy"
  depends_on "python@3.14"
  depends_on "vapoursynth"
  depends_on "vapoursynth-fillborders"
  depends_on "vapoursynth-remap"
  depends_on "vapoursynth-sub"

  pypi_packages exclude_packages: %w[numpy vapoursynth]

  resource "vs-rekt" do
    url "https://files.pythonhosted.org/packages/89/9a/c6f11f016ba0d54da2c0fe16b3f742dce5801beff3d01979c5d77d45ca4b/vs-rekt-1.0.0.tar.gz"
    sha256 "24fbc0b577074e841b80c7d02b7ab2c88c1a5c703276d37dea530d6ba109ae31"
  end

  resource "vsutil" do
    url "https://files.pythonhosted.org/packages/f2/dc/95df63612bd0a95d7a06a1c51dde3ca0f4ae697d9e231c2345390ff9638c/vsutil-0.8.0.tar.gz"
    sha256 "e01831203dfb9c3af86a101fba5e7fe04e3686bddec94bb3057ca73e84c98768"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    python = libexec/"bin/python3"
    (testpath/"test.py").write <<~PYTHON
      from awsmfunc import FrameInfo
      from vapoursynth import core
      import sys
      clip = core.std.BlankClip(length=5, width=1920, height=1080, fpsnum=24, fpsden=1)
      info = FrameInfo(clip)
      info.output(sys.stdin)
    PYTHON
    python_call = "#{python} #{testpath}/test.py"
    x265_call = "#{Formula["x265"].opt_bin}/x265 - --input-res 1920x1080 --fps 24 --output #{testpath}/test.hevc"
    call = "#{python_call} | #{x265_call}"
    system "sh", "-c", call
    assert_path_exists testpath/"test.hevc"
  end
end
