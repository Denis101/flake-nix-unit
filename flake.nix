{
  description = "Nix unit test checks";

  inputs = {
    flake-schemas = {
      type = "github";
      owner = "DeterminateSystems";
      repo = "flake-schemas";
      ref = "refs/tags/v0.1.5";
    };
    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "refs/tags/v1.0.0";
    };
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "24.11";
    };
    nix-unit = {
      type = "github";
      owner = "nix-community";
      repo = "nix-unit";
      ref = "v2.23.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-fmt = {
      type = "github";
      owner = "Denis101";
      repo = "flake-nix-fmt";
      ref = "0.0.2";
      inputs.flake-schemas.follows = "flake-schemas";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-unit,
    nix-fmt,
    flake-schemas,
    flake-utils,
    ...
  } @ inputs:
   {
    schemas = flake-schemas.schemas;
    formatter = nix-fmt.formatter;
  }
  // flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {inherit system;};
    test-check = pkgs.stdenvNoCC.mkDerivation {
      name = "test-check";
      src = ./.;
      dontBuild = true;
      doCheck = true;
      nativeBuildInputs = [ nix-unit.packages.${system}.default ];
      checkPhase = ''
        export HOME="$(realpath .)"
        # The nix derivation must be able to find all used inputs in the nix-store because it cannot download it during buildTime.
        nix-unit --eval-store "$HOME" \
          --extra-experimental-features flakes \
          --override-input nixpkgs ${pkgs} \
          --flake ${self}#tests
        touch $out
      '';
      installPhase = ''
        mkdir "$out"
      '';
    };
  in {
    checks = {inherit test-check;};
  });
}
