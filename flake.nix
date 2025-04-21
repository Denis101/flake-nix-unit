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
      ref = "0.0.2";
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

      tests = {
        testPass = {
          expr = 1;
          expected = 1;
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      test-check = pkgs.stdenvNoCC.mkDerivation {
        name = "test-check";
        src = ./.;
        dontBuild = true;
        doCheck = true;
        nativeBuildInputs = with pkgs; [nix-unit];
        checkPhase = ''
          export HOME="$(realpath .)"
          nix-unit --eval-store "$HOME" \
            --extra-experimental-features flakes \
            --flake ${self}#tests
        '';
        installPhase = ''
          mkdir "$out"
        '';
      };
    in {
      checks = {inherit test-check;};
    });
}
