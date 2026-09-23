# https://github.com/shahidshabbir-se/dotfiles

{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;

  herdrAssets = {
    x86_64-linux = {
      name = "herdr-linux-x86_64";
      hash = "sha256-KgL+0WvrZR7wBuHUPwSPZSyk3FitBTzS1ERQVj1cVLc=";
    };
    aarch64-linux = {
      name = "herdr-linux-aarch64";
      hash = "sha256-nI2yD7fnQnsTjVNnET8WIf/TGfL2XW8AniWUApEV8NI=";
    };
    x86_64-darwin = {
      name = "herdr-macos-x86_64";
      hash = "sha256-0MkgsqEmp0gJ+hSRQRyaCXpEeGysnCylG4GKmVWBzxY=";
    };
    aarch64-darwin = {
      name = "herdr-macos-aarch64";
      hash = "sha256-MrU98JhyYoBZx4mmnwKmuOKeFN3yZxFCHzRj9wwa7xc=";
    };
  };

  herdrAsset = herdrAssets.${system} or (throw "herdr: no release asset for system ${system}");

  herdr = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "herdr";
    version = "0.9.1";
    src = pkgs.fetchurl {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/${herdrAsset.name}";
      inherit (herdrAsset) hash;
    };
    dontUnpack = true;
    nativeBuildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ];
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/herdr"
      runHook postInstall
    '';
  };

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

  automaticRenameSrc = fetchPlugin {
    owner = "qu8n";
    repo = "herdr-automatic-rename";
    rev = "081489b4d961d0d9c0c8b6a02d472e5cfe125ad5";
    hash = "sha256-jgbX/WvlUAJYyVJRQ+IuC89TGC8rAISoTEofyf9IKS0=";
  };

  automaticRenameRoot = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr-automatic-rename";
    version = "0.11.1";
    src = automaticRenameSrc;
    patches = [ ../patches/herdr-automatic-rename-custom-icons.patch ];
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -a . $out/
    '';
  };

  iconAgentSrc = fetchPlugin {
    owner = "qintmb";
    repo = "herdr-icon-agent-ui";
    rev = "6bd682d5bfba1482380fecbb7da2375e95e5512d";
    hash = "sha256-Ab8NWk2VTMj4maKfAQCa7wuKv9vOeRmGlIsrWk5wrMg=";
  };

  herdrIconsFont = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr-agent-icons-max";
    version = "1.3.0";
    src = iconAgentSrc;
    nativeBuildInputs = [
      (pkgs.python3.withPackages (ps: [ ps.fonttools ]))
    ];
    postPatch = ''
      substituteInPlace tools/build_font.py \
        --replace-fail 'MAX_HEIGHT = 760' 'MAX_HEIGHT = 700'
    '';
    buildPhase = ''
      runHook preBuild
      python3 tools/build_font.py --output dist/HerdrAgentIconsMax-Regular.ttf
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/fonts/truetype
      cp dist/HerdrAgentIconsMax-Regular.ttf $out/share/fonts/truetype/
      runHook postInstall
    '';
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

  lastWorkspaceRoot = mkPluginRoot {
    src = lastWorkspaceSrc;
    extraInstall = ''
      mkdir -p $out/target/release
      cp ${lastWorkspaceBin}/bin/herdr-last-workspace $out/target/release/herdr-last-workspace
    '';
  };

  yaziFloatRoot = pkgs.runCommand "herdr-yazi-float" { } ''
        mkdir -p $out
        cat > $out/herdr-plugin.toml << 'EOF'
    id = "herdr.yazi-float"
    name = "Yazi float"
    version = "1.0.0"
    min_herdr_version = "0.7.0"
    description = "Open Yazi zoomed like a popup so Kitty image previews work"
    platforms = ["linux", "macos"]

    [[panes]]
    id = "yazi"
    title = "yazi"
    placement = "split"
    command = ["bash", "run-yazi.sh"]

    [[actions]]
    id = "open"
    title = "Open Yazi"
    contexts = ["workspace"]
    command = ["bash", "open.sh"]
    EOF
        cat > $out/run-yazi.sh << 'EOF'
    #!/usr/bin/env bash
    set -u
    cd "''${HERDR_YAZI_CWD:-$PWD}" 2>/dev/null || cd "$HOME" 2>/dev/null || true
    exec yazi
    EOF
        cat > $out/open.sh << 'EOF'
    #!/usr/bin/env bash
    set -uo pipefail

    LABEL="yazi"
    herdr="''${HERDR_BIN_PATH:-herdr}"

    if ! command -v jq >/dev/null 2>&1; then
      "$herdr" notification show "herdr.yazi-float needs 'jq' installed" >/dev/null 2>&1 || \
        echo "herdr.yazi-float: 'jq' is required (brew install jq / apt install jq)" >&2
      exit 1
    fi

    ws="''${HERDR_WORKSPACE_ID:-}"
    if [ -z "$ws" ]; then
      ws="$("$herdr" pane current 2>/dev/null | jq -r '.result.pane.workspace_id // empty')"
    fi

    open_pane() {
      local target="''${HERDR_PANE_ID:-}"
      [ -z "$target" ] && target="$("$herdr" pane current 2>/dev/null | jq -r '.result.pane.pane_id // empty')"

      local cwd=""
      if [ -n "$target" ]; then
        cwd="$("$herdr" pane get "$target" 2>/dev/null | jq -r '.result.pane.cwd // empty')"
      fi
      [ -z "$cwd" ] && cwd="$("$herdr" pane current 2>/dev/null | jq -r '.result.pane.cwd // empty')"

      set -- plugin pane open --plugin herdr.yazi-float --entrypoint yazi \
          --placement split --direction right --focus
      [ -n "$target" ] && set -- "$@" --target-pane "$target"
      [ -n "$cwd" ] && set -- "$@" --env "HERDR_YAZI_CWD=$cwd"
      local out pid
      out="$("$herdr" "$@" 2>/dev/null)"
      pid="$(printf '%s' "$out" | jq -r '.result.plugin_pane.pane.pane_id // empty')"
      [ -n "$pid" ] && "$herdr" pane zoom "$pid" --on >/dev/null 2>&1
      exit 0
    }

    found=""
    if [ -n "$ws" ]; then
      found="$("$herdr" pane list --workspace "$ws" 2>/dev/null \
        | jq -r --arg L "$LABEL" '
            .result.panes[]? | select(.label == $L)
            | "\(.focused) \(.pane_id)"' 2>/dev/null | head -n1)"
    fi

    [ -z "$found" ] && open_pane

    focused="''${found%% *}"
    pid="''${found#* }"

    if [ "$focused" = "true" ]; then
      exec "$herdr" plugin pane close "$pid"
    else
      exec "$herdr" pane zoom "$pid" --on
    fi
    EOF
        chmod +x $out/run-yazi.sh $out/open.sh
  '';

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
      dir = "herdr-automatic-rename-ee9406b88b77";
      root = automaticRenameRoot;
      json = {
        plugin_id = "herdr-automatic-rename";
        name = "Herdr Automatic Rename";
        version = "0.11.1";
        min_herdr_version = "0.7.1";
        description = "Auto-name tabs after where the work is and what is running there";
        enabled = true;
        platforms = [
          "linux"
          "macos"
        ];
        startup = [
          {
            command = [
              "bash"
              "automatic-rename.sh"
              "startup"
            ];
          }
        ];
        events = [
          {
            on = "workspace.created";
            command = [
              "bash"
              "automatic-rename.sh"
              "workspace.created"
            ];
          }
          {
            on = "workspace.closed";
            command = [
              "bash"
              "automatic-rename.sh"
              "workspace.closed"
            ];
          }
          {
            on = "workspace.renamed";
            command = [
              "bash"
              "automatic-rename.sh"
              "workspace.renamed"
            ];
          }
          {
            on = "workspace.moved";
            command = [
              "bash"
              "automatic-rename.sh"
              "workspace.moved"
            ];
          }
          {
            on = "workspace.reordered";
            command = [
              "bash"
              "automatic-rename.sh"
              "workspace.reordered"
            ];
          }
          {
            on = "worktree.created";
            command = [
              "bash"
              "automatic-rename.sh"
              "worktree.created"
            ];
          }
          {
            on = "worktree.opened";
            command = [
              "bash"
              "automatic-rename.sh"
              "worktree.opened"
            ];
          }
          {
            on = "worktree.removed";
            command = [
              "bash"
              "automatic-rename.sh"
              "worktree.removed"
            ];
          }
          {
            on = "tab.created";
            command = [
              "bash"
              "automatic-rename.sh"
              "tab.created"
            ];
          }
          {
            on = "tab.closed";
            command = [
              "bash"
              "automatic-rename.sh"
              "tab.closed"
            ];
          }
          {
            on = "tab.renamed";
            command = [
              "bash"
              "automatic-rename.sh"
              "tab.renamed"
            ];
          }
          {
            on = "tab.moved";
            command = [
              "bash"
              "automatic-rename.sh"
              "tab.moved"
            ];
          }
          {
            on = "tab.focused";
            command = [
              "bash"
              "automatic-rename.sh"
              "tab.focused"
            ];
          }
          {
            on = "pane.focused";
            command = [
              "bash"
              "automatic-rename.sh"
              "pane.focused"
            ];
          }
          {
            on = "pane.agent_detected";
            command = [
              "bash"
              "automatic-rename.sh"
              "pane.agent_detected"
            ];
          }
          {
            on = "pane.agent_status_changed";
            command = [
              "bash"
              "automatic-rename.sh"
              "pane.agent_status_changed"
            ];
          }
          {
            on = "pane.closed";
            command = [
              "bash"
              "automatic-rename.sh"
              "pane.closed"
            ];
          }
          {
            on = "pane.exited";
            command = [
              "bash"
              "automatic-rename.sh"
              "pane.exited"
            ];
          }
          {
            on = "pane.moved";
            command = [
              "bash"
              "automatic-rename.sh"
              "pane.moved"
            ];
          }
          {
            on = "pane.created";
            command = [
              "bash"
              "automatic-rename.sh"
              "pane.created"
            ];
          }
        ];
        actions = [
          {
            id = "reset";
            title = "Reset tab to automatic naming";
            contexts = [ "global" ];
            command = [
              "bash"
              "automatic-rename.sh"
              "reset"
            ];
          }
          {
            id = "doctor";
            title = "Herdr Automatic Rename: explain this tab's name";
            contexts = [ "global" ];
            command = [
              "bash"
              "automatic-rename.sh"
              "doctor"
            ];
          }
          {
            id = "clear";
            title = "Herdr Automatic Rename: strip all number prefixes";
            contexts = [ "global" ];
            command = [
              "bash"
              "automatic-rename.sh"
              "--clear"
            ];
          }
        ];
        source = {
          kind = "github";
          owner = "qu8n";
          repo = "herdr-automatic-rename";
          resolved_commit = "081489b4d961d0d9c0c8b6a02d472e5cfe125ad5";
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
              "DIR=\"$(bash \"$HERDR_PLUGIN_ROOT/bin/resolve-dir.sh\")\"; exec \"\${HERDR_BIN_PATH:-herdr}\" plugin pane open --plugin ray.file-explorer --entrypoint explorer --placement popup --cwd \"$DIR\""
            ];
          }
        ];
        panes = [
          {
            id = "explorer";
            title = "Explorer";
            placement = "popup";
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
    {
      dir = "herdr.yazi-float";
      root = yaziFloatRoot;
      json = {
        plugin_id = "herdr.yazi-float";
        name = "Yazi float";
        version = "1.0.0";
        min_herdr_version = "0.7.0";
        description = "Open Yazi zoomed like a popup so Kitty image previews work";
        enabled = true;
        platforms = [
          "linux"
          "macos"
        ];
        actions = [
          {
            id = "open";
            title = "Open Yazi";
            contexts = [ "workspace" ];
            command = [
              "bash"
              "open.sh"
            ];
          }
        ];
        panes = [
          {
            id = "yazi";
            title = "yazi";
            placement = "split";
            command = [
              "bash"
              "run-yazi.sh"
            ];
          }
        ];
        source = {
          kind = "local";
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
    import json, os, re, subprocess, sys, time
    from pathlib import Path

    FRAMES = (
      "⠋",
      "⠙",
      "⠹",
      "⠸",
      "⠼",
      "⠴",
      "⠦",
      "⠧",
      "⠇",
      "⠏"
    )
    STATIC = {
        "done": "",
        "blocked": "",
        "idle": "",
        "unknown": "",
    }
    LOGOS = {
        "claude": chr(0xE1A0),
        "codex": chr(0xE1A1),
        "opencode": chr(0xE1A2),
        "omp": chr(0xE1A3),
        "cline": chr(0xE1A4),
        "mastracode": chr(0xE1A5),
        "kimi": chr(0xE1A6),
        "kilo": chr(0xE1A7),
        "maki": chr(0xE1A8),
        "pi": chr(0xE1A9),
        "hermes": chr(0xE1AA),
        "cursor": chr(0xE1AB),
        "copilot": chr(0xE1AC),
        "deepseek": chr(0xE1AD),
        "gemini": chr(0xE1AE),
        "gpt": chr(0xE1AF),
        "qwen": chr(0xE1B0),
    }
    TOKENS = ("state_working", "state_done", "state_blocked", "state_idle", "state_unknown")
    STATUS_TOKEN = {
        "working": "state_working",
        "done": "state_done",
        "blocked": "state_blocked",
        "idle": "state_idle",
        "unknown": "state_unknown",
    }
    POLL = 0.15
    VERSION = "7"
    MARQUEE_HOLD = 12
    MARQUEE_GAP = 3
    FALLBACK_COLS = 22
    STATE_DIR = Path.home() / ".local/state/herdr/client-shell"
    SESSION_FILE = Path.home() / ".config/herdr/session.json"
    PID_FILE = Path(os.environ.get("XDG_RUNTIME_DIR") or "/tmp") / "herdr-space-icons.pid"
    last = {}

    def herdr_bin():
        return os.environ.get("HERDR_BIN_PATH", "herdr")

    def herdr_json(*args):
        proc = subprocess.run(
            [herdr_bin(), *args],
            capture_output=True,
            text=True,
        )
        if proc.returncode != 0 or not proc.stdout.strip():
            return {}
        try:
            return json.loads(proc.stdout)
        except json.JSONDecodeError:
            return {}

    def workspaces():
        data = herdr_json("workspace", "list")
        return (data.get("result") or data).get("workspaces") or []

    def agents():
        data = herdr_json("agent", "list")
        return (data.get("result") or data).get("agents") or []

    def session_name(agent):
        title = (agent.get("terminal_title_stripped") or agent.get("terminal_title") or "").strip()
        title = re.sub(r"^[^A-Za-z0-9]+\s*[-–—:]\s*", "", title)
        title = re.sub(r"^pi\s*[-–—:]\s*", "", title, flags=re.I)
        cwd = Path(agent.get("cwd") or "").name
        if cwd and title.endswith(" - " + cwd):
            title = title[: -(len(cwd) + 3)].rstrip()
        if " › " in title:
            title = title.split(" › ")[-1].strip()
        return title.replace(" · ", " ").strip(" -·")

    def bar_cols():
        latest = -1.0
        width = 0
        try:
            for p in STATE_DIR.glob("*.json"):
                try:
                    m = p.stat().st_mtime
                    w = json.loads(p.read_text()).get("sidebar_width")
                except Exception:
                    continue
                if isinstance(w, int) and w > 0 and m >= latest:
                    latest = m
                    width = w
        except Exception:
            pass
        if width:
            return width
        try:
            w = json.loads(SESSION_FILE.read_text()).get("sidebar_width")
            if isinstance(w, int) and w > 0:
                return w
        except Exception:
            pass
        return FALLBACK_COLS

    def marquee(text, width, tick):
        if not text or width <= 0 or len(text) <= width:
            return text
        pad = text + (" " * MARQUEE_GAP)
        cycle = MARQUEE_HOLD + len(pad)
        step = tick % cycle
        off = 0 if step < MARQUEE_HOLD else step - MARQUEE_HOLD
        looped = pad + text
        return looped[off:off + width]

    def titled(prefix, title, tick, focused):
        parts = [p for p in prefix if p]
        head = " ".join(parts)
        total = max(bar_cols() - 1, 8)
        room = total - (len(head) + 1 if head else 0)
        shown = marquee(title, max(room, 1), tick) if focused else title
        if head and shown:
            return f"{head} {shown}"
        return head or shown

    def write_tokens(kind, target, line, status):
        if status not in STATUS_TOKEN:
            status = "unknown"
        active = STATUS_TOKEN[status]
        args = [herdr_bin(), kind, "report-metadata", target, "--source", "sidebar-status"]
        if kind == "workspace":
            args += ["--clear-token", "icon"]
        for tok in TOKENS:
            if tok == active:
                args += ["--token", f"{tok}={line}"]
            else:
                args += ["--clear-token", tok]
        subprocess.run(args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)

    def set_line(kind, target, line, status):
        key = f"{kind}:{target}"
        val = (status, line)
        if last.get(key) == val:
            return
        last[key] = val
        write_tokens(kind, target, line, status)

    def paint(frame, tick):
        for w in workspaces():
            wid = w.get("workspace_id")
            if not wid:
                continue
            status = (w.get("agent_status") or "unknown").lower()
            glyph = frame if status == "working" else STATIC.get(status, "")
            name = (w.get("label") or "").lstrip(".")
            line = titled([glyph], name, tick, bool(w.get("focused")))
            set_line("workspace", wid, line, status)

        for a in agents():
            pane = a.get("pane_id")
            if not pane:
                continue
            status = (a.get("agent_status") or "unknown").lower()
            glyph = frame if status == "working" else STATIC.get(status, "")
            logo = LOGOS.get((a.get("agent") or "").lower(), "")
            session = session_name(a)
            line = titled([glyph, logo], session, tick, bool(a.get("focused")))
            set_line("pane", pane, line, status)

    def running_same():
        try:
            pid_s, ver = PID_FILE.read_text().split()
            pid = int(pid_s)
            os.kill(pid, 0)
            return ver == VERSION
        except Exception:
            return False

    def take_over():
        try:
            pid = int(PID_FILE.read_text().split()[0])
            if pid != os.getpid():
                os.kill(pid, 15)
        except Exception:
            pass

    if running_same():
        sys.exit(0)
    take_over()

    if os.fork() > 0:
        sys.exit(0)
    os.setsid()
    PID_FILE.write_text(f"{os.getpid()} {VERSION}")

    i = 0
    try:
        while True:
            t0 = time.monotonic()
            paint(FRAMES[i % len(FRAMES)], i)
            i += 1
            time.sleep(max(0.0, POLL - (time.monotonic() - t0)))
    finally:
        try:
            PID_FILE.unlink()
        except OSError:
            pass
  '';

  herdrSpaceIcons = pkgs.writeShellApplication {
    name = "herdr-space-icons";
    runtimeInputs = [
      pkgs.python3
      herdr
    ];
    excludeShellChecks = [ "SC2015" ];
    text = ''
      python3 ${spaceIconsPy}
    '';
  };

  herdrGitStatus = pkgs.writeShellApplication {
    name = "herdr-git-status";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
      pkgs.gnugrep
    ];
    excludeShellChecks = [
      "SC2015"
      "SC2034"
    ];
    text = ''
      export GIT_PAGER=cat GIT_OPTIONAL_LOCKS=0
      export GIT_TERMINAL_PROMPT=0

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
    move_tab_previous = "alt+shift+,"
    move_tab_next = "alt+shift+."
    switch_tab = "alt+1..9"
    switch_workspace = "ctrl+1..9"
    previous_workspace = "prefix+u"
    next_workspace = "prefix+i"
    copy_mode = "prefix+["
    workspace_picker = "prefix+w"
    goto = "prefix+g"
    new_workspace = "prefix+n"
    last_pane = "prefix+l"
    previous_agent = "alt+k"
    next_agent = "alt+j"
    focus_agent = "alt+shift+1..9"
    resize_pane_left = "alt+shift+h"
    resize_pane_down = "alt+shift+j"
    resize_pane_up = "alt+shift+k"
    resize_pane_right = "alt+shift+l"
    swap_pane_left = "prefix+shift+h"
    swap_pane_down = "prefix+shift+j"
    swap_pane_up = "prefix+shift+k"
    swap_pane_right = "prefix+shift+l"

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
    key = "prefix+ctrl+l"
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
    command = "herdr.yazi-float.open"
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
      { type = "command", command = "${herdrSpaceIcons}/bin/herdr-space-icons", interval_seconds = 1, timeout_seconds = 1 },
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

  automaticRenameConfig = ''
    NAME_TABS=1
    AUTO_INDEX=0
    AUTO_INDEX_WORKSPACES=0
    AUTO_INDEX_TABS=0
    AUTO_INDEX_AGENTS=0
    TAB_CONTEXT=1
    SHOW_BRANCH=1
    AGENT_TITLES=1
    TITLE_STYLE=task
    ICONS_ENABLED=1
    MAX_TITLE_LEN=40
  '';

in
{
  fonts.fontconfig.enable = true;

  home.packages = [
    herdr
    herdrGitStatus
    herdrSpaceIcons
    herdrIconsFont
    pkgs.dtach
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
      rm -rf "$github"/qintmb.herdr-icon-agent-ui-*
    fi
    ${pkgs.procps}/bin/pkill -f 'herdr-auto-title' >/dev/null 2>&1 || true
    ${pkgs.procps}/bin/pkill -f 'agent_state.py' >/dev/null 2>&1 || true
    ${pkgs.procps}/bin/pkill -f 'agent_icons.py' >/dev/null 2>&1 || true
    rm -rf /tmp/herdr-agent-state "$XDG_RUNTIME_DIR/herdr-agent-state" || true
    rm -f "$HOME/.local/share/fonts"/HerdrAgentIconsMax-*.ttf || true
  '';

  xdg.configFile = {
    "herdr/config.toml".text = configToml;
    "herdr/plugins.json".text = builtins.toJSON pluginsJson;
    "herdr-automatic-rename/config.sh".text = automaticRenameConfig;
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
