{
  lib,
  stdenv,
  xilinxVersion,
  xilinxSources,
}:

stdenv.mkDerivation (
  finalAttrs:
  lib.nixos-xlnx.withSource xilinxSources.vcu-ctrl-sw {

    installTargets = [ "install_headers" ];
    installFlags =
      [
        "PREFIX=$(out)"
      ]
      ++ lib.optionals (lib.versionAtLeast finalAttrs.version "2023.2") [
        "INSTALL_PATH=$(out)/bin"
      ];

    postInstall =
      ''
        for f in $out/lib/*.so; do ln -s "$f" "$f".0; done
        install -Dm755 bin/liballegro_{en,de}code.so -t $out/lib/
      ''
      + lib.optionalString (lib.versionOlder finalAttrs.version "2023.2") ''
        install -Dm755 bin/ctrlsw_{en,de}coder -t $out/bin/
      '';

    meta = with lib; {
      description = "Xilinx Zynq UltraScale+ VCU control software";
      homepage = "https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842546/Xilinx+Zynq+UltraScale+MPSoC+Video+Codec+Unit";
      license = licenses.unfree; # Based on X11 license, but with two extra terms
      sourceProvenance = with sourceTypes; [ fromSource ];
      platforms = platforms.linux;
      maintainers = with maintainers; [ chuangzhu ];
      nixos-xlnx = {
        inherit xilinxVersion;
      };
    };
  }
)
