{ lib
, haskellPackages
, stdenv
, graphviz
, makeDependencyDot
}:
let
  x = haskellPackages;
in
# Make a rendered dependency graph with graphviz
{ name ? "dependency-graph"
, packages ? [ ]
, haskellPackages ? x
, format ? "png"
}:
with lib;
let
  dotFile = makeDependencyDot { inherit name packages haskellPackages; };
in
stdenv.mkDerivation {
  inherit name;
  dontUnpack = true;
  buildCommand = ''
    mkdir -p $out
    ${graphviz}/bin/dot -T${format} ${dotFile} > $out/${name}.${format}
  '';
}
