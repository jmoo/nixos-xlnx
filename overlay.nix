inputs: final: prev:
let
  inherit (lib.nixos-xlnx) overrideSource sourcesForPlatform;

  lib = prev.lib.extend (
    _: _: {
      nixos-xlnx = (import ./lib.nix inputs);
    }
  );

  kernelPackages = overrides: kfinal: _: {
    xlnx-hdmi-modules = kfinal.callPackage ./pkgs/kernel-packages/hdmi-modules.nix overrides;
    xlnx-dp-modules = kfinal.callPackage ./pkgs/kernel-packages/dp-modules.nix overrides;
    # xlnx-vcu-modules = kfinal.callPackage ./pkgs/vcu-modules.nix overrides;
    # mali-module-xlnx = kfinal.callPackage ./pkgs/mali-module-xlnx.nix overrides;
    # xlnx-dma-proxy = kfinal.callPackage ./pkgs/dma-proxy.nix overrides;
    # bperez77-xilinx-axidma = kfinal.callPackage ./pkgs/xilinx-axidma.nix overrides;
    # jacobfeder-axisfifo = kfinal.callPackage ./pkgs/axisfifo.nix overrides;
  };

  buildNixosXlnx =
    (final.lib.makeScope final.newScope (nixos-xlnx: {
      xilinx-platforms = {
        zynq = final.lib.makeScope nixos-xlnx.newScope (zynq: {
          name = "zynq";

          bootgen = zynq.callPackage ./pkgs/xilinx-bootgen.nix { };

          kernel = zynq.callPackage ./pkgs/linux-xlnx {
            defconfig = "xilinx_zynq_defconfig";
            kernelPatches = [ ];
          };

          kernelPackages = (final.linuxKernel.packagesFor zynq.kernel).extend (
            kernelPackages (sourcesForPlatform zynq)
          );

          uboot = zynq.callPackage ./pkgs/u-boot.nix { platform = "zynq"; };

          fbsl =
            (final.pkgsCross.aarch64-embedded.callPackages ./pkgs/embeddedsw.nix (sourcesForPlatform zynq))
            .zynq-fsbl;
        });

        zynqmp = final.lib.makeScope nixos-xlnx.newScope (zynqmp: {
          name = "zynqmp";

          armTrustedFirmware = zynqmp.callPackage ./pkgs/arm-trusted-firmware-xlnx.nix { };

          bootgen = zynqmp.callPackage ./pkgs/xilinx-bootgen.nix { };

          kernel = zynqmp.callPackage ./pkgs/linux-xlnx {
            defconfig = "xilinx_defconfig";
            kernelPatches = [ ];
          };

          kernelPackages = (final.linuxKernel.packagesFor zynqmp.kernel).extend (
            kernelPackages (sourcesForPlatform zynqmp)
          );

          uboot = zynqmp.callPackage ./pkgs/u-boot.nix { platform = "zynqmp"; };

          fbsl =
            (final.pkgsCross.aarch64-embedded.callPackages ./pkgs/embeddedsw.nix (sourcesForPlatform zynqmp))
            .zynqmp-fsbl;

          pmufw =
            (final.pkgsCross.microblaze-embedded.callPackages ./pkgs/embeddedsw.nix (sourcesForPlatform zynqmp))
            .zynqmp-pmufw;

          vcu-firmware = zynqmp.callPackage ./pkgs/vcu-firmware.nix { };
        });
      };

      xorg = final.xorg // {
        xf86videoarmsoc = nixos-xlnx.callPackage ./pkgs/xf86-video-armsoc.nix { };
      };
    })).overrideScope;

in
{
  inherit buildNixosXlnx lib;

  nixos-xlnx = final.nixos-xlnx-2024_1;

  nixos-xlnx-2024_1 = buildNixosXlnx (
    _: _: {
      xilinxSources = import ./sources final;
      xilinxVersion = "2024.1";
      xilinxKernelVersion = "6.6.10";
    }
  );

  nixos-xlnx-2024_2 = buildNixosXlnx (
    _: _: {
      xilinxSources = import ./sources final;
      xilinxVersion = "2024.2";
      xilinxKernelVersion = "6.6.10";
    }
  );

  libmali-xlnx = prev.callPackages ./pkgs/libmali-xlnx.nix { };
  libomxil-xlnx = prev.callPackage ./pkgs/libomxil-xlnx.nix { };
  libvcu-xlnx = prev.callPackage ./pkgs/libvcu-xlnx.nix { };

  gst_all_1 = prev.gst_all_1 // {
    gst-omx-zynqultrascaleplus =
      (prev.callPackage ./pkgs/gst-omx.nix { omxTarget = "zynqultrascaleplus"; }).overrideAttrs
        (super: {
          mesonFlags = super.mesonFlags ++ [
            (prev.lib.mesonOption "header_path" "${final.libomxil-xlnx}/include/vcu-omx-il")
          ];
          postPatch =
            super.postPatch
            + ''
              substituteInPlace config/zynqultrascaleplus/gstomx.conf --replace "/usr" "${final.libomxil-xlnx}"
            '';
        });
  };

  python-lopper = prev.python3Packages.callPackage ./pkgs/lopper.nix { };
}
