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
    };
    nix-fmt = {
      type = "github";
      owner = "Denis101";
      repo = "flake-nix-fmt";
      ref = "0.0.6";
      inputs.flake-schemas.follows = "flake-schemas";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    nix-fmt,
    flake-schemas,
    flake-utils,
    ...
  }:
    {
      schemas = flake-schemas.schemas;
      formatter = nix-fmt.formatter;
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
        # test = pkgs.stdenvNoCC.mkDerivation {
        #   name = "test";
        #   src = ./.;
        #   dontBuild = true;
        #   doCheck = true;
        #   nativeBuildInputs = with pkgs; [nix-unit];
        #   checkPhase = ''
        #     nix-unit --extra-experimental-features flakes --flake ${self}#tests
        #   '';
        #   installPhase = "mkdir \"$out\"";
        # };
      };

      devShells = {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [alejandra nix-unit];
        };

        githubActions = pkgs.mkShellNoCC {
          packages = with pkgs; [j2cli nix-unit];
        };
      };
    });
}
