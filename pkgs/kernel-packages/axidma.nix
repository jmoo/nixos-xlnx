{
  lib,
  stdenv,
  kernel,
  xilinxSources,
  xilinxVersion,
  which,
  doxygen,
  ...
}:

stdenv.mkDerivation (
  finalAttrs:
  (lib.nixos-xlnx.withSource xilinxSources.xilinx_axidma {

    outputs = [
      "out"
      "bin"
      "dev"
      "devdoc"
      "drivers"
    ];

    nativeBuildInputs = kernel.moduleBuildDependencies ++ [
      which
      doxygen
    ];
    makeFlags = kernel.makeFlags ++ [
      "KBUILD_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    ];

    NIX_CFLAGS_COMPILE = "-Wno-error";

    postBuild = ''
      doxygen libaxidma.dox
    '';

    installPhase = ''
      runHook preInstall
      install -Dm555 outputs/libaxidma.so -t $out/lib/
      install -Dm555 outputs/axidma_benchmark -t $bin/bin/
      install -Dm555 outputs/axidma_display_image -t $bin/bin/
      install -Dm555 outputs/axidma_transfer -t $bin/bin/
      install -Dm444 include/axidma_ioctl.h -t $dev/include/
      install -Dm444 include/libaxidma.h -t $dev/include/
      install -Dm444 outputs/axidma.ko -t $drivers/lib/modules/${kernel.modDirVersion}/extra/
      runHook postInstall
    '';

    postFixup = ''
      # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
      mkdir -p $devdoc/share/doc/
      cp -r docs/html $devdoc/share/doc/xilinx_axidma
    '';

    meta = with lib; {
      description = "Zero-copy Linux driver and userspace interface library for Xilinx's AXI DMA and VDMA IP blocks";
      homepage = "https://github.com/bperez77/xilinx_axidma";
      license = with licenses; [
        gpl2Only
        mit
      ];
      platforms = platforms.linux;
      maintainer = with maintainers; [ chuangzhu ];
      broken = false;
      nixos-xlnx = {
        inherit xilinxVersion;
      };
    };
  })
)
