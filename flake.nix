{
  description = "TUI for MSI GF63 msi-ec fan, shift and cooler boost control";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
      pname = "msi-tui";
      version = "0.1.0";
      src = builtins.filterSource (path: _: baseNameOf path != "target") ./.;
      cargoLock.lockFile = ./Cargo.lock;
      meta.mainProgram = "msi-tui";
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = [pkgs.cargo pkgs.rustc pkgs.gcc];
    };
  };
}
