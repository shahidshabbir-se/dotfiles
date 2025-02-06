{ pkgs, lib, inputs, nixpkgs, config, ... }:

let
  system = import ./modules/packages/system.nix { inherit pkgs inputs; };
  dev = import ./modules/packages/dev.nix { inherit pkgs; };
  multimedia = import ./modules/packages/multimedia.nix { inherit pkgs; };
  hyprpanel = import ./modules/packages/hyprpanel.nix { inherit pkgs; };
  utilities = import ./modules/packages/utilities.nix { inherit pkgs; };

  userName = "shahid";
  homeDirectory = "/home/${userName}";
  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";
in
{
  home.username = userName;
  home.homeDirectory = homeDirectory;

  imports = [
    inputs.spicetify-nix.homeManagerModules.default
    # inputs.hyprpanel.homeManagerModules.hyprpanel
  ];

  home.pointerCursor = {
    x11.enable = true;
    gtk.enable = true;
    name = "catppuccin-mocha-dark-cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
    };
  };

  home.packages = system.systemPackages
    ++ dev.devPackages
    ++ multimedia.multimediaPackages
    ++ hyprpanel.hyprpanelPackages
    ++ utilities.utilityPackages;

  programs = {
    tmux = import ./modules/tmux.nix { inherit pkgs; };
    starship = import ./modules/starship.nix { inherit pkgs; };
    zsh = import ./modules/zsh.nix { inherit config pkgs lib; };
    git = import ./modules/git.nix { inherit config pkgs userGmail userGithub; };
    alacritty = import ./modules/alacritty.nix { inherit pkgs; };
    fzf = import ./modules/fzf.nix { inherit pkgs; };
    zoxide = import ./modules/zoxide.nix { inherit pkgs; };
    spicetify = import ./modules/spicetify.nix { inherit inputs pkgs; };
    atuin = {
      enable = true;
      enableZshIntegration = true;
    };
    home-manager.enable = true;
    # hyprpanel = import ./modules/hyprpanel.nix { inherit pkgs; };
  };

  home.file = {
    ".config/rofi".source = ./.config/rofi;
    # ".config/nvim".source = ./.config/nvim;
    ".local/share/fonts".source = ./fonts;
    # ".config/hypr".source = ./config/hypr;
    ".config/yazi".source = ./.config/yazi;
    ".config/ghostty".source = ./.config/ghostty;
    ".config/bat".source = ./.config/bat;
    ".config/hypr/hyprlock.conf".source = ./.config/hypr/hyprlock.conf;
    ".config/hypr/mocha.conf".source = ./.config/hypr/mocha.conf;
    ".config/hypr/theme.toml".source = ./.config/atac/theme.toml;
    ".config/hypr/key_bindings.toml".source = ./.config/atac/key_bindings.toml;
  };

  home.stateVersion = "24.11";
}


