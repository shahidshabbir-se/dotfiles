# Quickshell 0.3.2.r7.g2b4501a + Omarchy's load/reload patches.
#
# Omarchy's shell starts with `//@ pragma OmarchyLoadPatch`; the patch adds the
# pragma's QML load interception. The second patch removes a synchronous
# rescan that deadlocks plugin reload on the Qt version used here.
#
# Source and patches are pinned so the fork builds reproducibly. When nixpkgs
# carries an equivalent snapshot and both patches, remove this override.
{
  lib,
  quickshell,
  fetchFromGitea,
}:
let
  revision = "2b4501a282689792b62e94f3fb30d8f512324fe6";
in
quickshell.overrideAttrs (old: {
  version = "0.3.2.r7.g2b4501a";
  src = fetchFromGitea {
    domain = "git.outfoxxed.me";
    owner = "quickshell";
    repo = "quickshell";
    rev = revision;
    hash = "sha256-tq6x6CRG8Qikrjri59tzu9+b2gri8TjnShkGeh8kUgQ=";
  };
  cmakeFlags = builtins.filter (flag: !lib.hasPrefix "-DGIT_REVISION" flag) old.cmakeFlags ++ [
    (lib.cmakeFeature "GIT_REVISION" revision)
  ];
  patchFlags = (old.patchFlags or [ "-p1" ]) ++ [ "--fuzz=0" ];
  patches = (old.patches or [ ]) ++ [
    ./quickshell/load_qtquick_611.patch
    ./quickshell/intercept-rescan-fix.patch
  ];
})
