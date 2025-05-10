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
  (lib.nixos-xlnx.withSource xilinxSources.mali-modules {
    name = "mali-modules-${kernel.version}-${finalAttrs.version}";
    # sourceRoot = "DX910-SW-99002-${finalAttrs.version}/driver/src/devicedrv/mali";

    nativeBuildInputs = kernel.moduleBuildDependencies ++ [ ];

    makeFlags = kernel.makeFlags ++ [
      "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    ];

    installTargets = [ "modules_install" ];
    installFlags = [ "INSTALL_MOD_PATH=$(out)" ];

    enableParallelBuilding = true;

    meta = {
      description = "Open Source Mali Utgard GPU Kernel Drivers";
      homepage = "https://developer.arm.com/downloads/-/mali-drivers/utgard-kernel";
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
