{ pkgs, fetchFromGitHub, lib }:

pkgs.buildGoModule rec {
  pname = "cliproxyapi";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    rev = "main";
    sha256 = "1qlbl1pn0qsv3mn52scz2qvq746zqyr6mrfjh3lf0yv62gqhmfqz";
  };

  vendorHash = "sha256:0wf3bvr98bdmsw0g1fgbbszcb1kbw788cyr3rxsdyvrapbpcy8af";

  subPackages = [ "cmd/server" ];

  postInstall = ''
    mv $out/bin/server $out/bin/cliproxyapi
  '';
}
