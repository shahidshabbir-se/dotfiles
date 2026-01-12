{ pkgs }:

pkgs.runCommand "droid" {
  buildInputs = [ pkgs.makeWrapper ];
  src = pkgs.fetchurl {
    url = "https://downloads.factory.ai/factory-cli/releases/0.46.0/linux/x64/droid";
    sha256 = "1nzf845lga0m8qw8q5jawk3l611fppjhw7vjw7rk2dx5cyjl77za";
  };
} ''
  mkdir -p $out/bin
  cp $src $out/bin/droid
  chmod +x $out/bin/droid
''
