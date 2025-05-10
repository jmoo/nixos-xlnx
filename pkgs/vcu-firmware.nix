{
  lib,
  stdenvNoCC,
  xilinxSources,
  ...
}:

stdenvNoCC.mkDerivation (
  lib.nixos-xlnx.withSource xilinxSources.vcu-firmware {
    pname = "vcu-firmware";

    installPhase = ''
      runHook preInstall
      install -D -m644 1.0.0/lib/firmware/al5d.fw -t $out/lib/firmware/
      install -D -m644 1.0.0/lib/firmware/al5d_b.fw -t $out/lib/firmware/
      install -D -m644 1.0.0/lib/firmware/al5e.fw -t $out/lib/firmware/
      install -D -m644 1.0.0/lib/firmware/al5e_b.fw -t $out/lib/firmware/
      runHook postInstall
    '';

    dontFixup = true;

    meta = with lib; {
      description = "Firmware for Xilinx Zynq UltraScale+ Video Codec Unit (VCU)";
      homepage = "https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842546/Xilinx+Zynq+UltraScale+MPSoC+Video+Codec+Unit";
      license = licenses.unfreeRedistributableFirmware;
      sourceProvenance = with sourceTypes; [ binaryFirmware ];
      maintainers = with maintainers; [ chuangzhu ];
      broken = false;
      nixos-xlnx = {
        inherit xilinxVersion;
      };
    };
  }
)
