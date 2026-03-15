class NeoF3kdb < Formula
  desc "Forked from SAPikachu/flash3kyuu_deband"
  homepage "https://github.com/HomeOfAviSynthPlusEvolution/neo_f3kdb"
  license "GPL-3.0-only"
  head "https://github.com/HomeOfAviSynthPlusEvolution/neo_f3kdb.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "x265" => :test
  depends_on "vapoursynth"

  patch do
    url "https://github.com/HomeOfAviSynthPlusEvolution/neo_f3kdb/commit/5e520a359cd852bee5734962a4eebefbdd02deef.patch?full_index=1"
    sha256 "18160f25a1f20f7c11076b3def66a5513320679472d5d6ffdca7bf7ac26a088b"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    mkdir "#{lib}/vapoursynth"
    # Necessary because cmake --install doesn't actually do anything
    (lib/"vapoursynth").install "build/libneo-f3kdb.dylib" => "libneo-f3kdb.dylib"
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
      clip = core.resize.Point(clip, format=vs.YUV420P8, matrix_s="709") # Needed because neo_f3kdb doesn't support RGB input
      clip = core.neo_f3kdb.Deband(clip)
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
