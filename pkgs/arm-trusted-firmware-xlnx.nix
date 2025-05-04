{
  buildArmTrustedFirmware,
  unfreeIncludeHDCPBlob ? false,
  xilinxSources,
  lib,
  ...
}:

buildArmTrustedFirmware (
  lib.nixos-xlnx.withSource xilinxSources.arm-trusted-firmware {
    version = xilinxSources.arm-trusted-firmware.rev;
    src = xilinxSources.arm-trusted-firmware;
    extraMakeFlags = [ "bl31" ];
    platform = "zynqmp";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "build/zynqmp/release/bl31/bl31.elf" ];
    platformCanUseHDCPBlob = unfreeIncludeHDCPBlob;
  }
)
