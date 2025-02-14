{ pkgs, ... }:
let
  catppuccin = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "unstable-2023-01-06";
    src = pkgs.fetchFromGitHub {
      owner = "omerxx";
      repo = "catppuccin-tmux";
      rev = "main";
      sha256 = "sha256-Ig6+pB8us6YSMHwSRU3sLr9sK+L7kbx2kgxzgmpR920=";
    };
  };
  tokyo-night = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tokyo-night";
    version = "unstable-2023-01-06";
    src = pkgs.fetchFromGitHub {
      owner = "janoamaral";
      repo = "tokyo-night-tmux";
      rev = "master";
      sha256 = "sha256-3rMYYzzSS2jaAMLjcQoKreE0oo4VWF9dZgDtABCUOtY=";
    };
  };
in
{
  enable = true;
  baseIndex = 1;
  keyMode = "vi";
  terminal = "screen-256color";

  plugins = with pkgs.tmuxPlugins; [
    catppuccin
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

    set -g @catppuccin_window_left_separator ""
    set -g @catppuccin_window_right_separator " "
    set -g @catppuccin_window_middle_separator " █"
    set -g @catppuccin_window_number_position "right"
    set -g @catppuccin_window_default_fill "number"
    set -g @catppuccin_window_default_text "#W"
    set -g @catppuccin_window_current_fill "number"
    set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag,(),}"
    set -g @catppuccin_status_modules_right "directory date_time"
    set -g @catppuccin_status_modules_left "session"
    set -g @catppuccin_status_left_separator  " "
    set -g @catppuccin_status_right_separator " "
    set -g @catppuccin_status_right_separator_inverse "no"
    set -g @catppuccin_status_fill "icon"
    set -g @catppuccin_status_connect_separator "no"
    set -g @catppuccin_directory_text "#{b:pane_current_path}"
    set -g status-position top 
    set -g @catppuccin_date_time_text "%H:%M"

    run-shell ${catppuccin}/share/tmux-plugins/catppuccin/catppuccin.tmux

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
    set -g default-shell "${pkgs.nushell}/bin/nu"

    set -g default-terminal "alacritty"
    set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    set -as terminal-overrides ',alacritty:RGB'
  '';
}
