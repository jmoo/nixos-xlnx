{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }@inputs:
    let
      lib = import ./lib.nix inputs;
      inherit (lib)
        eachPackageSet
        eachSystem
        mapFlattenAttrsRec
        ;
    in
    {
      inherit lib;

      checks = eachSystem (
        system:
        nixpkgs.lib.mapAttrs' (name: value: {
          name = "build-${name}";
          inherit value;
        }) self.packages.${system}
      );

      devShells = eachPackageSet (pkgs: {
        default = pkgs.callPackage ./shell.nix { };
      });

      legacyPackages = eachSystem (
        system:
        import nixpkgs {
          inherit system;
          overlays = nixpkgs.lib.attrValues self.overlays;
          config.allowUnfree = true;
        }
      );

      nixosModules.default = _: {
        imports = [ ./sd-image.nix ];
        nixpkgs.overlays = nixpkgs.lib.attrValues self.overlays;
      };

      overlays.default = import ./overlay.nix inputs;

      packages = eachSystem (
        system:
        let
          mkNixosXlnxPackages =
            version:
            {
              # zynq-armvl7-cross =
              #   self.legacyPackages.${system}.pkgsCross.armv7l-hf-multiplatform.${version}.xilinx-platforms.zynq;
            }
            // (
              if system == "aarch64-linux" then
                {
                  zynqmp = self.legacyPackages.${system}.${version}.xilinx-platforms.zynqmp;
                }
              else
                {
                  zynqmp-aarch64-emu = self.legacyPackages.aarch64-linux.${version}.xilinx-platforms.zynqmp;
                  # zynqmp-aarch64-cross =
                  #   mkPlatformPackages
                  #     self.legacyPackages.${system}.pkgsCross.aarch64-multiplatform.${version}.xilinx-platforms.zynqmp;
                }
            );
        in
        nixpkgs.lib.filterAttrs
          (
            _: value:
            let
              check = builtins.tryEval (
                nixpkgs.lib.isDerivation value
                && nixpkgs.lib.hasAttr "meta" value
                && nixpkgs.lib.hasAttr "nixos-xlnx" value.meta
                && (!(nixpkgs.lib.hasAttr "broken" value.meta) || !value.meta.broken)
              );
            in
            check.success && check.value
          )
          (
            mapFlattenAttrsRec
              (path: value: {
                name = nixpkgs.lib.concatStringsSep "-" path;
                inherit value;
              })
              {
                nixos-xlnx-2024_1 = mkNixosXlnxPackages "nixos-xlnx-2024_1";
              }
          )
      );
    };
}
