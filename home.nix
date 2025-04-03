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
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "firefox";
    TERMINAL = "wezterm";
    PAGER = "bat";
  };

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
    git = import ./modules/git.nix { inherit config pkgs homeDirectory userGmail userGithub; };
    # alacritty = import ./modules/alacritty.nix { inherit pkgs; };
    fzf = import ./modules/fzf.nix { inherit pkgs; };
    zoxide = import ./modules/zoxide.nix { inherit pkgs; };
    spicetify = import ./modules/spicetify.nix { inherit inputs pkgs; };
    neovim = import ./modules/neovim.nix { inherit config pkgs; };
    eza = { enableZshIntegration = true; };
    password-store.enable = true;
    rofi.pass.enable = true;
    wezterm = {
      enable = true;
      package = pkgs.wezterm;
      extraConfig = builtins.readFile ./.config/wezterm.lua;
    };
    carapace = {
      enable = false;
    };
    atuin = {
      enable = true;
      enableZshIntegration = true;
    };
    # nushell = import ./modules/nushell.nix { inherit pkgs; };
    home-manager.enable = true;
    # hyprpanel = import ./modules/hyprpanel.nix { inherit pkgs; };
  };

  home.file = {
    ".config/rofi".source = ./.config/rofi;
    # ".config/nvim".source = ./.config/nvim;
    ".local/share/fonts".source = ./fonts;
    # ".config/hypr".source = ./config/hypr;
    ".config/yazi".source = ./.config/yazi;
    # ".config/ghostty".source = ./.config/ghostty;
    # ".wezterm.lua".source = ./.config/wezterm.lua;
    ".config/bat".source = ./.config/bat;
    ".config/hypr/hyprlock.conf".source = ./.config/hypr/hyprlock.conf;
    ".config/hypr/mocha.conf".source = ./.config/hypr/mocha.conf;
    ".config/git/themes.gitconfig".source = ./.config/themes.gitconfig;
    ".config/atac/theme.toml".source = ./.config/atac/theme.toml;
    ".config/atac/key_bindings.toml".source = ./.config/atac/key_bindings.toml;
  };

  # home.file = builtins.listToAttrs
  #   (map
  #     (name: {
  #       name = ".config/nushell/${name}";
  #       value.text = builtins.readFile ./modules/nushell/${name};
  #     }) [
  #     "adb-completions.nu"
  #     "poetry-completions.nu"
  #     "docker-completions.nu"
  #     "git-completions.nu"
  #     "nix-completions.nu"
  #     "npm-completions.nu"
  #     "pnpm-completions.nu"
  #     "rg-completions.nu"
  #     "winget-completions.nu"
  #   ]) // {
  #   ".config/rofi".source = ./.config/rofi;
  #   # ".config/nvim".source = ./.config/nvim;
  #   ".local/share/fonts".source = ./fonts;
  #   # ".config/hypr".source = ./config/hypr;
  #   ".config/yazi".source = ./.config/yazi;
  #   # ".config/ghostty".source = ./.config/ghostty;
  #   # ".wezterm.lua".source = ./.config/wezterm.lua;
  #   "./modules/nushell/pass".source = ./.config/nushell/pass;
  #   ".config/bat".source = ./.config/bat;
  #   ".config/hypr/hyprlock.conf".source = ./.config/hypr/hyprlock.conf;
  #   ".config/hypr/mocha.conf".source = ./.config/hypr/mocha.conf;
  #   ".config/git/themes.gitconfig".source = ./.config/themes.gitconfig;
  #   ".config/atac/theme.toml".source = ./.config/atac/theme.toml;
  #   ".config/atac/key_bindings.toml".source = ./.config/atac/key_bindings.toml;
  # };


  home.stateVersion = "24.11";
}


