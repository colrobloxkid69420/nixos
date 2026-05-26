{
  description = "NixOS flake";

  inputs = {
    nixpkgs.url             = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url    = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url         = "github:hercules-ci/flake-parts";
    import-tree.url         = "github:vic/import-tree";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    preservation.url = "github:nix-community/preservation";

    mcp-logic-src = {
      url   = "github:angrysky56/mcp-logic";
      flake = false;
    };
    mcp-proxy-src = {
      url   = "github:sparfenyuk/mcp-proxy";
      flake = false;
    };
    mcpo-src = {
      url   = "github:open-webui/mcpo";
      flake = false;
    };

    viu = {
      url = "github:viu-media/viu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kwin-effects-forceblur = {
      url = "github:taj-ny/kwin-effects-forceblur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wivrn = {
      url = "github:WiVRn/WiVRn";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    llama-cpp = {
      url = "github:ggml-org/llama.cpp/67b2b7f2f2d6dac7962b219168a4c7a20c7359b7";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  # import-tree loads every .nix file under modules/ as a flake-parts module
  # and merges their outputs together.
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules);
}
