#  ████████╗███╗   ███╗██╗   ██╗██╗  ██╗
#  ╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝
#     ██║   ██╔████╔██║██║   ██║ ╚███╔╝ 
#     ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗ 
#     ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
#     ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
#  https://github.com/shahidshabbir-se/dotfiles

{ pkgs, ... }:

# ─────────────────────────────────────────────────────────────
#  Custom Plugin: tokyonight-tmux theme
# ─────────────────────────────────────────────────────────────
let
  tokyo-night = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tokyo-night";
    version = "unstable-2025-02-26";
    src = pkgs.fetchFromGitHub {
      owner = "janoamaral";
      repo = "tokyo-night-tmux";
      rev = "master";
      sha256 = "sha256-TOS9+eOEMInAgosB3D9KhahudW2i1ZEH+IXEc0RCpU0=";
    };
  };
in

# ─────────────────────────────────────────────────────────────
#  Main Tmux Configuration
# ─────────────────────────────────────────────────────────────
{
  enable = true;

  # General settings
  aggressiveResize = true;
  baseIndex = 1;
  disableConfirmationPrompt = true;
  keyMode = "vi";
  terminal = "xterm-kitty";
  newSession = true;
  secureSocket = true;
  shell = "${pkgs.zsh}/bin/zsh";

  # Plugins
  plugins = with pkgs.tmuxPlugins; [
    tokyo-night
    yank
    sensible
    vim-tmux-navigator
  ];

  # Raw tmux configuration
  extraConfig = ''
    # ─────────────────────────────────────────────────────────
    #  Terminal Features
    # ─────────────────────────────────────────────────────────
    set -as terminal-features ",xterm-256color:RGB"
    # set-option -sa terminal-overrides ",xterm*:Tc"

    set -g mouse on

    # ─────────────────────────────────────────────────────────
    #  Prefix Customization
    # ─────────────────────────────────────────────────────────
    unbind C-b
    set -g prefix C-n
    bind C-n send-prefix

    # ─────────────────────────────────────────────────────────
    #  Pane Navigation (Vim style)
    # ─────────────────────────────────────────────────────────
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    # ─────────────────────────────────────────────────────────
    #  Window and Pane Indexing
    # ─────────────────────────────────────────────────────────
    set -g base-index 1
    set -g pane-base-index 1
    set-window-option -g pane-base-index 1
    set-option -g renumber-windows on

    # ─────────────────────────────────────────────────────────
    #  Clear Screen Binding
    # ─────────────────────────────────────────────────────────
    bind L send-keys '^L'

    # ─────────────────────────────────────────────────────────
    #  Pane Switching (Alt + Arrow)
    # ─────────────────────────────────────────────────────────
    bind -n M-Left select-pane -L
    bind -n M-Right select-pane -R
    bind -n M-Up select-pane -U
    bind -n M-Down select-pane -D


    # ─────────────────────────────────────────────────────────
    #  Window Switching (Shift + Arrow or Alt + Vim)
    # ─────────────────────────────────────────────────────────
    bind -n S-Left previous-window
    bind -n S-Right next-window
    bind -n M-h previous-window
    bind -n M-l next-window

    # ─────────────────────────────────────────────────────────
    #  Theme Configuration (tokyo-night)
    # ─────────────────────────────────────────────────────────
    set -g @tokyo-night-tmux_window_id_style dsquare
    set -g @tokyo-night-tmux_show_datetime 0
    set -g @tokyo-night-tmux_show_path 0
    set -g @tokyo-night-tmux_path_format relative
    set -g @tokyo-night-tmux_show_git 1
    set -g @tokyo-night-tmux_terminal_icon 
    set -g @tokyo-night-tmux_active_terminal_icon 
    set -g @tokyo-night-tmux_show_hostname 1
    set -g @tokyo-night-tmux_show_music 1
    set -g @tokyo-night-tmux_window_tidy_icons 0
    set -g @tokyo-night-tmux_transparent 1

    # Load theme
    run-shell ${tokyo-night}/share/tmux-plugins/tokyo-night/tokyo-night.tmux

    # ─────────────────────────────────────────────────────────
    #  Vim-Tmux Navigator Integration
    # ─────────────────────────────────────────────────────────
    set -g @vim_navigator_mapping_left "C-Left C-h"
    set -g @vim_navigator_mapping_right "C-Right C-l"
    set -g @vim_navigator_mapping_up "C-k"
    set -g @vim_navigator_mapping_down "C-j"
    set -g @vim_navigator_mapping_prev ""

    # ─────────────────────────────────────────────────────────
    #  Copy Mode (vi style)
    # ─────────────────────────────────────────────────────────
    set-window-option -g mode-keys vi
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
    bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

    # ─────────────────────────────────────────────────────────
    #  Smart Directory Context
    # ─────────────────────────────────────────────────────────
    bind v split-window -v -c "#{pane_current_path}"
    bind h split-window -h -c "#{pane_current_path}"
    bind c new-window -c "#{pane_current_path}"

    # ─────────────────────────────────────────────────────────
    #  Set default shell for new panes/windows
    # ─────────────────────────────────────────────────────────
    set -g default-shell "${pkgs.zsh}/bin/zsh"
    set -g default-command "${pkgs.zsh}/bin/zsh"
  '';
}

