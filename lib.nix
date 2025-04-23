{nixpkgs}: {
  mkTestDerivation = {
    self,
    src,
  }:
    nixpkgs.stdenvNoCC.mkDerivation {
      name = "test";
      src = src;
      dontBuild = true;
      doCheck = true;
      nativeBuildInputs = with nixpkgs; [nix-unit];
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
}
