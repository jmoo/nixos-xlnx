{
  buildUBoot,
  xilinxSources,
  platform ? "zynqmp",
  xilinxVersion,
  system,
  lib,
}:
buildUBoot {
  version = xilinxSources.u-boot-xlnx.rev;
  src = xilinxSources.u-boot-xlnx;

  defconfig = "xilinx_${platform}_virt_defconfig";
  extraMeta = rec {
    platforms = if platform == "zynq" then [ "armv7l-linux" ] else [ "aarch64-linux" ];
    broken = !(lib.elem system platforms);
    nixos-xlnx = {
      inherit xilinxVersion;
    };
  };

  filesToInstall = [ "u-boot.elf" ];
}
