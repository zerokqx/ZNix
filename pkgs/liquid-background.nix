{
  lib,
  runCommand,
  python3,
  ffmpeg-headless,
  libglvnd,
  mesa,
  colors,
  width ? 1920,
  height ? 1080,
  fps ? 30,
  duration ? 12,
  speed ? 1,
  intensity ? 1,
  grain ? 0.12,
  softness ? 0.6,
  seed ? 42,
}:
runCommand "znix-sddm-liquid-background"
  {
    nativeBuildInputs = [
      (python3.withPackages (ps: [ ps.moderngl ]))
      ffmpeg-headless
    ];
    GLCONTEXT_LINUX_LIBGL = "${libglvnd}/lib/libGL.so.1";
    GLCONTEXT_LINUX_LIBEGL = "${libglvnd}/lib/libEGL.so.1";
    __EGL_VENDOR_LIBRARY_FILENAMES = "${mesa}/share/glvnd/egl_vendor.d/50_mesa.json";
    GALLIUM_DRIVER = "llvmpipe";
    LP_NUM_THREADS = "4";
    MESA_SHADER_CACHE_DISABLE = "true";
  }
  ''
    cp ${../scripts/generate-liquid.py} generate-liquid.py
    cp ${../scripts/liquid.frag} liquid.frag
    mkdir -p "$out"
    python generate-liquid.py --software --output "$out/liquid.mp4" ${
      lib.escapeShellArgs [
        "--colors"
        (lib.concatStringsSep "," colors)
        "--width"
        (toString width)
        "--height"
        (toString height)
        "--fps"
        (toString fps)
        "--duration"
        (toString duration)
        "--speed"
        (toString speed)
        "--intensity"
        (toString intensity)
        "--grain"
        (toString grain)
        "--softness"
        (toString softness)
        "--seed"
        (toString seed)
      ]
    }
    ffmpeg -hide_banner -loglevel error -i "$out/liquid.mp4" \
      -frames:v 1 -update 1 "$out/poster.png"
  ''
