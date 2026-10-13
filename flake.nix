{
  description = "s0n1c's pinned ipadecrypt release package for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs, ... }: let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
      f (import nixpkgs { inherit system; }));
  in {
    packages = forAllSystems (pkgs: rec {
      default = ipadecrypt;
      ipadecrypt = pkgs.callPackage ./package.nix { };
    });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShellNoCC {
        packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.ipadecrypt ];
      };
    });

    checks = forAllSystems (pkgs: {
      inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) ipadecrypt;
    });
  };
}
