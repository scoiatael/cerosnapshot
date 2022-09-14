{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell { buildInputs = [ vlang sqlite flyctl ]; }
