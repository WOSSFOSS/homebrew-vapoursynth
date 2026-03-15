class Knlmeanscl < Formula
  desc "Optimized OpenCL implementation of the Non-local means de-noising algorithm"
  homepage "https://github.com/Khanattila/KNLMeansCL"
  license "GPL-3.0-only"
  head "https://github.com/Khanattila/KNLMeansCL.git", branch: "master"

  depends_on "boost" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "opencl-headers" => :build
  depends_on "x265" => :test
  depends_on "vapoursynth"

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    python = Formula["vapoursynth"].deps
                                   .find { |d| d.name.match?(/^python@\d\.\d+$/) }
                                   .to_formula
                                   .opt_libexec/"bin/python"
    if OS.mac?
      (testpath/"test.py").write <<~PYTHON
        from vapoursynth import core
        import sys
        clip = core.std.BlankClip(length=5, width=1920, height=1080, fpsnum=24, fpsden=1)
        clip = core.knlm.KNLMeansCL(clip, d=3, h=1.0, device_type='gpu', device_id=0)
        clip.output(sys.stdout)
      PYTHON
    else
      (testpath/"test.py").write <<~PYTHON
        from vapoursynth import core
        import sys
        clip = core.std.BlankClip(length=5, width=1920, height=1080, fpsnum=24, fpsden=1)
        clip = core.knlm.KNLMeansCL(clip, d=3, h=1.0, device_type='cpu')
        clip.output(sys.stdout)
      PYTHON
    end
    python_call = "#{python} test.py"
    x265_call = "#{Formula["x265"].opt_bin}/x265 - --input-res 1920x1080 --fps 24 --output test.hevc"
    call = "#{python_call} | #{x265_call}"
    system "sh", "-c", "#{python_call} > /dev/null"
    system "sh", "-c", call
    assert_path_exists testpath/"test.hevc"
  end
end
