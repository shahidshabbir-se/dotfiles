{ pkgs, ... }:
let
  tokyo-night = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tokyo-night";
    version = "unstable-2023-01-06";
    src = pkgs.fetchFromGitHub {
      owner = "janoamaral";
      repo = "tokyo-night-tmux";
      rev = "master";
      sha256 = "sha256-TOS9+eOEMInAgosB3D9KhahudW2i1ZEH+IXEc0RCpU0=";
    };
  };
in
{
  enable = true;
  baseIndex = 1;
  keyMode = "vi";
  terminal = "screen-256color";

  plugins = with pkgs.tmuxPlugins; [
    tokyo-night
    yank
    sensible
    vim-tmux-navigator
  ];

  extraConfig = ''
    set -as terminal-features ",xterm-256color:RGB"
    set -g mouse on

    unbind C-b
    set -g prefix C-n
    bind C-n send-prefix

    # Vim style pane selection
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    # Start windows and panes at 1, not 0
    set -g base-index 1
    set -g pane-base-index 1
    set-window-option -g pane-base-index 1
    set-option -g renumber-windows on

    # Bind clearing the screen
    bind L send-keys '^L'

    # Use Alt-arrow keys without prefix key to switch panes
    bind -n M-Left select-pane -L
    bind -n M-Right select-pane -R
    bind -n M-Up select-pane -U
    bind -n M-Down select-pane -D

    # Shift arrow to switch windows
    bind -n S-Left previous-window
    bind -n S-Right next-window

    # Shift Alt vim keys to switch windows
    bind -n M-H previous-window
    bind -n M-L next-window

    set -g @tokyo-night-tmux_window_id_style digital
    set -g @tokyo-night-tmux_pane_id_style hsquare
    set -g @tokyo-night-tmux_zoom_id_style dsquare

    set -g @tokyo-night-tmux_terminal_icon 
    set -g @tokyo-night-tmux_active_terminal_icon 
    set -g @tokyo-night-tmux_time_format 12H
    set -g @tokyo-night-tmux_show_netspeed 1
    set -g @tokyo-night-tmux_netspeed_iface "wlp1s0"
    set -g @tokyo-night-tmux_show_hostname 1
    set -g @tokyo-night-tmux_show_git 1

    set -g @tokyo-night-tmux_window_tidy_icons 0

    run-shell ${tokyo-night}/share/tmux-plugins/tokyo-night/tokyo-night.tmux

    # set vi-mode
    set-window-option -g mode-keys vi

    # keybindings
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
    bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

    bind '"' split-window -v -c "#{pane_current_path}"
    bind % split-window -h -c "#{pane_current_path}"
    bind c new-window -c "#{pane_current_path}"

    # Set the shell inside tmux itself
    set -g default-shell "${pkgs.zsh}/bin/zsh"

    
    set -g default-terminal "wezterm"
    set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    set -as terminal-overrides ',alacritty:RGB'
  '';
}
