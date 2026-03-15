class AwsmfuncFull < Formula
  include Language::Python::Virtualenv

  desc "Awesome VapourSynth functions"
  homepage "https://github.com/OpusGang/awsmfunc"
  url "https://github.com/OpusGang/awsmfunc/archive/refs/tags/1.3.5.tar.gz"
  sha256 "ce6cfe7c366171ced3b6d5f6675444d267909ce54da3e43b5a337d21f8f6cd96"
  license "MIT"
  head "https://github.com/OpusGang/awsmfunc.git", branch: "master"

  bottle do
    root_url "https://github.com/WOSSFOSS/homebrew-vapoursynth/releases/download/awsmfunc-full-1.3.5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "15f99df43d6143a09696b3189c0da2697d4da80f47cbe285e508d5385bef6d46"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "43059449f5f12590e313281ecc3f65c568bfe1fbb0f455fa0b56718e5af9f4c8"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "fa69fdb0b16445d84c8ea4592728885b02e501127a323bde69ad1b5253729674"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c3e093cbc793073e49f0651e55b93f859fd050f909f927aae048b26f1eff3eb3"
  end

  depends_on "x265" => :test
  depends_on "numpy"
  depends_on "python@3.14"
  depends_on "vapoursynth"
  depends_on "vapoursynth-bilateral"
  depends_on "vapoursynth-descale"
  depends_on "vapoursynth-fillborders"
  depends_on "vapoursynth-fpng"
  depends_on "vapoursynth-placebo"
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
      info = FrameInfo(clip, title="Test")
      info.output(sys.stdout)
    PYTHON
    python_call = "#{python} #{testpath}/test.py"
    x265_call = "#{Formula["x265"].opt_bin}/x265 - --input-res 1920x1080 --fps 24 --output #{testpath}/test.hevc"
    call = "#{python_call} | #{x265_call}"
    system "sh", "-c", "#{python_call} > /dev/null"
    system "sh", "-c", call
    assert_path_exists testpath/"test.hevc"
  end
end
