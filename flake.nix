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
    nix-fmt = {
      type = "github";
      owner = "Denis101";
      repo = "flake-nix-fmt";
      ref = "0.0.3";
      inputs.flake-schemas.follows = "flake-schemas";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-fmt,
    flake-schemas,
    flake-utils,
    ...
  } @ inputs:
    {
      schemas = flake-schemas.schemas;
      formatter = nix-fmt.formatter;
      lib = import ./lib.nix inputs;

      tests = {
        testPass = {
          expr = 1;
          expected = 1;
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      checks = {
        fmt = nix-fmt.checks.${system}.fmt;
        test = self.lib.mkTestDerivation {
          self = self;
          src = ./.;
        };
      };
      devShells.default = pkgs.mkShellNoCC {
        packages = with pkgs; [alejandra nix-unit];
      };
    });
}
