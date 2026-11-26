#   █████╗ ████████╗██╗   ██╗██╗███╗   ██╗
#  ██╔══██╗╚══██╔══╝██║   ██║██║████╗  ██║
#  ███████║   ██║   ██║   ██║██║██╔██╗ ██║
#  ██╔══██║   ██║   ██║   ██║██║██║╚██╗██║
#  ██║  ██║   ██║   ╚██████╔╝██║██║ ╚████║
#  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝╚═╝  ╚═══╝
#  https://github.com/shahidshabbir-se/dotfiles

{
  pkgs ? null,
}:
{
  enable = true;
  package = pkgs.atuin;

  # ───────────────────────────────────────────────
  # ▶ Zsh Integration
  # ───────────────────────────────────────────────
  enableZshIntegration = true;
  flags = [ "--bind-ai-resume" ]; # Ctrl+] opens the thread resume picker.

  # ───────────────────────────────────────────────
  # ▶ Atuin Settings
  # ───────────────────────────────────────────────
  settings = {
    auto_sync = true;
    sync_frequency = "5m";

    search_mode = "daemon-fuzzy";
    filter_mode = "global";
    filter_mode_shell_up_key_binding = "global";

    style = "full"; # Display style: minimal | compact | full
    enter_accept = true;
    keymap_mode = "vim-normal";

    daemon = {
      enabled = true;
      autostart = true;
    };

    threads.capture = true;
  };
}
