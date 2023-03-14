{ lib, pkgs, stdenv, system, ... }:

let
  gems = pkgs.bundlerEnv {
    name = "fork-awesome-gems";
    inherit(pkgs) ruby;
    gemdir  = ./.;
  };
in stdenv.mkDerivation {
  pname = "fork-awesome";
  version = "1.5";
  src = ./.;

  buildInputs = with pkgs; [
    fontforge
    fontforge-fonttools
    gems
    gnumake
    haskellPackages.sfnt2woff
    nodejs
    python3Packages.pyyaml
    ruby
    woff2
  ];

  installPhase = ''
    mkdir -p $out
    #cp -r $src $out

    # Config
    #bundle install
    #npm ci

    # Build
    make -C src/icons

    # Build Doc
    #npm run build # npm run dev
  '';

  meta = let
    inherit(lib) licenses platforms;
  in {
    description = "Fork Awesome Icon Font";
    homepage = "https://forkaweso.me/";
    license = licenses.ofl;
    maintainers = [];
    platforms = platforms.all;
  };
}
