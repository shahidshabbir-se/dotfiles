# https://github.com/shahidshabbir-se/dotfiles

{
  config,
  pkgs,
  lib,
  ...
}:

let
  herdr = import ./pkgs/herdr.nix { inherit pkgs lib; };

  fetchPlugin =
    {
      owner,
      repo,
      rev,
      hash,
    }:
    pkgs.fetchFromGitHub {
      inherit
        owner
        repo
        rev
        hash
        ;
    };

  floaxSrc = fetchPlugin {
    owner = "Tyru5";
    repo = "herdr-floax";
    rev = "d6b283110c2e455fb3782595549895a840585e2b";
    hash = "sha256-3plrwzhZPD1jCsw2j/Mkjz80AMkSNzb+PUuf5+6CFaI=";
  };

  autoTitleSrc = fetchPlugin {
    owner = "kryptamine";
    repo = "herdr-auto-title";
    rev = "f574e6eac8497038885972b4f664095ef886d00b";
    hash = "sha256-Rw75Bm6e7bBKssv7Mrf77r814//Lm8/nmkIeTTH8jDM=";
  };

  iconAgentSrc = fetchPlugin {
    owner = "qintmb";
    repo = "herdr-icon-agent-ui";
    rev = "6bd682d5bfba1482380fecbb7da2375e95e5512d";
    hash = "sha256-Ab8NWk2VTMj4maKfAQCa7wuKv9vOeRmGlIsrWk5wrMg=";
  };

  yaziSrc = fetchPlugin {
    owner = "speardragon";
    repo = "herdr-yazi";
    rev = "54aa4e6dff480189630fa3593146cdcc2768ade9";
    hash = "sha256-5bAy+xD1mLYJOUYvLWeU2pgZpYAeo+hxdNSlaM9pCkA=";
  };

  lastWorkspaceSrc = fetchPlugin {
    owner = "third774";
    repo = "herdr-last-workspace";
    rev = "8b55ebf15deaa52b49ff1c2500aab0c19c729420";
    hash = "sha256-HaNQx4uGYVGP3L3ljFHEDEE53Fs17fC7ypZFDnVjOHk=";
  };

  vimNavSrc = fetchPlugin {
    owner = "paulbkim-dev";
    repo = "vim-herdr-navigation";
    rev = "79679dacc791f70fc34de8b29a3cf9706c0f5b2f";
    hash = "sha256-iF0DLRn56eLGqY2iKTb3lX5iyVgl9CtSX5O2E5/pHjM=";
  };

  floaxBin = pkgs.rustPlatform.buildRustPackage {
    pname = "herdr-floax";
    version = "0.2.0";
    src = floaxSrc;
    cargoHash = "sha256-/cjPrU0tx1NkhJLvEGpSVZUfzNDkqH4t7t+mR9r/Bco=";
    doCheck = false;
  };

  lastWorkspaceBin = pkgs.rustPlatform.buildRustPackage {
    pname = "herdr-last-workspace";
    version = "0.1.0";
    src = lastWorkspaceSrc;
    cargoHash = "sha256-l9y7crYh2rd9CQdr7E5WuLd65Qlc6R2Yi2dZC/z4nNM=";
    doCheck = false;
  };

  autoTitleBin = pkgs.buildGoModule {
    pname = "herdr-auto-title";
    version = "0.4.0";
    src = autoTitleSrc;
    vendorHash = "sha256-QxFp1b7pf7bn3Hh0hyaj8ke5Z61N+WwjhHt3pFiapTs=";
    subPackages = [ "cmd/herdr-auto-title" ];
    doCheck = false;
  };

  mkPluginRoot =
    {
      src,
      extraInstall ? "",
    }:
    pkgs.runCommand "herdr-plugin-root" { } ''
      mkdir -p $out
      cp -a ${src}/. $out/
      chmod -R u+w $out
      ${extraInstall}
    '';

  floaxRoot = mkPluginRoot {
    src = floaxSrc;
    extraInstall = ''
      mkdir -p $out/target/release
      cp ${floaxBin}/bin/herdr-floax $out/target/release/herdr-floax
    '';
  };

  autoTitleRoot = mkPluginRoot {
    src = autoTitleSrc;
    extraInstall = ''
      cp ${autoTitleBin}/bin/herdr-auto-title $out/herdr-auto-title
    '';
  };

  lastWorkspaceRoot = mkPluginRoot {
    src = lastWorkspaceSrc;
    extraInstall = ''
      mkdir -p $out/target/release
      cp ${lastWorkspaceBin}/bin/herdr-last-workspace $out/target/release/herdr-last-workspace
    '';
  };

  plugins = [
    {
      dir = "herdr-floax-0151ef56c880";
      root = floaxRoot;
      json = {
        plugin_id = "herdr-floax";
        name = "herdr-floax";
        version = "0.2.0";
        min_herdr_version = "0.7.0";
        description = "Toggle a floating scratch shell (sized popup) for the current workspace, à la tmux-floax.";
        enabled = true;
        platforms = [
          "linux"
          "macos"
        ];
        actions = [
          {
            id = "toggle";
            title = "Toggle floating pane";
            description = "Open, reveal, or dismiss the floating scratch shell for this workspace.";
            command = [
              "bash"
              "scripts/toggle-floating.sh"
            ];
          }
        ];
        panes = [
          {
            id = "floating";
            title = "⌂ floax";
            placement = "split";
            command = [ "./target/release/herdr-floax" ];
          }
        ];
        source = {
          kind = "github";
          owner = "Tyru5";
          repo = "herdr-floax";
          resolved_commit = "d6b283110c2e455fb3782595549895a840585e2b";
        };
      };
    }
    {
      dir = "herdr.auto-title-4b7d61f48ce8";
      root = autoTitleRoot;
      json = {
        plugin_id = "herdr.auto-title";
        name = "Auto Title";
        version = "0.4.0";
        min_herdr_version = "0.8.2";
        description = "Automatically generates contextual tab titles";
        enabled = true;
        platforms = [
          "linux"
          "macos"
        ];
        startup = [
          {
            command = [ "./herdr-auto-title" ];
          }
        ];
        source = {
          kind = "github";
          owner = "kryptamine";
          repo = "herdr-auto-title";
          resolved_commit = "f574e6eac8497038885972b4f664095ef886d00b";
        };
      };
    }
    {
      dir = "qintmb.herdr-icon-agent-ui-3a8809b69f32";
      root = iconAgentSrc;
      json = {
        plugin_id = "qintmb.herdr-icon-agent-ui";
        name = "Agent Icon UI";
        version = "1.3.0";
        min_herdr_version = "0.8.0";
        description = "Large Unicode harness logos + animated lifecycle-state glyphs for the Herdr sidebar.";
        enabled = true;
        platforms = [
          "linux"
          "macos"
          "windows"
        ];
        startup = [
          {
            command = [
              "python3"
              "agent_icons.py"
            ];
          }
          {
            command = [
              "python3"
              "agent_state.py"
            ];
          }
        ];
        actions = [
          {
            id = "refresh";
            title = "Agent icons: refresh";
            command = [
              "python3"
              "agent_icons.py"
            ];
          }
        ];
        events = [
          {
            on = "pane.agent_detected";
            command = [
              "python3"
              "agent_icons.py"
            ];
          }
          {
            on = "pane.agent_detected";
            command = [
              "python3"
              "agent_state.py"
            ];
          }
          {
            on = "pane.agent_status_changed";
            command = [
              "python3"
              "agent_state.py"
            ];
          }
        ];
        source = {
          kind = "github";
          owner = "qintmb";
          repo = "herdr-icon-agent-ui";
          resolved_commit = "6bd682d5bfba1482380fecbb7da2375e95e5512d";
        };
      };
    }
    {
      dir = "ray.file-explorer-921f378e3e1b";
      root = yaziSrc;
      json = {
        plugin_id = "ray.file-explorer";
        name = "Yazi Explorer";
        version = "1.1.0";
        min_herdr_version = "0.7.0";
        description = "Open Yazi (terminal file manager) in a herdr pane";
        enabled = true;
        platforms = [
          "linux"
          "macos"
        ];
        actions = [
          {
            id = "open";
            title = "Open file explorer";
            contexts = [ "workspace" ];
            command = [
              "bash"
              "-c"
              "DIR=\"$(bash \"$HERDR_PLUGIN_ROOT/bin/resolve-dir.sh\")\"; exec \"\${HERDR_BIN_PATH:-herdr}\" plugin pane open --plugin ray.file-explorer --entrypoint explorer --placement split --cwd \"$DIR\""
            ];
          }
        ];
        panes = [
          {
            id = "explorer";
            title = "Explorer";
            placement = "split";
            command = [
              "bash"
              "-c"
              "exec yazi"
            ];
          }
        ];
        source = {
          kind = "github";
          owner = "speardragon";
          repo = "herdr-yazi";
          resolved_commit = "54aa4e6dff480189630fa3593146cdcc2768ade9";
        };
      };
    }
    {
      dir = "third774.last-workspace-5de7aeab3665";
      root = lastWorkspaceRoot;
      json = {
        plugin_id = "third774.last-workspace";
        name = "Last Workspace";
        version = "0.1.0";
        min_herdr_version = "0.7.0";
        description = "Toggle between the current and previously focused Herdr workspace.";
        enabled = true;
        platforms = [
          "linux"
          "macos"
        ];
        actions = [
          {
            id = "toggle";
            title = "Last workspace";
            contexts = [
              "global"
              "workspace"
            ];
            command = [
              "./target/release/herdr-last-workspace"
              "toggle"
            ];
          }
        ];
        events = [
          {
            on = "workspace.closed";
            command = [
              "./target/release/herdr-last-workspace"
              "closed"
            ];
          }
          {
            on = "workspace.focused";
            command = [
              "./target/release/herdr-last-workspace"
              "focused"
            ];
          }
        ];
        source = {
          kind = "github";
          owner = "third774";
          repo = "herdr-last-workspace";
          resolved_commit = "8b55ebf15deaa52b49ff1c2500aab0c19c729420";
        };
      };
    }
    {
      dir = "vim-herdr-navigation-a8bf42123d81";
      root = vimNavSrc;
      json = {
        plugin_id = "vim-herdr-navigation";
        name = "Vim Herdr Navigation";
        version = "0.1.0";
        min_herdr_version = "0.7.0";
        description = "Seamless Ctrl+h/j/k/l navigation across herdr panes and Vim/Neovim splits";
        enabled = true;
        platforms = [
          "linux"
          "macos"
        ];
        actions = [
          {
            id = "down";
            title = "Navigate down (Vim/herdr)";
            contexts = [ "global" ];
            command = [
              "bash"
              "navigate.sh"
              "down"
            ];
          }
          {
            id = "left";
            title = "Navigate left (Vim/herdr)";
            contexts = [ "global" ];
            command = [
              "bash"
              "navigate.sh"
              "left"
            ];
          }
          {
            id = "right";
            title = "Navigate right (Vim/herdr)";
            contexts = [ "global" ];
            command = [
              "bash"
              "navigate.sh"
              "right"
            ];
          }
          {
            id = "up";
            title = "Navigate up (Vim/herdr)";
            contexts = [ "global" ];
            command = [
              "bash"
              "navigate.sh"
              "up"
            ];
          }
        ];
        source = {
          kind = "github";
          owner = "paulbkim-dev";
          repo = "vim-herdr-navigation";
          resolved_commit = "79679dacc791f70fc34de8b29a3cf9706c0f5b2f";
        };
      };
    }
  ];

  pluginHome = "${config.xdg.configHome}/herdr/plugins/github";

  pluginsJson = map (
    p:
    p.json
    // {
      manifest_path = "${pluginHome}/${p.dir}/herdr-plugin.toml";
      plugin_root = "${pluginHome}/${p.dir}";
      source = p.json.source // {
        managed_path = "${pluginHome}/${p.dir}";
      };
    }
  ) plugins;

  spaceIconsPy = pkgs.writeText "herdr-space-icons.py" ''
    import json, os, subprocess, sys, time

    FRAMES = ("✽", "✼", "✻", "✺", "✻", "✼", "✽", "✼", "✻")
    STATIC = {
        "done": "",
        "blocked": "",
        "idle": "",
        "unknown": "",
    }
    TOKENS = ("state_working", "state_done", "state_blocked", "state_idle", "state_unknown")
    STATUS_TOKEN = {
        "working": "state_working",
        "done": "state_done",
        "blocked": "state_blocked",
        "idle": "state_idle",
        "unknown": "state_unknown",
    }

    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    ws = (data.get("result") or data).get("workspaces") or []
    herdr_bin = os.environ.get("HERDR_BIN_PATH", "herdr")
    frame = FRAMES[int(time.time() * 4) % len(FRAMES)]

    for w in ws:
        wid = w.get("workspace_id")
        if not wid:
            continue
        status = (w.get("agent_status") or "unknown").lower()
        if status not in STATUS_TOKEN:
            status = "unknown"
        glyph = frame if status == "working" else STATIC.get(status, "")
        name = (w.get("label") or "").lstrip(".")
        line = f"{glyph} {name}".strip() if name else glyph
        active = STATUS_TOKEN[status]
        args = [herdr_bin, "workspace", "report-metadata", wid, "--source", "space-status"]
        args += ["--clear-token", "icon"]
        for tok in TOKENS:
            if tok == active:
                args += ["--token", f"{tok}={line}"]
            else:
                args += ["--clear-token", tok]
        subprocess.run(args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
  '';

  herdrSpaceIcons = pkgs.writeShellApplication {
    name = "herdr-space-icons";
    runtimeInputs = [
      pkgs.python3
      herdr
    ];
    excludeShellChecks = [ "SC2015" ];
    text = ''
      herdr workspace list 2>/dev/null | python3 ${spaceIconsPy}
    '';
  };

  herdrGitStatus = pkgs.writeShellApplication {
    name = "herdr-git-status";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
      pkgs.gnugrep
      herdrSpaceIcons
    ];
    excludeShellChecks = [
      "SC2015"
      "SC2034"
    ];
    text = ''
      export GIT_PAGER=cat GIT_OPTIONAL_LOCKS=0
      export GIT_TERMINAL_PROMPT=0
      herdr-space-icons >/dev/null 2>&1 || true

      dir="''${HERDR_ACTIVE_PANE_CWD:-$PWD}"
      [ -n "$dir" ] || exit 0
      cd "$dir" 2>/dev/null || exit 0

      git --no-pager rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

      branch=$(git --no-pager rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
      [ -z "$branch" ] && exit 0
      [ ''${#branch} -gt 25 ] && branch="''${branch:0:25}…"

      porcelain=$(git --no-pager status --porcelain=v1 -u 2>/dev/null) || porcelain=""
      changed=0
      untracked=0
      if [ -n "$porcelain" ]; then
        changed=$(printf '%s\n' "$porcelain" | grep -cE '^[MADRCU ][MADRCU ]' || true)
        untracked=$(printf '%s\n' "$porcelain" | grep -cE '^\?\?' || true)
      fi

      ins=0
      del=0
      if [ "$changed" -gt 0 ]; then
        short=$(git --no-pager diff --shortstat 2>/dev/null || true)
        ins=$(printf '%s' "$short" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || true)
        del=$(printf '%s' "$short" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || true)
        ins=''${ins:-0}
        del=''${del:-0}
      fi

      sync_mode=0
      if [ "$changed" -gt 0 ] || [ "$untracked" -gt 0 ]; then
        sync_mode=1
      else
        need_push=$(git --no-pager rev-list --count '@{push}..HEAD' 2>/dev/null || echo 0)
        if [ "''${need_push:-0}" -gt 0 ]; then
          sync_mode=2
        else
          need_pull=$(git --no-pager rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo 0)
          [ "''${need_pull:-0}" -gt 0 ] && sync_mode=3
        fi
      fi

      case "$sync_mode" in
        1) remote="󱓎" ;;
        2) remote="󰛃" ;;
        3) remote="󰛀" ;;
        *) remote="" ;;
      esac

      out="$remote $branch"
      [ "$changed" -gt 0 ] && out="$out  $changed"
      [ "$ins" -gt 0 ] && out="$out  $ins"
      [ "$del" -gt 0 ] && out="$out  $del"
      [ "$untracked" -gt 0 ] && out="$out  $untracked"
      printf '%s\n' "$out"
    '';
  };

  configToml = ''
    onboarding = false

    [terminal]
    new_cwd = "follow"

    [theme]
    name = "tokyo-night"
    auto_switch = false

    [keys]
    prefix = "ctrl+n"
    reload_config = "alt+r"
    split_horizontal = "prefix+v"
    split_vertical = "prefix+h"
    toggle_sidebar = "ctrl+b"
    close_pane = "prefix+x"
    close_tab = "ctrl+x"
    zoom = "alt+z"
    new_tab = "prefix+c"
    previous_tab = ["alt+h", "alt+left"]
    next_tab = ["alt+l", "alt+right"]
    switch_tab = "alt+1..9"
    switch_workspace = "prefix+1..9"
    previous_workspace = "prefix+u"
    next_workspace = "prefix+i"
    copy_mode = "prefix+["
    workspace_picker = "prefix+w"
    goto = "prefix+g"
    new_workspace = "prefix+n"
    previous_agent = "alt+k"
    next_agent = "alt+j"
    focus_agent = "alt+shift+1..9"
    resize_pane_left = "alt+shift+h"
    resize_pane_down = "alt+shift+j"
    resize_pane_up = "alt+shift+k"
    resize_pane_right = "alt+shift+l"

    [[keys.command]]
    key = "ctrl+h"
    type = "plugin_action"
    command = "vim-herdr-navigation.left"
    description = "navigate left (vim/herdr)"

    [[keys.command]]
    key = "ctrl+j"
    type = "plugin_action"
    command = "vim-herdr-navigation.down"
    description = "navigate down (vim/herdr)"

    [[keys.command]]
    key = "ctrl+k"
    type = "plugin_action"
    command = "vim-herdr-navigation.up"
    description = "navigate up (vim/herdr)"

    [[keys.command]]
    key = "ctrl+l"
    type = "plugin_action"
    command = "vim-herdr-navigation.right"
    description = "navigate right (vim/herdr)"

    [[keys.command]]
    key = "prefix+l"
    type = "plugin_action"
    command = "third774.last-workspace.toggle"
    description = "last workspace"

    [[keys.command]]
    key = "prefix+f"
    type = "plugin_action"
    command = "herdr-floax.toggle"
    description = "Toggle floating pane"

    [[keys.command]]
    key = "ctrl+y"
    type = "plugin_action"
    command = "ray.file-explorer.open"
    description = "open file explorer"

    [ui.toast]
    delivery = "system"

    [ui]
    show_agent_labels_on_pane_borders = true
    pane_borders = true
    hide_tab_bar_when_single_tab = false
    prompt_new_tab_name = false
    prompt_new_workspace_name = false
    pane_gaps = false
    pane_outer_borders = false
    pane_scrollbars = false
    sidebar_start_collapsed = true
    sidebar_collapsed_mode = "hidden"
    tab_bar_position = "top"
    tab_bar_right = [
      { type = "command", command = "${herdrGitStatus}/bin/herdr-git-status", interval_seconds = 1, timeout_seconds = 2 }
    ]
    tab_bar_right_separator = " "
    window_title = "{workspace} › {tab}"
    sidebar_width = 22
    sidebar_min_width = 18
    sidebar_max_width = 28
    agent_panel_sort = "priority"

    [ui.sidebar.spaces]
    rows = [[
      { token = "$state_working", fg = "#ff9e64" },
      { token = "$state_done", fg = "#9ece6a" },
      { token = "$state_blocked", fg = "#f7768e" },
      { token = "$state_idle", fg = "#565f89" },
      { token = "$state_unknown", fg = "#565f89" },
    ]]

    [ui.sidebar.agents]
    row_gap = 0
    rows = [[
      { token = "$state_working", fg = "#ff9e64" },
      { token = "$state_done", fg = "#9ece6a" },
      { token = "$state_blocked", fg = "#f7768e" },
      { token = "$state_idle", fg = "#565f89" },
      { token = "$state_unknown", fg = "#565f89" },
    ]]

    [experimental]
    pane_history = true
    kitty_graphics = true

    [worktrees]
    directory = "~/.herdr/worktrees"
  '';

  autoTitleEnv = ''
    HERDR_AUTO_TITLE_POSITION=false
    HERDR_AUTO_TITLE_AGENT_NAME=true
    HERDR_AUTO_TITLE_MAX_LENGTH=40
  '';

in
{
  home.packages = [
    herdr
    herdrGitStatus
    herdrSpaceIcons
    pkgs.python3
    pkgs.jq
  ];

  home.activation.migrateHerdrPlugins = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    github="${config.xdg.configHome}/herdr/plugins/github"
    if [ -d "$github" ]; then
      for dir in ${lib.concatStringsSep " " (map (p: p.dir) plugins)}; do
        target="$github/$dir"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          rm -rf "$target"
        fi
      done
    fi
  '';

  xdg.configFile = {
    "herdr/config.toml".text = configToml;
    "herdr/plugins.json".text = builtins.toJSON pluginsJson;
    "herdr-auto-title/config.env".text = autoTitleEnv;
  }
  // lib.listToAttrs (
    map (p: {
      name = "herdr/plugins/github/${p.dir}";
      value = {
        source = p.root;
      };
    }) plugins
  );
}
