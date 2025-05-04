{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }@inputs:
    let
      inherit (import ./lib.nix inputs)
        eachPackageSet
        eachSystem
        ;
    in
    {
      devShells = eachPackageSet (pkgs: {
        default = pkgs.callPackage ./shell.nix { };
      });

      legacyPackages = eachSystem (
        system:
        import nixpkgs {
          inherit system;
          overlays = nixpkgs.lib.attrValues self.overlays;
        }
      );

      overlays.default = import ./overlay.nix inputs;

      nixosModules.default = _: {
        imports = [ ./sd-image.nix ];
        nixpkgs.overlays = nixpkgs.lib.attrValues self.overlays;
      };
    };
}
