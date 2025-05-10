{
  xilinx-bootgen,
  xilinxSources,
  xilinxVersion,
  lib,
  ...
}:
(lib.nixos-xlnx.overrideSource xilinxSources.bootgen xilinx-bootgen).overrideAttrs (prev: {
  meta = prev.meta // {
    broken = false;
    nixos-xlnx = {
      inherit xilinxVersion;
    };
  };
})
