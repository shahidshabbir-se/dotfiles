# ████████╗██╗   ██╗
# ╚══██╔══╝██║   ██║
#    ██║   ██║   ██║
#    ██║   ╚██╗ ██╔╝
#    ██║    ╚████╔╝
#    ╚═╝     ╚═══╝
# https://github.com/alexpasmantier/television

{ config, ... }:

{
  # ─────────────────────────────────────────────────────────
  #  Main config
  # ─────────────────────────────────────────────────────────
  xdg.configFile."television/config.toml".text = ''
    # ── General ──────────────────────────────────────────────
    tick_rate       = 50
    default_channel = "files"
    history_size    = 500
    global_history  = false

    # ── UI ───────────────────────────────────────────────────
    [ui]
    theme       = "tokyonight"
    orientation = "landscape"
    ui_scale    = 100

    [ui.input_bar]
    position    = "top"
    prompt      = " "
    border_type = "rounded"

    [ui.results_panel]
    border_type = "rounded"

    [ui.preview_panel]
    size        = 50
    scrollbar   = true
    border_type = "rounded"
    hidden      = false

    [ui.status_bar]
    separator_open  = ""
    separator_close = ""
    hidden          = true

    [ui.help_panel]
    hidden           = true
    show_categories  = true

    [ui.remote_control]
    show_channel_descriptions = true
    sort_alphabetically       = true

    # ── Keybindings (key = "action" format) ──────────────────
    [keybindings]
    esc        = "quit"
    ctrl-c     = "quit"
    down       = "select_next_entry"
    ctrl-j     = "select_next_entry"
    ctrl-n     = "select_next_entry"
    up         = "select_prev_entry"
    ctrl-k     = "select_prev_entry"
    ctrl-p     = "select_prev_entry"
    enter      = "confirm_selection"
    tab        = "toggle_selection_down"
    backtab    = "toggle_selection_up"
    ctrl-o     = "toggle_preview"
    ctrl-t     = "toggle_remote_control"
    ctrl-h     = "toggle_help"
    ctrl-y     = "copy_entry_to_clipboard"
    ctrl-u     = "scroll_preview_half_page_up"
    ctrl-d     = "scroll_preview_half_page_down"
    ctrl-s     = "cycle_sources"
    backspace  = "delete_prev_char"
    ctrl-w     = "delete_prev_word"
    left       = "go_to_prev_char"
    right      = "go_to_next_char"
    home       = "go_to_input_start"
    ctrl-a     = "go_to_input_start"
    end        = "go_to_input_end"
    ctrl-e     = "go_to_input_end"

    # ── Shell Integration ─────────────────────────────────────
    [shell_integration]
    fallback_channel = "files"

    [shell_integration.keybindings]
    smart_autocomplete = "ctrl-t"

    [shell_integration.channel_triggers]
    "git-branch"  = ["git checkout", "git branch", "git merge", "git rebase"]
    "git-log"     = ["git show", "git diff"]
    "git-repos"   = ["cd", "sesh connect"]
    "dirs"        = ["ls", "ll", "lsd", "rmdir", "mkdir"]
    "files"       = ["nvim", "vi", "bat", "cat", "cp", "mv", "rm"]
    "env"         = ["export", "unset", "echo"]
    "docker-containers" = ["docker exec", "docker logs", "docker stop", "docker start", "docker rm"]
    "docker-images"     = ["docker run", "docker pull", "docker rmi"]
  '';

  # ─────────────────────────────────────────────────────────
  #  Sesh channel — lets `tv sesh` open the sesh session picker
  #  (used by the tmux T binding)
  # ─────────────────────────────────────────────────────────
  xdg.configFile."television/cable/sesh.toml".text = ''
    [metadata]
    name        = "sesh"
    description = "Smart tmux session picker via sesh"
    requirements = ["sesh", "tmux"]

    [source]
    command = [
      "sesh list --icons",
      "sesh list -t --icons",
      "sesh list -c --icons",
      "sesh list -z --icons",
    ]
    ansi   = true
    output = "{strip_ansi|split: :1..|join: }"

    [preview]
    command = "sesh preview '{strip_ansi|split: :1..|join: }'"

    [keybindings]
    enter  = "actions:connect"
    ctrl-x = "actions:kill"

    [actions.connect]
    description = "Connect to the selected session"
    command     = "sesh connect '{strip_ansi|split: :1..|join: }'"
    mode        = "execute"

    [actions.kill]
    description = "Kill the selected tmux session"
    command     = "tmux kill-session -t '{strip_ansi|split: :1..|join: }'"
    mode        = "fork"
  '';

  # ─────────────────────────────────────────────────────────
  #  Dotfiles channel — browse your own config files
  # ─────────────────────────────────────────────────────────
  xdg.configFile."television/cable/dotfiles.toml".text = ''
    [metadata]
    name        = "dotfiles"
    description = "Browse and edit your dotfiles"
    requirements = ["fd", "bat"]

    [source]
    command = "fd -t f . ${config.home.homeDirectory}/dotfiles"

    [preview]
    command = "bat -n --color=always '{}'"

    [preview.env]
    BAT_THEME = "ansi"

    [keybindings]
    enter  = "actions:edit"

    [actions.edit]
    description = "Edit the selected dotfile in nvim"
    command     = "nvim '{}'"
    mode        = "execute"
  '';
}
