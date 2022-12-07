{ lib
, haskellPackages
, writeTextFile
, stdenv
, graphviz
}:
{ name ? "dependency-graph"
, packages ? [ ]
}:
with lib;
let
  # directDependenciesOf :: String -> [String]
  directDependenciesOf = pkg: builtins.map (p: builtins.toString (p.pname or p.name or p)) haskellPackages.${pkg}.getCabalDeps.libraryHaskellDepends;

  dotFile = writeTextFile {
    name = "${name}.dot";
    text =
      let
        packageNode = pkg: "\"${pkg}\" [style=solid];";
        dependencyEdge = pkgFrom: pkgTo: "\"${pkgFrom}\" -> \"${pkgTo}\";";
        packageDependencyEdges = pkg:
          let relevantDependencies = intersectLists (directDependenciesOf pkg) packages;
          in concatStringsSep "\n  " (builtins.map (dependencyEdge pkg) relevantDependencies);
      in
      ''
        strict digraph dependencies {
          ${concatStringsSep "\n  " (builtins.map packageNode packages)}
          ${concatStringsSep "\n  " (builtins.map packageDependencyEdges packages)}
        }
      '';
  };

in
stdenv.mkDerivation {
  inherit name;
  dontUnpack = true;
  buildCommand = ''
    mkdir -p $out
    ln -s ${dotFile} $out/${name}.dot
    ${graphviz}/bin/dot -Tpng ${dotFile} > $out/${name}.png
  '';
}
