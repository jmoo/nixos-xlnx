{
  mkShell,
  niv,
  writeShellScriptBin,
  runtimeShell,
  lib,
  gst_all_1,
  ...
}:
let
  nivWrapped = writeShellScriptBin "niv" ''
    #!${runtimeShell}
    (cd "$(git rev-parse --show-toplevel)/sources" && ${lib.getExe niv} "$@")
  '';
in
mkShell {
  packages = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-omx-zynqultrascaleplus
    nivWrapped
  ];
}
