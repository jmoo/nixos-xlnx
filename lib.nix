{ nixpkgs, self, ... }:
let
  inherit (nixpkgs.lib)
    hasAttr
    listToAttrs
    isDerivation
    concatLists
    genAttrs
    mapAttrs
    mapAttrsToList
    recursiveUpdate
    isAttrs
    elem
    optionalAttrs
    ;
in
rec {
  eachSystem = genAttrs [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];

  eachPackageSet = f: mapAttrs (_: f) self.legacyPackages;

  mapFlattenAttrsRec =
    f: attrs:
    let
      recurse =
        path: attrs:
        concatLists (
          mapAttrsToList (
            name: value:
            let
              check = builtins.tryEval (isAttrs value && !(isDerivation value));
            in
            if check.success && check.value then
              recurse (path ++ [ name ]) value
            else
              [
                (f (path ++ [ name ]) value)
              ]
          ) attrs
        );
    in
    listToAttrs (recurse [ ] attrs);

  overrideSource = src: drv: drv.overrideAttrs (prev: recursiveUpdate prev (withSource src { }));

  withSource =
    src: drv:
    let
      version =
        if hasAttr "version" src then
          src.version
        else if hasAttr "rev" src then
          src.rev
        else
          null;

      name = if hasAttr "repo" src then src.repo else null;
    in
    {
      inherit src;
      patches = if hasAttr "patches" src then src.patches else [ ];
    }
    // (optionalAttrs (name != null) { inherit name; })
    // (optionalAttrs (version != null) { inherit version; })
    // drv;

  sourcesForPlatform =
    platform:
    let
      sources = (
        platform.callPackage (
          { xilinxSources, xilinxVersion }:
          {
            inherit xilinxSources xilinxVersion;
          }
        ) { }
      );
    in
    {
      inherit (sources) xilinxSources xilinxVersion;
    };

  types = {
    xilinxPlatform = (nixpkgs.lib.types.attrsOf nixpkgs.lib.types.unspecified) // {
      name = "xilinxPlatform";
      description = "Platform scope from `pkgs.nixos-xlnx.xilinx-platforms";
      check =
        x:
        (isAttrs x)
        && elem x [
          "zynq"
          "zynqmp"
        ];
    };
  };
}
