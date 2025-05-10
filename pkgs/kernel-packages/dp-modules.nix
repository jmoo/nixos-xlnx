{
  lib,
  stdenv,
  kernel,
  xilinxSources,
  xilinxVersion,
}:

stdenv.mkDerivation (
  finalAttrs:
  (lib.nixos-xlnx.withSource xilinxSources.dp-modules {
    name = "xlnx-dp-modules-${kernel.version}-${finalAttrs.version}";
    version = xilinxVersion;

    nativeBuildInputs = kernel.moduleBuildDependencies ++ [ ];

    makeFlags = kernel.makeFlags ++ [
      "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    ];

    installTargets = [ "modules_install" ];
    installFlags = [ "INSTALL_MOD_PATH=$(out)" ];

    enableParallelBuilding = true;

    meta = {
      description = "Out-of-tree Linux modules for Xilinx DisplayPort IP cores";
      homepage = "https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/665747573/Xilinx+DRM+KMS+DisplayPort+1.4+TX+Subsystem+Driver";
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
