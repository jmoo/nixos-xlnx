{
  buildUBoot,
  xilinxSources,
  platform ? "zynqmp",
}:

buildUBoot {
  version = xilinxSources.u-boot-xlnx.rev;
  src = xilinxSources.u-boot-xlnx;

  defconfig = "xilinx_${platform}_virt_defconfig";
  extraMeta.platforms = if platform == "zynq" then [ "armv7l-linux" ] else [ "aarch64-linux" ];

  filesToInstall = [ "u-boot.elf" ];
}
