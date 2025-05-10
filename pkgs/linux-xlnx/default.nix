{
  lib,
  buildLinux,
  system,
  stdenv,
  defconfig ? "xilinx_defconfig",
  kernelPatches ? [ ],
  xilinxSources,
  xilinxKernelVersion,
  xilinxVersion,
  ...
}@args:
let
  fullVersion = "${xilinxKernelVersion}-xilinx-${xilinxVersion}";
in
buildLinux (
  args
  // (
    lib.nixos-xlnx.withSource xilinxSources.linux-xlnx {
      version = fullVersion;

      modDirVersion =
        if defconfig == "xilinx_zynq_defconfig" then
          "${xilinxKernelVersion}-xilinx"
        else
          xilinxKernelVersion;

      structuredExtraConfig =
        with lib.kernel;
        {
          DEBUG_INFO_BTF = lib.mkForce no;
          CRYPTO_DEV_XILINX_ECDSA = no; # Error: modpost: "ecdsasignature_decoder" undefined!
        }
        // lib.optionalAttrs (defconfig == "xilinx_zynq_defconfig") {
          DRM_XLNX_BRIDGE = yes; # DRM_XLNX uses xlnx_bridge_helper_init
          USB_XHCI_PLATFORM = no; # USB_XHCI_PLATFORM uses dwc3_host_wakeup_capable
          USB_XHCI_HCD = no;
          USB_DWC3 = no;
          USB_CDNS_SUPPORT = no;
        }
        // lib.optionalAttrs stdenv.is32bit {
          VIDEO_XILINX_HDMI21RXSS = no; # FIXME: div64
        };

      kernelPatches =
        [
          # ERROR: modpost: module tps544 uses symbol pmbus_do_probe from namespace PMBUS, but does not import it.
          {
            name = "fix-tps544-nsdeps";
            patch = ./fix-tps544-nsdeps.patch;
          }
        ]
        ++ lib.optionals (lib.versionAtLeast fullVersion "6.1.0-xilinx-v2023.2") [
          # ERROR: modpost: "xlnx_hdcp_tx_set_keys" [drivers/gpu/drm/xlnx/xlnx_hdmi.ko] undefined!
          # ERROR: modpost: module xlnx_mpg2tsmux uses symbol dma_buf_unmap_attachment from namespace DMA_BUF, but does not import it.
          {
            name = "fix-hdcp-modpost";
            patch = ./fix-hdcp-modpost.patch;
          }
        ]
        ++ lib.optionals (lib.versionOlder fullVersion "6.1.0-xilinx-v2023.2") [
          # error: implicit declaration of function 'FIELD_PREP'
          {
            name = "xilinx-hdcp1x-cipher";
            patch = ./xilinx-hdcp1x-cipher.patch;
          }
          # ] ++ lib.optionals stdenv.is32bit [
          #   # ERROR: modpost: "__aeabi_ldivmod" [drivers/clk/clk-xlnx-clock-wizard.ko] undefined!
          #   { name = "fix-various-xilinx-modules-div64"; patch = ./fix-various-xilinx-modules-div64.patch; }
        ]
        ++ kernelPatches;

      extraMeta = rec {
        platforms = [
          "aarch64-linux"
          "armv7l-linux"
        ];
        broken = !(lib.elem system platforms);
        nixos-xlnx = {
          inherit xilinxVersion;
        };
      };
    }
    // (args.argsOverride or { })
  )
)
