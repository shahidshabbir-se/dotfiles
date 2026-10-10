{
  homeDirectory,
  workspaceDirectory,
  dotfilesDirectory,
  userGithub,
}:
{ pkgs, lib, ... }:
let
  bin = {
    git = "${pkgs.git}/bin/git";
    grep = "${pkgs.gnugrep}/bin/grep";
    mkdir = "${pkgs.coreutils}/bin/mkdir";
    ssh = "${pkgs.openssh}/bin/ssh";
  };

  createProjectsWorkspaceScript = ''
    ${bin.mkdir} -p \
      "${workspaceDirectory}" \
      "${homeDirectory}/Desktop" \
      "${homeDirectory}/Documents" \
      "${homeDirectory}/Downloads" \
      "${homeDirectory}/Extras" \
      "${homeDirectory}/Music" \
      "${homeDirectory}/Pictures" \
      "${homeDirectory}/Public" \
      "${homeDirectory}/Templates" \
      "${homeDirectory}/Videos"

    # Auto-clone repos if not present. SSH host keys are accepted on first use
    # so fresh machines can complete activation non-interactively.
    export GIT_SSH_COMMAND="${bin.ssh} -o StrictHostKeyChecking=accept-new"

    if [ ! -d "${dotfilesDirectory}/.git" ]; then
      ${bin.git} clone git@github.com:${userGithub}/dotfiles.git "${dotfilesDirectory}" || true
    fi

    # Ensure dotfiles use SSH even if the repo was cloned with HTTPS earlier.
    DOTFILES_REMOTE=$(${bin.git} -C "${dotfilesDirectory}" remote get-url origin 2>/dev/null || true)

    if printf '%s\n' "$DOTFILES_REMOTE" | ${bin.grep} -q "^https://"; then
      ${bin.git} -C "${dotfilesDirectory}" remote set-url origin git@github.com:${userGithub}/dotfiles.git
    fi
  '';
in
{
  home.activation.createProjectsWorkspace = lib.hm.dag.entryAfter [
    "writeBoundary"
  ] createProjectsWorkspaceScript;
}
