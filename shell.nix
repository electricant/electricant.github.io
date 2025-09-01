{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    buildInputs = [
      pkgs.sbcl
      pkgs.gnumake

      pkgs.openssl
   ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath([pkgs.openssl])}:${pkgs.lib.makeLibraryPath([pkgs.sqlite])}
  '';
}
