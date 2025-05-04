{ nixpkgs, self, ... }:
rec {
  eachSystem = nixpkgs.lib.genAttrs [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];

  eachPackageSet = f: nixpkgs.lib.mapAttrs (_: f) self.legacyPackages;

  overrideSource =
    src: drv: drv.overrideAttrs (prev: nixpkgs.lib.recursiveUpdate prev (withSource src { }));

  withSource =
    src: drv:
    {
      inherit src;
      version = src.rev;
    }
    // drv;

  types = {
    xilinxPlatform = (nixpkgs.lib.attrsOf nixpkgs.lib.unspecified) // {
      name = "xilinxPlatform";
      description = "Platform scope from `pkgs.nixos-xlnx.xilinx-platforms";
      check =
        x:
        (nixpkgs.lib.isAttrs x)
        && nixpkgs.lib.elem x [
          "zynq"
          "zynqmp"
        ];
    };
  };
}
