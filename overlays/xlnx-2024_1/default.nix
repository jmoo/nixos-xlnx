final: prev:
let
  sources = import ./nix/sources.nix {
    pkgs = final;
  };
in
{
  xilinxVersion = "2024.1";
  xilinxKernelVersion = "6.6.10";
  xilinxSources = sources // {
    xf86-video-armsoc =
      (final.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        group = "xorg";
        owner = "driver";
        repo = "xf86-video-armsoc";
        rev = "1.4.1";
        hash = "sha256-iIfFa/hKKlhkQGHsw74WgJ/+kj7crWo+iQQuwaTK2Lg=";
      })
      // {
        patches = [
          (final.fetchpatch {
            url = "https://git.yoctoproject.org/meta-xilinx/plain/meta-xilinx-core/dynamic-layers/openembedded-layer/recipes-graphics/xorg-driver/xf86-video-armsoc/0001-armsoc_driver.c-Bypass-the-exa-layer-to-free-the-roo.patch?h=fd359f0cf8973aff3fa46cd43111e093fbad26a1";
            hash = "sha256-KYGjU41MV79O6nG+bNXO5OSRrD2mI/amJpG9iFvhNZ8=";
          })
          (final.fetchpatch {
            url = "https://git.yoctoproject.org/meta-xilinx/plain/meta-xilinx-core/dynamic-layers/openembedded-layer/recipes-graphics/xorg-driver/xf86-video-armsoc/0001-src-drmmode_xilinx-Add-the-dumb-gem-support-for-Xili.patch?h=fd359f0cf8973aff3fa46cd43111e093fbad26a1";
            hash = "sha256-ZbZivnv+rqHScl1YLS8ICW7bb1xMX1/DSJ2h+EI7yH4=";
          })
        ];
      };

    xilinx_axidma = sources.xilinx_axidma // {
      patches = final.fetchpatch {
        url = "https://github.com/andrewvoznytsa/xilinx_axidma/commit/a87240b08b61f5c8f8964318f73d249adcc6e9ce.patch";
        hash = "sha256-pNuIPj9s5R0P7x65+6+22dg9VZLBRegyJe94g6KmPU4=";
      };
    };

    mali-modules = sources.mali-modules // {
      patches =
        let
          fetchYoctoPatch =
            file: hash:
            final.fetchurl {
              url = "https://git.yoctoproject.org/meta-xilinx/plain/meta-xilinx-core/recipes-graphics/mali/kernel-module-mali/${file}.patch?h=ff9288d64f0b44b88c00ecb0862caa964d984fa9";
              inherit hash;
            };
        in
        [
          (fetchYoctoPatch "0001-Change-Makefile-to-be-compatible-with-Yocto" "sha256-oZY7437iXskpLwNUudpx7xded2k0DMBTHeeIPCXgKxw=")
          (fetchYoctoPatch "0002-staging-mali-r8p0-01rel0-Add-the-ZYNQ-ZYNQMP-platfor" "sha256-FMRNXNDf54/7mXVRojgfBSeMx6kiyA6ka/SiwjJul+I=")
          (fetchYoctoPatch "0003-staging-mali-r8p0-01rel0-Remove-unused-trace-macros" "sha256-gz41V0S9GtaVcSg9YctaGX6WzdNMBAB4LI3NFcFdY78=")
          (fetchYoctoPatch "0004-staging-mali-r8p0-01rel0-Don-t-include-mali_read_phy" "sha256-MJx+TdAnD4h5r1bj3v4UKTZr8boZ0+m17QPLS/DrUkU=")
          (fetchYoctoPatch "0005-linux-mali_kernel_linux.c-Handle-clock-when-probed-a" "sha256-D5z//VwkfQ10VHuLSxXDujWvnl/B6EN07s8AKZDqb18=")
          (fetchYoctoPatch "0006-arm.c-global-variable-dma_ops-is-removed-from-the-ke" "sha256-rlE8bfxWQMcS7hAjShvgx+CowDQCXHibZRH+meriH9o=")
          (fetchYoctoPatch "0010-common-mali_pm.c-Add-PM-runtime-barrier-after-removi" "sha256-oYDMJbcMOJQ1tT6IicF8mDHaFdlLQIp0nkQnPM3HjEw=")
          (fetchYoctoPatch "0011-linux-mali_kernel_linux.c-Enable-disable-clock-for-r" "sha256-5CyEMIajxOYtae086yvgjrdWGjIKk4Ezz0kd0BgaLU0=")
          (fetchYoctoPatch "0012-linux-mali_memory_os_alloc-Remove-__GFP_COLD" "sha256-+8lOrch+alzNGfLwrwfrZZK2YGNTPXvFpPNe+zgMk38=")
          (fetchYoctoPatch "0013-linux-mali_memory_secure-Add-header-file-dma-direct." "sha256-eMb1XHjZ2O62DMHKsC5Nfr8A3ul4BzuC5QPtyCF0Vbc=")
          (fetchYoctoPatch "0014-linux-mali_-timer-Get-rid-of-init_timer" "sha256-F798OUUhnL1mhuX4HZE10LdLRqz7ecI9AU/17Z/ng+4=")
          (fetchYoctoPatch "0015-fix-driver-failed-to-check-map-error" "sha256-Lt1NCC7nJfYChR90wi+V0BkMOPxOEphW4Ran0o+KhtQ=")
          (fetchYoctoPatch "0016-mali_memory_secure-Kernel-5.0-onwards-access_ok-API-" "sha256-CO5Bj19qg+Kzc4S27YeRW1EnBhKV/gGAHKeDEU7XCBY=")
          (fetchYoctoPatch "0017-Support-for-vm_insert_pfn-deprecated-from-kernel-4.2" "sha256-uDIBiO02vRLvfUThWl+sTvFEFoLHdsUh8ldfFS23T14=")
          (fetchYoctoPatch "0018-Change-return-type-to-vm_fault_t-for-fault-handler" "sha256-d/e3Id67wnQzXUy2QKh+VGtTMXOXPTv+ACnxa5Eh3F4=")
          (fetchYoctoPatch "0019-get_monotonic_boottime-ts-deprecated-from-kernel-4.2" "sha256-2vgtSN2AWBoGFbx8Jh0LjEO7DnnbwHQl4F+g1fuxo18=")
          (fetchYoctoPatch "0020-Fix-ioremap_nocache-deprecation-in-kernel-5.6" "sha256-WabhxBwGwDgVxu9u3+qh2J2Un+C4qJThxDFkC22rVE0=")
          (fetchYoctoPatch "0021-Use-updated-timekeeping-functions-in-kernel-5.6" "sha256-A9nTKBSZC2w+pithv+9orxMHuEQ5dr3CHEQhckz6CgQ=")
          (fetchYoctoPatch "0022-Set-HAVE_UNLOCKED_IOCTL-default-to-true" "sha256-GHfta8tXGkqX39QtQ+LkQXdL2OFiOQ5bbIp+Z0fUZgs=")
          (fetchYoctoPatch "0023-Use-PTR_ERR_OR_ZERO-instead-of-PTR_RET" "sha256-Fa3CjqahjhO+J2vxFgtFyWOiMKTIbbn3A46S9n3Nt2k=")
          (fetchYoctoPatch "0024-Use-community-device-tree-names" "sha256-ksnMAtvSOzW9D5u30jaBJR14gQUM+jp5t/VXE9vhOJM=")
          (fetchYoctoPatch "0025-Import-DMA_BUF-module-and-update-register_shrinker-f" "sha256-RDZ0AeyMEUNpDWQjYAkncXEsDTfVRS7MO4nF+wT7UN0=")
          (fetchYoctoPatch "0026-Fix-gpu-driver-probe-failure" "sha256-EGCxyFTdTBC8LbIM3Y+Byx4HdFkPxtjOxy6/xOP0gU0=")
          (fetchYoctoPatch "0027-Updated-clock-name-and-structure-to-match-LIMA-drive" "sha256-z6yHGkokFnTsi12FNWOky3xZGdJXpbZIrxz53ZBoTS0=")
          (fetchYoctoPatch "0028-Replace-vma-vm_flags-direct-modifications-with-modif" "sha256-BvYaYe1VSzNiY1RPVJWW0fbjK7kAJv3B/tFcxBg89CA=")
          (fetchYoctoPatch "0029-Fixed-buildpath-QA-warning" "sha256-O5cG2zXmExocea5yZL6ZoLL975uNWpBnBRLBB3zAKEk=")
        ];
    };
  };
}
