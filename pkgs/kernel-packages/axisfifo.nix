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
  (lib.nixos-xlnx.withSource xilinxSources.axisfifo {

    # Linux-xlnx includes an older version of this
    postPatch = ''
      mv axis-fifo.c jacobfeder-axis-fifo.c
      substituteInPlace Makefile --replace axis-fifo.o jacobfeder-axis-fifo.o
    '';

    hardeningDisable = [ "pic" ];

    nativeBuildInputs = kernel.moduleBuildDependencies;

    makeFlags = kernel.makeFlags ++ [
      "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    ];

    installTargets = [ "modules_install" ];
    installFlags = [ "INSTALL_MOD_PATH=$(out)" ];

    enableParallelBuilding = true;

    meta = with lib; {
      description = "Zynq SoC Linux kernel driver for Xilinx AXI-Stream FIFO IP";
      homepage = "https://support.xilinx.com/s/question/0D52E00006hpglYSAQ/axistream-fifo-linux-driver";
      license = with licenses; [
        gpl2Only
        gpl3Only
      ];
      platforms = platforms.linux;
      maintainer = with maintainers; [ chuangzhu ];
      broken = false;
      nixos-xlnx = {
        inherit xilinxVersion;
      };
    };

    passthru.bin = stdenv.mkDerivation {
      pname = "axisfifo-apps";
      inherit (finalAttrs) version src meta;
      sourceRoot = "source/apps";
      preInstall = "mkdir -p $out/bin";
      installFlags = [ "PREFIX=$(out)" ];
    };
  })
)
