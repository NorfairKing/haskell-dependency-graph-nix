{ lib
, haskellPackages
, writeTextFile
}:
let
  x = haskellPackages;
in

# Make a graphviz .dot file with a graph representing the interdependencies of given packages.

{ name ? "dependency-graph"
, packages ? [ ]
, haskellPackages ? x
}:
with lib;
let
  # directDependenciesOf :: String -> [String]
  directDependenciesOf = pkg: builtins.map (p: builtins.toString (p.pname or p.name or p)) haskellPackages.${pkg}.getCabalDeps.libraryHaskellDepends;

in
writeTextFile {
  name = "${name}.dot";
  text =
    let
      # packageNode :: String -> String
      packageNode = pkg: "\"${pkg}\" [style=solid];";
      # dependencyEdge :: String -> String -> String
      dependencyEdge = pkgFrom: pkgTo: "\"${pkgFrom}\" -> \"${pkgTo}\";";
      # packageDependencyEdges :: String -> String
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
}
