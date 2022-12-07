{
  description = "Haskell Dependency Graph Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-22.05";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, pre-commit-hooks }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    with pkgs.lib;
    {
      lib.${system} = {
        makeDependencyGraph = pkgs.callPackage ./nix/makeDependencyGraph.nix { };
      };
      checks.${system} = {
        yesod = self.lib.${system}.makeDependencyGraph {
          name = "yesod-dependency-graph";
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
        pre-commit = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
          };
        };
      };
      devShells.${system}.default = pkgs.mkShell {
        name = "haskell-dependency-graph-shell";
        buildInputs = (with pkgs; [
          graphviz
        ]) ++ (with pre-commit-hooks.packages.${system};
          [
            nixpkgs-fmt
          ]);
        shellHook = self.checks.${system}.pre-commit.shellHook;
      };
    };
}
