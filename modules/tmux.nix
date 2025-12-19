# ████████╗███╗   ███╗██╗   ██╗██╗  ██╗
# ╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝
#    ██║   ██╔████╔██║██║   ██║ ╚███╔╝ 
#    ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗ 
#    ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
#    ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
# https://github.com/shahidshabbir-se/dotfiles

{ pkgs, lib, ... }:

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
{
  enable = true;

  aggressiveResize = true;
  baseIndex = 1;
  disableConfirmationPrompt = true;
  keyMode = "vi";
  terminal = "xterm-256color";
  newSession = false;
  secureSocket = true;
  escapeTime = 0;
  shell = "${pkgs.zsh}/bin/zsh";
  sensibleOnTop = false;
  mouse = true;
  prefix = "C-n";

  plugins = with pkgs.tmuxPlugins; [
    {
      plugin = tokyo-night;
      extraConfig = ''
        set -g @tokyo-night-tmux_window_id_style dsquare
        set -g @tokyo-night-tmux_show_datetime 0
        ${lib.optionalString pkgs.stdenv.isDarwin ''
          set -g @tokyo-night-tmux_show_hostname 0

        ''}
        ${lib.optionalString (!pkgs.stdenv.isDarwin) ''
          set -g @tokyo-night-tmux_show_hostname 0
        ''}
        set -g @tokyo-night-tmux_path_format relative
        set -g @tokyo-night-tmux_show_git 1
        set -g @tokyo-night-tmux_terminal_icon ""
        set -g @tokyo-night-tmux_active_terminal_icon ""
        set -g @tokyo-night-tmux_show_path 0
        set -g @tokyo-night-tmux_show_music 1
        set -g @tokyo-night-tmux_window_tidy_icons 0
        set -g @tokyo-night-tmux_transparent 1

        run-shell ${tokyo-night}/share/tmux-plugins/tokyo-night/tokyo-night.tmux
      '';
    }
    yank
    # sensible  # removed - might override shell settings
    vim-tmux-navigator
    tmux-thumbs
    better-mouse-mode
    {
      plugin = tmux-floax;
      extraConfig =
        ''
          set -g @floax-width '80%'
          set -g @floax-height '80%'
          set -g @floax-border-color 'magenta'
          set -g @floax-text-color 'blue'
          set -g @floax-bind 'p'
          set -g @floax-change-path 'true'
        '';
    }
    {
      plugin = mkTmuxPlugin {
        pluginName = "tmux-super-fingers";
        version = "unstable-2023-10-03";
        src = pkgs.fetchFromGitHub {
          owner = "artemave";
          repo = "tmux_super_fingers";
          rev = "518044ef78efa1cf3c64f2e693fef569ae570ddd";
          sha256 = "1710pqvjwis0ki2c3mdrp2zia3y3i8g4rl6v42pg9nk4igsz39w8";
        };
      };
      extraConfig = ''
        set -g @super-fingers-key f
      '';
    }
    {
      plugin = resurrect;
      extraConfig = ''
        set -g @resurrect-strategy-vim 'session'
        set -g @resurrect-strategy-nvim 'session'
        set -g @resurrect-capture-pane-contents 'on'
        set -g @resurrect-processes 'nvim vim vi ~Vim "~nvim->nvim" "~opencode->opencode"  "~droid->droid" "~claude->claude"'
      ''
      + ''
        # Taken from: https://github.com/p3t33/nixos_flake/blob/5a989e5af403b4efe296be6f39ffe6d5d440d6d6/home/modules/tmux.nix
        resurrect_dir="$HOME/.cache/.tmux/resurrect"
        set -g @resurrect-dir $resurrect_dir

        set -g @resurrect-hook-post-save-all 'sed -i "" "s| --cmd .*-vim-pack-dir||g; s| --cmd lua vim\\.g\\.[^[:space:]]*||g; s|/etc/profiles/per-user/\$USER/bin/||g; s|/home/\$USER/.nix-profile/bin/||g; s|/nix/store/.*/bin/||g" $resurrect_dir/$(readlink $resurrect_dir/last)'
      '';
    }
    {
      plugin = continuum;
      extraConfig = ''
        set -g @continuum-restore 'on'
        set -g @continuum-boot 'on'
        set -g @continuum-save-interval '10'
        set -g @continuum-systemd-start-cmd 'start-server'
      '';
    }
  ];

  extraConfig = ''
    # ─────────────────────────────────────────────────────────
    #  Default Shell (MUST be first!)
    # ─────────────────────────────────────────────────────────
    set -g default-shell "${pkgs.zsh}/bin/zsh"
    set -g default-command "${pkgs.zsh}/bin/zsh -l"

    # ─────────────────────────────────────────────────────────
    #  Terminal Features
    # ─────────────────────────────────────────────────────────
    set -as terminal-features ",xterm-256color:RGB"

    set -g pane-active-border-style 'fg=magenta,bg=default'
    set -g pane-border-style 'fg=brightblack,bg=default'


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
    #  Window Moving (Ctrl + Shift + Arrow)
    # ─────────────────────────────────────────────────────────
    bind -n M-< swap-window -t -1\; select-window -t -1
    bind -n M-> swap-window -t +1\; select-window -t +1

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

    set -g @fzf-url-fzf-options '-p 60%,30% --prompt="   " --border-label=" Open URL "'
    set -g @fzf-url-history-limit '2000'

    set -g status-position bottom

    # ─────────────────────────────────────────────────────────
    #  Scroll up/down with Alt-k/j
    # ─────────────────────────────────────────────────────────
    bind -n M-k if-shell -F "#{pane_in_mode}" "send-keys -X scroll-up" "copy-mode; send-keys -X scroll-up"
    bind -n M-j if-shell -F "#{pane_in_mode}" "send-keys -X scroll-down" "send-keys M-j"
  '';
}
