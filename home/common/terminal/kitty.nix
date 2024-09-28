{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.strings) concatMapStringsSep;
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkIf mkDefault;
  inherit (pkgs.lib) gpuWrapCheck;
  font_features =
    types:
    concatMapStringsSep "\n" (
      type: "font_features CaskaydiaCoveNF-" + type + " +ss02 +ss20 +ss19"
    ) types;
  cfg = config.programs.kitty;
  baseline = config.baseline.kitty;
  terminal = config.baseline.terminal;
in
{
  options = {
    baseline.kitty = {
      enableKeybind = mkEnableOption "Enable opening the termninal via ctrl+alt+t (uses dconf)";
    };
  };
  config = mkIf terminal.enable {
    assertions = [
      {
        assertion = builtins.hasAttr "gpu" config.baseline;
        message = "Kitty requires the `baseline.gpu` module to be imported";
      }
      #FIXME: This assert is broken for nixos
      # {
      #   assertion = config.baselrne.gpu.enable or true;
      #   message = "Kitty requires the `baseline.gpu` module to be enabled";
      # }
    ];
    programs.kitty = {
      enable = mkDefault true;
      shellIntegration.enableFishIntegration = mkDefault true;
      font = {
        name = "CaskaydiaCove Nerd Font";
        # Only pull in the CaskaydiaCove nerd font + Fall back REVISIT: Why need fall back?
        package = pkgs.nerdfonts.override {
          fonts = [
            "CascadiaCode"
            "Iosevka"
          ];
        };
      };
      settings = {
        enable_audio_bell = false;
        disable_ligatures = "cursor";
      };
      # Support kitty on non nixos system
      package = gpuWrapCheck pkgs.kitty;

      themeFile = "Nightfox";
      extraConfig = font_features [
        "Regular"
        "Bold"
        "BoldItalic"
        "ExtraLight"
        "ExtraLightItalic"
        "Italic"
        "Light"
        "LightItalic"
        "SemiBold"
        "SemiBoldItalic"
        "SemiLight"
        "SemiLightItalic"
      ];
    };

    programs.fish.interactiveShellInit = ''
      set -e LD_LIBRARY_PATH VK_LAYER_PATH VK_ICD_FILENAMES LIBGL_DRIVERS_PATH  LIBVA_DRIVERS_PATH __EGL_VENDOR_LIBRARY_FILENAMES
    '';
    # This is needed for kitty to find the font
    fonts.fontconfig.enable = true;

    xdg.desktopEntries.kitty = {
      name = "Kitty";
      type = "Application";
      genericName = "Terminal emulator";
      comment = "Fast, feature-rich, GPU based terminal";
      exec = "${cfg.package}/bin/kitty";
      icon = "${cfg.package}/share/icons/hicolor/256x256/apps/kitty.png";
      categories = [
        "System"
        "TerminalEmulator"
      ];
    };

    xdg.desktopEntries.kitty-open = {
      name = "Kitty URL Launcher";
      type = "Application";
      genericName = "Terminal emulator";
      comment = "Open URLs with kitty";
      exec = "${cfg.package}/bin/kitty +open %U";
      icon = "${cfg.package}/share/icons/hicolor/256x256/apps/kitty.png";
      categories = [
        "System"
        "TerminalEmulator"
      ];
      noDisplay = true;
      mimeType = [
        "image/*"
        "application/x-sh"
        "application/x-shellscript"
        "inode/directory"
        "text/*"
        "x-scheme-handler/kitty"
      ];
    };

    home.activation = {
      linkDesktopApplications = {
        after = [
          "writeBoundary"
          "createXdgUserDirectories"
        ];
        before = [ ];
        data = ''
          # rm -rf ${config.xdg.dataHome}/"applications/home-manager"
          # mkdir -p ${config.xdg.dataHome}/"applications/home-manager"
          # cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/kitty* ${config.xdg.dataHome}/"applications/home-manager/"
        '';
      };
    };
    # Launch kitty with key command
    dconf.settings = mkIf baseline.enableKeybind {
      "org/gnome/desktop/applications/terminal" = {
        exec = "${cfg.package}/bin/kitty";
        exec-arg = "";
      };
    };
  };
}
