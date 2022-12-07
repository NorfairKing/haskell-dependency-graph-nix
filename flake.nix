{
  description = "Haskell dependency graph";

  outputs = { self, nixpkgs }:
    let system = "x86_64-linux";
    in
    {

      lib.${system} = {
        makeDependencyGraph =
          { name ? "dependency-graph"
          , packages ? [ ]
          }:
          let
            pkgs = import nixpkgs {
              inherit system;
            };
          in
          with pkgs.lib;
          let
            # directDependenciesOf :: String -> [String]
            directDependenciesOf = pkg: builtins.map (p: builtins.toString (p.pname or p.name or p)) pkgs.haskellPackages.${pkg}.getCabalDeps.libraryHaskellDepends;

            dotFile = pkgs.writeTextFile {
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
          pkgs.stdenv.mkDerivation {
            inherit name;
            dontUnpack = true;
            buildCommand = ''
              mkdir -p $out
              ln -s ${dotFile} $out/${name}.dot
              ${pkgs.graphviz}/bin/dot -Tpng ${dotFile} > $out/${name}.png
            '';
          };
      };
      checks.${system}.yesod = self.lib.${system}.makeDependencyGraph {
        packages = [
          "yesod"
          "yesod-auth"
          "yesod-auth-oauth" # Marked as broken
          "yesod-bin"
          "yesod-core"
          "yesod-eventsource"
          "yesod-form"
          "yesod-form-multi"
          "yesod-newsfeed"
          "yesod-persistent"
          "yesod-sitemap"
          "yesod-static"
          "yesod-test"
          "yesod-websockets"
        ];
      };
    };
}
