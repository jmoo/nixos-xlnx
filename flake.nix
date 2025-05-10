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
        filterPackage
        ;

      inherit (nixpkgs.lib) mapAttrs mapAttrs';
    in
    {
      inherit lib;

      checks = (
        eachSystem (
          system:
          (mapAttrs' (name: value: {
            name = "build-${name}";
            inherit value;
          }) self.packages.${system})

          # // (nixpkgs.lib.optionalAttrs (system == "aarch64-linux") {
          #   build-test-kr260-2024_2-aarch64-native =
          #     self.nixosConfigurations.test-kr260-2024_2-aarch64-native.config.system.build.toplevel;
          # })

          # // (nixpkgs.lib.optionalAttrs (system != "aarch64-linux") {
          #   build-test-kr260-2024_2-aarch64-emu =
          #     self.nixosConfigurations.test-kr260-2024_2-aarch64-native.config.system.build.toplevel;
          # })
        )
      );

      devShells = eachPackageSet (pkgs: {
        default = pkgs.nixos-xlnx.callPackage ./shell.nix { };
      });

      legacyPackages = eachSystem (
        system:
        import nixpkgs {
          inherit system;
          overlays = nixpkgs.lib.attrValues self.overlays;
          config.allowUnfree = true;
        }
      );

      nixosConfigurations = {
        test-kr260-2024_2-aarch64-native = nixpkgs.lib.nixosSystem {
          modules = [
            ./test/kr260-2024_2/nixos.nix
            {
              nixpkgs.overlays = [ self.overlays.default ];
            }
          ];
        };
      };

      nixosModules.default = _: {
        imports = [ ./sd-image.nix ];
        nixpkgs.overlays = nixpkgs.lib.attrValues self.overlays;
      };

      overlays.default = import ./overlays/top-level.nix inputs;

      packages = eachSystem (
        system:
        let
          mkPackages =
            version:
            let
              armv7l-cross-pkgs =
                with self.legacyPackages.${system}.pkgsCross.armv7l-hf-multiplatform.${version}; {
                  zynq-armvl7-cross = xilinx-platforms.zynq;
                };

              aarch64-native-pkgs = with self.legacyPackages.aarch64-linux.${version}; {
                inherit libmali-xlnx libomxil-xlnx libvcu-xlnx;
                zynqmp = xilinx-platforms.zynqmp;
              };
            in
            # Add armv7l-cross builds to every host system
            armv7l-cross-pkgs

            # Add native aarch64-linux builds to aarch64-linux hosts
            // (nixpkgs.lib.optionalAttrs (system == "aarch64-linux") aarch64-native-pkgs)

            # Add emulated aarch64 builds to all non-aarch64-linux host systems
            // (nixpkgs.lib.optionalAttrs (system != "aarch64-linux") (
              mapAttrs' (name: value: {
                name = "${name}-aarch64-emu";
                inherit value;
              }) aarch64-native-pkgs
            ));
        in
        (nixpkgs.lib.filterAttrs (_: filterPackage) (
          mapFlattenAttrsRec
            (path: value: {
              name = nixpkgs.lib.concatStringsSep "-" path;
              inherit value;
            })
            {
              nixos-xlnx-2024_1 = mkPackages "nixos-xlnx-2024_1";
            }
        ))
        // {
          lopper = self.legacyPackages.${system}.python3Packages.lopper;
        }
      );
    };
}
