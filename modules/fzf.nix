{ pkgs }: {
  enable = true;
  enableZshIntegration = true;
  tmux.enableShellIntegration = false;
  # use fd for speed
  defaultCommand = "fd --type f --hidden --exclude .git";
  changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
  fileWidgetCommand = "fd --type f --hidden --exclude .git";
}
