inputs: final: prev:
let
  inherit (lib.nixos-xlnx) overrideSource;

  lib = prev.lib.extend (
    _: _: {
      nixos-xlnx = (import ./lib.nix inputs);
    }
  );

  kernelPackages = kfinal: _: {
    xilinx-hdmi-modules = kfinal.callPackage ./pkgs/hdmi-modules.nix { };
    xlnx-dp-modules = kfinal.callPackage ./pkgs/dp-modules.nix { };
    xlnx-vcu-modules = kfinal.callPackage ./pkgs/vcu-modules.nix { };
    mali-module-xlnx = kfinal.callPackage ./pkgs/mali-module-xlnx.nix { };
    xlnx-dma-proxy = kfinal.callPackage ./pkgs/dma-proxy.nix { };
    bperez77-xilinx-axidma = kfinal.callPackage ./pkgs/xilinx-axidma.nix { };
    jacobfeder-axisfifo = kfinal.callPackage ./pkgs/axisfifo.nix { };
  };

  buildNixosXlnx =
    (final.lib.makeScope final.newScope (nixos-xlnx: {
      xilinx-bootgen = overrideSource nixos-xlnx.xilinxSources.bootgen final.xilinx-bootgen;

      xilinx-platforms = {
        zynq = final.lib.makeScope nixos-xlnx.newScope (zynq: {
          name = "zynq";

          bootgen = nixos-xlnx.xilinx-bootgen;

          kernel = zynq.callPackage ./pkgs/linux-xlnx {
            defconfig = "xilinx_zynq_defconfig";
            kernelPatches = [ ];
          };

          kernelPackages = (final.linuxKernel.packagesFor zynq.kernel).extend kernelPackages;

          uboot = zynq.callPackage ./pkgs/u-boot.nix { platform = "zynq"; };

          fbsl =
            (final.pkgsCross.aarch64-embedded.callPackages ./pkgs/embeddedsw.nix {
              xilinxSources = nixos-xlnx.xilinxSources;
            }).zynq-fsbl;
        });

        zynqmp = final.lib.makeScope nixos-xlnx.newScope (zynqmp: {
          name = "zynqmp";

          armTrustedFirmware = zynqmp.callPackage ./pkgs/arm-trusted-firmware-xlnx.nix { };

          bootgen = nixos-xlnx.xilinx-bootgen;

          kernel = zynqmp.callPackage ./pkgs/linux-xlnx {
            defconfig = "xilinx_defconfig";
            kernelPatches = [ ];
          };

          kernelPackages = (final.linuxKernel.packagesFor zynqmp.kernel).extend kernelPackages;

          uboot = zynqmp.callPackage ./pkgs/u-boot.nix { platform = "zynqmp"; };

          fbsl =
            (final.pkgsCross.aarch64-embedded.callPackages ./pkgs/embeddedsw.nix {
              xilinxSources = nixos-xlnx.xilinxSources;
            }).zynqmp-fsbl;

          pmufw =
            (final.pkgsCross.microblaze-embedded.callPackages ./pkgs/embeddedsw.nix {
              xilinxSources = nixos-xlnx.xilinxSources;
            }).zynqmp-pmufw;
        });
      };

      xilinx-vcu-firmware = nixos-xlnx.callPackage ./pkgs/vcu-firmware.nix { };

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
