{
  description = "Fork Awesome Icon Font";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };
  outputs
  = { nixpkgs, ... }: let
      inherit(nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in {
      packages = forAllSystems (
        system: let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit(pkgs) stdenv;
        in {
          default = import ./. { inherit lib pkgs stdenv system; };
        }
      );
    };
}
