# Haskell Dependency Graph Nix

Produce a dependency graph of Haskell Packages from Nix

## Quick Start

Add this repository as a flake:

``` nix
{
  inputs = {
    haskell-dependency-graph-nix.url = "github:NorfairKing/haskell-dependency-graph-nix";
  };
}
```

Produce a dependency graph:
``` nix
{
  outputs = { self, haskell-dependency-graph-nix }: {
    checks.x86-64_linux.dependency-graph = haskell-dependency-graph-nix.lib.x86-64_linux.makeDependencyGraph {
      packages = [
        "foobar"
        "foobar-gen"
      ];
    };
  };
}
```

## API Reference

### `makeDependencyDot`

Make a Graphviz .dot file with a graph representing the interdependencies of given packages.

```
makeDependencyDot {
  name = "foobar-graph";
  packages = [
    "foobar"
    "foobar-gen"
  ];
};
```

See `./nix/makeDependencyDot`.

### `makeDependencyGraph`

Make a rendered dependency graph using Graphviz.

Example:

```
makeDependencyGraph {
  name = "foobar-graph";
  packages = [
    "foobar"
    "foobar-gen"
  ];
};
```

See `./nix/makeDependencyGraph`.
