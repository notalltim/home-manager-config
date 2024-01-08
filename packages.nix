{ pkgs, internalLib, isHome ? false }:

let
  nixTools = with pkgs; [
    cachix
    lorri
    # nixseparatedebuginfod
    # nix-heuristic-gc
    # iragenix
  ];
  developerTools = with pkgs; [
    (gdb.overrideAttrs (old: rec {
      version = "14.1";
      src = pkgs.fetchurl {
        url = "mirror://gnu/gdb/gdb-${version}.tar.xz";
        hash = "sha256-1m31EnYUNFH8v/RkzIcj1o8enfRaai1WNaVOcWQ+24A=";
      };
    }))
    python3
    git
    clang-tools
    valgrind
    pkg-config
    gnumake
    cmake
    cmake-language-server
    # gersemi
    #rust
    # nix
    nil
    alejandra
    nixpkgs-fmt
    nixfmt
    rnix-lsp
    # rust
    rustc
    rustfmt
    cargo
    cargo-info
    cargo-audit
    cargo-license
    cargo-feature
    cargo-tarpaulin
    rust-analyzer
    bacon
    clippy

    # markdown
    marksman

    # lua
    lua-language-server

    direnv

    # Tools
    # wireshark needs a capability set on the dump cap file 

    nixgl.nixVulkanIntel
    nixgl.nixGLIntel
    # nixgl.auto.nixVulkanNvidia
    # nixgl.auto.nixGLNvidia
    # nixgl.auto.nixGLNvidiaBumblebee
    # kitty
    tbb
  ];

  unixTools = with pkgs; [ gnupg wget ];

  guiTools = with pkgs; [ solaar spotify inkscape gimp vlc ];

  homeTools = with pkgs; [
    (internalLib.writeIntelGLWrapper kicad)
    (internalLib.writeIntelGLWrapper freecad)
    discord
    radeontop
    bitwarden
    # musescore
    audacity
  ];
  workTools = with pkgs; [ gnome.dconf-editor ];
in nixTools ++ developerTools ++ unixTools ++ guiTools
++ (if isHome then homeTools else workTools)
