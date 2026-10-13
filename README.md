# ipadecrypt-nix

Pinned [ipadecrypt](https://github.com/londek/ipadecrypt) prebuilt release
for Nix, in the same style as [bunix](https://github.com/S0n1cHoldings/bunix).
Exports `packages.<system>.ipadecrypt`, `packages.<system>.default`, and a default
dev shell for Linux and macOS on x86_64 and aarch64.

## Local use

```sh
nix build path:.
nix run path:. -- --version
nix develop path:.
```

After publishing to `S0n1cHoldings/ipadecrypt-nix`:

```sh
nix shell github:S0n1cHoldings/ipadecrypt-nix
nix run github:S0n1cHoldings/ipadecrypt-nix -- --help
nix profile install github:S0n1cHoldings/ipadecrypt-nix
```

## Add to another project's dev shell

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    ipadecrypt.url = "github:S0n1cHoldings/ipadecrypt-nix";
    ipadecrypt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ipadecrypt, ... }: let
    system = "aarch64-darwin"; # Or x86_64-darwin, x86_64-linux, aarch64-linux.
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [ ipadecrypt.packages.${system}.default ];
    };
  };
}
```

## Package details

Pins upstream release `v0.8.0-rc.2` with SHA-256 hashes for each platform.
Uses GitHub release binaries; no Go build, Docker, or iOS SDK is required.
On Linux, `autoPatchelfHook` replaces the ELF interpreter and fixes library
paths. A wrapper supplies glibc and GCC runtime library paths for the Unicorn
library downloaded by the CLI. No system-wide `nix-ld` configuration is needed.

Nixpkgs 26.05 is pinned to retain support for Intel macOS as well as Linux and
Apple Silicon. If you make nixpkgs follow another input, use a compatible version
(Intel macOS is no longer supported by nixpkgs unstable).

Actual device operations require a network-accessible jailbroken iPhone with
OpenSSH, AppSync Unified, and appinst. Run `ipadecrypt bootstrap` for setup.
Upstream downloads Unicorn on first use, so that operation requires internet.

To update, change `version` and all four release hashes in `package.nix`.
Use `nix flake update` to update nixpkgs separately.
