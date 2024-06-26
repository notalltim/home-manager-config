{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf;
  pretty-printers = pkgs.stdenvNoCC.mkDerivation {
    name = "gcc-python-pretty-printers";
    version = "13.2";
    src =
      (pkgs.fetchgit {
        url = "https://gcc.gnu.org/git/gcc.git";
        sparseCheckout = ["libstdc++-v3/python/"];
        hash = "sha256-P0+Ayfm/SotVap9/9d/fpcFozwLQCHwtoV4k2NRnifI=";
      })
      + "/libstdc++-v3/python";
    dontConfigure = true;
    dontBuild = true;
    dontPatch = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/python
      cp -r $src/* $out/python
      runHook postInstall
    '';
  };
  cfg = config.baseline.gdb;
in {
  options = {
    baseline.gdb = {
      enable = mkEnableOption "Enable GDB configuration";
    };
  };

  config = mkIf cfg.enable {
    home.file.".gdbinit".text = ''
      set debuginfod enabled on
      python
      import sys
      sys.path.insert(0, '${pretty-printers}/python')
      from libstdcxx.v6.printers import register_libstdcxx_printers
      register_libstdcxx_printers (None)
    '';
  };
}
