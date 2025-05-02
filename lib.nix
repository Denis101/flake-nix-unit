{pkgs, ...}: {
  mkTestDerivation = {
    self,
    src,
  }:
    pkgs.stdenvNoCC.mkDerivation {
      name = "test";
      src = src;
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
}
