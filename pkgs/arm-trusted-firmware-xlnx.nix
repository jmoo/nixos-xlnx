{
  buildArmTrustedFirmware,
  unfreeIncludeHDCPBlob ? false,
  lib,
  xilinxVersion,
  xilinxSources,
  ...
}:

buildArmTrustedFirmware (
  lib.nixos-xlnx.withSource xilinxSources.arm-trusted-firmware {
    extraMakeFlags = [ "bl31" ];
    platform = "zynqmp";
    extraMeta = {
      platforms = [ "aarch64-linux" ];
      nixos-xlnx = {
        inherit xilinxVersion;
      };
    };
    filesToInstall = [ "build/zynqmp/release/bl31/bl31.elf" ];
    platformCanUseHDCPBlob = unfreeIncludeHDCPBlob;
  }
)
