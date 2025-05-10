{
  lib,
  stdenv,
  kernel,
  xilinxSources,
  xilinxVersion,
  ...
}:

stdenv.mkDerivation (
  finalAttrs:
  (lib.nixos-xlnx.withSource xilinxSources.vcu-modules {
    name = "xlnx-vcu-modules-${kernel.version}-${finalAttrs.version}";
    version = xilinxVersion;

    nativeBuildInputs = kernel.moduleBuildDependencies ++ [ ];

    makeFlags = kernel.makeFlags ++ [
      "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    ];

    installTargets = [ "modules_install" ];
    installFlags = [ "INSTALL_MOD_PATH=$(out)" ];

    enableParallelBuilding = true;

    meta = {
      description = "Out-of-tree Linux modules for Xilinx Zynq UltraScale+ Video Codec Unit (VCU)";
      homepage = "https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842546/Xilinx+Zynq+UltraScale+MPSoC+Video+Codec+Unit";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
      maintainers = with lib.maintainers; [ chuangzhu ];
      broken = false;
      nixos-xlnx = {
        inherit xilinxVersion;
      };
    };
  })
)
